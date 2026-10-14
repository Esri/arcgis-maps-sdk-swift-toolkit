// Copyright 2026 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import Foundation
internal import os
import SwiftUI

/// Portal item content framed by classification bars.
///
/// A classification view displays matching classification bars above and below
/// its content. It uses the classification assigned to the supplied portal item
/// and does not aggregate classifications from the item's basemap or operational
/// layers.
///
/// The view loads the supplied item's portal before resolving classification.
/// The supplied item is reused if classification is already available or it has
/// no identifier. Otherwise, a fresh item with the same identifier and portal
/// is loaded for classification metadata.
///
/// The view does not create a portal or change its configured connection mode.
/// Any available classification is displayed for anonymous and authenticated
/// portals. Loading an authenticated portal may trigger authentication challenges;
/// the application must configure challenge handling before using this view.
///
/// Content remains hidden until classification loading succeeds. Loading failures
/// are logged and displayed with a retry action. Content is displayed without bars
/// when no classification is available, or immediately when the item is missing.
///
/// Use the ``classification(portalItem:)`` modifier to add the classification
/// bars to an existing view:
///
/// ```swift
/// MapView(map: map)
///     .classification(portalItem: portalItem)
/// ```
///
/// To learn more about using `ClassificationView`, see the
/// <doc:ClassificationViewTutorial>.
public struct ClassificationView<Content: View>: View {
    /// The content framed by classification bars.
    private let content: Content

    /// The portal item whose classification is displayed.
    private let portalItem: PortalItem?

    /// The classification loading result, or `nil` while loading.
    @State private var result: Result<ClassificationMarking?, Error>?
    
    /// The item associated with the loading result, preventing stale content on item changes.
    @State private var loadingItemID: ObjectIdentifier?
    
    /// A new value restarts classification loading when the user retries.
    @State private var retryID = UUID()

    /// Creates classification-framed content for a portal item.
    ///
    /// The view may load a separate item through the supplied item's portal to obtain
    /// classification metadata without changing its configured connection mode.
    /// - Parameters:
    ///   - portalItem: The item whose classification applies to the content, or
    ///     `nil` to display content without classification bars.
    ///   - content: The content framed by classification bars.
    public init(
        portalItem: PortalItem?,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.portalItem = portalItem
    }

    public var body: some View {
        Group {
            if portalItem == nil {
                content
            } else if loadingItemID != portalItem.map(ObjectIdentifier.init) {
                loadingView
            } else {
                switch result {
                case .failure(let error):
                    ContentUnavailableView {
                        Label {
                            Text(
                                "Unable to Load Classification",
                                bundle: .toolkitModule,
                                comment: "The title of a classification loading error."
                            )
                        } icon: {
                            Image(systemName: "exclamationmark.triangle")
                        }
                    } description: {
                        Text(error.localizedDescription)
                    } actions: {
                        Button {
                            result = nil
                            retryID = UUID()
                        } label: {
                            Label {
                                Text(
                                    "Retry",
                                    bundle: .toolkitModule,
                                    comment: "An action to retry loading classification."
                                )
                            } icon: {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                    }
                case .success(let marking):
                    classifiedContent(marking: marking)
                case nil:
                    loadingView
                }
            }
        }
        .task(id: portalItem.map(ObjectIdentifier.init)) {
            await loadMarking()
        }
        .id(retryID)
    }
    
    /// A progress indicator while classification is loading.
    private var loadingView: some View {
        ProgressView {
            Text(
                "Loading classification...",
                bundle: .toolkitModule,
                comment: "The status while classification is loading."
            )
        }
    }
    
    /// Frames the content with bars when a classification marking is available.
    private func classifiedContent(marking: ClassificationMarking?) -> some View {
        VStack(spacing: 0) {
            if let marking {
                ClassificationBar(
                    marking: marking,
                    safeAreaEdges: []
                )
            }

            content

            if let marking {
                ClassificationBar(
                    marking: marking,
                    safeAreaEdges: .bottom
                )
                .accessibilityHidden(true)
            }
        }
    }

    /// Loads the classification marking for the portal item.
    private func loadMarking() async {
        result = nil
        loadingItemID = portalItem.map(ObjectIdentifier.init)

        guard let portalItem else { return }

        do {
            try await portalItem.portal.retryLoad()
            try Task.checkCancellation()
            
            let classificationItem = portalItem.itemForClassification
            let marking = try await classificationItem.loadClassificationMarking()
            try Task.checkCancellation()
            result = .success(marking)
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            let id = portalItem.id?.description ?? "<unknown>"
            Logger.classificationView.error(
                "Failed to load classification marking for portal item \(id): \(error)"
            )
            result = .failure(error)
        }
    }
}

private extension PortalItem {
    /// The item to load after its portal for classification metadata.
    ///
    /// A fresh item avoids cached metadata from a map or list loading the item
    /// before its portal. Items with classification or no identifier are reused.
    var itemForClassification: PortalItem {
        guard classification == nil, let id else { return self }
        return PortalItem(portal: portal, id: id)
    }
    
    /// Loads the item and returns its classification marking, if one is defined.
    func loadClassificationMarking() async throws -> ClassificationMarking? {
        let id = self.id?.description ?? "<unknown>"
        Logger.classificationView.debug(
            "Loading classification marking for portal item \(id)"
        )

        if classification == nil {
            try await retryLoad()
            Logger.classificationView.debug("Loaded portal item \(id)")
        }
        try Task.checkCancellation()

        guard let classification else {
            Logger.classificationView.debug(
                "No classification information for portal item \(id)"
            )
            return nil
        }

        var textColor: Color?
        var backgroundColor: Color?
        if portal.info?.hasClassificationSchema == true {
            let metadata = try await portal.classificationSchema.classificationMetadata
            let primaryAttribute = metadata.primaryAttribute
            if let primaryValue = classification.attributes[primaryAttribute]?.first,
               let valueProperty = metadata.classificationValueProperties[primaryValue] {
                textColor = valueProperty.textColor.map(Color.init(uiColor:))
                backgroundColor = valueProperty.backgroundColor.map(Color.init(uiColor:))
            }
        }

        try Task.checkCancellation()
        return ClassificationMarking(
            banner: classification.banner,
            textColor: textColor,
            backgroundColor: backgroundColor
        )
    }
}

public extension View {
    /// Frames this view with a portal item's classification marking.
    ///
    /// Uses the loading and authentication behavior of ``ClassificationView``:
    /// any available classification is displayed regardless of connection mode.
    /// A fresh item may be loaded through the supplied item's portal without
    /// creating a new portal or changing its configured connection mode.
    /// The application handles authentication challenges triggered by loading
    /// an authenticated portal.
    /// Content remains hidden while classification loads or loading fails.
    /// Loading failures are displayed with a retry action.
    ///
    /// - Parameter portalItem: The item whose classification applies to this
    ///   view, or `nil` to omit the bars.
    /// - Returns: A view framed by the portal item's classification bars.
    func classification(portalItem: PortalItem?) -> some View {
        ClassificationView(portalItem: portalItem) {
            self
        }
    }
}
