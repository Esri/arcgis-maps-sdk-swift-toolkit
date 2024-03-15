// Copyright 2024 Esri
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

/// A view for a read only field form element.
struct ReadOnlyInput: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The view model for the form.
    @EnvironmentObject var model: FormViewModel
    
    @State private var formattedValue: String = ""
    
    /// The current text value.
    @State private var text = ""
    
    /// The input's parent element.
    private let element: FieldFormElement
    
    /// Creates a view for text input spanning multiple lines.
    /// - Parameters:
    ///   - element: The input's parent element.
    init(element: FieldFormElement) {
        precondition(
            !element.isEditable,
            "\(Self.self).\(#function) element must not be editable."
        )
        self.element = element
    }
    
    var body: some View {
        InputHeader(label: element.label, isRequired: false)
            .padding([.top], elementPadding)
        if element.isMultiline {
            textReader
        } else {
            ScrollView(.horizontal) {
                textReader
            }
        }
        InputFooter(element: element)
        .padding([.bottom], elementPadding)
        .onValueChange(of: element) { newValue, newFormattedValue in
            formattedValue = newFormattedValue
        }
    }
}

private extension ReadOnlyInput {
    /// The body of the text input when the element is non-editable.
    var textReader: some View {
        Text(text.isEmpty ? "--" : text)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .textSelection(.enabled)
            .lineLimit(element.isMultiline ? nil : 1)
    }
}
