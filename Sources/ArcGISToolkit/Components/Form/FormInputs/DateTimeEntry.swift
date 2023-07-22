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
    
    /// The current date selection.
    @State private var date: Date?
    
    /// A Boolean value indicating whether a new date (or time is being set).
    @State private var isEditing = false
    
    /// A Boolean value indicating whether the date selection was cleared when a value is required.
    @State private var requiredValueMissing = false
    
    /// The field's parent element.
    private let element: FieldFeatureFormElement
    
    /// The input configuration of the field.
    private let input: DateTimePickerFeatureFormInput
    
    /// Creates a view for a date and time (if applicable) entry.
    /// - Parameters:
    ///   - element: The field's parent element.
    ///   - input: The input configuration of the field.
    init(element: FieldFeatureFormElement, input: DateTimePickerFeatureFormInput) {
        self.element = element
        self.input = input
    }
    
    var body: some View {
        Group {
            FormElementHeader(element: element)
                .padding([.top], elementPadding)
            
            dateEditor
            
            footer
        }
        .padding([.bottom], elementPadding)
        .onAppear {
            if let date = model.feature?.attributes[element.fieldName] as? Date {
                self.date = date
            }
        }
        .onChange(of: date) { newDate in
            requiredValueMissing = element.required && newDate == nil
            model.feature?.setAttributeValue(newDate, forKey: element.fieldName)
        }
    }
    
    /// Controls for modifying the date selection.
    @ViewBuilder var dateEditor: some View {
        dateDisplay
        if isEditing {
            datePicker
                .datePickerStyle(.graphical)
        }
    }
    
    /// Elements for display the date selection.
    /// - Note: Secondary foreground color is used across entry views for consistency.
    @ViewBuilder var dateDisplay: some View {
        HStack {
            TextField(
                element.label,
                text: Binding { date == nil ? "" : formattedDate } set: { _ in },
                prompt: .noValue.foregroundColor(.secondary)
            )
            .disabled(true)
            
            if isEditing {
                todayOrNowButton
            } else if date == nil {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
            } else {
                ClearButton { date = nil }
            }
        }
        .formTextEntryStyle()
        .onTapGesture {
            if date == nil { date = .now }
            withAnimation { isEditing.toggle() }
        }
    }
    
    /// Controls for making a specific date selection.
    @ViewBuilder var datePicker: some View {
        let components: DatePicker.Components = input.includeTime ? [.date, .hourAndMinute] : [.date]
        if let range = dateRange {
            DatePicker(selection: Binding($date)!, in: range, displayedComponents: components) { }
        } else {
            DatePicker(selection: Binding($date)!, displayedComponents: components) { }
        }
    }
    
    /// The range of dates available for selection, if applicable.
    var dateRange: ClosedRange<Date>? {
        if let min = input.min, let max = input.max {
            return min...max
        } else if let min = input.min {
            return min...Date.distantFuture
        } else if let max = input.max {
            return Date.distantPast...max
        } else {
            return nil
        }
    }
    
    /// The message shown below the date editor and viewer.
    @ViewBuilder var footer: some View {
        Group {
            if requiredValueMissing {
                Text.required
            } else if let description = element.description {
                Text(description)
            }
        }
        .font(.footnote)
        .foregroundColor(requiredValueMissing ? .red : .secondary)
    }
    
    /// The human-readable date and time selection.
    var formattedDate: String {
        if input.includeTime {
            return date!.formatted(.dateTime.day().month().year().hour().minute())
        } else {
            return date!.formatted(.dateTime.day().month().year())
        }
    }
    
    /// The button to set the date to the present time.
    var todayOrNowButton: some View {
        Button {
            date = .now
        } label: {
            input.includeTime ? Text.now : .today
        }
    }
}

private extension Text {
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
    
    /// A label indicating a required field was left blank.
    static var required: Self {
        Text(
            "Required",
            bundle: .toolkitModule,
            comment: "A label indicating a required field was left blank."
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
