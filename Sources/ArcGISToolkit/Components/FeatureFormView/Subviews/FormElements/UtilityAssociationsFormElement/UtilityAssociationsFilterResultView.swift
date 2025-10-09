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
    /// A view for a utility associations filter result.
    struct UtilityAssociationsFilterResultView: View {
        /// The model for the FeatureFormView containing the view.
        @Environment(FeatureFormViewModel.self) var featureFormViewModel
        /// The navigation path for the navigation stack presenting this view.
        @Environment(\.navigationPath) var navigationPath
        
        /// A Boolean value indicating whether the element is editable.
        @State private var isEditable = false
        
        /// The form element containing the filter result.
        let element: UtilityAssociationsFormElement
        /// The title of the selected utility associations filter result.
        let filterTitle: String
        /// The feature form defining the editing experience.
        let form: FeatureForm
        
        /// The model containing the latest association filter results.
        var associationsFilterResultsModel: AssociationsFilterResultsModel? {
            embeddedFeatureFormViewModel?.associationsFilterResultsModels[element]
        }
        
        /// The view model for the form.
        var embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel? {
            featureFormViewModel.getModel(form)
        }
        
        /// The selected utility associations filter result.
        var filterResult: UtilityAssociationsFilterResult? {
            try? associationsFilterResultsModel?.result?
                .get()
                .first(where: { $0.filter.title == filterTitle} )
        }
        /// The set of group results within the filter result.
        var groupResults: [UtilityAssociationGroupResult] {
            filterResult?.groupResults ?? []
        }
        
        var body: some View {
            List {
                Section {
                    // TODO: Improve group identification (Apollo 1391).
                    ForEach(groupResults, id: \.name) { utilityAssociationGroupResult in
                        Button {
                            navigationPath?.wrappedValue.append(
                                FeatureFormView.NavigationPathItem.utilityAssociationGroupResultView(
                                    form,
                                    element,
                                    filterTitle,
                                    utilityAssociationGroupResult.name
                                )
                            )
                        } label: {
                            HStack {
                                Text(utilityAssociationGroupResult.name)
                                Spacer()
                                Group {
                                    Text(utilityAssociationGroupResult.associationResults.count, format: .number)
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                        .tint(.primary)
                    }
                }
                .onChange(of: embeddedFeatureFormViewModel?.hasEdits) {
                    associationsFilterResultsModel?.fetchResults()
                }
            }
            .overlay(alignment: .bottomLeading) {
                addAssociationMenu
                    .padding()
            }
        }
        
        var addAssociationMenu: some View {
            Menu {
                Button {
                    navigationPath?.wrappedValue.append(
                        FeatureFormView.NavigationPathItem.utilityAssociationFeatureSourcesView(
                            form,
                            element,
                            filterResult!.filter
                        )
                    )
                } label: {
                    Text(
                        "From Network Data Source",
                        bundle: .toolkitModule,
                        comment: """
                            A label for a button to choose a feature for a new
                            utility association from a network data source.
                            """
                    )
                }
                Button {} label: {
                    Text(
                        "On Map",
                        bundle: .toolkitModule,
                        comment: """
                            A label indicating features can be selected by
                            interactively tapping on the map.
                            """
                    )
                }
                .disabled(true)
            } label: {
                Label {
                    Text(
                        "Add Association",
                        bundle: .toolkitModule,
                        comment: "A label for a button to add a new utility network association."
                    )
                } icon: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .disabled(!isEditable)
            .onIsEditableChange(of: element) { newIsEditable in
                isEditable = newIsEditable
            }
        }
    }
}
