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

extension EnvironmentValues /* FeatureFormView */ {
    /// The visibility of the "save" and "discard" buttons.
    @Entry var editingButtonVisibility: Visibility = .automatic
    
    /// An error thrown from a call to `FeatureForm.finishEditing()`.
    @Entry var finishEditingError: Binding<(any Error)?> = .constant(nil)
    
    /// The environment value which declares whether navigation to forms for features associated via utility association form
    /// elements is disabled.
    @Entry var navigationIsDisabled = false
    
    /// The navigation path for the navigation stack presenting this view.
    @Entry var navigationPath: Binding<NavigationPath>?
    
    /// The closure to perform when a ``EditingEvent`` occurs.
    @Entry var onFormEditingEventAction: ((FeatureFormView.EditingEvent) -> Void)?
    
    /// The environment value to set the continuation to use when the user responds to the alert.
    @Entry var setAlertContinuation: ((Bool, @escaping () -> Void) -> Void)?
    
    /// The developer configurable validation error visibility.
    @Entry var validationErrorVisibilityExternal: FeatureFormView.ValidationErrorVisibility = .automatic
    
    /// The internally managed validation error visibility.
    @Entry var validationErrorVisibilityInternal: Binding<FeatureFormView.ValidationErrorVisibility> = .constant(.automatic)
}
