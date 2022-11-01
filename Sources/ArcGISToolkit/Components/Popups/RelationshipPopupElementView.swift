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

/// A view displaying a `RelationshipPopupElement`.
struct RelationshipPopupElementView: View {
    /// The `PopupElement` to display.
    var popupElement: RelationshipPopupElement
    
    /// The feature associated with the popup
    var feature: ArcGISFeature?
    
    @StateObject private var viewModel: RelationshipPopupElementModel
    
    init(popupElement: RelationshipPopupElement, geoElement: GeoElement) {
        self.popupElement = popupElement
        self.feature = geoElement as? ArcGISFeature
        
        _viewModel = StateObject(
            wrappedValue: RelationshipPopupElementModel(
                feature: geoElement as? ArcGISFeature,
                popupElement: popupElement
            )
        )
    }
    
    @State var isExpanded: Bool = true
    
    @State var relatedFeatures: AnySequence<Feature>?
    
    @State var relatedPopups = [Popup]()
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            if #available(iOS 16.0, *) {
                VStack {
                    ForEach(viewModel.relatedPopups) { popup in
//                    List(viewModel.relatedPopups) { popup in
                        NavigationLink(value: popup) {
//                            VStack(alignment: .leading) {
                                Text(popup.title)
//                                Text(popup.definition.description)
//                            }
                        }
//                        NavigationLink(popup.title, value: popup)
                    }
                }
                .navigationDestination(for: Popup.self) { popup in
                    PopupViewInternal(
                        popup: popup,
                        showCloseButton: false,
                        evaluateExpressionsResult: Result<[PopupExpressionEvaluation], Error>.success([])

                    )
                }
            }
        } label: {
            VStack(alignment: .leading) {
                PopupElementHeader(
                    title: popupElement.title,
                    description: popupElement.description
                )
            }
        }
    }

//
////            relatedFeaturesView
//
////        .task {
////            guard let feature,
////                  let table = feature.table as? ServiceFeatureTable,
////                    let relationshipInfo = table.layerInfo?.relationshipInfos.first(where: { relationshipInfo in
////                        relationshipInfo.id == popupElement.relationshipID
////                    })
////            else { return }
////
////            // User QueryBy fields in `RelatedQueryParameters`
////            let params = RelatedQueryParameters(relationshipInfo: relationshipInfo)
////            params.addOrderByFields(popupElement.orderByFields)
////
////            // What about nested related records.  Can the UI handle unlimited recursive
////            // levels?  Or do we limit it to only 1 or 2 levels deep?  Test it.
////
////            // When service is up, look at what's it's displaying in the related fields
////            // Does it use "orderByFields" to display [last inspection result].
////            // Do we need to display all information in "orderByFields" in the related
////            // records view?
////            let relatedFeatureQueryResult = try? await table.queryRelatedFeatures(
////                to: feature,
////                using: params,
////                queryFeatureFields: .loadAll
////            ).first
////            // What about the rest of the `relatedFeatureQueryResult`s???
////            relatedFeatures = relatedFeatureQueryResult?.features()
////
////            // What about the rest of the `relatedFeatureQueryResult`s???
////            relatedFeatures = relatedFeatureQueryResult?.features()
////            guard let relatedFeatures = relatedFeatureQueryResult?.features() else { return }
////
////            //for each related feature, create a popup with the popupDefinition
////
////            //PopupDefinition from either feature table or feature layer?
////            //            let pud = relatedFeatures?.first(where: $0 = "x").featureTable
//////
////            let features = Array(relatedFeatures)
////            var popups = [Popup]()
////            features.forEach { feature in
////                let popupDefinition = feature.table?.popupDefinition
////                popups.append(
////                    Popup(
////                        geoElement: feature,
////                        definition: popupDefinition ?? PopupDefinition(geoElement: feature)
////                    )
////                )
////            }
////
////            popups.forEach { popup in
////                Task {
////                    let _ = try? await popup.evaluateExpressions()
////                    relatedPopups.append(popup)
////                }
////            }
////
////
////
////
////            //for each related feature, create a popup with the popupDefinition
////
////            //PopupDefinition from either feature table or feature layer?
//////            let pud = relatedFeatures?.first(where: $0 = "x").featureTable
////
////            // Test to see if a popupDefinition is created automatically if we're using
////            // a feature (from the feature's table) or if it's just a "dumb" one).
//////            let popup = Popup(geoElement: relatedFeatures.first, popupDefinition: PopupDefinition())
////
////            // Make sure to evaluate each popup
////            // Maybe need to just evaluate the title for display, then if the user
////            // taps on it, evaluate everything (which popupview should do automatically)
////
////            fields = relatedFeatureQueryResult?.fields ?? []
////        }
//    }
    
    @ViewBuilder private var relatedFeaturesView: some View {
        VStack(alignment: .leading) {
            if let relatedFeatures,
               let relatedFeaturesArray = Array(relatedFeatures) {
                ForEach(relatedFeaturesArray) { relatedFeature in
                    HStack {
                        VStack(alignment: .leading) {
//                            if let field = fields.first,
//                               let name = relatedFeature.attributes[field.name] as? String {
//                                Text(name)
//                            } else {
                                Text("Feature")
//                            }
                            Text("Feature description")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    Divider()
                }
                if relatedFeaturesArray.count > popupElement.displayCount {
                    VStack(alignment: .leading) {
                        Text("Show All")
                        Text("\(Array(relatedFeatures).count) records")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Divider()
                }
            }
        }

    }
}

extension Feature: Identifiable { }

extension Popup: Identifiable { }

extension Popup: Equatable {
    public static func == (lhs: Popup, rhs: Popup) -> Bool {
        lhs === rhs
    }
}

extension Popup: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
////                NavigationStack {
////                    ForEach(relatedPopups) { popup in
////                        NavigationLink(popup.title, value: popup)
////                    }
////                    .navigationDestination(for: Popup.self) { popup in
////                        PopupView(popup: popup)
////                    }
////                }
////                NavigationStack {
////                    relatedFeaturesView
////                }
//            } else {
//                // Fallback on earlier versions
//                Text("need iOS 16")
//            }
//
//
//            /*
//            NavigationStack {
//                List(parks) { park in
//                    NavigationLink(park.name, value: park)
//                }
//                .navigationDestination(for: Park.self) { park in
//                    ParkDetails(park: park)
//                }
//            }
//            */
//
