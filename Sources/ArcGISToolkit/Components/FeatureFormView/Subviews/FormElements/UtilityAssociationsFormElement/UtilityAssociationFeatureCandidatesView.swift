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
        
        /// The candidates that can be used to create an association.
        @State private var candidates: [UtilityAssociationFeatureCandidate] = []
        /// The phrase used to filter candidates by name.
        @State private var filterPhrase = ""
        /// The parameters for retrieving the next page of results.
        @State private var nextQueryParameters: QueryParameters?
        /// A Boolean value indicating whether a filter based query is running.
        @State private var queryForFilterPhraseIsRunning = false
        /// A Boolean value indicating if the initial candidate query is complete.
        @State private var queryForFirstPageIsComplete = false
        /// A Boolean value indicating whether a query is running.
        @State private var queryIsRunning = false
        /// The task for the current query.
        @State private var queryTask: Task<Void, Never>?
        /// The model for the filter view
        @State private var filterViewModel = FilterViewModel()
        
        @State private var whereClause = "1=1"
        
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
                if !queryForFirstPageIsComplete {
                    ProgressView()
                        .task {
                            let parameters = QueryParameters()
                            parameters.whereClause = filterViewModel.whereClause()
                            queryFeatures(parameters: parameters)
                            await queryTask?.value
                            queryForFirstPageIsComplete = true
                        }
                } else {
                    if filteredCandidates.isEmpty {
                        if queryForFilterPhraseIsRunning {
                            ProgressView()
                                .id(filterPhrase)
                        } else if !queryIsRunning {
                            contentUnavailableView
                        }
                    } else {
                        sectionForCandidates
                    }
                }
            }
            .onAppear {
                filterViewModel.featureTable = form.feature.table as? ArcGISFeatureTable
            }
            .onChange(of: whereClause) { oldValue, newValue in
                Task {
                    candidates.removeAll()
                    let parameters = QueryParameters()
                    parameters.whereClause = filterViewModel.whereClause()
                    queryFeatures(parameters: parameters)
                    await queryTask?.value
                    queryForFirstPageIsComplete = true
                }
                
            }
            .sheet(isPresented: $filterViewModel.filterViewIsPresented) {
                FilterView(model: filterViewModel) {
                    queryForFirstPageIsComplete = false
                    whereClause = filterViewModel.whereClause()
                }
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
                ForEach(filteredCandidates, id: \.feature.globalID) { candidate in
                    Button {
                        featureFormViewModel.navigationPath.append(
                            FeatureFormView.NavigationPathItem.utilityAssociationCreationView(
                                form,
                                element,
                                filter,
                                candidate
                            )
                        )
                    } label: {
                        HStack {
                            CandidateLabel(candidate: candidate)
                                .lineLimit(4)
                                .truncationMode(.middle)
                            Spacer()
                            ShowOnMapButton(feature: candidate.feature)
                                .labelStyle(.iconOnly)
                        }
                    }
                    .tint(.primary)
                }
                if let nextQueryParameters {
                    if filterPhrase.isEmpty {
                        // Paging via scrolling
                        ProgressView()
                            .id(nextQueryParameters.resultOffset)
                            .task {
                                queryFeatures(parameters: nextQueryParameters)
                            }
                    }
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
                HStack {
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
                    .disabled(!queryForFirstPageIsComplete)
                    .task(id: filterPhrase) {
                        try? await Task.sleep(for: .milliseconds(500))
                        queryForFilterPhraseIsRunning = true
                        while !Task.isCancelled, filteredCandidates.isEmpty, let nextQueryParameters {
                            queryFeatures(parameters: nextQueryParameters)
                            await queryTask?.value
                        }
                        queryForFilterPhraseIsRunning = false
                    }
                    
                    Button {
                        filterViewModel.filterViewIsPresented.toggle()
                    } label: {
                        if filterViewModel.fieldFilters.isEmpty {
                            Image(systemName: "line.3.horizontal.decrease")
                        } else {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title2)
                        }
                    }
                }
            }
        }
        
        func queryFeatures(parameters: QueryParameters) {
            queryTask?.cancel()
            queryIsRunning = true
            queryTask = Task {
                do {
                    let result = try? await source.queryFeatures(assetType: assetType, parameters: parameters)
                    candidates.append(contentsOf: result?.candidates ?? [])
                    nextQueryParameters = result?.nextQueryParams
                } catch {
                    nextQueryParameters = nil
                }
                queryIsRunning = false
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
