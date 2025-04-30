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
    @EnvironmentObject private var formViewModel: FormViewModel
    
    /// The set of utility associations filter results for the element.
    @State private var associationsFilterResults = [UtilityAssociationsFilterResult]()
    
    /// The backing utility associations form element.
    let element: UtilityAssociationsFormElement
    
    var body: some View {
        FeatureFormGroupedContentView(content: associationsFilterResults.compactMap {
            if $0.resultCount > 0 {
                UtilityAssociationsFilterResultListRowView(utilityAssociationsFilterResult: $0)
                    .environmentObject(formViewModel)
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
    
    @Environment(\.setAlertContinuation) var setAlertContinuation
    
    /// The view model for the form.
    @EnvironmentObject private var formViewModel: FormViewModel
    
    /// The model for the navigation layer.
    @EnvironmentObject private var navigationLayerModel: NavigationLayerModel
    
    /// The backing utility association group result.
    let utilityAssociationGroupResult: UtilityAssociationGroupResult
    
    var body: some View {
        List(utilityAssociationGroupResult.associationResults, id: \.associatedFeature.globalID) { utilityAssociationResult in
            UtilityAssociationResultView(
                selectionAction: {
                    let navigationAction: () -> Void = {
                        navigationLayerModel.push {
                            InternalFeatureFormView(
                                featureForm: FeatureForm(feature: utilityAssociationResult.associatedFeature)
                            )
                        }
                    }
                    if formViewModel.featureForm.hasEdits {
                        setAlertContinuation?(true, navigationAction)
                    } else {
                        navigationAction()
                    }
                },
                result: utilityAssociationResult
            )
        }
        .onAppear {
            // This view is considered the tail end of a navigable FeatureForm.
            // When a user is backing out of a navigation path, this view
            // appearing is considered a change to the presented FeatureForm.
            formChangedAction?(formViewModel.featureForm)
        }
    }
}

/// A view referencing a utility associations filter result.
private struct UtilityAssociationsFilterResultListRowView: View {
    /// The view model for the form.
    @EnvironmentObject private var formViewModel: FormViewModel
    
    /// The model for the navigation layer.
    @EnvironmentObject private var navigationLayerModel: NavigationLayerModel
    
    /// The referenced utility associations filter result.
    let utilityAssociationsFilterResult: UtilityAssociationsFilterResult
    
    var body: some View {
        let listRowTitle = "\(utilityAssociationsFilterResult.filter.title)".capitalized
        Button {
            navigationLayerModel.push {
                UtilityAssociationsFilterResultView(utilityAssociationsFilterResult: utilityAssociationsFilterResult)
                    .navigationLayerTitle(listRowTitle, subtitle: formViewModel.title)
                    .environmentObject(formViewModel)
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
    @EnvironmentObject private var formViewModel: FormViewModel
    
    /// The model for the navigation layer.
    @EnvironmentObject private var navigationLayerModel: NavigationLayerModel
    
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
                        .environmentObject(formViewModel)
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

/// A view for a utility association result.
private struct UtilityAssociationResultView: View {
    /// The closure to call when the utility association result is selected.
    let selectionAction: (() -> Void)
    
    /// The backing utility association result.
    let result: UtilityAssociationResult
    
    var body: some View {
        Button {
            selectionAction()
        } label: {
            HStack {
                if let icon {
                    icon
                }
                VStack(alignment: .leading) {
                    Text(title)
                    Text(description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)
                Spacer()
                Group {
                    if let containmentIsVisible {
                        Text("Containment Visible: \(containmentIsVisible)".capitalized)
                    } else if let fractionAlongEdge {
                        Text(fractionAlongEdge.formatted(.percent))
                    } else if let terminalName {
                        Text("Terminal: \(terminalName)")
                    }
                }
                .padding(2.5)
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(5)
                .font(.caption2)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .tint(.primary)
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

private extension UtilityAssociationResultView {
    /// A Boolean value indicating whether the containment is visible if result represents a containment association.
    var containmentIsVisible: Bool? {
        guard (result.association.toElement.globalID == result.associatedElement.globalID) else {
            return nil
        }
        switch result.association.kind {
        case .containment:
            return result.association.containmentIsVisible
        default:
            return nil
        }
    }
    
    /// A description for the result.
    var description: String {
        if let table = result.associatedFeature.table as? ArcGISFeatureTable,
           let description = table.featureFormDefinition?.description {
            description
        } else {
            result.associatedElement.assetGroup.name
        }
    }
    
    /// The relative location along a non-spatial edge where the junction represented via the association is
    /// (logically) located.
    var fractionAlongEdge: Double? {
        switch result.association.kind {
        case .junctionEdgeObjectConnectivityFromSide, .junctionEdgeObjectConnectivityMidspan, .junctionEdgeObjectConnectivityToSide:
            if result.associatedElement.networkSource.kind == .edge {
                result.association.fractionAlongEdge
            } else {
                nil
            }
        default:
            nil
        }
    }
    
    /// An icon representing the association.
    var icon: Image? {
        let imageName: String? = switch result.association.kind {
        case .junctionEdgeObjectConnectivityMidspan:
            "connection-middle"
        case .connectivity, .junctionEdgeObjectConnectivityFromSide, .junctionEdgeObjectConnectivityToSide:
            if result.associatedFeature.globalID == result.association.fromElement.globalID {
                "connection-end-left"
            } else {
                "connection-end-right"
            }
        default:
            nil
        }
        return imageName != nil ? Image(imageName!, bundle: .toolkitModule) : nil
    }
    
    /// The UtilityTerminal of the associated utility network feature.
    var terminalName: String? {
        switch result.association.kind {
        case .connectivity, .junctionEdgeObjectConnectivityFromSide, .junctionEdgeObjectConnectivityMidspan, .junctionEdgeObjectConnectivityToSide:
            if result.associatedElement.networkSource.kind == .junction {
                result.associatedElement.terminal?.name
            } else {
                nil
            }
        default:
            nil
        }
    }
    
    /// A title for the result.
    var title: String {
        if let table = result.associatedFeature.table as? ArcGISFeatureTable,
           let title = table.featureFormDefinition?.title {
            title
        } else {
            "\(result.associatedElement.assetGroup.name) - \(result.associatedElement.objectID)"
        }
    }
}
