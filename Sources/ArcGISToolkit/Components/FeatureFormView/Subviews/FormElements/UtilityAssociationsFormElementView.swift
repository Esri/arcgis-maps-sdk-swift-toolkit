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

/// A view for a utility associations form element.
struct UtilityAssociationsFormElementView: View {
    /// The view model for the form.
    @Environment(InternalFeatureFormViewModel.self) private var internalFeatureFormViewModel
    
    /// The set of utility associations filter results for the element.
    @State private var associationsFilterResults = [UtilityAssociationsFilterResult]()
    
    /// The backing utility associations form element.
    let element: UtilityAssociationsFormElement
    
    var body: some View {
        FeatureFormGroupedContentView(content: associationsFilterResults.compactMap {
            if $0.resultCount > 0 {
                UtilityAssociationsFilterResultListRowView(utilityAssociationsFilterResult: $0)
                    .environment(internalFeatureFormViewModel)
            } else {
                nil
            }
        })
        .task {
            if let results = try? await element.associationsFilterResults {
                associationsFilterResults = results
            }
        }
    }
}

/// A view for a utility association group result.
private struct UtilityAssociationGroupResultView: View {
    @Environment(\.formChangedAction) var formChangedAction
    
    /// A Boolean which declares whether navigation to forms for features associated via utility association form
    /// elements is disabled.
    @Environment(\.navigationIsDisabled) var navigationIsDisabled
    
    @Environment(\.setAlertContinuation) var setAlertContinuation
    
    /// The view model for the form.
    @Environment(InternalFeatureFormViewModel.self) private var internalFeatureFormViewModel
    
    /// The model for the navigation layer.
    @Environment(NavigationLayerModel.self) private var navigationLayerModel
    
    /// The backing utility association group result.
    let utilityAssociationGroupResult: UtilityAssociationGroupResult
    
    var body: some View {
        List(utilityAssociationGroupResult.associationResults, id: \.associatedFeature.globalID) { utilityAssociationResult in
            Button {
                let navigationAction: () -> Void = {
                    navigationLayerModel.push {
                        InternalFeatureFormView(
                            featureForm: FeatureForm(feature: utilityAssociationResult.associatedFeature)
                        )
                    }
                }
                if internalFeatureFormViewModel.featureForm.hasEdits {
                    setAlertContinuation?(true, navigationAction)
                } else {
                    navigationAction()
                }
            } label: {
                UtilityAssociationResultLabel(result: utilityAssociationResult)
            }
        }
        .disabled(navigationIsDisabled)
        .onAppear {
            // This view is considered the tail end of a navigable FeatureForm.
            // When a user is backing out of a navigation path, this view
            // appearing is considered a change to the presented FeatureForm.
            formChangedAction?(internalFeatureFormViewModel.featureForm)
        }
    }
}

/// A view referencing a utility associations filter result.
private struct UtilityAssociationsFilterResultListRowView: View {
    /// The view model for the form.
    @Environment(InternalFeatureFormViewModel.self) private var internalFeatureFormViewModel
    
    /// The model for the navigation layer.
    @Environment(NavigationLayerModel.self) private var navigationLayerModel
    
    /// The referenced utility associations filter result.
    let utilityAssociationsFilterResult: UtilityAssociationsFilterResult
    
    var body: some View {
        let listRowTitle = "\(utilityAssociationsFilterResult.filter.title)".capitalized
        Button {
            navigationLayerModel.push {
                UtilityAssociationsFilterResultView(utilityAssociationsFilterResult: utilityAssociationsFilterResult)
                    .navigationLayerTitle(listRowTitle, subtitle: internalFeatureFormViewModel.title)
                    .environment(internalFeatureFormViewModel)
            }
        } label: {
            HStack {
                VStack {
                    Text(listRowTitle)
                    if !utilityAssociationsFilterResult.filter.description.isEmpty {
                        Text(utilityAssociationsFilterResult.filter.description)
                            .font(.caption)
                    }
                }
                .lineLimit(1)
                Spacer()
                Group {
                    Text(utilityAssociationsFilterResult.resultCount.formatted())
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
private struct UtilityAssociationsFilterResultView: View {
    /// The view model for the form.
    @Environment(InternalFeatureFormViewModel.self) private var internalFeatureFormViewModel
    
    /// The model for the navigation layer.
    @Environment(NavigationLayerModel.self) private var navigationLayerModel
    
    /// The backing utility associations filter result.
    let utilityAssociationsFilterResult: UtilityAssociationsFilterResult
    
    var body: some View {
        List(utilityAssociationsFilterResult.groupResults, id: \.name) { utilityAssociationGroupResult in
            Button {
                navigationLayerModel.push {
                    UtilityAssociationGroupResultView(utilityAssociationGroupResult: utilityAssociationGroupResult)
                        .navigationLayerTitle(
                            utilityAssociationGroupResult.name,
                            subtitle: utilityAssociationsFilterResult.filter.title
                        )
                        .environment(internalFeatureFormViewModel)
                }
            } label: {
                HStack {
                    Text(utilityAssociationGroupResult.name)
                    Spacer()
                    Group {
                        Text(utilityAssociationGroupResult.associationResults.count.formatted())
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.secondary)
                }
            }
            .tint(.primary)
        }
    }
}
