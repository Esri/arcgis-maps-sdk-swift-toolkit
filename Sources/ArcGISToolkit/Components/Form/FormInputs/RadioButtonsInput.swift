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
    @Environment(\.formElementPadding) var elementPadding
    
    /// The set of options in the input.
    @State private var codedValues = [CodedValue]()
    
    /// A Boolean value indicating whether the date selection was cleared when a value is required.
    @State private var requiredValueMissing = false
    
    /// The selected option.
    @State private var selectedValue: CodedValue?
    
    /// A Boolean value indicating whether a `ComboBoxInput`` should be used instead. This will be `true` if
    /// the current value doesn't exist as an option in the domain
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
                
                VStack(alignment: .leading, spacing: .zero) {
                    if input.noValueOption == .show {
                        makeRadioButtonRow(
                            placeholderValue,
                            selectedValue == nil,
                            !codedValues.isEmpty,
                            useNoValueStyle: true
                        ) {
                            selectedValue = nil
                        }
                    }
                    ForEach(codedValues, id: \.self) { codedValue in
                        makeRadioButtonRow(
                            codedValue.name,
                            codedValue == selectedValue,
                            codedValue != codedValues.last
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
                        .foregroundColor(.accentColor)
                        .accessibilityIdentifier("\(element.label) \(label) Checkmark")
                }
            }
            .padding(10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
        .accessibilityIdentifier("\(element.label) \(label)")
        if addDivider {
            Divider()
                .padding(.leading, 10)
        }
    }
}
