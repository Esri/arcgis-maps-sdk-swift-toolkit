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

***REMOVED***/ A view for numerical value input.
***REMOVED***/
***REMOVED***/ This is the preferable input type for long lists of coded value domains.
struct ComboBoxInput: View {
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ The phrase to use when filtering by coded value name.
***REMOVED***@State private var filterPhrase = ""
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the combo box picker is presented.
***REMOVED***@State private var isPresented = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether a value for the input is required.
***REMOVED***@State private var isRequired = false
***REMOVED***
***REMOVED******REMOVED***/ The selected option.
***REMOVED***@State private var selectedValue: CodedValue?
***REMOVED***
***REMOVED******REMOVED***/ The element's current (but unsupported) value.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ If the element has a value not in its domain, it has an unsupported value. This unsupported value is
***REMOVED******REMOVED***/ present until the user selects a value within the element's domain.
***REMOVED***@State private var unsupportedValue: String?
***REMOVED***
***REMOVED******REMOVED***/ The element's current value.
***REMOVED***@State private var value: Any?
***REMOVED***
***REMOVED******REMOVED***/ The element the input belongs to.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The text used to represent a `nil` value.
***REMOVED***private let noValueLabel: String
***REMOVED***
***REMOVED******REMOVED***/ The display state value for `nil` value options.
***REMOVED***private let noValueOption: FormInputNoValueOption
***REMOVED***
***REMOVED******REMOVED***/ A subset of coded values with names containing `filterPhrase` or all of the coded values
***REMOVED******REMOVED***/ if `filterPhrase` is empty.
***REMOVED***var matchingValues: [CodedValue] {
***REMOVED******REMOVED***guard !filterPhrase.isEmpty else {
***REMOVED******REMOVED******REMOVED***return element.codedValues
***REMOVED***
***REMOVED******REMOVED***return element.codedValues
***REMOVED******REMOVED******REMOVED***.filter { $0.name.localizedStandardContains(filterPhrase) ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for a combo box input.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The input's parent element.
***REMOVED***init(element: FieldFormElement) {
***REMOVED******REMOVED***precondition(
***REMOVED******REMOVED******REMOVED***element.input is ComboBoxFormInput,
***REMOVED******REMOVED******REMOVED***"\(Self.self).\(#function) element's input must be \(ComboBoxFormInput.self)."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***let input = element.input as! ComboBoxFormInput
***REMOVED******REMOVED***self.noValueLabel = input.noValueLabel
***REMOVED******REMOVED***self.noValueOption = input.noValueOption
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for a combo box input.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The input's parent element.
***REMOVED******REMOVED***/   - noValueLabel: The text used to represent a `nil` value.
***REMOVED******REMOVED***/   - noValueOption: The display state value for `nil` value options.
***REMOVED***init(element: FieldFormElement, noValueLabel: String, noValueOption: FormInputNoValueOption) {
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.noValueLabel = noValueLabel
***REMOVED******REMOVED***self.noValueOption = noValueOption
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Text(unsupportedValue ?? selectedValue?.name ?? placeholderValue)
***REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Combo Box Value")
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(selectedValue != nil ? .primary : .secondary)
***REMOVED******REMOVED******REMOVED***if selectedValue != nil, !isRequired {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Only show clear button if we have a value
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** and we're not required. (i.e., Don't show clear if
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** the field is required.)
***REMOVED******REMOVED******REMOVED******REMOVED***ClearButton {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = element
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***defer { model.focusedElement = nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedValue = nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Clear Button")
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Otherwise, always show list icon.
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "list.bullet")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Options Button")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.formInputStyle()
***REMOVED******REMOVED***.sheet(isPresented: $isPresented) {
***REMOVED******REMOVED******REMOVED***makePicker()
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***if let currentValue = element.codedValues.first(where: {
***REMOVED******REMOVED******REMOVED******REMOVED***$0.name == element.formattedValue
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***selectedValue = currentValue
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***unsupportedValue = element.formattedValue
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED***model.focusedElement = element
***REMOVED******REMOVED******REMOVED***isPresented = true
***REMOVED***
***REMOVED******REMOVED***.onChange(selectedValue) { selectedValue in
***REMOVED******REMOVED******REMOVED***unsupportedValue = nil
***REMOVED******REMOVED******REMOVED***element.updateValue(selectedValue?.code)
***REMOVED******REMOVED******REMOVED***model.evaluateExpressions()
***REMOVED***
***REMOVED******REMOVED***.onValueChange(of: element) { newValue, newFormattedValue in
***REMOVED******REMOVED******REMOVED***value = newValue
***REMOVED******REMOVED******REMOVED***selectedValue = element.codedValues.first { $0.name == newFormattedValue ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onIsRequiredChange(of: element) { newIsRequired in
***REMOVED******REMOVED******REMOVED***isRequired = newIsRequired
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view that allows the user to filter and select coded values by name.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Adds navigation context to support toolbar items and other visual elements in the picker.
***REMOVED***func makePicker() -> some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !element.isRequired {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if noValueOption == .show {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makePickerRow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***label: noValueLabel.isEmpty ? String.noValue : noValueLabel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selected: selectedValue == nil && unsupportedValue == nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.selectedValue = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.italic()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(matchingValues, id: \.self) { codedValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makePickerRow(label: codedValue.name, selected: codedValue == selectedValue) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.selectedValue = codedValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let unsupportedValue {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makePickerRow(label: unsupportedValue, selected: true) { ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.italic()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** header: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text.unsupportedValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED***.searchable(text: $filterPhrase, placement: .navigationBarDrawer, prompt: .filter)
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationTitle(element.label)
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text.done
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.semibold)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.accentColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func makePickerRow(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Button(label) { action() ***REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if selected {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "checkmark")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.accentColor)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension ComboBoxInput {
***REMOVED******REMOVED***/ The placeholder value to display.
***REMOVED***var placeholderValue: String {
***REMOVED******REMOVED***guard !element.isRequired else {
***REMOVED******REMOVED******REMOVED***return .enterValue
***REMOVED***
***REMOVED******REMOVED***switch (noValueOption, noValueLabel.isEmpty) {
***REMOVED******REMOVED***case (.show, true):
***REMOVED******REMOVED******REMOVED***return .noValue
***REMOVED******REMOVED***case (.show, false):
***REMOVED******REMOVED******REMOVED***return noValueLabel
***REMOVED******REMOVED***case (_, _):
***REMOVED******REMOVED******REMOVED***return ""
***REMOVED***
***REMOVED***
***REMOVED***

private extension String {
***REMOVED******REMOVED***/ A label for a combo box input that prompts the user to enter a value.
***REMOVED***static var enterValue: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Enter Value",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a combo box input that prompts the user to enter a value."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private extension Text {
***REMOVED******REMOVED***/ A label for a text entry field that allows the user to filter a list of values by name.
***REMOVED***static var filter: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Filter",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a text entry field that allows the user to filter a list of values by name."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var unsupportedValue: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Unsupported Value",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a section in a list of possible values that contains a single value outside the list of valid values."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

extension ArcGIS.CodedValue: Swift.Equatable {
***REMOVED***public static func == (lhs: CodedValue, rhs: CodedValue) -> Bool {
***REMOVED******REMOVED***lhs.name == rhs.name
***REMOVED***
***REMOVED***

extension ArcGIS.CodedValue: Swift.Hashable {
***REMOVED***public func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(name)
***REMOVED***
***REMOVED***
