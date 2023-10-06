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
    
    /// The input's parent element.
    private let element: FieldFormElement
    
    /// The input configuration of the view.
    private let input: TextBoxFormInput
    
    /// The model for the input.
    @StateObject var inputModel: FormInputModel
    
    /// Creates a view for single line text input.
    /// - Parameters:
    ///   - featureForm: The feature form containing the input.
    ///   - element: The input's parent element.
    ///   - input: The input configuration of the view.
    init(featureForm: FeatureForm?, element: FieldFormElement, input: TextBoxFormInput) {
        self.featureForm = featureForm
        self.element = element
        self.input = input
        
        _inputModel = StateObject(
            wrappedValue: FormInputModel(fieldFormElement: element)
        )
    }
    
    var body: some View {
        Group {
            InputHeader(label: element.label, isRequired: inputModel.isRequired)
                .padding([.top], elementPadding)
            // Secondary foreground color is used across input views for consistency.
            HStack {
                TextField(element.label, text: $text, prompt: Text(element.hint).foregroundColor(.secondary))
                    .focused($isFocused)
                    .accessibilityIdentifier("\(element.label) Text Field")
                    .disabled(!inputModel.isEditable)
                if !text.isEmpty && inputModel.isEditable {
                    ClearButton { text.removeAll() }
                        .accessibilityIdentifier("\(element.label) Clear Button")
                }
            }
            .formTextInputStyle()
            TextInputFooter(
                currentLength: text.count,
                isFocused: isFocused,
                element: element,
                input: input,
                isRequired: inputModel.isRequired
            )
            .padding([.bottom], elementPadding)
        }
        .onAppear {
            text = element.value
        }
        .onChange(of: isFocused) { newFocus in
            if newFocus {
                model.focusedFieldName = element.fieldName
            }
        }
        .onChange(of: text) { newValue in
            guard newValue != inputModel.value else {
                return
            }
            
            featureForm?.feature.setAttributeValue(newValue, forKey: element.fieldName)
            model.evaluateExpressions()
        }
        .onChange(of: inputModel.value) { newValue in
            text = newValue
        }
    }
}
