// Copyright 2023 Esri
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

/// A header for elements in a feature form.
struct FormElementHeader: View {
    @Environment(\.formElementPadding) var formElementPadding
    
    /// The form element the header belongs to.
    let element: FormElement
    
    var body: some View {
        title
            .foregroundStyle(.secondary)
    }
    
    @ViewBuilder
    var title: some View {
        switch element {
        case is GroupFormElement:
            EmptyView()
        case let element as FieldFormElement:
            FieldFormElementTitle(element: element)
        default:
            Text(element.label)
        }
    }
}

extension FormElementHeader {
    struct FieldFormElementTitle: View {
        let element: FieldFormElement
        
        /// A Boolean value indicating whether the input is editable.
        @State private var isEditable = false
        /// A Boolean value indicating whether a value for the input is required.
        @State private var isRequired = false
        
        var body: some View {
            Text(verbatim: "\(element.label + (isEditable && isRequired ? " *" : ""))")
                .onIsEditableChange(of: element) { newIsEditable in
                    isEditable = newIsEditable
                }
                .onIsRequiredChange(of: element) { newIsRequired in
                    isRequired = newIsRequired
                }
        }
    }
}
