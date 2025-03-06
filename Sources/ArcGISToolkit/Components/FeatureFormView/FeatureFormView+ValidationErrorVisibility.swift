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

extension FeatureFormView {
    /// The validation error visibility configuration of a form.
    enum _ValidationErrorVisibility: Sendable {
        /// Errors may be visible or hidden for a given form field depending on its focus state.
        case automatic
        /// Errors will always be visible for a given form field.
        case visible
    }
}

extension EnvironmentValues {
    /// The validation error visibility configuration of a form.
    /// - Attention: Deprecated at 200.7.
    @available(*, deprecated)
    var validationErrorVisibility: FeatureFormView.ValidationErrorVisibility {
        get { self[FormViewValidationErrorVisibility.self] }
        set { self[FormViewValidationErrorVisibility.self] = newValue }
    }
}

/// The validation error visibility configuration of a form.
/// - Attention: Deprecated at 200.7.
@available(*, deprecated)
struct FormViewValidationErrorVisibility: EnvironmentKey {
    static let defaultValue: FeatureFormView.ValidationErrorVisibility = .automatic
}
