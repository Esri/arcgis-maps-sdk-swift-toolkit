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
        @Environment(FeatureFormViewModel.self) private var featureFormViewModel
        
        @Environment(FeatureFormView.AddUtilityAssociationView.Model.self) private var addUtilityAssociationViewModel
        
        /// The set of all possible features to add as an association.
        let features: [ArcGISFeature]
        
        /// The name of the source the features were obtained from.
        ///
        /// If the features were selected via spatial means, no name is provided.
        let sourceName: String?
        
        struct InspectedFeature: Equatable {
            static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.id == rhs.id
            }
            
            let id = UUID()
            let feature: ArcGISFeature
        }
        
        /// The feature row that was last inspected.
        ///
        /// A row is inspected when the magnifying glass is pressed. The map is panned to the feature's
        /// center and the feature is selected. If there was a previously inspected feature, it is deselected.
        @State private var inspectedFeature: InspectedFeature?
        
        /// The filter phrase for the available features.
        @State private var searchTerm = ""
        
        var body: some View {
            Group {
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField(text: $searchTerm) {
                            Text.searchFeatures
                        }
                        if !searchTerm.isEmpty {
                            XButton(.clear) {
                                searchTerm.removeAll()
                            }
                        }
                    }
                    .padding(5)
                    .padding(.vertical, 5)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        withAnimation {
                            addUtilityAssociationViewModel.featureIsBeingInspected = false
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
                .padding(.horizontal, 20)
                .padding(.vertical)
                List {
                    Section {
                        ForEach(Array(filteredFeatures.enumerated()), id: \.offset) { _, feature in
                            Row(feature: feature, inspectedFeature: $inspectedFeature)
                        }
                    } header: {
                        Text.makeCountText(count: filteredFeatures.count)
                            .textCase(.none)
                    }
                }
            }
            .navigationLayerTitle(sourceName ?? "Add Association")
            .onChange(of: inspectedFeature, initial: false) { oldValue, newValue in
                if let feature = oldValue?.feature, let layer = feature.featureLayer {
                    layer.unselectFeature(feature)
                }
                if let feature = newValue?.feature, let layer = feature.featureLayer {
                    layer.selectFeature(feature)
                    if let center = feature.geometry?.extent.center {
                        Task {
                            await featureFormViewModel.mapViewProxy?.setViewpointCenter(center)
                        }
                    }
                    addUtilityAssociationViewModel.featureIsBeingInspected = true
                }
            }
            .onDisappear {
                addUtilityAssociationViewModel.featureIsBeingInspected = false
                if let feature = inspectedFeature?.feature, let layer = feature.featureLayer {
                    layer.unselectFeature(feature)
                }
            }
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
