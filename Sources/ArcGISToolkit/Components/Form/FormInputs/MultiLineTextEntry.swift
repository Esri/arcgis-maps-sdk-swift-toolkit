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
    
    /// The model for the ancestral form view.
    @EnvironmentObject var model: FormViewModel
    
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
    
    /// The form element that corresponds to this text field.
    private let element: FieldFeatureFormElement
    
    /// A `TextAreaFeatureFormInput` which acts as a configuration.
    private let input: TextAreaFeatureFormInput
    
    /// Creates a view for text entry spanning multiple lines.
    /// - Parameters:
    ///   - element: The form element that corresponds to this text field.
    ///   - input: A `TextAreaFeatureFormInput` which acts as a configuration.
    init(element: FieldFeatureFormElement, input: TextAreaFeatureFormInput) {
        self.element =  element
        self.input = input
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
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            
                            Button { } label: { Image(systemName: "chevron.up") }
                            
                            Button { } label: { Image(systemName: "chevron.down") }
                            
                            Button("Done") {
                                isFocused = false
                            }
                        }
                    }
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
        .onAppear {
            let text = model.feature?.attributes[element.fieldName] as? String
            if let text, !text.isEmpty {
                isPlaceholder = false
                self.text = text
                
            } else {
                isPlaceholder = true
                self.text = element.hint ?? ""
            }
        }
        .onChange(of: text) { newValue in
            if !isPlaceholder {
                model.feature?.setAttributeValue(newValue, forKey: element.fieldName)
            }
        }
    }
}
