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

private import os

extension View {
    func associationRemovalConfirmation(
        isPresented: Binding<Bool>,
        association: UtilityAssociation?,
        element: UtilityAssociationsFormElement,
        embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel,
        onRemoval: @escaping () -> Void
    ) -> some View {
        modifier(
            AssociationRemovalConfirmation(
                isPresented: isPresented,
                association: association,
                element: element,
                embeddedFeatureFormViewModel: embeddedFeatureFormViewModel,
                onRemoval: onRemoval
            )
        )
    }
}

private struct AssociationRemovalConfirmation: ViewModifier {
    @Binding var isPresented: Bool
    
    /// The association to be removed.
    let association: UtilityAssociation?
    /// The element containing the association to remove.
    let element: UtilityAssociationsFormElement
    /// The model for the feature form containing the element with the association to be removed.
    let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
    /// The action to run when the removal is completed.
    let onRemoval: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert(
                confirmationTitle,
                isPresented: $isPresented
            ) {
                actions
            } message: {
                confirmationMessage
            }
    }
}

extension AssociationRemovalConfirmation {
    @ViewBuilder var actions: some View {
        if let association {
            Button(role: .destructive) {
                do {
                    try element.delete(association)
                    embeddedFeatureFormViewModel.evaluateExpressions()
                    onRemoval()
                    Logger.featureFormView.info("Association removed successfully.")
                } catch {
                    Logger.featureFormView.error("Failed to remove association: \(error.localizedDescription).")
                }
            } label: {
                Text(
                    "Remove",
                    bundle: .toolkitModule,
                    comment: "A label for a button to remove a utility network association."
                )
            }
        }
        Button.cancel {}
    }
    
    var confirmationMessage: Text {
        Text(
            "Only removes the association. The feature remains.",
            bundle: .toolkitModule,
            comment: """
                Helper text indicating that an accompanying button only 
                removes only the association. 
                """
        )
    }
    
    var confirmationTitle: Text {
        Text(
            "Remove association?",
            bundle: .toolkitModule,
            comment: "A label for a confirmation to remove a utility association."
        )
    }
}
