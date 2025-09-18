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
        @State private var associationsFilterResultsModel: AssociationsFilterResultsModel
        
        /// The form element.
        let element: UtilityAssociationsFormElement
        
        init(element: UtilityAssociationsFormElement) {
            self.element = element
            self._associationsFilterResultsModel = .init(wrappedValue: .init(element: element, includeEmptyFilterResults: true))
        }
        
        var body: some View {
            Group {
                switch associationsFilterResultsModel.result {
                case .success(_):
                    FeatureFormGroupedContentView(content: element.associationFilters.map {
                        UtilityAssociationsFilterResultListRowView(
                            associationsFilterResultsModel: associationsFilterResultsModel,
                            element: element,
                            filter: $0
                        )
                        .environment(embeddedFeatureFormViewModel)
                    })
                case .failure(let error):
                    FeatureFormGroupedContentView(content: [
                        Text.errorFetchingFilterResults(error)
                    ])
                case .none:
                    FeatureFormGroupedContentView(content: [ProgressView()])
                }
            }
            .onChange(of: embeddedFeatureFormViewModel.hasEdits) {
                associationsFilterResultsModel.fetchResults()
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
        
        /// The association to be potentially removed.
        @State private var associationPendingRemoval: UtilityAssociation?
        
        /// A Boolean value indicating whether the removal confirmation is presented.
        @State private var removalConfirmationIsPresented = false
        
        /// The model containing the latest association filter results.
        let associationsFilterResultsModel: AssociationsFilterResultsModel
        
        /// The form element containing the group result.
        let element: UtilityAssociationsFormElement
        
        /// The view model for the form.
        let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
        
        /// The selected utility associations filter.
        let filter: UtilityAssociationsFilter
        
        /// The title of the selected utility association group result.
        let groupTitle: String
        
        /// The set of association results within the group result.
        var associationResults: [UtilityAssociationResult] {
            utilityAssociationGroupResult?.associationResults ?? []
        }
        
        /// The backing utility association group result.
        var utilityAssociationGroupResult: UtilityAssociationGroupResult? {
            // TODO: Improve group identification (Apollo 1391).
            try? associationsFilterResultsModel.result?
                .get()
                .first(where: { $0.filter.kind == filter.kind })?
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
                associationsFilterResultsModel.fetchResults()
            }
            .onChange(of: associationResults.count) {
                if associationResults.isEmpty {
                    navigationPath?.wrappedValue.removeLast()
                }
            }
            .onChange(of: embeddedFeatureFormViewModel.hasEdits) {
                associationsFilterResultsModel.fetchResults()
            }
        }
        
        func deleteButton(for association: UtilityAssociation) -> some View {
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
        
        func detailsButton(for result: UtilityAssociationResult) -> some View {
            Button {
                navigationPath?.wrappedValue.append(
                    FeatureFormView.NavigationPathItem.utilityAssociationDetailsView(
                        embeddedFeatureFormViewModel,
                        associationsFilterResultsModel,
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
                    navigationPath?.wrappedValue.append(
                        FeatureFormView.NavigationPathItem.form(
                            FeatureForm(feature: result.associatedFeature)
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
                    UtilityAssociationResultLabel(result: result)
                    detailsButton(for: result)
                        .buttonStyle(.plain)
                        .hoverEffect()
                }
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
        
        /// The utility association filter represented by the row.
        let filter: UtilityAssociationsFilter
        
        /// The referenced utility associations filter result.
        var filterResult: UtilityAssociationsFilterResult? {
            try? associationsFilterResultsModel.result?
                .get()
                .first(where: { $0.filter.kind == filter.kind } )
        }
        
        var body: some View {
            Button {
                navigationPath?.wrappedValue.append(
                    FeatureFormView.NavigationPathItem.utilityAssociationFilterResultView(
                        embeddedFeatureFormViewModel,
                        associationsFilterResultsModel,
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
                        Text(filterResult?.resultCount ?? 0, format: .number)
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
        /// The model containing the latest association filter results.
        let associationsFilterResultsModel: AssociationsFilterResultsModel
        
        /// The form element containing the filter result.
        let element: UtilityAssociationsFormElement
        
        /// The view model for the form.
        let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
        
        /// The selected utility associations filter.
        let filter: UtilityAssociationsFilter
        
        /// The selected utility associations filter result.
        var filterResult: UtilityAssociationsFilterResult? {
            try? associationsFilterResultsModel.result?
                .get()
                .first(where: { $0.filter.kind == filter.kind })
        }
        
        /// The set of group results within the filter result.
        var groupResults: [UtilityAssociationGroupResult] {
            filterResult?.groupResults ?? []
        }
        
        /// The navigation path for the navigation stack presenting this view.
        @Environment(\.navigationPath) var navigationPath
        
        @Namespace private var namespace
        
        var body: some View {
            List {
                Section {
                    // TODO: Improve group identification (Apollo 1391).
                    ForEach(groupResults, id: \.name) { utilityAssociationGroupResult in
                        Button {
                            navigationPath?.wrappedValue.append(
                                FeatureFormView.NavigationPathItem.utilityAssociationGroupResultView(
                                    embeddedFeatureFormViewModel,
                                    associationsFilterResultsModel,
                                    element,
                                    filter,
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
                    Button {
                        withAnimation {
//                            featureFormViewModel.addUtilityAssociationScreenIsPresented = true
                        }
                    } label: {
                        Label {
                            Text.addAssociation
                                .textCase(.none)
                        } icon: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    .buttonStyle(.borderless)
                    .padding(.bottom)
                }
                .onChange(of: embeddedFeatureFormViewModel.hasEdits) {
                    associationsFilterResultsModel.fetchResults()
                }
            }
        }
    }
}

private extension Text {
    static var addAssociation: Self {
        .init(
            "Add Association",
            bundle: .toolkitModule,
            comment: "A label for a button to add a new utility network association."
        )
    }
}
