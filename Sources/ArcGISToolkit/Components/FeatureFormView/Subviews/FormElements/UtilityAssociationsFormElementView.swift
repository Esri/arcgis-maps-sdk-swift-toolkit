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
        
        init(element: UtilityAssociationsFormElement) {
            self._associationsFilterResultModel = .init(wrappedValue: .init(element: element))
        }
        
        var body: some View {
            switch associationsFilterResultModel.result {
            case .success(let results):
                if results.isEmpty {
                    Text.noAssociations
                } else {
                    FeatureFormGroupedContentView(content: results.compactMap {
                        if $0.resultCount > 0 {
                            UtilityAssociationsFilterResultListRowView(utilityAssociationsFilterResult: $0)
                                .environment(embeddedFeatureFormViewModel)
                        } else {
                            nil
                        }
                    })
                }
            case .failure(let error):
                Text.makeErrorFetchingFilterResultsMessage(error)
            case nil:
                ProgressView()
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
        
        /// The view model for the form.
        let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
        
        /// The backing utility association group result.
        let utilityAssociationGroupResult: UtilityAssociationGroupResult
        
        var body: some View {
            List(utilityAssociationGroupResult.associationResults, id: \.associatedFeature.globalID) { utilityAssociationResult in
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
                    UtilityAssociationResultLabel(result: utilityAssociationResult)
                }
                .disabled(navigationIsDisabled)
                .tint(.primary)
            }
        }
    }
    
    /// A view referencing a utility associations filter result.
    struct UtilityAssociationsFilterResultListRowView: View {
        /// The view model for the form.
        @Environment(EmbeddedFeatureFormViewModel.self) private var embeddedFeatureFormViewModel
        
        /// The navigation path for the navigation stack presenting this view.
        @Environment(\.navigationPath) var navigationPath
        
        /// The referenced utility associations filter result.
        let utilityAssociationsFilterResult: UtilityAssociationsFilterResult
        
        var body: some View {
            Button {
                navigationPath?.wrappedValue.append(
                    FeatureFormView.NavigationPathItem.utilityAssociationFilterResultView(
                        utilityAssociationsFilterResult,
                        embeddedFeatureFormViewModel
                    )
                )
            } label: {
                HStack {
                    VStack {
                        Text(utilityAssociationsFilterResult.filter.title.capitalized)
                        if !utilityAssociationsFilterResult.filter.description.isEmpty {
                            Text(utilityAssociationsFilterResult.filter.description)
                                .font(.caption)
                        }
                    }
                    .lineLimit(1)
                    Spacer()
                    Group {
                        Text(utilityAssociationsFilterResult.resultCount, format: .number)
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
        
        /// The view model for the form.
        let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
        
        /// The backing utility associations filter result.
        let utilityAssociationsFilterResult: UtilityAssociationsFilterResult
        
        /// The navigation path for the navigation stack presenting this view.
        @Environment(\.navigationPath) var navigationPath
        
        @Namespace private var namespace
        
        var body: some View {
            List {
                Section {
                    ForEach(utilityAssociationsFilterResult.groupResults, id: \.name) { utilityAssociationGroupResult in
                        Button {
                            navigationPath?.wrappedValue.append(
                                FeatureFormView.NavigationPathItem.utilityAssociationGroupResultView(
                                    utilityAssociationGroupResult,
                                    embeddedFeatureFormViewModel
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
