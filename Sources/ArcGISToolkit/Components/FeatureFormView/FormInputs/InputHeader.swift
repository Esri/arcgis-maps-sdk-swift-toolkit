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

import SwiftUI
import ArcGIS

/// A view shown at the top of a field element in a form.
struct InputHeader: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The name of the form element.
    let label: String
    
    /// A Boolean value indicating whether a value for the input is required.
    let isRequired: Bool
    
    /// - Parameter element: The form element the header is for.
    init(element: FieldFormElement) {
        self.label = element.label
        self.isRequired = element.isRequired
    }
    
    /// - Parameters:
    ///   - label: The name of the form element.
    ///   - isRequired: A Boolean value indicating whether the a value for the input is required.
    init(label: String, isRequired: Bool) {
        self.label = label
        self.isRequired = isRequired
    }
    
    var body: some View {
        HStack {
            Text(verbatim: "\(label + (isRequired ? " *" : ""))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, elementPadding)
    }
}
