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
    /// A view for a utility associations form element.
    struct UtilityAssociationsFormElementView: View {
        /// The view model for the form.
        @Environment(EmbeddedFeatureFormViewModel.self) private var embeddedFeatureFormViewModel
        
        /// The form element.
        let element: UtilityAssociationsFormElement
        
        init(element: UtilityAssociationsFormElement) {
            self.element = element
        }
        
        /// The model for fetching the form element's associations filter results.
        var associationsFilterResultsModel: AssociationsFilterResultsModel? {
            embeddedFeatureFormViewModel.associationsFilterResultsModels[element]
        }
        
        var body: some View {
            Group {
                switch associationsFilterResultsModel?.result {
                case .success(let results):
                    ForEach(results, id: \.filter.kind) { result in
                        Row(
                            associationsFilterResultsModel: associationsFilterResultsModel,
                            element: element,
                            filter: result.filter,
                            form: embeddedFeatureFormViewModel.featureForm
                        )
                        .environment(embeddedFeatureFormViewModel)
                    }
                case .failure(let error):
                    Text.errorFetchingFilterResults(error)
                case .none:
                    ProgressView()
                }
            }
            .onChange(of: embeddedFeatureFormViewModel.hasEdits) {
                associationsFilterResultsModel?.fetchResults()
            }
            .task {
                self.embeddedFeatureFormViewModel.associationsFilterResultsModels[element] = .init(
                    element: element,
                    includeEmptyFilterResults: true
                )
            }
        }
    }
    
    /// A view referencing a utility associations filter result.
    private struct Row: View {
        /// The view model for the form.
        @Environment(EmbeddedFeatureFormViewModel.self) private var embeddedFeatureFormViewModel
        /// The model for the FeatureFormView containing the view.
        @Environment(FeatureFormViewModel.self) var featureFormViewModel
        
        /// The model containing the latest association filter results.
        let associationsFilterResultsModel: AssociationsFilterResultsModel?
        /// The form element containing the filter result.
        let element: UtilityAssociationsFormElement
        /// The referenced utility associations filter.
        let filter: UtilityAssociationsFilter
        /// The feature form defining the editing experience.
        let form: FeatureForm
        
        /// The referenced utility associations filter result.
        var result: UtilityAssociationsFilterResult? {
            try? associationsFilterResultsModel?.result?
                .get()
                .first(where: { $0.filter === filter } )
        }
        
        var body: some View {
            Button {
                featureFormViewModel.navigationPath.append(
                    FeatureFormView.NavigationPathItem.utilityAssociationFilterResultView(
                        form,
                        element,
                        filter
                    )
                )
            } label: {
                HStack {
                    VStack {
                        Text(filter.title)
                        if !filter.description.isEmpty {
                            Text(filter.description)
                                .font(.caption)
                        }
                    }
                    .lineLimit(1)
                    Spacer()
                    Group {
                        if let result {
                            Text(result.resultCount, format: .number)
                        }
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.secondary)
                }
#if os(iOS)
                // Make the entire row tappable.
                .contentShape(.rect)
#endif
            }
            // Disables the blue tint on iOS and allows the button to fill the
            // entire row on Catalyst and visionOS.
            .buttonStyle(.plain)
        }
    }
}
