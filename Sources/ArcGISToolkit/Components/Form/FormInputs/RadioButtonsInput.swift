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
    
    /// A Boolean value indicating whether the date selection was cleared when a value is required.
    @State private var requiredValueMissing = false
    
    /// The selected option.
    @State private var selectedValue: CodedValue?
    
    /// A Boolean value indicating whether the current value doesn't exist as an option in the domain.
    ///
    /// In this scenario a ``ComboBoxInput`` should be used instead.
    @State private var fallbackToComboBox = false
    
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
        if fallbackToComboBox {
            ComboBoxInput(
                featureForm: featureForm,
                element: element,
                noValueLabel: input.noValueLabel,
                noValueOption: input.noValueOption
            )
        } else {
            Group {
                InputHeader(element: element)
                    .padding([.top], elementPadding)
                
                Picker(element.label, selection: $selectedValue) {
                    Text(placeholderValue)
                        .tag(nil as CodedValue?)
                    ForEach(codedValues, id: \.self) { codedValue in
                        Text(codedValue.name)
                            .tag(Optional(codedValue))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .formTextInputStyle()
                
                InputFooter(element: element, requiredValueMissing: requiredValueMissing)
            }
            .padding([.bottom], elementPadding)
            .onAppear {
                codedValues = featureForm!.codedValues(fieldName: element.fieldName)
                if let selectedValue = codedValues.first(where: { $0.name == element.value }) {
                    self.selectedValue = selectedValue
                } else if !element.value.isEmpty {
                    fallbackToComboBox = true
                }
            }
            .onChange(of: selectedValue) { newValue in
                guard codedValues.first(where: { $0.name == element.value }) != newValue else {
                    return
                }
                requiredValueMissing = element.isRequired && newValue == nil
                featureForm?.feature.setAttributeValue(newValue?.code ?? "", forKey: element.fieldName)
            }
        }
    }
}

extension RadioButtonsInput {
    /// The placeholder value to display.
    var placeholderValue: String {
        if input.noValueOption == .show && !input.noValueLabel.isEmpty {
            return input.noValueLabel
        } else {
            return .noValue
        }
    }
}
