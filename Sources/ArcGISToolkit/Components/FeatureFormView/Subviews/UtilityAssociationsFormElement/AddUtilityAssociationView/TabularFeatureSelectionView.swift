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
    struct TabularFeatureSelectionView: View {
        @Environment(FeatureFormView.AddUtilityAssociationView.Model.self) private var addUtilityAssociationViewModel
        
        /// The set of all possible features to add as an association.
        let features: [ArcGISFeature]
        
        /// The name of the source the features were obtained from.
        ///
        /// If the features were selected via spatial means, no name is provided.
        let sourceName: String?
        
        /// The filter phrase for the available features.
        @State private var searchTerm = ""
        
        var body: some View {
            List {
                Section {
                    HStack {
                        Group {
                            Image(systemName: "magnifyingglass")
                            TextField(text: $searchTerm) {
                                Text.searchFeatures
                            }
                        }
                        .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            withAnimation {
                                addUtilityAssociationViewModel.featureQueryConditionsViewIsPresented = true
                            }
                        } label: {
                            Label {
                                Text.filter
                            } icon: {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            }
                            .tint(addUtilityAssociationViewModel.featureQueryConditions.isEmpty ? .secondary : .accentColor)
                            .labelStyle(.iconOnly)
                        }
                    }
                }
                
                Section {
                    ForEach(Array(filteredFeatures.enumerated()), id: \.offset) { _, feature in
                        Row(feature: feature)
                    }
                } header: {
                    Text.makeCountText(count: filteredFeatures.count)
                        .textCase(.none)
                }
            }
            .navigationLayerTitle(sourceName ?? "Add Association")
        }
    }
}

private extension FeatureFormView.AddUtilityAssociationView.TabularFeatureSelectionView {
#warning("Object ID is used temporarily")
    /// The set of features matching the current filters to add as an association.
    var filteredFeatures: [ArcGISFeature] {
        if searchTerm.isEmpty {
            features
        } else {
            features.filter {
                if let objectId = $0.objectID {
                    String(objectId).localizedStandardContains(searchTerm)
                } else {
                    false
                }
            }
        }
    }
}

private extension Text {
    static func makeCountText(count: Int) -> Self {
        .init(
            "Count \(count)",
            bundle: .toolkitModule,
            comment: "The number of features to choose from."
        )
    }
    
    static var filter: Self {
        .init(
            "Filter",
            bundle: .toolkitModule,
            comment: "A filter used to reduce the number of results."
        )
    }
    
    static var searchFeatures: Self {
        .init(
            "Search features",
            bundle: .toolkitModule,
            comment: "A label for a feature search field."
        )
    }
}
