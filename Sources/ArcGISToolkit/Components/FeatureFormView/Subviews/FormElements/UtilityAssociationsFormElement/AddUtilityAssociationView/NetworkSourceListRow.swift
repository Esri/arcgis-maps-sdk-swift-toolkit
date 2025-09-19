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

extension FeatureFormView.AddUtilityAssociationView {
    struct NetworkSourceListRow: View {
        /// The model for the navigation layer.
//        @Environment(NavigationLayerModel.self) private var navigationLayerModel
        
        let layer: Layer
        
        /// A Boolean value that indicates if a feature query is running.
        @Binding var featureQueryIsRunning: Bool
        
        /// A Boolean value that indicates if the layer represented by this row is being queried.
        @State private var rowIsQuerying = false
        
        var body: some View {
            Button {
                if let featureLayer = layer as? FeatureLayer,
                   let table = featureLayer.featureTable {
                    Task {
                        rowIsQuerying = true
                        featureQueryIsRunning = true
                        defer {
                            featureQueryIsRunning = false
                            rowIsQuerying = false
                        }
                        do {
                            let queryParameters = QueryParameters()
                            queryParameters.whereClause = "1=1"
                            let featureQueryResult = try await table.queryFeatures(using: queryParameters)
                            let identifiedFeatures = Array(featureQueryResult.features()).compactMap { $0 as? ArcGISFeature }
//                            navigationLayerModel.push {
//                                TabularFeatureSelectionView(
//                                    features: identifiedFeatures,
//                                    sourceName: layer.name
//                                )
//                            }
                        } catch {
#warning("Present errors to user.")
                            print(String(reflecting: error))
                        }
                    }
                }
            } label: {
                HStack {
                    Text(layer.name)
                    Spacer()
                    if rowIsQuerying {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Image(systemName: "chevron.right")
                    }
                    
                }
                .contentShape(.rect)
                .tint(.primary)
            }
        }
    }
}
