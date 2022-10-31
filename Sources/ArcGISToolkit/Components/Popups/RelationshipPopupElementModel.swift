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
    /// The array of `AttachmentModels`, one for each popup attachment.
    @Published var relatedPopups = [Popup]()
    
    let feature: ArcGISFeature?

    /// The `PopupElement` to display.
    var popupElement: RelationshipPopupElement
    @State var fields = [Field]()

    
    //
///// A view model representing the combination of a `PopupAttachment` and
///// an associated `UIImage` used as a thumbnail.
//@MainActor class AttachmentModel: ObservableObject {
    
    /// The `LoadStatus` of the popup attachment.
    @Published var loadStatus: LoadStatus = .notLoaded
    
    
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
//            loadStatus = .loading
            
            guard let feature,
                  let table = feature.table as? ServiceFeatureTable,
                  let relationshipInfo = table.layerInfo?.relationshipInfos.first(where: { relationshipInfo in
                      relationshipInfo.id == popupElement.relationshipID
                  })
            else { return }
            
            // User QueryBy fields in `RelatedQueryParameters`
            let params = RelatedQueryParameters(relationshipInfo: relationshipInfo)
            params.addOrderByFields(popupElement.orderByFields)
            
            // What about nested related records.  Can the UI handle unlimited recursive
            // levels?  Or do we limit it to only 1 or 2 levels deep?  Test it.
            
            // When service is up, look at what's it's displaying in the related fields
            // Does it use "orderByFields" to display [last inspection result].
            // Do we need to display all information in "orderByFields" in the related
            // records view?
        Task { [weak self] in
            guard let self else { return }
            let relatedFeatureQueryResult = try? await table.queryRelatedFeatures(
                to: feature,
                using: params,
                queryFeatureFields: .loadAll
            ).first
            // What about the rest of the `relatedFeatureQueryResult`s???
//            let relatedFeatures = relatedFeatureQueryResult?.features()
            
            guard let relatedFeatures = relatedFeatureQueryResult?.features() else { return }
            
            //for each related feature, create a popup with the popupDefinition
            
            //PopupDefinition from either feature table or feature layer?
            //            let pud = relatedFeatures?.first(where: $0 = "x").featureTable
            //
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
            
            popups.forEach { popup in
                Task {
                    let _ = try? await popup.evaluateExpressions()
                    relatedPopups.append(popup)
                }
            }
            
            
            
            
            //for each related feature, create a popup with the popupDefinition
            
            //PopupDefinition from either feature table or feature layer?
            //            let pud = relatedFeatures?.first(where: $0 = "x").featureTable
            
            // Test to see if a popupDefinition is created automatically if we're using
            // a feature (from the feature's table) or if it's just a "dumb" one).
            //            let popup = Popup(geoElement: relatedFeatures.first, popupDefinition: PopupDefinition())
            
            // Make sure to evaluate each popup
            // Maybe need to just evaluate the title for display, then if the user
            // taps on it, evaluate everything (which popupview should do automatically)
            
            fields = relatedFeatureQueryResult?.fields ?? []
        }
    }
}

//extension AttachmentModel: Identifiable {}
//
//extension AttachmentModel: Equatable {
//    static func == (lhs: AttachmentModel, rhs: AttachmentModel) -> Bool {
//        lhs.attachment === rhs.attachment &&
//        lhs.thumbnail === rhs.thumbnail
//    }
//}
