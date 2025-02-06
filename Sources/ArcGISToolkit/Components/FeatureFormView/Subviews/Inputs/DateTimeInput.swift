***REMOVED*** Copyright 2023 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

***REMOVED***/ A view for date/time input.
struct DateTimeInput: View {
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ The current date selection.
***REMOVED***@State private var date: Date?
***REMOVED***
***REMOVED******REMOVED***/ The formatted version of the element's current value.
***REMOVED***@State private var formattedValue = ""
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether a new date (or time is being set).
***REMOVED***@State private var isEditing = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether a value for the input is required.
***REMOVED***@State private var isRequired = false
***REMOVED***
***REMOVED******REMOVED***/ The element the input belongs to.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the view.
***REMOVED***private let input: DateTimePickerFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for a date (and time if applicable) input.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The input's parent element.
***REMOVED***init(element: FieldFormElement) {
***REMOVED******REMOVED***precondition(
***REMOVED******REMOVED******REMOVED***element.input is DateTimePickerFormInput,
***REMOVED******REMOVED******REMOVED***"\(Self.self).\(#function) element's input must be \(DateTimePickerFormInput.self)."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.input = element.input as! DateTimePickerFormInput
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***dateEditor
***REMOVED******REMOVED******REMOVED***.onChange(model.focusedElement) { focusedElement in
***REMOVED******REMOVED******REMOVED******REMOVED***isEditing = focusedElement == element
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(date) { date in
***REMOVED******REMOVED******REMOVED******REMOVED***element.updateValue(date)
***REMOVED******REMOVED******REMOVED******REMOVED***formattedValue = element.formattedValue
***REMOVED******REMOVED******REMOVED******REMOVED***model.evaluateExpressions()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onValueChange(of: element) { newValue, newFormattedValue in
***REMOVED******REMOVED******REMOVED******REMOVED***if newFormattedValue.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***date = nil
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***date = newValue as? Date
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***formattedValue = newFormattedValue
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onIsRequiredChange(of: element) { newIsRequired in
***REMOVED******REMOVED******REMOVED******REMOVED***isRequired = newIsRequired
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Controls for modifying the date selection.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Because the value/date can be cleared out at a higher level (e.g. from discarding edits) we must
***REMOVED******REMOVED***/ confirm a value is present to include a date picker in the hierarchy.
***REMOVED***@ViewBuilder var dateEditor: some View {
***REMOVED******REMOVED***dateDisplay
***REMOVED******REMOVED***if isEditing, let date {
***REMOVED******REMOVED******REMOVED***makeDatePicker(
***REMOVED******REMOVED******REMOVED******REMOVED***with: Binding(get: { date ***REMOVED***, set: { self.date = $0 ***REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Elements for display the date selection.
***REMOVED******REMOVED***/ - Note: Secondary foreground color is used across input views for consistency.
***REMOVED***@ViewBuilder var dateDisplay: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Text(!formattedValue.isEmpty ? formattedValue : .noValue)
***REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Value")
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(displayColor)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if isEditing {
***REMOVED******REMOVED******REMOVED******REMOVED***todayOrNowButton
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***if date == nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "calendar")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Calendar Image")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED*** else if !isRequired {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***XButton(.clear) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = element
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***defer { model.focusedElement = nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***date = nil
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Clear Button")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.formInputStyle(isTappable: true)
***REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED***if date == nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if dateRange.contains(.now) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***date = .now
***REMOVED******REMOVED******REMOVED******REMOVED*** else if let min = input.min {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***date = min
***REMOVED******REMOVED******REMOVED******REMOVED*** else if let max = input.max {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***date = max
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***isEditing.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = isEditing ? element : nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes control for date selection.
***REMOVED******REMOVED***/ - Bug: Apple Feedback #FB13699023 "DatePicker time input cutoff". Original ref Apollo #567.
***REMOVED***@ViewBuilder func makeDatePicker(with date: Binding<Date>) -> some View {
***REMOVED******REMOVED***DatePicker(
***REMOVED******REMOVED******REMOVED***selection: date,
***REMOVED******REMOVED******REMOVED***in: dateRange,
***REMOVED******REMOVED******REMOVED***displayedComponents: input.includesTime ? [.date, .hourAndMinute] : [.date]
***REMOVED******REMOVED***) { ***REMOVED***
***REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Date Picker")
***REMOVED******REMOVED******REMOVED***.datePickerStyle(.graphical)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The range of dates available for selection, if applicable.
***REMOVED***var dateRange: ClosedRange<Date> {
***REMOVED******REMOVED***if let min = input.min, let max = input.max {
***REMOVED******REMOVED******REMOVED***return min...max
***REMOVED*** else if let min = input.min {
***REMOVED******REMOVED******REMOVED***return min...Date.distantFuture
***REMOVED*** else if let max = input.max {
***REMOVED******REMOVED******REMOVED***return Date.distantPast...max
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return Date.distantPast...Date.distantFuture
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The color in which to display the selected date.
***REMOVED***var displayColor: Color {
***REMOVED******REMOVED***if date == nil {
***REMOVED******REMOVED******REMOVED***return .secondary
***REMOVED*** else if isEditing {
#if os(visionOS)
***REMOVED******REMOVED******REMOVED***return .primary
#else
***REMOVED******REMOVED******REMOVED***return .accentColor
#endif
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .primary
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The button to set the date to the present time.
***REMOVED***var todayOrNowButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***let now = Date.now
***REMOVED******REMOVED******REMOVED***if dateRange.contains(now) {
***REMOVED******REMOVED******REMOVED******REMOVED***date = now
***REMOVED******REMOVED*** else if now > dateRange.upperBound {
***REMOVED******REMOVED******REMOVED******REMOVED***date = dateRange.upperBound
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***date = dateRange.lowerBound
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***input.includesTime ? Text.now : .today
***REMOVED***
***REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) \(input.includesTime ? "Now" : "Today") Button")
#if !os(visionOS)
***REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED***.foregroundStyle(.tint)
#endif
***REMOVED***
***REMOVED***

private extension Text {
***REMOVED******REMOVED***/ A label for a button to choose the current time and date for a field.
***REMOVED***static var now: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Now",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to choose the current time and date for a field."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A label for a button to choose the current date for a field.
***REMOVED***static var today: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Today",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to choose the current date for a field."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
