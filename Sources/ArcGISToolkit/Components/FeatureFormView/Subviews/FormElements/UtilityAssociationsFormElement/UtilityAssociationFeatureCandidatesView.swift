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
    /// A view to choose a feature source when selecting a feature to create a utility association with.
    struct UtilityAssociationFeatureCandidatesView: View {
        /// The navigation path for the navigation stack presenting this view.
        @Environment(\.navigationPath) var navigationPath
        
        /// The candidates that can be used to create an association.
        @State private var candidates: [UtilityAssociationFeatureCandidate] = []
        /// The phrase used to filter candidates by name.
        @State private var filterPhrase = ""
        
        /// The element to add the new association to.
        let element: UtilityAssociationsFormElement
        /// The model for the feature form containing the element to add the association to.
        let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
        /// The filter to use when creating the association.
        let filter: UtilityAssociationsFilter
        /// The feature source to query and obtain candidates from.
        let source: UtilityAssociationFeatureSource
        
        /// The candidates that can be used to create an association filtered by name.
        private var filteredCandidates: [UtilityAssociationFeatureCandidate] {
            if filterPhrase.isEmpty {
                candidates
            } else {
                candidates.filter({ $0.title.localizedStandardContains(filterPhrase) })
            }
        }
        
        var body: some View {
            List {
                Section {
                    ForEach(filteredCandidates, id: \.title) { candidate in
                        NavigationLink(
                            candidate.title,
                            value: FeatureFormView.NavigationPathItem.utilityAssociationCreationView(
                                embeddedFeatureFormViewModel,
                                candidate,
                                element,
                                filter
                            )
                        )
                    }
                } header: {
                    Text(
                        "Choose to add",
                        bundle: .toolkitModule,
                        comment: """
                            Instructional text for the user to choose a feature
                            candidate to add as a utility association.
                            """
                    )
                    .font(.caption)
                }
            }
            .navigationTitle(
                Text(
                    "^[\(candidates.count) Available Features](inflect: true)",
                    bundle: .toolkitModule,
                    comment: """
                        A navigation title for a page listing utility association
                        feature candidates where the variable represents the number
                        of available candidates.
                        """
                )
            )
            .searchable(
                text: $filterPhrase,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text(
                    "Search Features",
                    bundle: .toolkitModule,
                    comment: """
                        A label for a search bar to search through feature 
                        candidates to use in a new utility association.
                        """
                )
            )
            .task {
                let parameters = QueryParameters()
                parameters.whereClause = "1=1"
                candidates = (try? await source.queryFeatures(parameters: parameters).candidates) ?? []
            }
        }
    }
}
