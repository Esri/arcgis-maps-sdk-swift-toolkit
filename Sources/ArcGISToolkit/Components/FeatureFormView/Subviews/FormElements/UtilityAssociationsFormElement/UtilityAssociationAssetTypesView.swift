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

extension FeatureFormView {
    /// A view to choose a utility asset type when selecting a feature to create a utility association with.
    struct UtilityAssociationAssetTypesView: View {
        /// The phrase used to filter asset types by name.
        @State private var filterPhrase = ""
        
        /// The element to add the new association to.
        let element: UtilityAssociationsFormElement
        /// The model for the feature form containing the element to add the association to.
        let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
        /// The filter to use when creating the association.
        let filter: UtilityAssociationsFilter
        /// The feature source to obtain asset types from.
        let source: UtilityAssociationFeatureSource
        
        /// The filtered asset types that can be used to query for association candidates.
        private var filteredTypes: [UtilityAssetType] {
            if filterPhrase.isEmpty {
                source.assetTypes
            } else {
                source.assetTypes.filter({ $0.name.localizedStandardContains(filterPhrase) })
            }
        }
        
        var body: some View {
            List {
                Section {
                    Searchable(
                        text: $filterPhrase,
                        label: Text(
                            "Filter asset types by name",
                            bundle: .toolkitModule,
                            comment: """
                                A label for a search field to filter utility 
                                asset types by name.
                                """,
                        ),
                        prompt: nil
                    )
                }
                Section {
                    ForEach(filteredTypes, id: \.code) { assetType in
                        NavigationLink(
                            assetType.name,
                            value: FeatureFormView.NavigationPathItem.utilityAssociationFeatureCandidatesView(
                                embeddedFeatureFormViewModel, element, filter, source, assetType
                            )
                        )
                    }
                } header: {
                    HStack {
                        Text(
                            "Available Asset Types",
                            bundle: .toolkitModule,
                            comment: """
                                A section header label in reference to the asset
                                types available to use when querying for utility
                                association feature candidates.
                                """
                        )
                        Spacer()
                        Text.count(filteredTypes.count)
                    }
                    .font(.caption)
                    .textCase(nil)
                }
            }
        }
    }
}
