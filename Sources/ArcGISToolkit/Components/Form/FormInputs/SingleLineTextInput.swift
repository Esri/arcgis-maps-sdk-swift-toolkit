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
    
    /// The model for the ancestral form view.
    @EnvironmentObject var model: FormViewModel
    
    /// The model for the input.
    @StateObject var inputModel: FormInputModel
    
    /// A Boolean value indicating whether or not the field is focused.
    @FocusState private var isFocused: Bool
    
    /// The current text value.
    @State private var text = ""
    
    /// The input's parent element.
    private let element: FieldFormElement
    
    /// The input configuration of the view.
    private let input: TextBoxFormInput
    
    /// Creates a view for single line text input.
    /// - Parameters:
    ///   - element: The input's parent element.
    init(element: FieldFormElement) {
        precondition(
            element.input is TextBoxFormInput,
            "\(Self.self).\(#function) element's input must be \(TextBoxFormInput.self)."
        )
        
        self.element = element
        self.input = element.input as! TextBoxFormInput
        
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
        .onChange(of: isFocused) { isFocused in
            if isFocused {
                model.focusedElement = element
            } else if model.focusedElement == element {
                model.focusedElement = nil
            }
        }
        .onChange(of: model.focusedElement) { focusedElement in
            // Another form input took focus
            if focusedElement != element {
                isFocused  = false
            }
        }
        .onAppear {
            text = inputModel.formattedValue
        }
        .onChange(of: text) { text in
            do {
                try element.updateValue(text)
            } catch {
                print(error.localizedDescription)
            }
            model.evaluateExpressions()
        }
        .onChange(of: inputModel.formattedValue) { formattedValue in
            self.text = formattedValue
        }
    }
}

private extension SingleLineTextInput {
    /// The field type of the text input.
    var fieldType: FieldType {
        model.featureForm!.feature.table!.field(named: element.fieldName)!.type!
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
        if let field = model.featureForm?.feature.table?.field(named: element.fieldName) {
            return field.domain as? RangeDomain
        } else {
            return nil
        }
    }
}
