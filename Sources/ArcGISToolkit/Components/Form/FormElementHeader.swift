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

/// A view shown at the top of each field element in a form.
struct FormElementHeader: View {
    /// The form element the header is for.
    let element: FieldFormElement
    
    var body: some View {
        //TODO: add `required` property to API
//        Text(verbatim: "\(element.label + (element.required ? " *" : ""))")
        Text(verbatim: "\(element.label)")
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
}
