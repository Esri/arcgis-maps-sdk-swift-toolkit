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
@MainActor
struct TextInput: View {
    /// The view model for the form.
    @EnvironmentObject var model: FormViewModel
    
    /// A Boolean value indicating whether or not the field is focused.
    @FocusState private var isFocused: Bool
    
    /// A Boolean value indicating whether the full screen text input is presented.
    @State private var fullScreenTextInputIsPresented = false
    
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
            .onChange(isFocused) { isFocused in
                if isFocused {
                    model.focusedElement = element
                } else if model.focusedElement == element {
                    model.focusedElement = nil
                }
            }
            .onChange(model.focusedElement) { focusedElement in
                // Another form input took focus
                if focusedElement != element {
                    isFocused  = false
                }
            }
            .onChange(text) { text in
                element.convertAndUpdateValue(text)
                model.evaluateExpressions()
            }
            .onTapGesture {
                if element.isMultiline {
                    fullScreenTextInputIsPresented = true
                    model.focusedElement = element
                }
            }
            .onValueChange(of: element, when: !element.isMultiline || !fullScreenTextInputIsPresented) { _, newFormattedValue in
                text = newFormattedValue
            }
    }
}

private extension TextInput {
    /// The body of the text input when the element is editable.
    var textWriter: some View {
        HStack(alignment: .bottom) {
            Group {
                if element.isMultiline {
                    Text(text)
                        .accessibilityIdentifier("\(element.label) Text Input Preview")
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(10)
                        .truncationMode(.tail)
                        .sheet(isPresented: $fullScreenTextInputIsPresented) {
                            FullScreenTextInput(text: $text, element: element, model: model)
                                .padding()
#if targetEnvironment(macCatalyst)
                                .environmentObject(model)
#endif
                        }
                } else {
                    TextField(
                        element.label,
                        text: $text,
                        prompt: Text(element.hint).foregroundColor(.secondary),
                        axis: .horizontal
                    )
                    .accessibilityIdentifier("\(element.label) Text Input")
                    .keyboardType(keyboardType)
                }
            }
            .focused($isFocused)
            .frame(maxWidth: .infinity, alignment: .leading)
#if !os(visionOS)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if UIDevice.current.userInterfaceIdiom == .phone, isFocused, (element.fieldType?.isNumeric ?? false) {
                        positiveNegativeButton
                        Spacer()
                    }
                }
            }
#endif
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
        
        if fieldType.isNumeric {
#if os(visionOS)
            // The 'positiveNegativeButton' doesn't show on visionOS
            // so we need to show this keyboard so the user can type
            // a negative number.
            return .numbersAndPunctuation
#else
            if fieldType.isFloatingPoint {
                return .decimalPad
            } else {
                return .numberPad
            }
#endif
        } else {
            return .default
        }
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
        
        /// The view model for the form.
        let model: FormViewModel
        
        var body: some View {
            HStack {
                InputHeader(element: element)
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            RepresentedUITextView(initialText: text) { text in
                element.convertAndUpdateValue(text)
                model.evaluateExpressions()
            } onTextViewDidEndEditing: { text in
                self.text = text
            }
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

private extension View {
    /// Wraps `onValueChange(of:action:)` with an additional boolean property that when false will
    /// not monitor value changes.
    /// - Parameters:
    ///   - element: The form element to watch for changes on.
    ///   - when: The boolean value which disables monitoring. When `true` changes will be monitored.
    ///   - action: The action which watches for changes.
    /// - Returns: The modified view.
    func onValueChange(of element: FieldFormElement, when: Bool, action: @escaping (_ newValue: Any?, _ newFormattedValue: String) -> Void) -> some View {
        modifier(
            ConditionalChangeOfModifier(element: element, condition: when) { newValue, newFormattedValue in
                action(newValue, newFormattedValue)
            }
        )
    }
}

private struct ConditionalChangeOfModifier: ViewModifier {
    let element: FieldFormElement
    
    let condition: Bool
    
    let action: (_ newValue: Any?, _ newFormattedValue: String) -> Void
    
    func body(content: Content) -> some View {
        if condition {
            content
                .onValueChange(of: element) { newValue, newFormattedValue in
                    action(newValue, newFormattedValue)
                }
        } else {
            content
        }
    }
}
