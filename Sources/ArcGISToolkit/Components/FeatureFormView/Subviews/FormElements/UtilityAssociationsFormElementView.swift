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
        
        /// The model for fetching the form element's associations filter results.
        @State private var associationsFilterResultModel: AssociationsFilterResultsModel
        
        /// The form element.
        let element: UtilityAssociationsFormElement
        
        init(element: UtilityAssociationsFormElement) {
            self.element = element
            self._associationsFilterResultModel = .init(wrappedValue: .init(element: element))
        }
        
        var body: some View {
            switch associationsFilterResultModel.result {
            case .success(let results):
                if results.isEmpty {
                    FeatureFormGroupedContentView(
                        content: [Text.noAssociations]
                    )
                } else {
                    FeatureFormGroupedContentView(content: results.map {
                        UtilityAssociationsFilterResultListRowView(
                            associationsFilterResultsModel: associationsFilterResultModel,
                            element: element,
                            filterTitle: $0.filter.title
                        )
                        .environment(embeddedFeatureFormViewModel)
                    })
                }
            case .failure(let error):
                FeatureFormGroupedContentView(content: [
                    Text.errorFetchingFilterResults(error)
                ])
            case nil:
                FeatureFormGroupedContentView(content: [ProgressView()])
            }
        }
    }
    
    /// A view for a utility association group result.
    struct UtilityAssociationGroupResultView: View {
        /// A Boolean which declares whether navigation to forms for features associated via utility
        /// association form elements is disabled.
        @Environment(\.navigationIsDisabled) var navigationIsDisabled
        
        /// The navigation path for the navigation stack presenting this view.
        @Environment(\.navigationPath) var navigationPath
        
        /// The environment value to set the continuation to use when the user responds to the alert.
        @Environment(\.setAlertContinuation) var setAlertContinuation
        
        /// The association to be potentially deleted.
        @State private var associationPendingDeletion: UtilityAssociation?
        
        /// A Boolean value indicating whether the deletion confirmation is presented.
        @State private var deletionConfirmationIsPresented = false
        
        /// The model containing the latest association filter results.
        let associationsFilterResultsModel: AssociationsFilterResultsModel
        
        /// The form element containing the group result.
        let element: UtilityAssociationsFormElement
        
        /// The view model for the form.
        let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
        
        /// The title of the selected utility associations filter result.
        let filterTitle: String
        
        /// The title of the selected utility association group result.
        let groupTitle: String
        
        /// The backing utility association group result.
        var utilityAssociationGroupResult: UtilityAssociationGroupResult? {
            try? associationsFilterResultsModel.result?.get().first(where: { $0.filter.title == filterTitle} )?.groupResults.first(where: { $0.name == groupTitle })
        }
        
        var body: some View {
            List(utilityAssociationGroupResult?.associationResults ?? [], id: \.associatedFeature.globalID) { utilityAssociationResult in
                Button {
                    let navigationAction = {
                        navigationPath?.wrappedValue.append(
                            FeatureFormView.NavigationPathItem.form(
                                FeatureForm(feature: utilityAssociationResult.associatedFeature)
                            )
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
                        UtilityAssociationResultLabel(result: utilityAssociationResult)
                        Button {
                            navigationPath?.wrappedValue.append(
                                FeatureFormView.NavigationPathItem.utilityAssociationDetailsView(
                                    embeddedFeatureFormViewModel,
                                    associationsFilterResultsModel,
                                    element,
                                    utilityAssociationResult.association
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
                }
                .disabled(navigationIsDisabled)
                .swipeActions {
                    Button {
                        associationPendingDeletion = utilityAssociationResult.association
                        deletionConfirmationIsPresented = true
                    } label: {
                        Label(String.delete, systemImage: "trash.fill")
                            .labelStyle(.iconOnly)
                            .tint(.red)
                    }
                }
                .tint(.primary)
            }
            .associationRemovalConfirmationDialog(
                isPresented: $deletionConfirmationIsPresented,
                association: associationPendingDeletion,
                element: element,
                embeddedFeatureFormViewModel: embeddedFeatureFormViewModel
            ) {
                associationsFilterResultsModel.fetchResults()
            }
        }
    }
    /// A view referencing a utility associations filter result.
    struct UtilityAssociationsFilterResultListRowView: View {
        /// The view model for the form.
        @Environment(EmbeddedFeatureFormViewModel.self) private var embeddedFeatureFormViewModel
        
        /// The navigation path for the navigation stack presenting this view.
        @Environment(\.navigationPath) var navigationPath
        
        /// The model containing the latest association filter results.
        let associationsFilterResultsModel: AssociationsFilterResultsModel
        
        /// The form element containing the filter result.
        let element: UtilityAssociationsFormElement
        
        /// The title of the referenced utility associations filter result.
        let filterTitle: String
        
        /// The referenced utility associations filter result.
        var filterResult: UtilityAssociationsFilterResult? {
            try? associationsFilterResultsModel.result?.get().first(where: { $0.filter.title == filterTitle } )
        }
        
        var body: some View {
            Button {
                navigationPath?.wrappedValue.append(
                    FeatureFormView.NavigationPathItem.utilityAssociationFilterResultView(
                        embeddedFeatureFormViewModel,
                        associationsFilterResultsModel,
                        element,
                        filterTitle
                    )
                )
            } label: {
                HStack {
                    VStack {
                        Text(filterTitle.capitalized)
                        if let filterResult, !filterResult.filter.description.isEmpty {
                            Text(filterResult.filter.description)
                                .font(.caption)
                        }
                    }
                    .lineLimit(1)
                    Spacer()
                    Group {
                        if let filterResult {
                            Text(filterResult.resultCount, format: .number)
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
    
    /// A view for a utility associations filter result.
    struct UtilityAssociationsFilterResultView: View {
        /// Add association support is not yet currently supported.
        let futureAddAssociationSupportIsEnabled = false
        
        /// The model containing the latest association filter results.
        let associationsFilterResultsModel: AssociationsFilterResultsModel
        
        /// The form element containing the filter result.
        let element: UtilityAssociationsFormElement
        
        /// The view model for the form.
        let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
        
        /// The title of the selected utility associations filter result.
        let filterTitle: String
        
        /// The selected utility associations filter result.
        var filterResult: UtilityAssociationsFilterResult? {
            try? associationsFilterResultsModel.result?.get().first(where: { $0.filter.title == filterTitle} )
        }
        
        /// The navigation path for the navigation stack presenting this view.
        @Environment(\.navigationPath) var navigationPath
        
        @Namespace private var namespace
        
        var body: some View {
            List {
                Section {
                    ForEach(filterResult?.groupResults ?? [], id: \.name) { utilityAssociationGroupResult in
                        Button {
                            navigationPath?.wrappedValue.append(
                                FeatureFormView.NavigationPathItem.utilityAssociationGroupResultView(
                                    embeddedFeatureFormViewModel,
                                    associationsFilterResultsModel,
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
                } footer: {
                    if futureAddAssociationSupportIsEnabled {
                        if #available(iOS 18.0, *) {
                            NavigationLink(String.addAssociation) {
                                ContentUnavailableView(String.addAssociation, systemImage: "link")
                                    .navigationTransition(.zoom(sourceID: "world", in: namespace))
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            NavigationLink(String.addAssociation) {
                                ContentUnavailableView(String.addAssociation, systemImage: "link")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
        }
    }
}

private extension String {
    static var addAssociation: Self {
        .init(
            localized: "Add Association",
            bundle: .toolkitModule,
            comment: "A label for an option to add a new utility association."
        )
    }
}

private extension UtilityAssociationResult {
    /// The utility element for the association.
    var associatedElement: UtilityElement {
        if associatedFeature.globalID == association.toElement.globalID {
            association.toElement
        } else {
            association.fromElement
        }
    }
}
