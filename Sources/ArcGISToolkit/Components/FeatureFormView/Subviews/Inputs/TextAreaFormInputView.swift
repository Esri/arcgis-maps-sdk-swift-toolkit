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
    @ScaledMetric private var idealHeight = 100
    
    @State private var value: String = ""
    
    let element: FieldFormElement
    
    init(element: FieldFormElement) {
        precondition(
            element.input is TextAreaFormInput,
            "\(Self.self).\(#function) element's input must be \(TextAreaFormInput.self)."
        )
        self.element = element
    }
    
    var body: some View {
        TextEditor(text: $value)
            // Ideally we'd specify a line limit but the line limit modifier
            // does not currently work with the text editor (FB19423738) so we
            // use a scaled ideal height instead.
            .frame(idealHeight: idealHeight)
            .formInputStyle(isTappable: true)
            .scrollContentBackground(.hidden)
    }
}
