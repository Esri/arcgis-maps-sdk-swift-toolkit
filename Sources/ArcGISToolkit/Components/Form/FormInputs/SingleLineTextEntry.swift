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

/// A view for single line text entry.
struct SingleLineTextEntry: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// <#Description#>
    private var featureForm: FeatureForm?
    
    /// The model for the ancestral form view.
    @EnvironmentObject var model: FormViewModel
    
    /// A Boolean value indicating whether or not the field is focused.
    @FocusState private var isFocused: Bool
    
    /// The current text value.
    @State private var text = ""
    
    /// The field's parent element.
    private let element: FieldFormElement
    
    /// The input configuration of the field.
    private let input: TextBoxFormInput
    
    /// Creates a view for single line text entry.
    /// - Parameters:
    ///   - featureForm: <#featureForm description#>
    ///   - element: The field's parent element.
    ///   - input: The input configuration of the field.
    init(featureForm: FeatureForm?, element: FieldFormElement, input: TextBoxFormInput) {
        self.featureForm = featureForm
        self.element = element
        self.input = input
    }
    
    var body: some View {
        FormElementHeader(element: element)
            .padding([.top], elementPadding)
        // Secondary foreground color is used across entry views for consistency.
        HStack {
            TextField(element.label, text: $text, prompt: Text(element.hint ?? "").foregroundColor(.secondary))
                .focused($isFocused)
                .accessibilityIdentifier("\(element.label) Text Field")
            if !text.isEmpty {
                ClearButton { text.removeAll() }
                    .accessibilityIdentifier("\(element.label) Clear Button")
            }
        }
        .formTextEntryStyle()
        TextEntryFooter(
            currentLength: text.count,
            isFocused: isFocused,
            element: element,
            input: input
        )
        .padding([.bottom], elementPadding)
        .onAppear {
            text = featureForm?.feature.attributes[element.fieldName] as? String ?? ""
        }
        .onChange(of: isFocused) { newFocus in
            if newFocus {
                model.focusedFieldName = element.fieldName
            }
        }
        .onChange(of: text) { newValue in
            featureForm?.feature.setAttributeValue(newValue, forKey: element.fieldName)
        }
    }
}
