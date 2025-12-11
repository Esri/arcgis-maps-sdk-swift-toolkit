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
    /// The view model for the embedded feature form.
    @Environment(EmbeddedFeatureFormViewModel.self) private var embeddedFeatureFormViewModel
    /// The view model for the feature form.
    @Environment(FeatureFormViewModel.self) private var featureFormViewModel
    
    /// A Boolean value indicating whether or not the field is focused.
    @FocusState private var isFocused: Bool
    
    /// Performs camera authorization request handling.
    @State private var cameraRequester = CameraRequester()
    
    /// A Boolean value indicating whether the full screen text input is presented.
    @State private var fullScreenTextInputIsPresented = false
    
    /// A Boolean value indicating whether the code scanner is presented.
    @State private var scannerIsPresented = false
    
    /// The element's current value.
    ///
    /// - Note: A string is used, irrespective of the element's field type, in order to take advantage of the
    /// feature form's validation system. If the user enters an alphanumeric value into a numeric field, it
    /// triggers a validation error that is shown in the UI. If a type respective of the field type is used
    /// instead, when the user enters an alphanumeric string into a numeric field, the bound value is not
    /// updated and the opportunity to present a validation error to the user is lost. Additionally, if the user
    /// gives focus to another field, the bad value they've entered is lost, creating a potentially frustrating
    /// user experience. The string approach affords the user the opportunity to return the input and resolve
    /// the validation error.
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
            .onChange(of: text) {
                guard text != element.formattedValue else { return }
                element.convertAndUpdateValue(text)
                embeddedFeatureFormViewModel.evaluateExpressions()
            }
#if !os(visionOS)
            .sheet(isPresented: $scannerIsPresented) {
                CodeScanner(code: $text, isPresented: $scannerIsPresented)
            }
#endif
            .onValueChange(of: element) { _, newFormattedValue in
                guard text != newFormattedValue else { return }
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
                            FullScreenTextInput(text: $text, element: element, embeddedFeatureFormViewModel: embeddedFeatureFormViewModel)
                                .padding()
#if targetEnvironment(macCatalyst)
                                .environment(embeddedFeatureFormViewModel)
                                .environment(featureFormViewModel)
#endif
                        }
                        .frame(minHeight: 100, alignment: .top)
                        .contentShape(.rect)
                        .onTapGesture {
                            if element.isMultiline {
                                fullScreenTextInputIsPresented = true
                            }
                        }
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
                    .hoverEffectDisabled()
#endif
                    .onChange(of: isFocused) {
                        embeddedFeatureFormViewModel.focusedElement = isFocused ? element : nil
                    }
                    .onChange(of: embeddedFeatureFormViewModel.focusedElement) {
                        // Another form input took focus.
                        if embeddedFeatureFormViewModel.focusedElement != element {
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
                        embeddedFeatureFormViewModel.focusedElement = element
                        embeddedFeatureFormViewModel.focusedElement = nil
                    }
                    text.removeAll()
                }
                .accessibilityIdentifier("\(element.label) Clear Button")
            }
#if !os(visionOS)
            if isBarcodeScanner {
                Button {
                    embeddedFeatureFormViewModel.focusedElement = element
                    if cameraRequester.authorizationStatus == .authorized {
                        scannerIsPresented = true
                    } else {
                        cameraRequester.request()
                    }
                } label: {
                    Image(systemName: "barcode.viewfinder")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                }
                .disabled(cameraIsDisabled)
                .buttonStyle(.plain)
                .accessibilityIdentifier("\(element.label) Scan Button")
                .cameraRequester(cameraRequester)
                .onChange(of: cameraRequester.authorizationStatus) { _, newValue in
                    if newValue == .authorized {
                        scannerIsPresented = true
                    }
                }
            }
#endif
        }
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
        .inspectorTint(.blue)
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
        let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
        
        var body: some View {
            HStack {
                FormElementHeader(element: element)
                Button.done {
                    dismiss()
                }
#if !os(visionOS)
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
#endif
            }
            TextEditor(text: $text)
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }
                .onChange(of: isFocused) {
                    embeddedFeatureFormViewModel.focusedElement = isFocused ? element : nil
                }
                .scrollContentBackground(.hidden)
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
