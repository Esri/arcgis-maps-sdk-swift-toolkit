// Copyright 2023 Esri
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

struct RadioButtonsInput: View {
    /// The field's parent element.
    private let element: FieldFormElement
    
    /// The feature form containing the input.
    private var featureForm: FeatureForm?
    
    /// The input configuration of the field.
    private let input: RadioButtonsFormInput
    
    /// Creates a view for a date (and time if applicable) input.
    /// - Parameters:
    ///   - featureForm: The feature form containing the input.
    ///   - element: The field's parent element.
    ///   - input: The input configuration of the field.
    init(featureForm: FeatureForm?, element: FieldFormElement, input: RadioButtonsFormInput) {
        self.featureForm = featureForm
        self.element = element
        self.input = input
    }
}
