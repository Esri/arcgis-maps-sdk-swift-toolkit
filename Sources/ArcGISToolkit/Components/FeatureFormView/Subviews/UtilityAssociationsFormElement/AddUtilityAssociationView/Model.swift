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

import Observation

extension FeatureFormView.AddUtilityAssociationView {
    /// A model to hold properties common to the views in the "add utility association" workflow.
    @Observable
    class Model {
        /// The model for the navigation layer.
        var navigationLayerModel: NavigationLayerModel? = nil
        
        // MARK: Presentation properties
        
        var featureQueryConditionsViewIsPresented = false
        var spatialFeatureSelectionViewIsPresented = false
    }
}
