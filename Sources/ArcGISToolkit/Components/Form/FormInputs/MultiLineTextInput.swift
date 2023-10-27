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

/// A view for text input spanning multiple lines.
struct MultiLineTextInput: View {
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
    /// - Note: As of Swift 5.9, SwiftUI text editors do not have built-in placeholder functionality
    /// so it must be implemented manually.
    @State private var isPlaceholder = false
    
    /// The input's parent element.
    private let element: FieldFormElement
    
    /// The input configuration of the view.
    private let input: TextAreaFormInput
    
    /// Creates a view for text input spanning multiple lines.
    /// - Parameters:
    ///   - element: The input's parent element.
    init(element: FieldFormElement) {
        precondition(
            element.input is TextAreaFormInput,
            "\(Self.self).\(#function) element's input must be \(TextAreaFormInput.self)."
        )
        
        self.element =  element
        self.input = element.input as! TextAreaFormInput
        
        _inputModel = StateObject(
            wrappedValue: FormInputModel(fieldFormElement: element)
        )
    }
    
    var body: some View {
        InputHeader(label: element.label, isRequired: inputModel.isRequired)
            .padding([.top], elementPadding)
        HStack(alignment: .bottom) {
            if #available(iOS 16.0, *) {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .disabled(!inputModel.isEditable)
            } else {
                TextEditor(text: $text)
                    .disabled(!inputModel.isEditable)
            }
            if isFocused && !text.isEmpty && inputModel.isEditable {
                ClearButton { text.removeAll() }
            }
        }
        .background(.clear)
        .focused($isFocused)
        .foregroundColor(isPlaceholder ? .secondary : .primary)
        .frame(minHeight: 75, maxHeight: 150)
        .onChange(of: isFocused) { isFocused in
            if isFocused && isPlaceholder {
                isPlaceholder = false
                text = ""
            } else if !isFocused && text.isEmpty {
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
        .formInputStyle()
        TextInputFooter(
            text: isPlaceholder ? "" : text,
            isFocused: isFocused,
            element: element,
            input: input,
            fieldType: fieldType
        )
        .padding([.bottom], elementPadding)
        .onAppear {
            let text = inputModel.formattedValue
            isPlaceholder = text.isEmpty
            self.text = isPlaceholder ? element.hint : text
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
        .onChange(of: inputModel.formattedValue) { formattedValue in
            let text = formattedValue
            isPlaceholder = text.isEmpty
            self.text = isPlaceholder ? element.hint : text
        }
    }
}

private extension MultiLineTextInput {
    /// The field type of the text input.
    var fieldType: FieldType {
        model.featureForm!.feature.table!.field(named: element.fieldName)!.type!
    }
}
