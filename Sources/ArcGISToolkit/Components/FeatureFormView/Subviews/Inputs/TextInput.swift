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
    @Environment(InternalFeatureFormViewModel.self) private var internalFeatureFormViewModel
    
    /// A Boolean value indicating whether or not the field is focused.
    @FocusState private var isFocused: Bool
    
    /// A Boolean value indicating whether the full screen text input is presented.
    @State private var fullScreenTextInputIsPresented = false
    
    /// A Boolean value indicating whether the code scanner is presented.
    @State private var scannerIsPresented = false
    
    /// The element's current value.
    @State private var value: Any?
    
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
    
    /// Creates a view for text based input.
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
            .onTapGesture {
                if element.isMultiline {
                    fullScreenTextInputIsPresented = true
                }
            }
#if !os(visionOS)
            .sheet(isPresented: $scannerIsPresented) {
                CodeScanner(code: valueAsDynamicType, isPresented: $scannerIsPresented)
            }
#endif
            .onValueChange(of: element, when: !element.isMultiline || !fullScreenTextInputIsPresented) { newValue, _ in
                value = newValue
            }
    }
}

private extension Formatter {
    /// A number formatter which applies the decimal number style.
    static var decimal: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }
}

private extension TextInput {
    func updateValueAndEvaluateExpressions<V>(_ newValue: V?) where V: Equatable, V: Sendable {
        guard newValue != element.value as? V else { return }
        element.updateValue(newValue)
        internalFeatureFormViewModel.evaluateExpressions()
    }
    
    /// The body of the text input when the element is editable.
    var textWriter: some View {
        HStack(alignment: .firstTextBaseline) {
            Group {
                if element.isMultiline {
                    Text(valueAsString.wrappedValue)
                        .accessibilityIdentifier("\(element.label) Text Input Preview")
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(5)
                        .truncationMode(.tail)
                        .sheet(isPresented: $fullScreenTextInputIsPresented) {
                            FullScreenTextInput(
                                text: valueAsString,
                                element: element,
                                internalFeatureFormViewModel: internalFeatureFormViewModel
                            )
                            .padding()
#if targetEnvironment(macCatalyst)
                            .environment(internalFeatureFormViewModel)
#endif
                        }
                        .frame(minHeight: 100, alignment: .top)
                } else {
                    textField
                        .accessibilityIdentifier("\(element.label) Text Input")
                        .focused($isFocused)
                        .keyboardType(keyboardType)
#if os(visionOS)
                    // No need for hover effect since it will be applied
                    // properly at 'formInputStyle'.
                        .hoverEffectDisabled()
#endif
                        .onChange(of: isFocused) {
                            internalFeatureFormViewModel.focusedElement = isFocused ? element : nil
                        }
                        .onChange(of: internalFeatureFormViewModel.focusedElement) {
                            // Another form input took focus.
                            if internalFeatureFormViewModel.focusedElement != element {
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
            if value != nil,
               !isBarcodeScanner,
               !element.isMultiline {
                XButton(.clear) {
                    if !isFocused {
                        // If the user wasn't already editing the field provide
                        // instantaneous focus to enable validation.
                        internalFeatureFormViewModel.focusedElement = element
                        internalFeatureFormViewModel.focusedElement = nil
                    }
                    element.updateValue(nil)
                    internalFeatureFormViewModel.evaluateExpressions()
                }
                .accessibilityIdentifier("\(element.label) Clear Button")
            }
#if !os(visionOS)
            if isBarcodeScanner {
                Button {
                    internalFeatureFormViewModel.focusedElement = element
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
            switch value {
            case var value as Float16:
                updateValueAndEvaluateExpressions(value * -1)
            case var value as Float32:
                updateValueAndEvaluateExpressions(value * -1)
            case var value as Int16:
                updateValueAndEvaluateExpressions(value * -1)
            case var value as Int32:
                updateValueAndEvaluateExpressions(value * -1)
            case var value as Int64:
                updateValueAndEvaluateExpressions(value * -1)
            default:
                break
            }
        } label: {
            Image(systemName: "plus.forwardslash.minus")
        }
    }
    
    /// The text field to edit the element's value.
    @ViewBuilder
    var textField: some View {
        switch element.fieldType {
        case .float32:
            TextField(
                element.label,
                value: Binding { element.value as? Float32 } set: { updateValueAndEvaluateExpressions($0) },
                formatter: .decimal,
                prompt: textFieldPrompt
            )
            .keyboardType(.decimalPad)
        case .float64:
            TextField(
                element.label,
                value: Binding { element.value as? Float64 } set: { updateValueAndEvaluateExpressions($0) },
                formatter: .decimal,
                prompt: textFieldPrompt
            )
            .keyboardType(.decimalPad)
        case .int16:
            TextField(
                element.label,
                value: Binding { element.value as? Int16 } set: { updateValueAndEvaluateExpressions($0) },
                formatter: .decimal,
                prompt: textFieldPrompt
            )
            .keyboardType(.numberPad)
        case .int32:
            TextField(
                element.label,
                value: Binding { element.value as? Int32 } set: { updateValueAndEvaluateExpressions($0) },
                formatter: .decimal,
                prompt: textFieldPrompt
            )
            .keyboardType(.numberPad)
        case .int64:
            TextField(
                element.label,
                value: Binding { element.value as? Int64 } set: { updateValueAndEvaluateExpressions($0) },
                formatter: .decimal,
                prompt: textFieldPrompt
            )
            .keyboardType(.numberPad)
        default:
            TextField(
                element.label,
                text: Binding { element.value as? String ?? element.formattedValue } set: { updateValueAndEvaluateExpressions($0) },
                prompt: textFieldPrompt,
                axis: .horizontal
            )
        }
    }
    
    /// The common prompt used across the various forms of the text field.
    var textFieldPrompt: Text {
        Text(element.input is BarcodeScannerFormInput ? String.noValue : element.hint)
            .foregroundColor(.secondary)
    }
    
    /// A binding which gets the element's value as a string and sets the value according to the element's
    /// field type.
    var valueAsDynamicType: Binding<String> {
        .init {
            valueAsString.wrappedValue
        } set: {
            switch element.fieldType {
            case .float32:
                updateValueAndEvaluateExpressions(Float32($0))
            case .float64:
                updateValueAndEvaluateExpressions(Float64($0))
            case .int16:
                updateValueAndEvaluateExpressions(Int16($0))
            case .int32:
                updateValueAndEvaluateExpressions(Int32($0))
            case .int64:
                updateValueAndEvaluateExpressions(Int64($0))
            default:
                updateValueAndEvaluateExpressions($0)
            }
        }
    }
    
    /// A binding which gets and sets the element's value as a string.
    var valueAsString: Binding<String> {
        Binding {
            value as? String ?? element.formattedValue
        } set: { newValue in
            updateValueAndEvaluateExpressions(newValue)
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
        let internalFeatureFormViewModel: InternalFeatureFormViewModel
        
        var body: some View {
            HStack {
                FormElementHeader(element: element)
                Button("Done") {
                    dismiss()
                }
#if !os(visionOS)
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
#endif
            }
            RepresentedUITextView(initialText: text) { text in
                self.text = text
            } onTextViewDidEndEditing: { text in
                self.text = text
            }
            .focused($isFocused)
            .onAppear {
                isFocused = true
            }
            .onChange(of: isFocused) {
                internalFeatureFormViewModel.focusedElement = isFocused ? element : nil
            }
            Spacer()
            FormElementFooter(element: element)
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
