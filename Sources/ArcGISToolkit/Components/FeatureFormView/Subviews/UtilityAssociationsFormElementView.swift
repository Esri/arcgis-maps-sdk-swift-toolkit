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
    
    /// The view model for the form.
    @EnvironmentObject private var formViewModel: FormViewModel
    
    /// <#Description#>
    @EnvironmentObject private var navigationLayerModel: NavigationLayerModel
    
    /// <#Description#>
    let utilityAssociationGroupResult: UtilityAssociationGroupResult
    
    var body: some View {
        List(utilityAssociationGroupResult.associationResults, id: \.associatedFeature.globalID) { utilityAssociationResult in
            if let currentFeatureGlobalID = formViewModel.featureForm.feature.globalID {
                let associatedElement = utilityAssociationResult.association.displayedElement(for: currentFeatureGlobalID)
                let title: String = {
                    if let formDefinitionTitle = associatedElement.networkSource.featureTable.featureFormDefinition?.title {
                        formDefinitionTitle
                    } else {
                        "\(associatedElement.assetGroup.name) - \(associatedElement.objectID)"
                    }
                }()
                let connection: UtilityAssociationView.Association.Connection? = switch utilityAssociationResult.association.kind {
                case .junctionEdgeObjectConnectivityMidspan:
                        .middle
                case .connectivity, .junctionEdgeObjectConnectivityFromSide, .junctionEdgeObjectConnectivityToSide:
                    currentFeatureGlobalID == utilityAssociationResult.association.fromElement.globalID ? .left : .right
                default:
                    nil
                }
                
                UtilityAssociationView(
                    association: UtilityAssociationView.Association(
                        connectionPoint: connection,
                        description: nil,
                        fractionAlongEdge: utilityAssociationResult.association.fractionAlongEdge,
                        name: title,
                        selectionAction: {
                            navigationLayerModel.push {
                                InternalFeatureFormView(
                                    featureForm: FeatureForm(feature: utilityAssociationResult.associatedFeature)
                                )
                            }
                        },
                        terminalName: associatedElement.terminal?.name
                    )
                )
            }
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
        Button {
            navigationLayerModel.push {
                UtilityAssociationsFilterResultView(utilityAssociationsFilterResult: utilityAssociationsFilterResult)
                    .environmentObject(formViewModel)
            }
        } label: {
            HStack {
                Text("\(utilityAssociationsFilterResult.filter.filterType)".capitalized)
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
            Button(utilityAssociationGroupResult.name) {
                navigationLayerModel.push {
                    UtilityAssociationGroupResultView(utilityAssociationGroupResult: utilityAssociationGroupResult)
                        .environmentObject(formViewModel)
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

private extension UtilityAssociation {
    /// Determines whether to show the `fromElement` or `toElement`.
    /// - Parameter id: <#id description#>
    /// - Returns: <#description#>
    func displayedElement(for id: UUID) -> UtilityElement {
        if id == toElement.globalID {
            fromElement
        } else {
            toElement
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
