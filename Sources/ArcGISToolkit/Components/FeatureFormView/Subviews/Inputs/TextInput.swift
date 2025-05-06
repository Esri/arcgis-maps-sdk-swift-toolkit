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
    @Environment(FormViewModel.self) private var formViewModel: FormViewModel
    
    /// A Boolean value indicating whether or not the field is focused.
    @FocusState private var isFocused: Bool
    
    /// A Boolean value indicating whether the full screen text input is presented.
    @State private var fullScreenTextInputIsPresented = false
    
    /// A Boolean value indicating whether the code scanner is presented.
    @State private var scannerIsPresented = false
    
    /// The current text value.
    @State private var text = ""
    
    /// A Boolean value indicating whether the device camera is accessible for scanning.
    private let cameraIsDisabled: Bool = {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }()
    
    /// The element the input belongs to.
    private let element: FieldFormElement
    
    /// Creates a view for text input spanning multiple lines.
    /// - Parameters:
    ///   - element: The input's parent element.
    init(element: FieldFormElement) {
        precondition(
            element.input is TextAreaFormInput
            || element.input is TextBoxFormInput
            || element.input is BarcodeScannerFormInput,
            "\(Self.self).\(#function) element's input must be \(TextAreaFormInput.self), \(TextBoxFormInput.self) or \(BarcodeScannerFormInput.self)."
        )
        self.element = element
    }
    
    var body: some View {
        textWriter
            .onChange(of: text) {
                element.convertAndUpdateValue(text)
                formViewModel.evaluateExpressions()
            }
            .onTapGesture {
                if element.isMultiline {
                    fullScreenTextInputIsPresented = true
                }
            }
#if !os(visionOS)
            .sheet(isPresented: $scannerIsPresented) {
                CodeScanner(code: $text, isPresented: $scannerIsPresented)
            }
#endif
            .onValueChange(of: element, when: !element.isMultiline || !fullScreenTextInputIsPresented) { _, newFormattedValue in
                text = newFormattedValue
            }
    }
}

private extension TextInput {
    /// The body of the text input when the element is editable.
    var textWriter: some View {
        HStack(alignment: .firstTextBaseline) {
            Group {
                if element.isMultiline {
                    Text(text)
                        .accessibilityIdentifier("\(element.label) Text Input Preview")
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(5)
                        .truncationMode(.tail)
                        .sheet(isPresented: $fullScreenTextInputIsPresented) {
                            FullScreenTextInput(text: $text, element: element, model: formViewModel)
                                .padding()
#if targetEnvironment(macCatalyst)
                                .environment(formViewModel)
#endif
                        }
                        .frame(minHeight: 100, alignment: .top)
                } else {
                    TextField(
                        element.label,
                        text: $text,
                        prompt: Text(element.input is BarcodeScannerFormInput ? String.noValue : element.hint).foregroundColor(.secondary),
                        axis: .horizontal
                    )
                    .accessibilityIdentifier("\(element.label) Text Input")
                    .focused($isFocused)
                    .keyboardType(keyboardType)
#if os(visionOS)
                    // No need for hover effect since it will be applied
                    // properly at 'formInputStyle'.
                    .hoverEffectDisabled()
#endif
                    .onChange(of: isFocused) {
                        formViewModel.focusedElement = isFocused ? element : nil
                    }
                    .onChange(of: formViewModel.focusedElement) {
                        // Another form input took focus.
                        if formViewModel.focusedElement != element {
                            isFocused  = false
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
#if os(iOS)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if UIDevice.current.userInterfaceIdiom == .phone, isFocused, (element.fieldType?.isNumeric ?? false) {
                        // Known SwiftUI issue: This button is known to sometimes not appear. (See Apollo #1159)
                        positiveNegativeButton
                        Spacer()
                    }
                }
            }
#endif
            .scrollContentBackground(.hidden)
            if !text.isEmpty,
               !isBarcodeScanner,
               !element.isMultiline {
                XButton(.clear) {
                    if !isFocused {
                        // If the user wasn't already editing the field provide
                        // instantaneous focus to enable validation.
                        formViewModel.focusedElement = element
                        formViewModel.focusedElement = nil
                    }
                    text.removeAll()
                }
                .accessibilityIdentifier("\(element.label) Clear Button")
            }
#if !os(visionOS)
            if isBarcodeScanner {
                Button {
                    formViewModel.focusedElement = element
                    scannerIsPresented = true
                } label: {
                    Image(systemName: "barcode.viewfinder")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                }
                .disabled(cameraIsDisabled)
                .buttonStyle(.plain)
                .accessibilityIdentifier("\(element.label) Scan Button")
            }
#endif
        }
        .formInputStyle(isTappable: true)
    }
    
    /// The keyboard type to use depending on where the input is numeric and decimal.
    var keyboardType: UIKeyboardType {
        guard let fieldType = element.fieldType else { return .default }
        
        return if fieldType.isNumeric {
#if os(visionOS)
            // The 'positiveNegativeButton' doesn't show on visionOS
            // so we need to show this keyboard so the user can type
            // a negative number.
            .numbersAndPunctuation
#else
            if fieldType.isFloatingPoint { .decimalPad } else { .numberPad }
#endif
        } else {
            .default
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
        @FocusState private var isFocused: Bool
        
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
#if !os(visionOS)
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
#endif
            }
            RepresentedUITextView(initialText: text) { text in
                element.convertAndUpdateValue(text)
                model.evaluateExpressions()
            } onTextViewDidEndEditing: { text in
                self.text = text
            }
            .focused($isFocused)
            .onAppear {
                isFocused = true
            }
            .onChange(of: isFocused) {
                model.focusedElement = isFocused ? element : nil
            }
            Spacer()
            InputFooter(element: element)
        }
    }
}

private extension TextInput {
    private var isBarcodeScanner: Bool {
        element.input is BarcodeScannerFormInput
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
