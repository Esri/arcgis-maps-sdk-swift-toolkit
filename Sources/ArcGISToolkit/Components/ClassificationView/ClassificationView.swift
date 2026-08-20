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
import SwiftUI

internal import os

/// A view that frames content with a portal item's classification marking.
///
/// A classification view displays matching classification bars above and below
/// its content. It uses the classification assigned to the supplied portal item
/// and does not aggregate classifications from the item's basemap or operational
/// layers.
///
/// The view loads the portal item through an authenticated portal and uses the
/// portal's classification schema to resolve the banner colors when available.
/// The application is responsible for configuring authentication challenge
/// handling before displaying the view. While loading, or when no classification
/// is available, the content is displayed without classification bars.
///
/// Use the ``classification(portalItem:)`` modifier to add the classification
/// bars to an existing view:
///
/// ```swift
/// MapView(map: map)
///     .classification(portalItem: portalItem)
/// ```
public struct ClassificationView<Content: View>: View {
    /// The content framed by classification bars.
    private let content: Content

    /// The portal item whose classification is displayed.
    private let portalItem: PortalItem?

    /// The classification displayed by the bars.
    @State private var marking: ClassificationMarking?

    /// Creates a classification view for a portal item and its content.
    /// - Parameters:
    ///   - portalItem: The portal item whose classification is displayed.
    ///   - content: The content framed by classification bars.
    public init(
        portalItem: PortalItem?,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.portalItem = portalItem
    }

    public var body: some View {
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
        .task(id: portalItem.map(ObjectIdentifier.init)) {
            await loadMarking()
        }
    }

    /// Loads the classification marking for the portal item.
    private func loadMarking() async {
        marking = nil

        guard let portalItem, let id = portalItem.id else { return }

        // Classification information is only returned when the item is
        // loaded through an authenticated portal.
        let authenticatedPortalItem: PortalItem
        if portalItem.portal.connection == .authenticated || portalItem.portal.user != nil {
            authenticatedPortalItem = portalItem
        } else {
            let authenticatedPortal = Portal(
                url: portalItem.portal.url,
                connection: .authenticated
            )
            authenticatedPortalItem = PortalItem(portal: authenticatedPortal, id: id)
        }

        do {
            let marking = try await authenticatedPortalItem.loadClassificationMarking()
            try Task.checkCancellation()
            self.marking = marking
        } catch is CancellationError {
            return
        } catch {
            Logger.classificationView.error(
                "Failed to load classification marking for portal item \(id): \(error)"
            )
        }
    }
}

private extension PortalItem {
    /// Loads the item and returns its classification marking, if one is defined.
    func loadClassificationMarking() async throws -> ClassificationMarking? {
        let id = self.id?.description ?? "<unknown>"
        Logger.classificationView.debug(
            "Loading classification marking for portal item \(id)"
        )

        // The portal must finish authenticating before the item loads or the
        // item's classification information may be unavailable.
        try await portal.retryLoad()
        try Task.checkCancellation()
        try await retryLoad()
        Logger.classificationView.debug("Loaded portal item \(id)")
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
    /// The modifier loads the portal item through an authenticated portal. If
    /// the item has a classification, matching bars appear above and below this
    /// view using the portal's classification schema colors when available. If
    /// the item has no classification or loading fails, this view is displayed
    /// without classification bars.
    ///
    /// The application is responsible for configuring authentication challenge
    /// handling.
    ///
    /// - Parameter portalItem: The portal item whose classification is displayed.
    /// - Returns: A view framed by the portal item's classification bars.
    func classification(portalItem: PortalItem?) -> some View {
        ClassificationView(portalItem: portalItem) {
            self
        }
    }
}
