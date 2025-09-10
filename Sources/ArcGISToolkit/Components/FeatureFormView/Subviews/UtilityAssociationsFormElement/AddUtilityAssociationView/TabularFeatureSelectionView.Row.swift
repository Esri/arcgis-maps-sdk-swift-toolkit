// Copyright 2025 Esri
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

extension FeatureFormView.AddUtilityAssociationView.TabularFeatureSelectionView {
    struct Row: View {
        /// The display scale of the environment.
        @Environment(\.displayScale) private var displayScale
        
//        @Environment(NavigationLayerModel.self) private var navigationLayerModel
        
        @Environment(FeatureFormView.AddUtilityAssociationView.Model.self) private var addUtilityAssociationViewModel
        
        /// The feature represented by the row.
        let feature: ArcGISFeature
        
        /// The feature row that was last inspected.
        @Binding var inspectedFeature: InspectedFeature?
        
        /// The feature's symbol.
        @State private var image: UIImage?
        
        /// A Boolean value indicating whether a fallback is used for the feature's symbol.
        @State private var imageIsFallback = false
        
        var body: some View {
            Button {
//                navigationLayerModel.push {
//                    FeatureFormView.UtilityAssociationDetailsCore(
//                        addUtilityAssociationViewModel: addUtilityAssociationViewModel
//                    )
//                }
            } label: {
                HStack {
                    if let image {
                        Image(uiImage: image)
                            .renderingMode(imageIsFallback ? .template : .original)
                            .foregroundStyle(imageIsFallback ? .red.opacity(0.5) : .primary)
                    } else {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .task {
#warning("TODO: Handle SubtypeFeatureLayer and the absence of a renderer here.")
                                if let renderer = feature.featureLayer?.renderer,
                                   let symbol = renderer.symbol(for: feature),
                                   let swatch = try? await symbol.makeSwatch(scale: displayScale) {
                                    image = swatch
                                } else {
                                    image = UIImage(systemName: "questionmark")
                                    imageIsFallback = true
                                }
                            }
                    }
                    if let objectID = feature.objectID {
                        Text(objectID, format: .number.grouping(.never))
                            .tint(.primary)
                    }
                    Spacer()
                    Button {
                        inspectedFeature = InspectedFeature(feature: feature)
                    } label: {
                        Label {
                            if let objectID = feature.objectID {
#warning("Localization needed.")
                                Text(
                                    "Zoom to \(objectID)"
                                )
                            }
                        } icon: {
                            Image(systemName: "plus.magnifyingglass")
                        }
                        .labelStyle(.iconOnly)
                        .tint(.secondary)
                    }
                }
            }
        }
    }
}
