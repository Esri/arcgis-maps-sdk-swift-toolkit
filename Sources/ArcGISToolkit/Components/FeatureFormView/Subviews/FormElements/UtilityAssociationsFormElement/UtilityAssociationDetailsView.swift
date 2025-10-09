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
    /// A view to inspect and delete a utility network association.
    struct UtilityAssociationDetailsView: View {
        /// The model for the FeatureFormView containing the view.
        @Environment(FeatureFormViewModel.self) var featureFormViewModel
        /// The navigation path for the navigation stack presenting this view.
        @Environment(\.navigationPath) var navigationPath
        
        /// A Boolean value indicating whether the element is editable.
        @State private var isEditable = false
        /// A Boolean value indicating whether the removal confirmation is presented.
        @State private var removalConfirmationIsPresented = false
        
        /// The association result.
        let associationResult: UtilityAssociationResult
        /// The element containing the association.
        let element: UtilityAssociationsFormElement
        /// The feature form defining the editing experience.
        let form: FeatureForm
        
        var body: some View {
            List {
                sectionForAssociation
                sectionForFromElement
                sectionForToElement
                sectionForRemoveButton
            }
            .navigationTitle(
                Text(
                    "Association Settings",
                    bundle: .toolkitModule,
                    comment: "A navigation title for the Association Settings page."
                )
            )
            .onIsEditableChange(of: element) { newIsEditable in
                isEditable = newIsEditable
            }
        }
        
        /// The name of the provided terminal as labeled content.
        func row(for terminal: UtilityTerminal) -> some View {
            LabeledContent {
                Text(terminal.name)
            } label: {
                Text.terminal
            }
        }
        
        /// The model containing the latest association filter results.
        var associationsFilterResultsModel: AssociationsFilterResultsModel {
            embeddedFeatureFormViewModel.associationsFilterResultsModels[element]!
        }
        
        /// The model for the feature form containing the element with the association.
        var embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel {
            featureFormViewModel.getModel(form)!
        }
        
        /// A section which contains the association type label.
        var sectionForAssociation: some View {
            Section {
                LabeledContent {
                    associationResult.association.kind.name
                } label: {
                    Text.associationType
                }
            }
        }
        
        /// A section which contains a label for the feature on the from side of the association.
        var sectionForFromElement: some View {
            Section {
                LabeledContent {
                    Text(associationResult.associatedFeatureIsToElement ? embeddedFeatureFormViewModel.title : associationResult.title)
                } label: {
                    Text.fromElement
                }
                if let fromElementTerminal = associationResult.association.fromElement.terminal {
                    row(for: fromElementTerminal)
                }
            }
        }
        
        /// A section which contains a label for the feature on the to side of the association.
        var sectionForToElement: some View {
            Section {
                LabeledContent {
                    Text(associationResult.associatedFeatureIsToElement ? associationResult.title : embeddedFeatureFormViewModel.title)
                } label: {
                    Text.toElement
                }
                if let toElementTerminal = associationResult.association.toElement.terminal {
                    row(for: toElementTerminal)
                }
            }
        }
        
        /// A section with a button to remove the association.
        @ViewBuilder var sectionForRemoveButton: some View {
            if isEditable {
                Section {
                    Button(role: .destructive) {
                        removalConfirmationIsPresented = true
                    } label: {
                        Text(LocalizedStringResource.removeAssociation)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .associationRemovalConfirmation(
                        isPresented: $removalConfirmationIsPresented,
                        association: associationResult.association,
                        element: element,
                        embeddedFeatureFormViewModel: embeddedFeatureFormViewModel
                    ) {
                        associationsFilterResultsModel.fetchResults()
                        navigationPath?.wrappedValue.removeLast()
                    }
                }
            }
        }
    }
}
