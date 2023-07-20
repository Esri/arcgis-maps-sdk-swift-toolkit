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
    
    @State private var date: Date?
    
    @State private var isEditing = false
    
    private let element: FieldFeatureFormElement
    
    private let input: DateTimePickerFeatureFormInput
    
    /// Creates a view for a date and time (if applicable) entry.
    /// - Parameters:
    ///   - element: The form element that corresponds to the field.
    ///   - input: A `DateTimePickerFeatureFormInput` which acts as a configuration.
    init(element: FieldFeatureFormElement, input: DateTimePickerFeatureFormInput) {
        self.element = element
        self.input = input
    }
    
    var body: some View {
        Group {
            FormElementHeader(element: element)
                .padding([.top], elementPadding)
            
            if isEditing {
                dateEditor
            } else {
                dateViewer
            }
            
            description
        }
        .padding([.bottom], elementPadding)
        .onAppear {
            if let date = model.feature?.attributes[element.fieldName] as? Date {
                self.date = date
            }
        }
        .onChange(of: date) { newDate in
            model.feature?.setAttributeValue(newDate, forKey: element.fieldName)
        }
    }
    
    @ViewBuilder var dateEditor: some View {
        HStack {
            todayOrNowButton
            Spacer()
            doneButton
        }
        datePicker
            .datePickerStyle(.graphical)
    }
    
    /// - Note: Secondary foreground color is used across entry views for consistency.
    @ViewBuilder var dateViewer: some View {
        HStack {
            
            TextField(
                element.label,
                text: Binding { date == nil ? "" : formattedDate } set: { _ in },
                prompt: .noValue.foregroundColor(.secondary)
            )
            .disabled(true)
            
            if date == nil {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
            } else {
                ClearButton { date = nil }
            }
        }
        .formTextEntryStyle()
        .onTapGesture {
            if date == nil { date = .now }
            withAnimation { isEditing = true }
        }
    }
    
    @ViewBuilder var datePicker: some View {
        let components: DatePicker.Components = input.includeTime ? [.date, .hourAndMinute] : [.date]
        if let min = input.min, let max = input.max {
            DatePicker(selection: Binding($date)!, in: min...max, displayedComponents: components) { }
        } else if let min = input.min {
            DatePicker(selection: Binding($date)!, in: min..., displayedComponents: components) { }
        } else if let max = input.max {
            DatePicker(selection: Binding($date)!, in: ...max, displayedComponents: components) { }
        } else {
            DatePicker(selection: Binding($date)!, displayedComponents: components) { }
        }
    }
    
    @ViewBuilder var description: some View {
        if let description = element.description {
            Text(description)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
    var formattedDate: String {
        if input.includeTime {
            return date!.formatted(.dateTime.day().month().year().hour().minute())
        } else {
            return date!.formatted(.dateTime.day().month().year())
        }
    }
    
    var doneButton: some View {
        Button {
            withAnimation { isEditing = false }
        } label: {
            Text.done
        }
    }
    
    var todayOrNowButton: some View {
        Button {
            date = .now
        } label: {
            input.includeTime ? Text.now : .today
        }
    }
}

private extension Text {
    /// A label for a button to save a date (and time if applicable) selection.
    static var done: Self {
        Text(
            "Done",
            bundle: .toolkitModule,
            comment: "A label for a button to save a date (and time if applicable) selection."
        )
    }
    
    /// A label indicating that no date or time has been set for a date/time field.
    static var noValue: Self {
        Text(
            "No Value",
            bundle: .toolkitModule,
            comment: "A label indicating that no date or time has been set for a date/time field."
        )
    }
    
    /// A label for a button to choose the current time and date for a field.
    static var now: Self {
        Text(
            "Now",
            bundle: .toolkitModule,
            comment: "A label for a button to choose the current time and date for a field."
        )
    }
    
    /// A label for a button to choose the current date for a field.
    static var today: Self {
        Text(
            "Today",
            bundle: .toolkitModule,
            comment: "A label for a button to choose the current date for a field."
        )
    }
}
