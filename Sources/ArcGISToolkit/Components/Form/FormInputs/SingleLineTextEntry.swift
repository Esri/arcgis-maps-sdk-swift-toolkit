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

import FormsPlugin
import SwiftUI

/// A view for single line text entry.
struct SingleLineTextEntry: View {
    @Environment(\.formElementPadding) var padding
    
    /// A Boolean value indicating whether or not the field is focused.
    @FocusState private var isFocused: Bool
    
    /// The current text value.
    @State private var text: String
    
    /// The form element that corresponds to this text field.
    private let element: FieldFeatureFormElement
    
    /// A `TextBoxFeatureFormInput` which acts as a configuration.
    private let input: TextBoxFeatureFormInput
    
    /// Creates a view for single line text entry.
    /// - Parameters:
    ///   - element: The form element that corresponds to this text field.
    ///   - text: The current text value.
    ///   - input: A `TextBoxFeatureFormInput` which acts as a configuration.
    init(element: FieldFeatureFormElement, text: String?, input: TextBoxFeatureFormInput) {
        self.element = element
        self.text = text ?? ""
        self.input = input
    }
    
    var body: some View {
        FormElementHeader(element: element)
            .padding([.top], padding)
        // `MultiLineTextEntry` uses secondary foreground color so it's applied here for consistency.
        HStack {
            TextField(element.label, text: $text, prompt: Text(element.hint ?? "").foregroundColor(.secondary))
                .focused($isFocused)
            if isFocused && !text.isEmpty {
                ClearButton { text.removeAll() }
            }
        }
        .formTextEntryStyle()
        TextEntryFooter(
            currentLength: text.count,
            isFocused: isFocused,
            description: element.description ?? "",
            isRequired: element.required,
            maxLength: input.maxLength,
            minLength: input.minLength
        )
        .padding([.bottom], padding)
    }
}
