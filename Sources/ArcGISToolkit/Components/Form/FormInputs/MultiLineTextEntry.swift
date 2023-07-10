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

/// A view for text entry spanning multiple lines.
struct MultiLineTextEntry: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// A Boolean value indicating whether or not the field is focused.
    @FocusState private var isFocused: Bool
    
    /// The current text value.
    @State private var text: String
    
    /// A Boolean value indicating whether placeholder text is shown, thereby indicating the
    /// presence of a value.
    ///
    /// - Note: As of Swift 5.9, SwiftUI text editors do not have built-in placeholder functionality
    /// so it must be implemented manually.
    @State private var isPlaceholder: Bool
    
    /// The form element that corresponds to this text field.
    private let element: FieldFeatureFormElement
    
    /// A `TextAreaFeatureFormInput` which acts as a configuration.
    private let input: TextAreaFeatureFormInput
    
    /// Creates a view for text entry spanning multiple lines.
    /// - Parameters:
    ///   - element: The form element that corresponds to this text field.
    ///   - text: The current text value.
    ///   - input: A `TextAreaFeatureFormInput` which acts as a configuration.
    init(element: FieldFeatureFormElement, text: String?, input: TextAreaFeatureFormInput) {
        self.element =  element
        self.input = input
        
        if let text, !text.isEmpty {
            _text = State(initialValue: text)
            isPlaceholder = false
        } else {
            _text = State(initialValue: element.hint ?? "")
            isPlaceholder = true
        }
    }
    
    /// - Bug: Focus detection works as of Xcode 14.3.1 but is broken as of Xcode 15 Beta 2.
    /// [More info](https://openradar.appspot.com/FB12432084)
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
                text = element.hint ?? ""
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
    }
}
