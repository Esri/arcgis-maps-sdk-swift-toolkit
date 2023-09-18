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

/// A view for text entry spanning multiple lines.
struct MultiLineTextEntry: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The model for the ancestral form view.
    @EnvironmentObject var model: FormViewModel
    
    /// <#Description#>
    private var featureForm: FeatureForm?
    
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
    
    /// The field's parent element.
    private let element: FieldFormElement
    
    /// The input configuration of the field.
    private let input: TextAreaFormInput
    
    /// Creates a view for text entry spanning multiple lines.
    /// - Parameters:
    ///   - featureForm: <#featureForm description#>
    ///   - element: The field's parent element.
    ///   - input: The input configuration of the field.
    init(featureForm: FeatureForm?, element: FieldFormElement, input: TextAreaFormInput) {
        self.featureForm = featureForm
        self.element =  element
        self.input = input
    }
    
    var body: some View {
        FormElementHeader(element: element)
            .padding([.top], elementPadding)
        HStack(alignment: .bottom) {
            if #available(iOS 16.0, *) {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
            } else {
                TextEditor(text: $text)
            }
            if isFocused && !text.isEmpty {
                ClearButton { text.removeAll() }
            }
        }
        .background(.clear)
        .focused($isFocused)
        .foregroundColor(isPlaceholder ? .secondary : .primary)
        .frame(minHeight: 75, maxHeight: 150)
        .onChange(of: isFocused) { focused in
            if focused && isPlaceholder {
                isPlaceholder = false
                text = ""
            } else if !focused && text.isEmpty {
                isPlaceholder = true
                text = element.hint
            }
            if focused {
                model.focusedFieldName = element.fieldName
            }
        }
        .formTextEntryStyle()
        TextEntryFooter(
            currentLength: isPlaceholder ? .zero : text.count,
            isFocused: isFocused,
            element: element,
            input: input
        )
        .padding([.bottom], elementPadding)
        .onAppear {
            let text = element.value
            if !text.isEmpty {
                isPlaceholder = false
                self.text = text
            } else {
                isPlaceholder = true
                self.text = element.hint
            }
        }
        .onChange(of: text) { newValue in
            if !isPlaceholder {
                guard newValue != element.value else {
                    return
                }
                featureForm?.feature.setAttributeValue(newValue, forKey: element.fieldName)
            }
        }
        .onChange(of: model.formScroll) { _ in
            if isFocused { isFocused = false }
        }
    }
}
