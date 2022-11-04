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
    /// The array of related `Popup`s
    @Published var relatedPopups = [Popup]()
    
    @Published var displayedPopups = [Popup]()
    
    /// The feature to display relationships for.
    var feature: ArcGISFeature?

    /// The `PopupElement` to display.
    var popupElement: RelationshipPopupElement
    
    @State var fields = [Field]()
    
    init(
        feature: ArcGISFeature?,
        popupElement: RelationshipPopupElement
    ) {
        self.feature = feature
        self.popupElement = popupElement
        load()
    }
    
    /// Loads the popup attachment and generates a thumbnail image.
    /// - Parameter thumbnailSize: The size for the generated thumbnail.
    func load() {
            guard let feature,
                  let table = feature.table as? ServiceFeatureTable,
                  let relationshipInfo = table.layerInfo?.relationshipInfos.first(where: { relationshipInfo in
                      relationshipInfo.id == popupElement.relationshipID
                  })
            else { return }
            
            // User QueryBy fields in `RelatedQueryParameters`
            let params = RelatedQueryParameters(relationshipInfo: relationshipInfo)
            params.addOrderByFields(popupElement.orderByFields)
            
            // When service is up, look at what's it's displaying in the related fields
            // Does it use "orderByFields" to display [last inspection result].
            // Do we need to display all information in "orderByFields" in the related
            // records view?
        Task {
            let relatedFeatureQueryResult = try? await table.queryRelatedFeatures(
                to: feature,
                using: params,
                queryFeatureFields: .loadAll
            ).first
            // What about the rest of the `relatedFeatureQueryResult`s???
            
            guard let relatedFeatures = relatedFeatureQueryResult?.features() else { return }
            
            let features = Array(relatedFeatures)
            var popups = [Popup]()
            features.forEach { feature in
                let popupDefinition = feature.table?.popupDefinition
                popups.append(
                    Popup(
                        geoElement: feature,
                        definition: popupDefinition ?? PopupDefinition(geoElement: feature)
                    )
                )
            }
            
            await withThrowingTaskGroup(of: Void.self) { taskGroup in
                for popup in popups {
                    taskGroup.addTask {
                        let _ = try await popup.evaluateExpressions()
                    }
                }
            }
            
            relatedPopups.append(contentsOf: popups)
            displayedPopups = Array(relatedPopups.prefix(Int(popupElement.displayCount)))
            print("relatedPopups: \(relatedPopups.count)")
            print("displayedPopups: \(displayedPopups.count); displayCount = \(popupElement.displayCount)")
                        
            fields.append(contentsOf: relatedFeatureQueryResult?.fields ?? [])
            print("fields: \(fields); rfqr?.fields: \(relatedFeatureQueryResult?.fields ?? [])")
        }
    }
}

extension Popup {
    /// The description of the popup using the `orderByFields` property and the popup definition`.`
    /// - Parameters:
    ///   - popup: The popup to get the description for.
    ///   - popupElement: The relationship popup element.
    /// - Returns: The description.
    func description(popup: Popup, popupElement: RelationshipPopupElement) -> String? {
        print("")
        if let firstOrderByFieldName = popupElement.orderByFields.first?.fieldName,
           let popupField = popup.definition.fields.first(where: {
               $0.fieldName == firstOrderByFieldName
           }) {
            return popup.formattedValue(for: popupField)
        }

        return nil
    }
}
