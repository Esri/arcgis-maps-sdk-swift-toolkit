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

@Observable class FeatureFormViewModel {
    /// The models for each feature form in the navigation path.
    private var formModels: [ObjectIdentifier: EmbeddedFeatureFormViewModel] = [:]
    
    /// An error thrown from finish editing.
    var finishEditingError: (any Error)?
    
    /// Continuation information for the alert.
    var navigationAlertInfo: (willNavigate: Bool, action: () -> Void)?
    
    /// The navigation path used by the navigation stack in the root feature form view.
    var navigationPath: [FeatureFormView.NavigationPathItem] = []
    
    /// The feature form presented in the navigation stack.
    private(set) var presentedForm: FeatureForm?
    
    /// The internally managed validation error visibility.
    var validationErrorVisibilityInternal = FeatureFormView.ValidationErrorVisibility.automatic
    
    /// Creates and adds a model for the provided form.
    /// - Parameter form: The form to create and add a model for.
    @MainActor func addModel(_ form: FeatureForm) {
        formModels[ObjectIdentifier(form)] = EmbeddedFeatureFormViewModel(featureForm: form)
    }
    
    /// Gets the model for the specified form.
    /// - Parameter form: The form to get a model for.
    /// - Returns: The model for the provided form.
    func getModel(_ form: FeatureForm) -> EmbeddedFeatureFormViewModel? {
        formModels[ObjectIdentifier(form)]
    }
    
    /// Removes the model for the provided form.
    /// - Parameter form: The form to remove the model for.
    func removeModel(_ form: FeatureForm) {
        formModels.removeValue(forKey: ObjectIdentifier(form))
    }
    
    
    /// Sets the presented form in the feature form view.
    /// - Parameter form: The new presented form.
    func setPresentedForm(_ form: FeatureForm) {
        form.feature.refresh()
        presentedForm = form
        validationErrorVisibilityInternal = .automatic
    }
    
    /// Sets the root feature form in the feature form view.
    /// - Parameter form: The new root form.
    @MainActor func setRootForm(_ form: FeatureForm) {
        formModels.removeAll()
        navigationPath.removeAll()
        addModel(form)
        presentedForm = form
        validationErrorVisibilityInternal = .automatic
    }
    
    // MARK: Computed properties
    
    /// A Boolean value indicating if the form presented in the navigation stack has validation errors.
    var presentedFormHasValidationErrors: Bool {
        !(presentedForm?.validationErrors.isEmpty ?? true)
    }
}
