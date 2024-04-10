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

/// A view for text input.
struct TextInput: View {
    /// The view model for the form.
    @EnvironmentObject var model: FormViewModel
    
    /// A Boolean value indicating whether or not the field is focused.
    @FocusState private var isFocused: Bool
    
    /// The formatted version of the element's current value.
    @State private var formattedValue = ""
    
    /// A Boolean value indicating whether the full screen text input is presented.
    @State private var fullScreenTextInputIsPresented = false
    
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
    
    /// The current text value.
    @State private var text = ""
    
    /// The element the input belongs to.
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
    }
    
    var body: some View {
        textWriter
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
                element.convertAndUpdateValue(text)
                model.evaluateExpressions()
            }
            .onTapGesture {
                if element.isMultiline {
                    fullScreenTextInputIsPresented = true
                    model.focusedElement = element
                }
            }
            .onValueChange(of: element) { newValue, newFormattedValue in
                formattedValue = newFormattedValue
                updateText()
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
    
    /// The body of the text input when the element is editable.
    var textWriter: some View {
        HStack(alignment: .bottom) {
            Group {
                if #available(iOS 16.0, *) {
                    TextField(
                        element.label,
                        text: $text,
                        prompt: Text(element.hint).foregroundColor(.secondary),
                        axis: element.isMultiline ? .vertical : .horizontal
                    )
                    .disabled(element.isMultiline)
                    .sheet(isPresented: $fullScreenTextInputIsPresented) {
                        FullScreenTextInput(text: $text, element: element)
#if targetEnvironment(macCatalyst)
                            .environmentObject(model)
#endif
                            .padding()
                    }
                } else if element.isMultiline {
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
                    if UIDevice.current.userInterfaceIdiom == .phone, isFocused, (element.fieldType?.isNumeric ?? false) {
                        positiveNegativeButton
                        Spacer()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            if !text.isEmpty {
                ClearButton {
                    if !isFocused {
                        // If the user wasn't already editing the field provide
                        // instantaneous focus to enable validation.
                        model.focusedElement = element
                        model.focusedElement = nil
                    }
                    text.removeAll()
                }
                .accessibilityIdentifier("\(element.label) Clear Button")
            }
        }
        .formInputStyle()
    }
    
    /// The keyboard type to use depending on where the input is numeric and decimal.
    var keyboardType: UIKeyboardType {
        guard let fieldType = element.fieldType else { return .default }
        return fieldType.isNumeric ? (fieldType.isFloatingPoint ? .decimalPad : .numberPad) : .default
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
    
    /// Updates ``text`` and ``placeholder`` values in response to
    /// a change in ``formattedValue``.
    private func updateText() {
        let text = formattedValue
        isPlaceholder = text.isEmpty && !iOS16MinimumIsSupported
        self.text = isPlaceholder ? element.hint : text
    }
}

@available(iOS 16.0, *)
private extension TextInput {
    /// A view for displaying a multiline text input outside the body of the feature form view.
    ///
    /// By moving outside of the feature form view's scroll view we let the text field naturally manage
    /// keeping the input caret visible.
    struct FullScreenTextInput: View {
        /// The current text value.
        @Binding var text: String
        
        /// An action that dismisses the current presentation.
        @Environment(\.dismiss) private var dismiss
        
        /// A Boolean value indicating whether the text field is focused.
        @FocusState private var textFieldIsFocused: Bool
        
        /// The element the input belongs to.
        let element: FieldFormElement
        
        var body: some View {
            HStack {
                InputHeader(element: element)
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            TextField(
                element.label,
                text: $text,
                prompt: Text(element.hint).foregroundColor(.secondary),
                axis: .vertical
            )
            .focused($textFieldIsFocused, equals: true)
            .onAppear {
                textFieldIsFocused = true
            }
            Spacer()
            InputFooter(element: element)
        }
    }
}

private extension FieldFormElement {
    /// Attempts to convert the value to a type suitable for the element's field type and then update
    /// the element with the converted value.
    func convertAndUpdateValue(_ value: String) {
        if fieldType == .text {
            updateValue(value)
        } else if let fieldType {
            if fieldType.isNumeric && value.isEmpty {
                updateValue(nil)
            } else if fieldType == .int16, let value = Int16(value) {
                updateValue(value)
            } else if fieldType == .int32, let value = Int32(value) {
                updateValue(value)
            } else if fieldType == .int64, let value = Int64(value) {
                updateValue(value)
            } else if fieldType == .float32, let value = Float32(value) {
                updateValue(value)
            } else if fieldType == .float64, let value = Float64(value) {
                updateValue(value)
            } else {
                updateValue(value)
            }
        }
    }
}
