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
    /// The current text value.
    @State private var text: String
    
    /// The title of the item.
    let title: String
    
    /// The text to to be shown in the entry area if no value is present.
    let prompt: String
    
    /// A `TextBoxFeatureFormInput` which acts as a configuration.
    let input: TextBoxFeatureFormInput
    
    /// Creates a view for single line text entry.
    /// - Parameters:
    ///   - title: The title of the item.
    ///   - text: The current text value.
    ///   - prompt: The text to to be shown in the entry area if no value is present.
    ///   - input: A `TextBoxFeatureFormInput` which acts as a configuration.
    init(element: FieldFeatureFormElement, text: String?, input: TextBoxFeatureFormInput) {
        self.text = text ?? ""
        self.title = element.label
        self.prompt = element.hint
        self.input = input
    }
    
    public var body: some View {
        TextField(title, text: $text, prompt: Text(prompt))
            .formTextEntryBorder()
        TextEntryProgress(current: text.count, max: input.maxLength)
    }
}
