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
    
    /// Creates and adds a model for the provided form.
    /// - Parameter form: The form to create and add a model for.
    @MainActor func addModel(_ form: FeatureForm) {
        formModels[ObjectIdentifier(form)] = EmbeddedFeatureFormViewModel(featureForm: form)
    }
    
    /// Removes all form models.
    func clearModels() {
        formModels.removeAll()
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
}
