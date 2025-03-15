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
            let associatedElement = utilityAssociationResult.associatedElement
            let associatedFeature = utilityAssociationResult.associatedFeature
            
            let title: String = {
                if let table = associatedFeature.table as? ArcGISFeatureTable, let formDefinitionTitle = table.featureFormDefinition?.title {
                    formDefinitionTitle
                } else {
                    "\(associatedElement.assetGroup.name) - \(associatedElement.objectID)"
                }
            }()
            
            // Resolve the connection icon
            let connection: UtilityAssociationView.Association.Connection? = switch utilityAssociationResult.association.kind {
            case .junctionEdgeObjectConnectivityMidspan:
                    .middle
            case .connectivity, .junctionEdgeObjectConnectivityFromSide, .junctionEdgeObjectConnectivityToSide:
                associatedFeature.globalID == utilityAssociationResult.association.fromElement.globalID ? .left : .right
            default:
                nil
            }
            
            // Resolve the terminal name
            let terminalName: String? = switch utilityAssociationResult.association.kind {
            case .connectivity, .junctionEdgeObjectConnectivityMidspan, .junctionEdgeObjectConnectivityFromSide, .junctionEdgeObjectConnectivityToSide:
                utilityAssociationResult.associatedElement.terminal?.name
            default:
                nil
            }
            
            UtilityAssociationView(
                association: UtilityAssociationView.Association(
                    connectionPoint: connection,
                    description: associatedElement.assetGroup.name,
                    fractionAlongEdge: utilityAssociationResult.association.fractionAlongEdge,
                    name: title,
                    selectionAction: {
                        let navigationAction: () -> Void = {
                            navigationLayerModel.push {
                                InternalFeatureFormView(
                                    featureForm: FeatureForm(feature: associatedFeature)
                                )
                            }
                        }
                        if formViewModel.featureForm.hasEdits {
                            setAlertContinuation?(true, navigationAction)
                        } else {
                            navigationAction()
                        }
                    },
                    terminalName: terminalName
                )
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
private struct UtilityAssociationView: View {
    /// <#Description#>
    var association: Association
    
    var body: some View {
        Button {
            association.selectionAction()
        } label: {
            HStack {
                if let connection = association.connectionPoint {
                    let image: String = switch connection {
                    case .left:
                        "connection-end-left"
                    case .middle:
                        "connection-middle"
                    case .right:
                        "connection-end-right"
                    }
                    Image(image, bundle: .toolkitModule)
                }
                
                VStack(alignment: .leading) {
                    Text(association.name)
                        .lineLimit(1)
                    if let description = association.description {
                        Text(description)
                            .font(.caption2)
                    }
                }
                Spacer()
                Group {
                    if let percent = association.fractionAlongEdge {
                        Text(percent.formatted(.percent))
                    } else if let terminal = association.terminalName {
                        Text("Terminal: \(terminal)")
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

private extension UtilityAssociationView {
    struct Association {
        /// <#Description#>
        enum Connection {
            case left
            case middle
            case right
        }
        
        /// <#Description#>
        let connectionPoint: Connection?
        
        /// <#Description#>
        let description: String?
        
        /// <#Description#>
        let fractionAlongEdge: Double?
        
        /// <#Description#>
        let name: String
        
        /// <#Description#>
        let selectionAction: (() -> Void)
        
        /// <#Description#>
        let terminalName: String?
    }
}
