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
    
    /// A Boolean value indicating whether the deletion confirmation is presented.
    @State private var deletionConfirmationIsPresented = false
    
    /// The association.
    let association: UtilityAssociation
    /// The model containing the latest association filter results.
    let associationsFilterResultsModel: AssociationsFilterResultsModel
    /// The element containing the association.
    let element: UtilityAssociationsFormElement
    /// The model for the feature form containing the element with the association.
    let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
    
    var body: some View {
        List {
            Section {
                LabeledContent {
                    Text("\(association.kind)".capitalized)
                } label: {
                    Text(
                        "Association Type",
                        bundle: .toolkitModule,
                        comment: "A label in reference to a utility association type."
                    )
                }
            }
            Section {
                LabeledContent {} label: {
                    Text(
                        "From Element",
                        bundle: .toolkitModule,
                        comment: "A label for the element on the \"from\" side of a utility association."
                    )
                }
                if let fromElementTerminal = association.fromElement.terminal {
                    LabeledContent {
                        Text(fromElementTerminal.name)
                    } label: {
                        terminal
                    }
                }
            }
            Section {
                LabeledContent {} label: {
                    Text(
                        "To Element",
                        bundle: .toolkitModule,
                        comment: "A label for the element on the \"to\" side of a utility association."
                    )
                }
                if let toElementTerminal = association.toElement.terminal {
                    LabeledContent {
                        Text(toElementTerminal.name)
                    } label: {
                        terminal
                    }
                }
            }
            Section {
                Button(role: .destructive) {
                    deletionConfirmationIsPresented = true
                } label: {
                    Text(
                        "Remove Association",
                        bundle: .toolkitModule,
                        comment: "A label for a button to remove an utility association."
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .associationRemovalConfirmationDialog(
                    isPresented: $deletionConfirmationIsPresented,
                    association: association,
                    element: element,
                    embeddedFeatureFormViewModel: embeddedFeatureFormViewModel
                ) {
                    associationsFilterResultsModel.fetchResults()
                    navigationPath?.wrappedValue.removeLast()
                }
            }
        }
        .navigationTitle(
            Text(
                "Association Settings",
                bundle: .toolkitModule,
                comment: "A navigation title for the Association Settings page."
            )
        )
    }
    
    var terminal: Text {
        Text(
            "Terminal",
            bundle: .toolkitModule,
            comment: "A label in reference to a utility terminal."
        )
    }
}
