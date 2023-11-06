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

/// A view for text input.
struct TextInput: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The model for the ancestral form view.
    @EnvironmentObject var model: FormViewModel
    
    /// The model for the input.
    @StateObject var inputModel: FormInputModel
    
    /// A Boolean value indicating whether or not the field is focused.
    @FocusState private var isFocused: Bool
    
    /// The current text value.
    @State private var text = ""
    
    /// A Boolean value indicating whether placeholder text is shown, thereby indicating the
    /// presence of a value.
    ///
    /// If iOS 16.0 minimum APIs are not supported we use a TextField for single line entry and a
    /// TextEditor for multiline entry. TextEditors don't have placeholder support so instead we
    /// replace empty text with the configured placeholder message and adjust the font
    /// color.
    ///
    /// Once iOS 16.0 is the minimum supported platform this property can be removed.
    @State private var isPlaceholder = false
    
    /// The input's parent element.
    private let element: FieldFormElement
    
    /// Creates a view for text input spanning multiple lines.
    /// - Parameters:
    ///   - element: The input's parent element.
    init(element: FieldFormElement) {
        precondition(
            element.input is TextAreaFormInput || element.input is TextBoxFormInput,
            "\(Self.self).\(#function) element's input must be \(TextAreaFormInput.self) or \(TextBoxFormInput.self)."
        )
        self.element = element
        _inputModel = StateObject(
            wrappedValue: FormInputModel(fieldFormElement: element)
        )
    }
    
    var body: some View {
        InputHeader(label: element.label, isRequired: inputModel.isRequired)
            .padding([.top], elementPadding)
        if inputModel.isEditable {
            textField
        } else {
            Text(text.isEmpty ? "--" : text)
                .padding([.horizontal], 10)
                .padding([.vertical], 5)
        }
        TextInputFooter(
            text: isPlaceholder ? "" : text,
            isFocused: isFocused,
            element: element,
            fieldType: fieldType
        )
        .padding([.bottom], elementPadding)
        .onAppear {
            let text = inputModel.formattedValue
            isPlaceholder = text.isEmpty && !iOS16MinimumIsSupported
            self.text = isPlaceholder ? element.hint : text
        }
        .onChange(of: inputModel.formattedValue) { formattedValue in
            let text = formattedValue
            isPlaceholder = text.isEmpty && !iOS16MinimumIsSupported
            self.text = isPlaceholder ? element.hint : text
        }
        .onChange(of: isFocused) { isFocused in
            if isFocused && isPlaceholder {
                isPlaceholder = false
                text = ""
            } else if !isFocused && text.isEmpty && !iOS16MinimumIsSupported {
                isPlaceholder = true
                text = element.hint
            }
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
        .onChange(of: text) { text in
            guard !isPlaceholder else { return }
            do {
                try element.updateValue(text)
            } catch {
                print(error.localizedDescription)
            }
            model.evaluateExpressions()
        }
    }
}

private extension TextInput {
    /// A Boolean value indicating whether iOS 16.0 minimum APIs are supported.
    var iOS16MinimumIsSupported: Bool {
        if #available(iOS 16.0, *) {
            return true
        } else {
            return false
        }
    }
    
    /// The field type of the text input.
    var fieldType: FieldType {
        model.featureForm!.feature.table!.field(named: element.fieldName)!.type!
    }
    
    /// The body of the text input when the element is editable.
    var textField: some View {
        HStack(alignment: .bottom) {
            Group {
                if #available(iOS 16.0, *) {
                        TextField(
                            element.label,
                            text: $text,
                            prompt: Text(element.hint).foregroundColor(.secondary),
                            axis: isMultiline ? .vertical : .horizontal
                        )
                } else if isMultiline {
                    TextEditor(text: $text)
                        .foregroundColor(isPlaceholder ? .secondary : .primary)
                } else {
                    TextField(
                        element.label,
                        text: $text,
                        prompt: Text(element.hint).foregroundColor(.secondary)
                    )
                }
            }
            .accessibilityIdentifier("\(element.label) Text Input")
            .background(.clear)
            .focused($isFocused)
            .keyboardType(keyboardType)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if UIDevice.current.userInterfaceIdiom == .phone, isFocused, fieldType.isNumeric {
                        positiveNegativeButton
                        Spacer()
                    }
                }
            }
            .scrollContentBackgroundHidden()
            if isFocused && !text.isEmpty && inputModel.isEditable {
                ClearButton { text.removeAll() }
                    .accessibilityIdentifier("\(element.label) Clear Button")
            }
        }
        .formInputStyle()
    }
    
    /// A Boolean value indicating whether the input is multiline or not.
    var isMultiline: Bool {
        element.input is TextAreaFormInput
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
}

private extension View {
    /// - Returns: A view with the scroll content background hidden.
    func scrollContentBackgroundHidden() -> some View {
        if #available(iOS 16.0, *) {
            return self
                .scrollContentBackground(.hidden)
        } else {
            return self
        }
    }
}
