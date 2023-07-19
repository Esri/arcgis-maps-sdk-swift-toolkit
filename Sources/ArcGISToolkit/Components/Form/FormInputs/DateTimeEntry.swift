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
    
    /// The model for the ancestral form view.
    @EnvironmentObject var model: FormViewModel
    
    let element: FieldFeatureFormElement
    
    let input: DateTimePickerFeatureFormInput
    
    @State private var date = Date.now
    
    var body: some View {
        Group {
            FormElementHeader(element: element)
                .padding([.top], elementPadding)
            
            datePicker
            
            if let description = element.description {
                Text(description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding([.bottom], elementPadding)
        .onAppear {
            if let date = model.feature?.attributes[element.fieldName] as? Date {
                self.date = date
            }
        }
    }
    
    @ViewBuilder var datePicker: some View {
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
