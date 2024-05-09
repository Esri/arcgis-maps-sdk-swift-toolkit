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
                text = formattedValue
            }
    }
}

private extension TextInput {
    /// The body of the text input when the element is editable.
    var textWriter: some View {
        HStack(alignment: .bottom) {
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
        
        var body: some View {
            HStack {
                InputHeader(element: element)
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            LegacyTextView(text: $text)
            .focused($textFieldIsFocused, equals: true)
            .onAppear {
                textFieldIsFocused = true
            }
            Spacer()
//            InputFooter(element: element)
        }
    }
}

struct LegacyTextView: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let uiTextView = UITextView()
        uiTextView.delegate = context.coordinator
        return uiTextView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        var text: Binding<String>
        
        init(text: Binding<String>) {
            self.text = text
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
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
