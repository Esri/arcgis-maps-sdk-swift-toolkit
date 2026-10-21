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
import Observation

extension FeatureFormView.StackView {
    @MainActor @Observable final class Model {
        init(featureForm: FeatureForm) {
            self.formModel = .init(featureForm: featureForm)
        }
        
        #warning("Optional no longer needed here.")
        /// The model for the feature form at the root of the navigation path.
        var formModel: FeatureFormView.FormView.Model?
        
        /// An error thrown from finish editing.
        var finishEditingError: (any Error)?
        
        /// Continuation information for the alert.
        var navigationAlertInfo: (willNavigate: Bool, action: () -> Void)?
        
        /// The navigation path used by the navigation stack in the root feature form view.
        var navigationPath: [FeatureFormView.NavigationPathItem] = []
        
        /// The internally managed validation error visibility.
        var validationErrorVisibilityInternal = FeatureFormView.ValidationErrorVisibility.automatic
        
        // MARK: Computed properties
        
        /// A Boolean value indicating if the form presented in the navigation stack has validation errors.
        var presentedFormHasValidationErrors: Bool {
            !(formModel?.featureForm.elementValidationErrors.isEmpty ?? false)
        }
    }
}
