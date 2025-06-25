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
    
    /// The environment value to access the closure to call when the presented feature form changes.
    @Entry var formChangedAction: ((FeatureForm) -> Void)?
    
    /// The navigation path for the navigation stack presenting this view.
    @Entry var navigationPath: Binding<NavigationPath>?
    
    /// The closure to perform when a ``EditingEvent`` occurs.
    @Entry var onFormEditingEventAction: ((FeatureFormView.EditingEvent) -> Void)?
    
    /// The feature form currently visible in the Navigation Stack.
    @Entry var presentedForm: Binding<FeatureForm?>?
    
    /// The environment value to set the continuation to use when the user responds to the alert.
    @Entry var setAlertContinuation: ((Bool, @escaping () -> Void) -> Void)?
    
    /// The environment value to access the validation error visibility.
    @Entry var _validationErrorVisibility: Binding<Visibility> = .constant(.hidden)
}
