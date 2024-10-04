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

/// A view which wraps the creation of a view for the underlying field form element.
///
/// This view injects a header and footer. It also monitors whether a field form element is editable and
/// chooses the correct input view based on the input type.
struct InputWrapper: View {
    /// A Boolean value indicating whether the input is editable.
    @State private var isEditable = false
    
    /// The element the input belongs to.
    let element: FieldFormElement
    
    var body: some View {
        VStack(alignment: .leading) {
            InputHeader(element: element)
            if isEditable {
                switch element.input {
                case is BarcodeScannerFormInput, is TextAreaFormInput, is TextBoxFormInput:
                    TextInput(element: element)
                case is ComboBoxFormInput:
                    ComboBoxInput(element: element)
                case is DateTimePickerFormInput:
                    DateTimeInput(element: element)
                case is RadioButtonsFormInput:
                    RadioButtonsInput(element: element)
                case is SwitchFormInput:
                    SwitchInput(element: element)
                default:
                    EmptyView()
                }
            } else {
                ReadOnlyInput(element: element)
            }
            InputFooter(element: element)
        }
        .onIsEditableChange(of: element) { newIsEditable in
            isEditable = newIsEditable
        }
    }
}
