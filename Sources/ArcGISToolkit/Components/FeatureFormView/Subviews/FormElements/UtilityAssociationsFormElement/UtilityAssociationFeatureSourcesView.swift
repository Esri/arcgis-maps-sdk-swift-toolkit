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
    struct UtilityAssociationFeatureSourcesView: View {
        /// A Boolean value that indicates if a feature query is running.
        @State private var featureQueryIsRunning = false
        /// The phrase used to filter feature sources by name.
        @State private var filterPhrase = ""
        /// The feature sources that can be used to create an association.
        @State private var sources: [UtilityAssociationFeatureSource] = []
        
        /// The element to add the new association to.
        let element: UtilityAssociationsFormElement
        /// The filter to use when creating the association.
        let filter: UtilityAssociationsFilter
        /// The feature form defining the editing experience.
        let form: FeatureForm
        
        /// The feature sources that can be used to create an association filtered by name.
        private var filteredSources: [UtilityAssociationFeatureSource] {
            if filterPhrase.isEmpty {
                sources
            } else {
                sources.filter({ $0.name.localizedStandardContains(filterPhrase) })
            }
        }
        
        var body: some View {
            List {
                Section {
                    Searchable(
                        text: $filterPhrase,
                        label: Text(
                            "Filter feature sources by name",
                            bundle: .toolkitModule,
                            comment: """
                                A label for a search field to filter utility 
                                association feature sources by name.
                                """,
                        ),
                        prompt: nil
                    )
                }
                if filteredSources.isEmpty {
                    ContentUnavailableView(
                        String(
                            localized: LocalizedStringResource(
                                "No Feature Sources Found",
                                bundle: .toolkit,
                                comment: """
                                A label indicating no utility association 
                                feature sources were found.
                                """
                            )
                        ),
                        systemImage: "exclamationmark.magnifyingglass"
                    )
                } else {
                    Section {
                        ForEach(filteredSources, id: \.name) { source in
                            NavigationLink(
                                source.name,
                                value: FeatureFormView.NavigationPathItem.utilityAssociationAssetTypesView(
                                    form, element, filter, source
                                )
                            )
                        }
                    } header: {
                        Text.count(filteredSources.count)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .textCase(nil)
                    }
                }
            }
            .task {
                featureQueryIsRunning = true
                defer { featureQueryIsRunning = false }
                sources = (try? await element.associationFeatureSources(filter: filter)) ?? []
            }
        }
    }
}
