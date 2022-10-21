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
    
    init(popupElement: RelationshipPopupElement, geoElement: GeoElement) {
        self.popupElement = popupElement
        self.feature = geoElement as? ArcGISFeature
    }
    
    @State var isExpanded: Bool = true
    
    @State var relatedFeatures: AnySequence<Feature>?
    @State var fields = [Field]()
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            Divider()
                .padding(.bottom, 4)
//            if let relatedFeatures {
//                NavigationView {
//                    ForEach(Array(relatedFeatures)) { relatedFeature in
//                        NavigationLink("Feature", destination: Text("wow"))
////                        HStack {
////                            Text("Feature")
////                            Spacer()
////                        }
//                    }

//                    List(Array(relatedFeatures)) { relatedFeature in
//                        NavigationLink("Feature", destination: Text("wow"))
//                    }
//                                    .navigationBarTitle(Text("Examples"), displayMode: .inline)
//                }
//                .navigationViewStyle(StackNavigationViewStyle())
//            }
            VStack(alignment: .leading) {
                if let relatedFeatures,
                   let relatedFeaturesArray = Array(relatedFeatures) {
                    ForEach(relatedFeaturesArray) { relatedFeature in
                        HStack {
                            VStack(alignment: .leading) {
                                if let field = fields.first,
                                    let name = relatedFeature.attributes[field.name] as? String {
                                    Text(name)
                                } else {
                                    Text("Feature")
                                }
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
        } label: {
            VStack(alignment: .leading) {
                PopupElementHeader(
                    title: popupElement.title,
                    description: popupElement.description
                )
            }
        }
        .task {
            guard let feature,
                  let table = feature.table as? ServiceFeatureTable,
                  let relationshipInfo = table.layerInfo?.relationshipInfos.first
            else { return }
            
            let params = RelatedQueryParameters(relationshipInfo: relationshipInfo)
            let relatedFeatureQueryResult = try? await table.queryRelatedFeatures(
                to: feature,
                using: params,
                queryFeatureFields: .loadAll
            ).first
            relatedFeatures = relatedFeatureQueryResult?.features()
            fields = relatedFeatureQueryResult?.fields ?? []
        }
    }
    
    /// A view displaying an array of `PopupMedia`.
    struct PopupMediaView: View {
        /// The popup media to display.
        let popupMedia: [PopupMedia]
        
        /// The number of popup media that can be displayed.
        let displayableMediaCount: Int
        
        /// The width of the view content.
        @State private var width: CGFloat = .zero
        
        var body: some View {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(popupMedia) { media in
                        Group {
                            switch media.kind {
                            case .image:
                                ImageMediaView(
                                    popupMedia: media,
                                    mediaSize: mediaSize
                                )
                            case .barChart, .columnChart, .lineChart, .pieChart:
                                ChartMediaView(
                                    popupMedia: media,
                                    mediaSize: mediaSize
                                )
                            default:
                                EmptyView()
                            }
                        }
                        .frame(width: mediaSize.width, height: mediaSize.height)
                        .contentShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .onSizeChange {
                width = $0.width * widthScaleFactor
            }
        }
        
        /// The scale factor for specifying the width of popup media.  If there is only one popup media,
        /// the scale is 1.0 (full width); if there is more than one, the scale is 0.85, which allows for
        /// second and subsequent media to be partially visible, to indicate there is more than one.
        var widthScaleFactor: Double {
            get {
                displayableMediaCount > 1 ? 0.75 : 1
            }
        }
        
        /// The size of the image or chart media.
        var mediaSize: CGSize {
            CGSize(width: width, height: 200)
        }
    }
}

extension Feature: Identifiable { }
