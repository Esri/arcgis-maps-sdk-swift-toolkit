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
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED******REMOVED***/ The model for the ancestral form view.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ The set of options in the combo box.
***REMOVED***@State private var codedValues = [CodedValue]()
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the combo box picker is presented.
***REMOVED***@State private var isPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The phrase to use when filtering by coded value name.
***REMOVED***@State private var filterPhrase = ""
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether a value is required but missing.
***REMOVED***@State private var requiredValueMissing = false
***REMOVED***
***REMOVED******REMOVED***/ The selected option.
***REMOVED***@State private var selectedValue: CodedValue?
***REMOVED***
***REMOVED******REMOVED***/ The feature form containing the input.
***REMOVED***private var featureForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ The input's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The text used to represent a `nil` value.
***REMOVED***private let noValueLabel: String
***REMOVED***
***REMOVED******REMOVED***/ The display state value for `nil` value options.
***REMOVED***private let noValueOption: FormInputNoValueOption
***REMOVED***
***REMOVED******REMOVED***/ The model for the input.
***REMOVED***@StateObject var inputModel: FormInputModel
***REMOVED***
***REMOVED******REMOVED***/ A subset of coded values with names containing `filterPhrase` or all of the coded values
***REMOVED******REMOVED***/ if `filterPhrase` is empty.
***REMOVED***var matchingValues: [CodedValue] {
***REMOVED******REMOVED***guard !filterPhrase.isEmpty else {
***REMOVED******REMOVED******REMOVED***return codedValues
***REMOVED***
***REMOVED******REMOVED***return codedValues
***REMOVED******REMOVED******REMOVED***.filter { $0.name.localizedStandardContains(filterPhrase) ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for a combo box input.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form containing the input.
***REMOVED******REMOVED***/   - element: The input's parent element.
***REMOVED******REMOVED***/   - input: The input configuration of the view.
***REMOVED***init(featureForm: FeatureForm?, element: FieldFormElement, input: ComboBoxFormInput) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.noValueLabel = input.noValueLabel
***REMOVED******REMOVED***self.noValueOption = input.noValueOption
***REMOVED******REMOVED***
***REMOVED******REMOVED***_inputModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: FormInputModel(fieldFormElement: element)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for a combo box input.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form containing the input.
***REMOVED******REMOVED***/   - element: The input's parent element.
***REMOVED******REMOVED***/   - noValueLabel: The text used to represent a `nil` value.
***REMOVED******REMOVED***/   - noValueOption: The display state value for `nil` value options.
***REMOVED***init(featureForm: FeatureForm?, element: FieldFormElement, noValueLabel: String, noValueOption: FormInputNoValueOption) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.noValueLabel = noValueLabel
***REMOVED******REMOVED***self.noValueOption = noValueOption
***REMOVED******REMOVED***
***REMOVED******REMOVED***_inputModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: FormInputModel(fieldFormElement: element)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***InputHeader(label: element.label, isRequired: inputModel.isRequired)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(selectedValue?.name ?? placeholderValue)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(selectedValue != nil ? .primary : .secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Value")
***REMOVED******REMOVED******REMOVED******REMOVED***if selectedValue == nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "list.bullet")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Options Button")
***REMOVED******REMOVED******REMOVED*** else if !inputModel.isRequired && inputModel.isEditable  {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ClearButton { selectedValue = nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Clear Button")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.formInputStyle()
***REMOVED******REMOVED******REMOVED******REMOVED*** Pass `matchingValues` via a capture list so that the sheet receives up-to-date values.
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isPresented) { [matchingValues] in
***REMOVED******REMOVED******REMOVED******REMOVED***makePicker(for: matchingValues)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***InputFooter(element: element, requiredValueMissing: requiredValueMissing)
***REMOVED***
***REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***codedValues = featureForm!.codedValues(fieldName: element.fieldName)
***REMOVED******REMOVED******REMOVED***selectedValue = codedValues.first { $0.name == element.value ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: selectedValue) { newValue in
***REMOVED******REMOVED******REMOVED***guard newValue?.name != inputModel.value else {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***

***REMOVED******REMOVED******REMOVED***requiredValueMissing = element.isRequired && newValue == nil
***REMOVED******REMOVED******REMOVED***featureForm?.feature.setAttributeValue(newValue?.code, forKey: element.fieldName)
***REMOVED******REMOVED******REMOVED***model.evaluateExpressions()
***REMOVED***
***REMOVED******REMOVED***.onChange(of: inputModel.value) { newValue in
***REMOVED******REMOVED******REMOVED***let codedValues = featureForm!.codedValues(fieldName: element.fieldName)
***REMOVED******REMOVED******REMOVED***selectedValue = codedValues.first { $0.name == newValue ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view that allows the user to filter and select coded values by name.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Adds navigation context to support toolbar items and other visual elements in the picker.
***REMOVED******REMOVED***/ - Note `NavigationView` is deprecated after iOS 17.0.
***REMOVED***func makePicker(for values: [CodedValue]) -> some View {
***REMOVED******REMOVED***let picker = {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if element.value.isEmpty && !element.isRequired {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if noValueOption == .show {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedValue = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(noValueLabel.isEmpty ? String.noValue : noValueLabel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.italic()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if selectedValue == nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "checkmark")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.accentColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(values, id: \.self) { codedValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(codedValue.name) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedValue = codedValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if codedValue == selectedValue {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "checkmark")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.accentColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if #available(iOS 16, macCatalyst 16, *) {
***REMOVED******REMOVED******REMOVED***return NavigationStack {
***REMOVED******REMOVED******REMOVED******REMOVED***picker()
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return NavigationView {
***REMOVED******REMOVED******REMOVED******REMOVED***picker()
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
***REMOVED******REMOVED***case (.hide, _):
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

extension CodedValue: Equatable {
***REMOVED******REMOVED***/ - Note: Equatable conformance added temporarily in lieu of finalized API.
***REMOVED***public static func == (lhs: CodedValue, rhs: CodedValue) -> Bool {
***REMOVED******REMOVED***lhs.name == rhs.name
***REMOVED***
***REMOVED***

extension CodedValue: Hashable {
***REMOVED******REMOVED***/ - Note: Hashable conformance added temporarily in lieu of finalized API.
***REMOVED***public func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(name)
***REMOVED***
***REMOVED***

extension FeatureForm {
***REMOVED******REMOVED***/ - Note: This property added temporarily in lieu of finalized API.
***REMOVED***func codedValues(fieldName: String) -> [CodedValue] {
***REMOVED******REMOVED***if let field = feature.table?.field(named: fieldName),
***REMOVED******REMOVED***   let domain = field.domain as? CodedValueDomain {
***REMOVED******REMOVED******REMOVED***return domain.codedValues
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return []
***REMOVED***
***REMOVED***
***REMOVED***
