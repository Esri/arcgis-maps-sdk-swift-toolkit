// Copyright 2025 Esri
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

/// A view for multi-line text input.
struct TextAreaFormInputView: View {
    /// The view model for the form.
    @Environment(EmbeddedFeatureFormViewModel.self) private var embeddedFeatureFormViewModel
    
    /// A Boolean value indicating whether or not the expanded field is focused.
    @FocusState private var expandedEditorIsFocused: Bool
    /// A Boolean value indicating whether or not the inline field is focused.
    @FocusState private var inlineEditorIsFocused: Bool
    
    @ScaledMetric private var idealHeight = 100
    
    /// A Boolean value indicating whether the full screen text input is presented.
    @State private var fullScreenTextInputIsPresented = false
    /// The element's current value.
    @State private var text = ""
    
    let element: FieldFormElement
    
    init(element: FieldFormElement) {
        precondition(
            element.input is TextAreaFormInput,
            "\(Self.self).\(#function) element's input must be \(TextAreaFormInput.self)."
        )
        self.element = element
    }
    
    var body: some View {
        TextEditor(text: $text)
            .focused($inlineEditorIsFocused)
            .formInputStyle(isTappable: true)
            // Ideally we'd specify a line limit but the line limit modifier
            // does not currently work with the text editor (FB19423738) so we
            // use a scaled ideal height instead.
            .frame(idealHeight: idealHeight)
            .onChange(of: text) {
                guard text != element.formattedValue else { return }
                element.convertAndUpdateValue(text)
                embeddedFeatureFormViewModel.evaluateExpressions()
            }
            .onValueChange(of: element) { _, newFormattedValue in
                guard text != newFormattedValue else { return }
                text = newFormattedValue
            }
            .scrollContentBackground(.hidden)
            .sheet(isPresented: $fullScreenTextInputIsPresented) {
                TextEditor(text: $text)
                    .focused($expandedEditorIsFocused)
                    .padding()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if inlineEditorIsFocused {
                        Button {
                            fullScreenTextInputIsPresented = true
                            inlineEditorIsFocused = false
                        } label: {
                            Label("", systemImage: "rectangle.expand.diagonal")
                        }
                        Spacer()
                    }
                }
            }
    }
}
