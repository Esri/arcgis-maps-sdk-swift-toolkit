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
    
    /// The field's parent element.
    private let element: FieldFormElement
    
    /// The input configuration of the field.
    private let input: TextBoxFormInput
    
    /// Creates a view for single line text input.
    /// - Parameters:
    ///   - featureForm: The feature form containing the input.
    ///   - element: The field's parent element.
    ///   - input: The input configuration of the field.
    init(featureForm: FeatureForm?, element: FieldFormElement, input: TextBoxFormInput) {
        self.featureForm = featureForm
        self.element = element
        self.input = input
    }
    
    var body: some View {
        FormElementHeader(element: element)
            .padding([.top], elementPadding)
        // Secondary foreground color is used across input views for consistency.
        HStack {
            TextField(element.label, text: $text, prompt: Text(element.hint).foregroundColor(.secondary))
                .keyboardType(keyboardType)
                .focused($isFocused)
                .accessibilityIdentifier("\(element.label) Text Field")
            if !text.isEmpty {
                ClearButton { text.removeAll() }
                    .accessibilityIdentifier("\(element.label) Clear Button")
            }
        }
        .formTextInputStyle()
        TextInputFooter(
            text: text,
            isFocused: isFocused,
            element: element,
            input: input,
            rangeDomain: rangeDomain,
            isNumeric: isNumeric
        )
        .padding([.bottom], elementPadding)
        .onAppear {
            text = featureForm?.feature.attributes[element.fieldName] as? String ?? ""
        }
        .onChange(of: isFocused) { newFocus in
            if newFocus {
                model.focusedFieldName = element.fieldName
            }
        }
        .onChange(of: text) { newValue in
            // Note: this will be replaced by `element.updateValue()`, which will
            // handle all the following logic internally.
            if isDecimal {
                // Note: this should handle other decimal types as well, if they exist (float?)
                let value = Double(newValue)
                featureForm?.feature.setAttributeValue(value, forKey: element.fieldName)
            } else if isNumeric {
                // Note: this should handle more than just Int32
                let value = Int32(newValue)
                featureForm?.feature.setAttributeValue(value, forKey: element.fieldName)
            } else {
                // Text field
                featureForm?.feature.setAttributeValue(newValue, forKey: element.fieldName)
            }
        }
    }
}

private extension SingleLineTextInput {
    /// A Boolean value indicating whether the input is for a numeric data type.
    var isNumeric: Bool {
        if let field = featureForm?.feature.table?.field(named: element.fieldName)?.type {
            return field.isNumeric
        }
        return false
    }
    
    /// A Boolean value indicating whether the field has a numeric data type with decimal precision.
    var isDecimal: Bool {
        if let field = featureForm?.feature.table?.field(named: element.fieldName)?.type {
            return field.isFloatingPoint
        }
        return false
    }
    
    /// The keyboard type to use depending on where the input is numeric and decimal.
    var keyboardType: UIKeyboardType {
        isNumeric ? (isDecimal ? .decimalPad : .numberPad) : .default
    }
    
    /// The range of valid values for a numeric input field.
    var rangeDomain: RangeDomain? {
        if let field = featureForm?.feature.table?.field(named: element.fieldName) {
            return field.domain as? RangeDomain
        } else {
            return nil
        }
    }
}

private extension FieldType {
    /// A Boolean value indicating whether the field has a numeric data type.
    var isNumeric: Bool {
        self == .float32 || self == .float64 || self == .int16 || self == .int32 || self == .int64
    }
    
    /// A Boolean value indicating whether the field has a floating point data type.
    var isFloatingPoint: Bool {
        self == .float32 || self == .float64
    }
}
