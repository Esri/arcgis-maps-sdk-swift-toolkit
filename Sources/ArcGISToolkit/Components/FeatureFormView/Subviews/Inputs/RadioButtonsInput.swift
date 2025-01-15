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
    @EnvironmentObject var model: FormViewModel
    
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
            VStack(alignment: .leading, spacing: .zero) {
                if input.noValueOption == .show {
                    makeRadioButtonRow(
                        placeholderValue,
                        selectedValue == nil,
                        !element.codedValues.isEmpty,
                        useNoValueStyle: true
                    ) {
                        selectedValue = nil
                    }
                }
                ForEach(element.codedValues, id: \.self) { codedValue in
                    makeRadioButtonRow(
                        codedValue.name,
                        codedValue == selectedValue,
                        codedValue != element.codedValues.last
                    ) {
                        selectedValue = codedValue
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(uiColor: .tertiarySystemFill))
            )
            .frame(maxWidth: .infinity, alignment: .leading)
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
            .onChange(selectedValue) { selectedValue in
                element.updateValue(selectedValue?.code)
                model.evaluateExpressions()
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
    
    /// Makes a radio button row.
    /// - Parameters:
    ///   - label: The label for the radio button.
    ///   - selected: A Boolean value indicating whether the button is selected.
    ///   - addDivider: A Boolean value indicating whether a divider should be included under the row.
    ///   - useNoValueStyle: A Boolean value indicating whether the button represents a no value option.
    ///   - action: The action to perform when the user triggers the button.
    @ViewBuilder func makeRadioButtonRow(
        _ label: String,
        _ selected: Bool,
        _ addDivider: Bool,
        useNoValueStyle: Bool = false,
        _ action: @escaping () -> Void
    ) -> some View {
        Button {
            model.focusedElement = element
            action()
        } label: {
            HStack {
                if useNoValueStyle {
                    Text(label)
                        .italic()
                        .foregroundStyle(.secondary)
                } else {
                    Text(label)
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .accessibilityIdentifier("\(element.label) \(label) Checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(10)
            .contentShape(Rectangle())
        }
        .accessibilityIdentifier("\(element.label) \(label) Radio Button")
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        if addDivider {
            Divider()
                .padding(.leading, 10)
        }
    }
}
