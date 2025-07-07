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
struct FormElementWrapper: View {
    /// The wrapped form element.
    let element: FormElement
    
    var body: some View {
        VStack(alignment: .leading) {
            FormElementHeader(element: element)
            switch element {
            case let element as FieldFormElement:
                FieldFormElementView(element: element)
            case let element as UtilityAssociationsFormElement:
                FeatureFormView.UtilityAssociationsFormElementView(element: element)
            default:
                EmptyView()
            }
            FormElementFooter(element: element)
        }
    }
}
