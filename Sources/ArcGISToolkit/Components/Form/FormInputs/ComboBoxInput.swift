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

struct ComboBoxInput: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
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
***REMOVED******REMOVED***/ The selected option.
***REMOVED***@State private var selectedValue: CodedValue?
***REMOVED***
***REMOVED******REMOVED***/ The feature form containing the input.
***REMOVED***private var featureForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ The field's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the field.
***REMOVED***private let input: ComboBoxFormInput
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
***REMOVED******REMOVED***/   - element: The field's parent element.
***REMOVED******REMOVED***/   - input: The input configuration of the field.
***REMOVED***init(featureForm: FeatureForm?, element: FieldFormElement, input: ComboBoxFormInput) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.input = input
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***FormElementHeader(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(selectedValue?.name ?? "No value")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(selectedValue != nil ? .primary : .secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if selectedValue == nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "list.bullet")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ClearButton { selectedValue = nil ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Clear Button")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.formTextInputStyle()
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***picker
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED*** isPresented = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***footer
***REMOVED***
***REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***codedValues = featureForm!.codedValues(fieldName: element.fieldName)
***REMOVED******REMOVED******REMOVED***selectedValue = codedValues.first { $0.name == element.value ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: selectedValue) { newValue in
***REMOVED******REMOVED******REMOVED***guard let current = codedValues.first(where: { $0.name == element.value ***REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***  current != newValue else {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***featureForm?.feature.setAttributeValue(newValue?.code, forKey: element.fieldName)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The message shown below the picker.
***REMOVED***@ViewBuilder var footer: some View {
***REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view that allows the user to filter and select coded values by name.
***REMOVED***var picker: some View {
***REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***List(matchingValues, id: \.self) { codedValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(codedValue.name) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedValue = codedValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if codedValue == selectedValue {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "checkmark")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.accentColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED***.searchable(text: $filterPhrase, placement: .navigationBarDrawer, prompt: "Filter")
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationTitle(element.label)
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Done")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
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
