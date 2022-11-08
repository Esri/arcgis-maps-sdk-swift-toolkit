// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS

/// The view model for an `RelationshipPopupElementModel`.
@MainActor class RelationshipPopupElementModel: ObservableObject {
    /// The array of all related `Popup`s
    @Published var relatedPopups = [Popup]()
    
    /// The array of displayed `Popup`s.
    @Published var displayedPopups = [Popup]()
    
    /// The feature to display relationships for.
    var feature: ArcGISFeature?

    /// The `PopupElement` being displayed.
    var popupElement: RelationshipPopupElement
    
    /// Creates a `RelationshipPopupElementModel`.
    /// - Parameters:
    ///   - feature: The feature to display relationships for.
    ///   - popupElement: The `PopupElement` being displayed.
    init(
        feature: ArcGISFeature?,
        popupElement: RelationshipPopupElement
    ) {
        self.feature = feature
        self.popupElement = popupElement
        Task {
            try? await load()
        }
    }
    
    /// Queries the feature for related popups and populates `relatedPopups`
    /// and `displayedPopups`.
    func load() async throws {
        guard let feature else { return }
        relatedPopups = try await popupElement.relatedPopups(for: feature)
        displayedPopups = Array(relatedPopups.prefix(Int(popupElement.displayCount)))
    }
}

public extension RelationshipPopupElement {
    /// The description of the popup using the `orderByFields` property and the popup definition`.`
    /// - Parameter popup: The popup to get the description for.
    /// - Returns: The description
    func relatedPopupDescription(popup: Popup) -> String? {
        if let firstOrderByFieldName = orderByFields.first?.fieldName,
           let popupField = popup.definition.fields.first(where: {
               $0.fieldName == firstOrderByFieldName
           }) {
            return popup.formattedValue(for: popupField)
        }
        
        return nil
    }
    
    /// Queries the related popups for the feature.
    /// - Parameter feature: The feature to display relationships for.
    /// - Returns: An array of related popups.
    func relatedPopups(for feature: ArcGISFeature) async throws -> [Popup] {
        guard let table = feature.table as? ServiceFeatureTable,
              let relationshipInfo = table.layerInfo?.relationshipInfos.first(where: { relationshipInfo in
                  relationshipInfo.id == relationshipID
              })
        else { return [] }
        
        // User QueryBy fields in `RelatedQueryParameters`
        let params = RelatedQueryParameters(relationshipInfo: relationshipInfo)
        params.addOrderByFields(orderByFields)
        let relatedFeatureQueryResult = try? await table.queryRelatedFeatures(
            to: feature,
            using: params,
            queryFeatureFields: .loadAll
        ).first
        // What about the rest of the `relatedFeatureQueryResult`s???
        
        guard let relatedFeatures = relatedFeatureQueryResult?.features() else { return [] }
        
        let features = Array(relatedFeatures)
        var relatedPopups = [Popup]()
        features.forEach { feature in
            let popupDefinition = feature.table?.popupDefinition
            relatedPopups.append(
                Popup(
                    geoElement: feature,
                    definition: popupDefinition ?? PopupDefinition(geoElement: feature)
                )
            )
        }
        
        await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for popup in relatedPopups {
                taskGroup.addTask {
                    // Need to evaluate expressions to make sure
                    // `popup.title` is evaluated.
                    let _ = try await popup.evaluateExpressions()
                }
            }
        }
        return relatedPopups
    }
}
