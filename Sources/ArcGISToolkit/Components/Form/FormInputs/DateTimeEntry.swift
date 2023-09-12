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

***REMOVED***
***REMOVED***

struct DateTimeEntry: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED******REMOVED***/ The model for the ancestral form view.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED***private var featureForm: FeatureForm?
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
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the field.
***REMOVED***private let input: DateTimePickerFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for a date and time (if applicable) entry.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: <#featureForm description#>
***REMOVED******REMOVED***/   - element: The field's parent element.
***REMOVED******REMOVED***/   - input: The input configuration of the field.
***REMOVED***init(featureForm: FeatureForm?, element: FieldFormElement, input: DateTimePickerFormInput) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.input = input
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***FormElementHeader(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***dateEditor
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***footer
***REMOVED***
***REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***if element.value.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***date = nil
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***date = try? Date(element.value, strategy: Date.ParseStrategy.arcGISDateParseStrategy)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: date) { newDate in
***REMOVED******REMOVED******REMOVED***guard let currentDate = try? Date(element.value, strategy: Date.ParseStrategy.arcGISDateParseStrategy),
***REMOVED******REMOVED******REMOVED******REMOVED***  newDate != currentDate else {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***TODO: add `required` property to API
***REMOVED******REMOVED******REMOVED***requiredValueMissing = /*element.required && */newDate == nil
***REMOVED******REMOVED******REMOVED***featureForm?.feature.setAttributeValue(newDate, forKey: element.fieldName)
***REMOVED***
***REMOVED******REMOVED***.onChange(of: model.focusedFieldName) { newFocusedFieldName in
***REMOVED******REMOVED******REMOVED***isEditing = newFocusedFieldName == element.fieldName
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Controls for modifying the date selection.
***REMOVED***@ViewBuilder var dateEditor: some View {
***REMOVED******REMOVED***dateDisplay
***REMOVED******REMOVED***if isEditing {
***REMOVED******REMOVED******REMOVED***datePicker
***REMOVED******REMOVED******REMOVED******REMOVED***.datePickerStyle(.graphical)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Elements for display the date selection.
***REMOVED******REMOVED***/ - Note: Secondary foreground color is used across entry views for consistency.
***REMOVED***@ViewBuilder var dateDisplay: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Text(formattedDate ?? .noValue)
***REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Value")
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(displayColor)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if isEditing {
***REMOVED******REMOVED******REMOVED******REMOVED***todayOrNowButton
***REMOVED******REMOVED*** else if true/*element.editable*/ {
***REMOVED******REMOVED******REMOVED******REMOVED***if date == nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "calendar")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Calendar Image")
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ClearButton { date = nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Clear Button")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.padding([.vertical], 1.5)
***REMOVED******REMOVED***.formTextEntryStyle()
***REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard element.editable else { return ***REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED***model.focusedFieldName = isEditing ? element.fieldName : nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Controls for making a specific date selection.
***REMOVED***@ViewBuilder var datePicker: some View {
***REMOVED******REMOVED***DatePicker(
***REMOVED******REMOVED******REMOVED***selection: Binding($date)!,
***REMOVED******REMOVED******REMOVED***in: dateRange,
***REMOVED******REMOVED******REMOVED***displayedComponents: input.includeTime ? [.date, .hourAndMinute] : [.date]
***REMOVED******REMOVED***) { ***REMOVED***
***REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Date Picker")
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
***REMOVED******REMOVED******REMOVED***return .accentColor
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .primary
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The message shown below the date editor and viewer.
***REMOVED***@ViewBuilder var footer: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if requiredValueMissing {
***REMOVED******REMOVED******REMOVED******REMOVED***Text.required
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED***.foregroundColor(requiredValueMissing ? .red : .secondary)
***REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Footer")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The human-readable date and time selection.
***REMOVED***var formattedDate: String? {
***REMOVED******REMOVED***if input.includeTime {
***REMOVED******REMOVED******REMOVED***return date?.formatted(.dateTime.day().month().year().hour().minute())
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return date?.formatted(.dateTime.day().month().year())
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
***REMOVED******REMOVED******REMOVED***input.includeTime ? Text.now : .today
***REMOVED***
***REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) \(input.includeTime ? "Now" : "Today") Button")
***REMOVED***
***REMOVED***

private extension Date.ParseStrategy {
***REMOVED******REMOVED***/ A parse strategy for date/time strings with a yyyy-MM-dd'T'HH:mm:ss format.
***REMOVED***static var arcGISDateParseStrategy: Self {
***REMOVED******REMOVED***.fixed(
***REMOVED******REMOVED******REMOVED***format: "\(year: .defaultDigits)-\(month: .defaultDigits)-\(day: .defaultDigits)T\(hour: .defaultDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .defaultDigits):\(second: .defaultDigits)",
***REMOVED******REMOVED******REMOVED***timeZone: .current
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private extension String {
***REMOVED******REMOVED***/ A string indicating that no date or time has been set for a date/time field.
***REMOVED***static var noValue: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "No Value",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A string indicating that no date or time has been set for a date/time field."
***REMOVED******REMOVED***)
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
***REMOVED******REMOVED***/ A label indicating a required field was left blank.
***REMOVED***static var required: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Required",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating a required field was left blank."
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
