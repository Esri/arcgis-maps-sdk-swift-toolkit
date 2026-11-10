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

extension View {
    func featureFormToolbar() -> some View {
        self.modifier(FeatureFormView.Toolbar())
    }
}

private extension FeatureFormView {
    struct Toolbar: ViewModifier {
        /// The model for the feature form view.
        @Environment(FeatureFormView.Model.self) var groupModel
        
        func body(content: Content) -> some View {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if groupModel.showSaveAndDiscardButtons {
                            DismissButton(kind: .cancel) {
                                groupModel.discard()
                            }
                        }
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if groupModel.showSaveAndDiscardButtons {
                            saveButton
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        if groupModel.showInvalidGeometryBadge {
                            invalidGeometryLabel
                        }
                    }
                }
        }
    }
}

private extension FeatureFormView.Toolbar /* Items */ {
    /// Indicates to the user that the current's feature geometry has been reported invalid.
    var invalidGeometryLabel: some View {
        Label {
            Text(
                "Invalid Geometry",
                bundle: .toolkitModule,
                comment: """
                    A label indicating that the geometry for the current \
                    feature has been reported invalid.
                    """
            )
        } icon: {
            Image(systemName: "move.3d")
                .foregroundStyle(.red)
                .symbolEffect(.breathe.pulse.wholeSymbol, options: .repeat(.continuous))
        }
        .labelStyle(.titleAndIcon)
    }
    
    /// Starts the sequence of events for saving the form(s).
    ///
    /// Disabled when the group has no edits and was not created with a feature creation set.
    var saveButton: some View {
        Button {
            withAnimation {
                groupModel.save()
            }
        } label: {
            if groupModel.isSaving {
                ProgressView()
            } else {
                Label {
                    Text(
                        "Save",
                        bundle: .toolkitModule,
                        comment: "Finish editing the feature form."
                    )
                } icon: {
                    Image(systemName: "checkmark")
                }
            }
        }
        .disabled(!groupModel.groupHasEdits && !groupModel.groupIsFinal)
    }
}

private extension FeatureFormView.Model {
    /// A Boolean value indicating if the invalid geometry toolbar item should be shown.
    var showInvalidGeometryBadge: Bool {
        guard let selectedModel else { return false }
        return (allValidationErrorsAreVisible || selectedModel.visited)
        && (selectedModel.geometryStatus == .invalid)
    }
    
    /// A Boolean value indicating whether the Save and Discard buttons in the toolbar should be
    /// shown.
    var showSaveAndDiscardButtons: Bool {
        multiFormModeIsActive && selectedForm == nil
        || !multiFormModeIsActive
    }
}
