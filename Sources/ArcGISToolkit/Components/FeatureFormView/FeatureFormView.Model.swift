// Copyright 2026 Esri
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

public extension FeatureFormView {
    @MainActor @Observable
    class Model {
        /// A binding to a Boolean value that determines whether the view is presented.
        var isPresented: Bool?
        /// The root feature form.
        let rootFeatureForm: FeatureForm?
        
        /// The visibility of the "save" and "discard" buttons.
        var editingButtonsVisibility: Visibility = .automatic
        /// A Boolean which declares whether navigation to forms for features associated via utility association
        /// form elements is disabled.
        var navigationIsDisabled = false
        /// The user-provided closure to perform when a new feature form is shown in the navigation stack.
        var onFeatureFormChanged: ((FeatureForm) -> Void)?
        /// The user-provided closure to perform when a ``EditingEvent`` occurs.
        var onFormEditingEventAction: FormEditingEventAction?
        /// The developer configurable validation error visibility.
        var validationErrorVisibilityExternal = ValidationErrorVisibility.automatic
        /// An action to run before finishing editing.
        ///
        /// If the action throws an error, `finishEditing` should not be
        /// called.
        var willFinishEditingAction: (() throws -> Void)?
        
        /// A Boolean value indicating whether legacy mode (single-form) is active.
        var legacyModeIsActive: Bool {
            rootFeatureForm != nil
        }
        
        init(isPresented: Bool? = nil, rootFeatureForm: FeatureForm) {
            self.isPresented = isPresented
            self.rootFeatureForm = rootFeatureForm
        }
    }
}
