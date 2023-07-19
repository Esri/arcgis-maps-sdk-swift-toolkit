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

struct DateTimeEntry: View {
    @Environment(\.formElementPadding) var elementPadding
    
    let element: FieldFeatureFormElement
    
    let input: DateTimePickerFeatureFormInput
    
    @State private var date = Date.now
    
    var body: some View {
        FormElementHeader(element: element)
            .padding([.top], elementPadding)
        
        if let min = input.min, let max = input.max {
            DatePicker(selection: $date, in: min...max, displayedComponents: displayedComponents) { EmptyView() }
        } else if let min = input.min {
            DatePicker(selection: $date, in: min..., displayedComponents: displayedComponents) { EmptyView() }
        } else if let max = input.max {
            DatePicker(selection: $date, in: ...max, displayedComponents: displayedComponents) { EmptyView() }
        } else {
            DatePicker(selection: $date, displayedComponents: displayedComponents) { EmptyView() }
        }
    }
    
    var displayedComponents: DatePicker.Components {
        input.includeTime ? [.date, .hourAndMinute] : [.date]
    }
}
