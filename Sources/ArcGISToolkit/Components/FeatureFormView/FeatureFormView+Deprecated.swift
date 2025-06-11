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

public extension FeatureFormView /* Deprecated */ {
    /// Initializes a form view.
    /// - Parameters:
    ///   - featureForm: The feature form defining the editing experience.
    /// - Attention: Deprecated at 200.7.
    @available(*, deprecated, message: "Use init(featureForm:) instead.")
    init(featureForm: FeatureForm) {
        self.init(featureForm: .constant(featureForm))
    }
    
    /// The validation error visibility configuration of a form.
    /// - Attention: Deprecated at 200.7.
    @available(*, deprecated)
    enum ValidationErrorVisibility: Sendable {
        /// Errors may be visible or hidden for a given form field depending on its focus state.
        case automatic
        /// Errors will always be visible for a given form field.
        case visible
    }
    
    /// Specifies the visibility of validation errors in the form.
    /// - Parameter visibility: The preferred visibility of validation errors in the form.
    /// - Attention: Deprecated at 200.7. ``FeatureFormView`` automatically manages
    /// validation error visibility.
    @available(*, deprecated)
    func validationErrors(_ visibility: ValidationErrorVisibility) -> Self {
        self
    }
}
