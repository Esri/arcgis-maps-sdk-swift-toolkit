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

struct UtilityAssociationDetailsView: View {
    /// The navigation path for the navigation stack presenting this view.
    @Environment(\.navigationPath) var navigationPath
    
    /// A Boolean value indicating whether the element is editable.
    @State private var isEditable = false
    /// A Boolean value indicating whether the removal confirmation is presented.
    @State private var removalConfirmationIsPresented = false
    
    /// The association result.
    let associationResult: UtilityAssociationResult
    /// The model containing the latest association filter results.
    let associationsFilterResultsModel: AssociationsFilterResultsModel
    /// The element containing the association.
    let element: UtilityAssociationsFormElement
    /// The model for the feature form containing the element with the association.
    let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
    
    var body: some View {
        List {
            sectionForAssociation
            sectionForFromElement
            sectionForToElement
            sectionForRemoveButton
        }
        .navigationTitle(
            Text(
                "Association Settings",
                bundle: .toolkitModule,
                comment: "A navigation title for the Association Settings page."
            )
        )
        .onIsEditableChange(of: element) { newIsEditable in
            isEditable = newIsEditable
        }
    }
    
    /// The name of the provided terminal as labeled content.
    func row(for terminal: UtilityTerminal) -> some View {
        LabeledContent {
            Text(terminal.name)
        } label: {
            Text(
                "Terminal",
                bundle: .toolkitModule,
                comment: "A label in reference to a utility terminal."
            )
        }
    }
    
    /// <#Description#>
    var sectionForAssociation: some View {
        Section {
            LabeledContent {
                associationResult.association.kind.name
            } label: {
                Text.associationType
            }
        }
    }
    
    /// <#Description#>
    var sectionForFromElement: some View {
        Section {
            LabeledContent {
                Text(associationResult.associatedFeatureIsToElement ? embeddedFeatureFormViewModel.title : associationResult.title)
            } label: {
                Text.fromElement
            }
            if let fromElementTerminal = associationResult.association.fromElement.terminal {
                row(for: fromElementTerminal)
            }
        }
    }
    
    /// <#Description#>
    var sectionForToElement: some View {
        Section {
            LabeledContent {
                Text(associationResult.associatedFeatureIsToElement ? associationResult.title : embeddedFeatureFormViewModel.title)
            } label: {
                Text.toElement
            }
            if let toElementTerminal = associationResult.association.toElement.terminal {
                row(for: toElementTerminal)
            }
        }
    }
    
    /// <#Description#>
    @ViewBuilder var sectionForRemoveButton: some View {
        if isEditable {
            Section {
                Button(role: .destructive) {
                    removalConfirmationIsPresented = true
                } label: {
                    Text(LocalizedStringResource.removeAssociation)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .associationRemovalConfirmation(
                    isPresented: $removalConfirmationIsPresented,
                    association: associationResult.association,
                    element: element,
                    embeddedFeatureFormViewModel: embeddedFeatureFormViewModel
                ) {
                    associationsFilterResultsModel.fetchResults()
                    navigationPath?.wrappedValue.removeLast()
                }
            }
        }
    }
}

private extension UtilityAssociation.Kind {
    /// A localized label for the association kind.
    var name: Text {
        switch self {
        case .attachment:
            Text(
                "Attachment",
                bundle: .toolkitModule,
                comment: #"A label for the "Attachment" utility association kind."#
            )
        case .connectivity:
            Text(
                "Connectivity",
                bundle: .toolkitModule,
                comment: #"A label for the "Connectivity" utility association kind."#
            )
        case .containment:
            Text(
                "Containment",
                bundle: .toolkitModule,
                comment: #"A label for the "Containment" utility association kind."#
            )
        case .junctionEdgeObjectConnectivityFromSide:
            Text(
                "Junction Edge Object Connectivity From Side",
                bundle: .toolkitModule,
                comment: #"A label for the "Junction Edge Object Connectivity From Side" utility association kind."#
            )
        case .junctionEdgeObjectConnectivityMidspan:
            Text(
                "Junction Edge Object Connectivity Midspan",
                bundle: .toolkitModule,
                comment: #"A label for the "Junction Edge Object Connectivity Midspan" utility association kind."#
            )
        case .junctionEdgeObjectConnectivityToSide:
            Text(
                "Junction Edge Object Connectivity To Side",
                bundle: .toolkitModule,
                comment: #"A label for the "Junction Edge Object Connectivity To Side" utility association kind."#
            )
        @unknown default:
            Text(
                LocalizedStringResource(
                    "utility-association-unknown-label",
                    defaultValue: "Unknown",
                    bundle: .toolkit,
                    comment: "A label for an unknown utility association kind."
                )
            )
        }
    }
}
