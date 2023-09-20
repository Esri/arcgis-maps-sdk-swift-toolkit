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
    @Environment(\.formElementPadding) var elementPadding
    
    /// The set of options in the input.
    @State private var codedValues = [CodedValue]()
    
    
    /// The selected option.
    @State private var selectedValue: CodedValue?
    
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
    
    var body: some View {
        Group {
            InputHeader(element: element)
                .padding([.top], elementPadding)
            
            Picker(element.label, selection: $selectedValue) {
                ForEach(codedValues, id: \.self) { codedValue in
                    Text(codedValue.name)
                }
            }
            
            InputFooter(element: element, requiredValueMissing: requiredValueMissing)
        }
        .padding([.bottom], elementPadding)
        .onAppear {
            codedValues = featureForm!.codedValues(fieldName: element.fieldName)
            selectedValue = codedValues.first { $0.name == element.value }
        }
    }
}
