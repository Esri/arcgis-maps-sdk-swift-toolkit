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

/// <#Description#>
struct UtilityAssociationsFormElementView: View {
    /// <#Description#>
    @EnvironmentObject private var formViewModel: FormViewModel
    
    /// <#Description#>
    @State private var associationsFilterResults = [UtilityAssociationsFilterResult]()
    
    /// <#Description#>
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
            try? await element.fetchAssociationsFilterResults()
            associationsFilterResults = element.associationsFilterResults
        }
    }
}

/// <#Description#>
private struct UtilityAssociationGroupResultView: View {
    @Environment(\.formChangedAction) var formChangedAction
    
    @Environment(\.setAlertContinuation) var setAlertContinuation
    
    /// The view model for the form.
    @EnvironmentObject private var formViewModel: FormViewModel
    
    /// <#Description#>
    @EnvironmentObject private var navigationLayerModel: NavigationLayerModel
    
    /// <#Description#>
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

/// <#Description#>
private struct UtilityAssociationsFilterResultListRowView: View {
    /// <#Description#>
    @EnvironmentObject private var formViewModel: FormViewModel
    
    /// <#Description#>
    @EnvironmentObject private var navigationLayerModel: NavigationLayerModel
    
    /// <#Description#>
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
#warning("TODO: Description line is not showing.")
                    Text(utilityAssociationsFilterResult.filter.description)
                        .font(.caption)
                }
                .lineLimit(1)
                Spacer()
                Text(utilityAssociationsFilterResult.resultCount.formatted())
                Image(systemName: "chevron.right")
            }
        }
    }
}

/// <#Description#>
private struct UtilityAssociationsFilterResultView: View {
    /// <#Description#>
    @EnvironmentObject private var formViewModel: FormViewModel
    
    /// <#Description#>
    @EnvironmentObject private var navigationLayerModel: NavigationLayerModel
    
    /// <#Description#>
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
                    Text(utilityAssociationGroupResult.associationResults.count.formatted())
                }
            }
        }
    }
}

/// <#Description#>
private struct UtilityAssociationResultView: View {
    /// <#Description#>
    let selectionAction: (() -> Void)
    
    /// <#Description#>
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
            }
        }
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
        switch result.association.kind {
        case .containment:
            result.association.containmentIsVisible
        default:
            nil
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
