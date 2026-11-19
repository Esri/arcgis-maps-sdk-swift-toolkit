// Copyright 2024 Esri
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

import SwiftUI

public extension FeatureFormView {
    /// The validation error visibility configuration of a form.
    enum ValidationErrorVisibility: Sendable {
        /// Errors may be visible or hidden for a given form field depending on its focus state.
        case automatic
        /// Errors will always be visible for a given form field.
        case visible
    }
    
    /// Sets the visibility of validation errors on the form.
    /// - Parameter visibility: The preferred visibility of validation errors in the form.
    ///
    /// `FeatureFormView` will automatically show validation errors on fields once they've received
    /// user interaction or the user has attempted to save the form with the built-in "Save" buttons.
    ///
    /// If it's preferred that validation errors are always shown, override the default behavior with this
    /// modifier, passing `.visible`.
    ///
    /// If the built-in "Save" button in the form footer has been hidden with
    /// ``FeatureFormView/editingButtons(_:)``, use this modifier to make any validation
    /// errors visible when the user attempts to save the form with a custom save button.
    func validationErrors(_ visibility: ValidationErrorVisibility) -> Self {
        var copy = self
        copy.validationErrorVisibilityExternal = visibility
        return copy
    }
}
