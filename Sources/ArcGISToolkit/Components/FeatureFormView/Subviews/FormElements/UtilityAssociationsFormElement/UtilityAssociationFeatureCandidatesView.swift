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
        /// The model for the FeatureFormView containing the view.
        @Environment(FeatureFormViewModel.self) var featureFormViewModel
        /// The closure to perform when a ``EditingEvent`` occurs.
        @Environment(\.onFormEditingEventAction) var onFormEditingEventAction
        
        /// The candidates that can be used to create an association.
        @State private var candidates: [UtilityAssociationFeatureCandidate] = []
        /// The phrase used to filter candidates by name.
        @State private var filterPhrase = ""
        /// A Boolean value indicating if a candidate query is running.
        @State private var queryIsRunning = false
        
        /// The asset type to use when querying for feature candidates.
        let assetType: UtilityAssetType
        /// The element to add the new association to.
        let element: UtilityAssociationsFormElement
        /// The filter to use when creating the association.
        let filter: UtilityAssociationsFilter
        /// The feature form defining the editing experience.
        let form: FeatureForm
        /// The feature source to query and obtain candidates from.
        let source: UtilityAssociationFeatureSource
        
        var body: some View {
            List {
                sectionForFilter
                if queryIsRunning {
                    ProgressView()
                } else {
                    if filteredCandidates.isEmpty {
                        contentUnavailableView
                    } else {
                        sectionForCandidates
                    }
                }
            }
            .task {
                queryIsRunning = true
                defer { queryIsRunning = false }
                let parameters = QueryParameters()
                parameters.whereClause = "1=1"
                candidates = (try? await source.queryFeatures(assetType: assetType, parameters: parameters).candidates) ?? []
            }
        }
        
        /// A view to indicate no utility association candidate results were found.
        var contentUnavailableView: some View {
            ContentUnavailableView(
                String(
                    localized: LocalizedStringResource(
                        "No Candidates Found",
                        bundle: .toolkit,
                        comment: """
                        A label indicating no utility association 
                        candidates matching the filter criteria were
                        found.
                        """
                    )
                ),
                systemImage: "exclamationmark.magnifyingglass"
            )
        }
        
        /// The model for the feature form containing the element to add the association to.
        var embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel {
            featureFormViewModel.getModel(form)!
        }
        
        /// The candidates that can be used to create an association filtered by name.
        var filteredCandidates: [UtilityAssociationFeatureCandidate] {
            if filterPhrase.isEmpty {
                candidates
            } else {
                candidates.filter({ $0.title.localizedStandardContains(filterPhrase) })
            }
        }
        
        /// A section with the candidate results.
        var sectionForCandidates: some View {
            Section {
                ForEach(filteredCandidates, id: \.title) { candidate in
                    NavigationLink(
                        value: FeatureFormView.NavigationPathItem.utilityAssociationCreationView(
                            form,
                            element,
                            filter,
                            candidate
                        )
                    ) {
                        HStack {
                            CandidateLabel(candidate: candidate)
                                .lineLimit(4)
                                .truncationMode(.middle)
                            Spacer()
                            Image(systemName: "scope")
                                .padding()
                                .clipShape(.circle)
                                .hoverEffect()
                                .onTapGesture {
                                    // onTapGesture is not optimal but is
                                    // the only configuration found to work
                                    // so far that avoids selecting the
                                    // navigation link
                                    onFormEditingEventAction?(.showOnMapRequested(candidate.feature))
                                }
                        }
                    }
                    ._navigationLinkIndicatorVisibility(.hidden)
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
                .textCase(nil)
            }
        }
        
        /// A section with a text field to filter the candidates by name.
        var sectionForFilter: some View {
            Section {
                Searchable(
                    text: $filterPhrase,
                    label: Text(
                        "Filter candidates by name",
                        bundle: .toolkitModule,
                        comment: """
                            A label for a search field to filter utility 
                            association candidate features by name.
                            """,
                    ),
                    prompt: Text(
                        "Search Features",
                        bundle: .toolkitModule,
                        comment: """
                            A label for a search bar to search through feature 
                            candidates to use in a new utility association.
                            """
                    )
                )
            }
        }
    }
    
    /// A label for a utility association feature candidate in a set of candidates.
    private struct CandidateLabel: View {
        /// The symbol for the candidate feature.
        @State private var symbol: Image? = nil
        
        /// The represented candidate.
        let candidate: UtilityAssociationFeatureCandidate
        
        var body: some View {
            Label {
                Text(candidate.title)
            } icon: {
                if let symbol {
                    symbol
                        .foregroundStyle(.secondary)
                } else {
                    ProgressView()
                        .task {
                            symbol = await candidate
                                .feature
                                .symbol
                            ?? Image(systemName: "questionmark.circle")
                        }
                }
            }
        }
    }
}
