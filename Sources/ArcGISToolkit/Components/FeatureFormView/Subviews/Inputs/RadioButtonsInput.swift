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

/// A view for numerical value input.
///
/// This is the preferable input type for short lists of coded value domains.
struct RadioButtonsInput: View {
    /// The view model for the form.
    @Environment(EmbeddedFeatureFormViewModel.self) private var embeddedFeatureFormViewModel
    
    /// A Boolean value indicating whether a ``ComboBoxInput`` should be used instead.
    /// This will be `true` if the current value doesn't exist as an option in the domain
    @State private var fallbackToComboBox = false
    /// The selected option.
    @State private var selectedValue: CodedValue?
    /// The element's current value.
    @State private var value: Any?
    
    /// The element the input belongs to.
    private let element: FieldFormElement
    /// The input configuration of the field.
    private let input: RadioButtonsFormInput
    
    /// Creates a view for a date (and time if applicable) input.
    /// - Parameters:
    ///   - element: The field's parent element.
    init(element: FieldFormElement) {
        precondition(
            element.input is RadioButtonsFormInput,
            "\(Self.self).\(#function) element's input must be \(RadioButtonsFormInput.self)."
        )
        self.element = element
        self.input = element.input as! RadioButtonsFormInput
    }
    
    var body: some View {
        if fallbackToComboBox {
            ComboBoxInput(
                element: element,
                noValueLabel: input.noValueLabel,
                noValueOption: input.noValueOption
            )
        } else {
            Picker(element.label, selection: $selectedValue) {
                if input.noValueOption == .show {
                    Text(placeholderValue)
                        .foregroundStyle(.secondary)
                        .tag(nil as CodedValue?)
                }
                ForEach(element.codedValues, id: \.self) { value in
                    Text(value.name)
                        .tag(value)
                }
            }
            .labelsHidden()
            .pickerStyle(.inline)
            .onAppear {
                if let selectedValue = element.codedValues.first(where: {
                    $0.name == element.formattedValue
                }) {
                    self.selectedValue = selectedValue
                } else {
                    fallbackToComboBox =
                    (input.noValueOption == .show && element.formattedValue != input.noValueLabel)
                    || (input.noValueOption == .hide && !element.formattedValue.isEmpty)
                }
            }
            .onChange(of: selectedValue) {
                guard selectedValue?.name != element.formattedValue else { return }
                embeddedFeatureFormViewModel.focusedElement = element
                element.updateValue(selectedValue?.code)
                embeddedFeatureFormViewModel.evaluateExpressions()
            }
            .onValueChange(of: element) { newValue, newFormattedValue in
                value = newValue
                selectedValue = element.codedValues.first { $0.name == newFormattedValue }
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
