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
    /// A view for a utility association group result.
    struct UtilityAssociationGroupResultView: View {
        /// The model for the FeatureFormView containing the view.
        @Environment(FeatureFormViewModel.self) var featureFormViewModel
        /// A Boolean which declares whether navigation to forms for features associated via utility
        /// association form elements is disabled.
        @Environment(\.navigationIsDisabled) var navigationIsDisabled
        /// The navigation path for the navigation stack presenting this view.
        @Environment(\.navigationPath) var navigationPath
        /// The environment value to set the continuation to use when the user responds to the alert.
        @Environment(\.setAlertContinuation) var setAlertContinuation
        
        /// The association to be potentially removed.
        @State private var associationPendingRemoval: UtilityAssociation?
        /// A Boolean value indicating whether the element is editable.
        @State private var isEditable = false
        /// A Boolean value indicating whether the removal confirmation is presented.
        @State private var removalConfirmationIsPresented = false
        
        /// The form element containing the group result.
        let element: UtilityAssociationsFormElement
        /// The title of the selected utility associations filter result.
        let filterTitle: String
        /// The title of the selected utility association group result.
        let groupTitle: String
        
        /// The set of association results within the group result.
        var associationResults: [UtilityAssociationResult] {
            utilityAssociationGroupResult?.associationResults ?? []
        }
        
        /// The backing utility association group result.
        var utilityAssociationGroupResult: UtilityAssociationGroupResult? {
            // TODO: Improve group identification (Apollo 1391).
            try? associationsFilterResultsModel?.result?
                .get()
                .first(where: { $0.filter.title == filterTitle} )?
                .groupResults
                .first(where: { $0.name == groupTitle })
        }
        
        var body: some View {
            List(associationResults, id: \.associatedFeature.globalID) { utilityAssociationResult in
                mainButton(for: utilityAssociationResult)
                    .disabled(navigationIsDisabled)
#if targetEnvironment(macCatalyst)
                    .contextMenu {
                        deleteButton(for: utilityAssociationResult.association)
                    }
#else
                    .swipeActions {
                        deleteButton(for: utilityAssociationResult.association)
                    }
#endif
                    .tint(.primary)
            }
            .associationRemovalConfirmation(
                isPresented: $removalConfirmationIsPresented,
                association: associationPendingRemoval,
                element: element,
                embeddedFeatureFormViewModel: embeddedFeatureFormViewModel
            ) {
                associationsFilterResultsModel?.fetchResults()
            }
            .onChange(of: associationResults.count) {
                if associationResults.isEmpty {
                    navigationPath?.wrappedValue.removeLast()
                }
            }
            .onChange(of: embeddedFeatureFormViewModel.hasEdits) {
                associationsFilterResultsModel?.fetchResults()
            }
            .onIsEditableChange(of: element) { newIsEditable in
                isEditable = newIsEditable
            }
        }
        
        /// The model containing the latest association filter results.
        var associationsFilterResultsModel: AssociationsFilterResultsModel? {
            embeddedFeatureFormViewModel.associationsFilterResultsModels[element]
        }
        
        /// The view model for the form.
        var embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel {
            featureFormViewModel.presentedEmbeddedFeatureFormViewModel!
        }
        
        @ViewBuilder func deleteButton(for association: UtilityAssociation) -> some View {
            if isEditable {
                Button {
                    associationPendingRemoval = association
                    removalConfirmationIsPresented = true
                } label: {
                    Label {
                        Text(LocalizedStringResource.removeAssociation)
                    } icon: {
                        Image(systemName: "trash.fill")
                    }
                    .labelStyle(.iconOnly)
                    .tint(.red)
                }
            }
        }
        
        func detailsButton(for result: UtilityAssociationResult) -> some View {
            Button {
                navigationPath?.wrappedValue.append(
                    FeatureFormView.NavigationPathItem.utilityAssociationDetailsView(
                        element,
                        result
                    )
                )
            } label: {
                Label {
                    Text(
                        "Utility Association Details",
                        bundle: .toolkitModule,
                        comment: "A label for a button to view utility association details."
                    )
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
                .contentShape(.circle)
                .labelStyle(.iconOnly)
                .tint(.blue)
            }
        }
        
        func mainButton(for result: UtilityAssociationResult) -> some View {
            Button {
                let navigationAction = {
                    let form = FeatureForm(feature: result.associatedFeature)
                    featureFormViewModel.embeddedFeatureFormViewModels.append(
                        EmbeddedFeatureFormViewModel(featureForm: form)
                    )
                    navigationPath?.wrappedValue.append(
                        FeatureFormView.NavigationPathItem.form(form)
                    )
                }
                if embeddedFeatureFormViewModel.featureForm.hasEdits {
                    setAlertContinuation?(true) {
                        navigationAction()
                    }
                } else {
                    navigationAction()
                }
            } label: {
                HStack {
                    UtilityAssociationResultLabel(result: result)
                    detailsButton(for: result)
                        .buttonStyle(.plain)
                        .hoverEffect()
                }
            }
        }
    }
}
