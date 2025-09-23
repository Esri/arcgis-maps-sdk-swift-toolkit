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
    struct UtilityAssociationNetworkSourcesView: View {
        /// The view model for the feature form view.
        @Environment(FeatureFormViewModel.self) private var featureFormViewModel
        
        /// The navigation path for the navigation stack presenting this view.
        @Environment(\.navigationPath) var navigationPath
        
        /// <#Description#>
        @State private var addUtilityAssociationViewModel = Model()
        /// A Boolean value that indicates if a feature query is running.
        @State private var featureQueryIsRunning = false
        /// <#Description#>
        @State private var query = ""
        /// <#Description#>
        @State private var sources: [UtilityAssociationFeatureSource] = []
        
        /// <#Description#>
        let element: UtilityAssociationsFormElement
        /// The view model for the form.
        let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
        /// <#Description#>
        let filter: UtilityAssociationsFilter
        
        /// <#Description#>
        private var filteredSources: [UtilityAssociationFeatureSource] {
            if query.isEmpty {
                sources
            } else {
                sources.filter({ $0.name.localizedStandardContains(query) })
            }
        }
        
        var body: some View {
            List {
                Section {
                    ForEach(filteredSources, id: \.name) { source in
                        HStack {
                            Button(source.name) {
                                navigationPath?.wrappedValue.append(
                                    FeatureFormView.NavigationPathItem.utilityAssociationFeatureCandidatesView(embeddedFeatureFormViewModel, element, filter, source)
                                )
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            }
            .searchable(text: $query, prompt: "Search")
            .task {
                featureQueryIsRunning = true
                defer { featureQueryIsRunning = false }
                sources = (try? await element.associationFeatureSources(filter: filter)) ?? []
            }
            Group {
                if addUtilityAssociationViewModel.utilityAssociationDetailsCoreIsPresented {
                    Button {
#warning("ADD API NOT IMPLEMENTED")
                        withAnimation {
                            featureFormViewModel.addUtilityAssociationScreenIsPresented = false
                        }
                    } label: {
                        Text(
                            "Add",
                            bundle: .toolkitModule,
                            comment: "Label for a button to add a configured utility association."
                        )
                    }
                }
            }
            // TODO: Combine with similar code in FeatureFormView.UtilityAssociationDetailsScreen.swift
            .overlay {
                if addUtilityAssociationViewModel.spatialFeatureSelectionViewIsPresented {
                    SpatialFeatureSelectionView()
                } else if addUtilityAssociationViewModel.featureQueryConditionsViewIsPresented {
                    FeatureQueryConditionsView()
                }
            }
            .environment(addUtilityAssociationViewModel)
        }
    }
}
