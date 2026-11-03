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
        /// The model for the feature form view.
        @Environment(FeatureFormView.Model.self) var groupModel
        /// The model for the feature form which presented this view.
        @Environment(FeatureFormView.FormModel.self) var formModel
        
        /// The association to be potentially removed.
        @State private var associationPendingRemoval: UtilityAssociation?
        /// A Boolean value indicating whether the element is editable.
        @State private var isEditable = false
        /// A Boolean value indicating whether the removal confirmation is presented.
        @State private var removalConfirmationIsPresented = false
        
        /// The form element containing the group result.
        let element: UtilityAssociationsFormElement
        /// The feature form source of the group result, useful for identifying a group result.
        let featureFormSource: FeatureFormSource
        /// The selected utility associations filter.
        let filter: UtilityAssociationsFilter
        /// The feature form defining the editing experience.
        let form: FeatureForm
        
        /// The set of association results within the group result.
        var associationResults: [UtilityAssociationResult] {
            utilityAssociationGroupResult?.associationResults ?? []
        }
        
        /// The backing utility association group result.
        var utilityAssociationGroupResult: UtilityAssociationGroupResult? {
            try? associationsFilterResultsModel?.result?
                .get()
                .first(where: { $0.filter === filter })?
                .groupResults
                .first(where: { $0.featureFormSource === featureFormSource })
        }
        
        var body: some View {
            List(associationResults, id: \.associatedFeature.globalID) { utilityAssociationResult in
                mainButton(for: utilityAssociationResult)
                    .swipeActions {
                        deleteButton(for: utilityAssociationResult.association)
                    }
                    .tint(.primary)
            }
            .associationRemovalConfirmation(
                isPresented: $removalConfirmationIsPresented,
                association: associationPendingRemoval,
                element: element,
                formModel: formModel
            ) {
                associationsFilterResultsModel?.fetchResults()
            }
            .navigationTitle(
                utilityAssociationGroupResult?.name ?? "",
                subtitle: formModel.title
            )
            .onChange(of: associationResults.count) {
                if associationResults.isEmpty, !formModel.navigationPath.isEmpty {
                    formModel.navigationPath.removeLast()
                }
            }
            .onChange(of: formModel.hasEdits) {
                associationsFilterResultsModel?.fetchResults()
            }
            .onIsEditableChange(of: element) { newIsEditable in
                isEditable = newIsEditable
            }
        }
        
        /// The model containing the latest association filter results.
        var associationsFilterResultsModel: AssociationsFilterResultsModel? {
            formModel.associationsFilterResultsModels[element]
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
            Menu {
                ShowOnMapButton(feature: result.associatedFeature)
                Button {
                    formModel.navigationPath.append(
                        FeatureFormView.NavigationPathItem.utilityAssociationDetailsView(
                            form,
                            element,
                            result
                        )
                    )
                } label: {
                    Label {
                        Text(
                            "More Information",
                            bundle: .toolkitModule,
                            comment: "A label for a button to view details for a list row."
                        )
                    } icon: {
                        Image(systemName: "info.circle")
                    }
                }
                deleteButton(for: result.association)
            } label: {
                Label {
                    Text(
                        "More Options",
                        bundle: .toolkitModule,
                        comment: "A label for a button to see more options for a list row."
                    )
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
                .labelStyle(.iconOnly)
            }
        }
        
        func mainButton(for result: UtilityAssociationResult) -> some View {
            Button {
                groupModel.add(
                    form: FeatureForm(feature: result.associatedFeature),
                    select: true,
                    recordAsBrowsed: true
                )
            } label: {
                HStack {
                    UtilityAssociationResultLabel(result: result)
                    detailsButton(for: result)
                        .buttonStyle(.plain)
                        .hoverEffect()
                        .tint(.blue)
                }
            }
        }
    }
}
