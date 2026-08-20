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

/// Portal item content framed by classification bars.
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
    /// Adds classification bars above and below this view.
    /// - Parameter portalItem: The portal item whose classification is displayed.
    /// - Returns: A view framed by the portal item's classification bars.
    func classification(portalItem: PortalItem?) -> some View {
        ClassificationView(portalItem: portalItem) {
            self
        }
    }
}
