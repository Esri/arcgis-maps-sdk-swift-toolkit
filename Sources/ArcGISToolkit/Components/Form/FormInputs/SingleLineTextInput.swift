// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS

/// A view for single line text input.
struct SingleLineTextInput: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The feature form containing the input.
    private var featureForm: FeatureForm?
    
    /// The model for the ancestral form view.
    @EnvironmentObject var model: FormViewModel
    
    /// A Boolean value indicating whether or not the field is focused.
    @FocusState private var isFocused: Bool
    
    /// The current text value.
    @State private var text = ""
    
    /// The input's parent element.
    private let element: FieldFormElement
    
    /// The input configuration of the view.
    private let input: TextBoxFormInput
    
    /// The model for the input.
    @StateObject var inputModel: FormInputModel
    
    /// Creates a view for single line text input.
    /// - Parameters:
    ///   - featureForm: The feature form containing the input.
    ///   - element: The input's parent element.
    ///   - input: The input configuration of the view.
    init(featureForm: FeatureForm?, element: FieldFormElement, input: TextBoxFormInput) {
        self.featureForm = featureForm
        self.element = element
        self.input = input
        
        _inputModel = StateObject(
            wrappedValue: FormInputModel(fieldFormElement: element)
        )
    }
    
    var body: some View {
        InputHeader(element: element)
            .padding([.top], elementPadding)
        // Secondary foreground color is used across input views for consistency.
        HStack {
            TextField(element.label, text: $text, prompt: Text(element.hint).foregroundColor(.secondary))
                .keyboardType(keyboardType)
                .focused($isFocused)
                .disabled(!inputModel.isEditable)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        if UIDevice.current.userInterfaceIdiom == .phone, isFocused, fieldType.isNumeric {
                            positiveNegativeButton
                            Spacer()
                        }
                    }
                }
                .accessibilityIdentifier("\(element.label) Text Field")
            if !text.isEmpty && inputModel.isEditable {
                ClearButton { text.removeAll() }
                    .accessibilityIdentifier("\(element.label) Clear Button")
            }
        }
        .formInputStyle()
        TextInputFooter(
            text: text,
            isFocused: isFocused,
            element: element,
            input: input,
            rangeDomain: rangeDomain,
            fieldType: fieldType
        )
        .padding([.bottom], elementPadding)
        .onAppear {
            text = element.value
        }
        .onChange(of: isFocused) { newFocus in
            if newFocus {
                model.focusedFieldName = element.fieldName
            }
        }
        .onChange(of: text) { newValue in
            guard newValue != inputModel.value else {
                return
            }
            
            // Note: this will be replaced by `element.updateValue()`, which will
            // handle all the following logic internally.
            if fieldType.isFloatingPoint {
                // Note: this should handle other decimal types as well, if they exist (float?)
                let value = Double(newValue)
                featureForm?.feature.setAttributeValue(value, forKey: element.fieldName)
            } else if fieldType.isNumeric {
                // Note: this should handle more than just Int32
                let value = Int32(newValue)
                featureForm?.feature.setAttributeValue(value, forKey: element.fieldName)
            } else {
                // Text field
                featureForm?.feature.setAttributeValue(newValue, forKey: element.fieldName)
            }
            model.evaluateExpressions()
        }
        .onChange(of: inputModel.value) { newValue in
            text = newValue
        }
    }
}

private extension SingleLineTextInput {
    /// The field type of the text input.
    var fieldType: FieldType {
        featureForm!.feature.table!.field(named: element.fieldName)!.type!
    }
    
    /// The keyboard type to use depending on where the input is numeric and decimal.
    var keyboardType: UIKeyboardType {
        fieldType.isNumeric ? (fieldType.isFloatingPoint ? .decimalPad : .numberPad) : .default
    }
    
    /// The button that allows a user to switch the numeric value between positive and negative.
    var positiveNegativeButton: some View {
        Button {
            if let value = Int(text) {
                text = String(value * -1)
            } else if let value = Float(text) {
                text = String(value * -1)
            } else if let value = Double(text) {
                text = String(value * -1)
            }
        } label: {
            Image(systemName: "plus.forwardslash.minus")
        }
    }
    
    /// The range of valid values for a numeric input field.
    var rangeDomain: RangeDomain? {
        if let field = featureForm?.feature.table?.field(named: element.fieldName) {
            return field.domain as? RangeDomain
        } else {
            return nil
        }
        .onChange(of: model.lastScroll) { _ in
            if isFocused { isFocused = false }
        }
    }
}
