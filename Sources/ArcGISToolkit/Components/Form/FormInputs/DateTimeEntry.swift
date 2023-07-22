***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import FormsPlugin
***REMOVED***

struct DateTimeEntry: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED******REMOVED***/ The model for the ancestral form view.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ The current date selection.
***REMOVED***@State private var date: Date?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether a new date (or time is being set).
***REMOVED***@State private var isEditing = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the date selection was cleared when a value is required.
***REMOVED***@State private var requiredValueMissing = false
***REMOVED***
***REMOVED******REMOVED***/ The field's parent element.
***REMOVED***private let element: FieldFeatureFormElement
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the field.
***REMOVED***private let input: DateTimePickerFeatureFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for a date and time (if applicable) entry.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The field's parent element.
***REMOVED******REMOVED***/   - input: The input configuration of the field.
***REMOVED***init(element: FieldFeatureFormElement, input: DateTimePickerFeatureFormInput) {
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.input = input
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***FormElementHeader(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***dateViewer
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if isEditing {
***REMOVED******REMOVED******REMOVED******REMOVED***dateEditor
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***footer
***REMOVED***
***REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***if let date = model.feature?.attributes[element.fieldName] as? Date {
***REMOVED******REMOVED******REMOVED******REMOVED***self.date = date
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: date) { newDate in
***REMOVED******REMOVED******REMOVED***requiredValueMissing = element.required && newDate == nil
***REMOVED******REMOVED******REMOVED***model.feature?.setAttributeValue(newDate, forKey: element.fieldName)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Controls for modifying the date selection.
***REMOVED***@ViewBuilder var dateEditor: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***todayOrNowButton
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***doneButton
***REMOVED***
***REMOVED******REMOVED***datePicker
***REMOVED******REMOVED******REMOVED***.datePickerStyle(.graphical)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Elements for viewing the date selection.
***REMOVED******REMOVED***/ - Note: Secondary foreground color is used across entry views for consistency.
***REMOVED***@ViewBuilder var dateViewer: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED******REMOVED***element.label,
***REMOVED******REMOVED******REMOVED******REMOVED***text: Binding { date == nil ? "" : formattedDate ***REMOVED*** set: { _ in ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED***prompt: .noValue.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.disabled(true)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if date == nil {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "calendar")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***ClearButton { date = nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.formTextEntryStyle()
***REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED***if date == nil { date = .now ***REMOVED***
***REMOVED******REMOVED******REMOVED***withAnimation { isEditing.toggle() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Controls for making a specific date selection.
***REMOVED***@ViewBuilder var datePicker: some View {
***REMOVED******REMOVED***let components: DatePicker.Components = input.includeTime ? [.date, .hourAndMinute] : [.date]
***REMOVED******REMOVED***if let min = input.min, let max = input.max {
***REMOVED******REMOVED******REMOVED***DatePicker(selection: Binding($date)!, in: min...max, displayedComponents: components) { ***REMOVED***
***REMOVED*** else if let min = input.min {
***REMOVED******REMOVED******REMOVED***DatePicker(selection: Binding($date)!, in: min..., displayedComponents: components) { ***REMOVED***
***REMOVED*** else if let max = input.max {
***REMOVED******REMOVED******REMOVED***DatePicker(selection: Binding($date)!, in: ...max, displayedComponents: components) { ***REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***DatePicker(selection: Binding($date)!, displayedComponents: components) { ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The message shown below the date editor and viewer.
***REMOVED***@ViewBuilder var footer: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if requiredValueMissing {
***REMOVED******REMOVED******REMOVED******REMOVED***Text.required
***REMOVED******REMOVED*** else if let description = element.description {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED***.foregroundColor(requiredValueMissing ? .red : .secondary)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The human-readable date and time selection.
***REMOVED***var formattedDate: String {
***REMOVED******REMOVED***if input.includeTime {
***REMOVED******REMOVED******REMOVED***return date!.formatted(.dateTime.day().month().year().hour().minute())
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return date!.formatted(.dateTime.day().month().year())
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The button to stop editing the date.
***REMOVED***var doneButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***withAnimation { isEditing = false ***REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text.done
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The button to set the date to the present time.
***REMOVED***var todayOrNowButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***date = .now
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***input.includeTime ? Text.now : .today
***REMOVED***
***REMOVED***
***REMOVED***

private extension Text {
***REMOVED******REMOVED***/ A label for a button to save a date (and time if applicable) selection.
***REMOVED***static var done: Self {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Done",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to save a date (and time if applicable) selection."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A label indicating that no date or time has been set for a date/time field.
***REMOVED***static var noValue: Self {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"No Value",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating that no date or time has been set for a date/time field."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A label for a button to choose the current time and date for a field.
***REMOVED***static var now: Self {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Now",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to choose the current time and date for a field."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A label indicating a required field was left blank.
***REMOVED***static var required: Self {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Required",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating a required field was left blank."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A label for a button to choose the current date for a field.
***REMOVED***static var today: Self {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Today",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to choose the current date for a field."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
