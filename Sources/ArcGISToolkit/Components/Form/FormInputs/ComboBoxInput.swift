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
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var codedValues = [CodedValue]()
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var isPresented = false
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var searchText = ""
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var selectedName: String?
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var value: Bool?
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***private var featureForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ The field's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the field.
***REMOVED***private let input: ComboBoxFormInput
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
***REMOVED******REMOVED******REMOVED******REMOVED***Text(element.value)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.gray)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List(codedValues, id: \.self) { codedValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(codedValue.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Filter")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationTitle(element.label)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Done")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if /*element.value.isEmpty*/ true {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = true
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "list.bullet")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ClearButton { ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Clear Button")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.formTextInputStyle()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***footer
***REMOVED***
***REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***codedValues = featureForm!.codedValues(fieldName: element.fieldName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let value = element.value {  ***REMOVED*** returns name for CodedValues
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switchState = (value == input.onValue.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let codedValue = featureForm?.feature.attributes[element.fieldName] as? CodedValue {
***REMOVED******REMOVED******REMOVED******REMOVED***selectedName = codedValue.name
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: selectedName) { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED***let codedValue = element.codedValues.first { $0.name == newValue ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** element.updateValue(codedValue)
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm?.feature.setAttributeValue(codedValue, forKey: element.fieldName)
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

extension CodedValue: Equatable {
***REMOVED***public static func == (lhs: CodedValue, rhs: CodedValue) -> Bool {
***REMOVED******REMOVED***lhs.name == rhs.name
***REMOVED***
***REMOVED***

extension CodedValue: Hashable {
***REMOVED***public func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(name)
***REMOVED***
***REMOVED***

extension FeatureForm {
***REMOVED***func codedValues(fieldName: String) -> [CodedValue] {
***REMOVED******REMOVED***if let field = feature.table?.field(named: fieldName),
***REMOVED******REMOVED***   let domain = field.domain as? CodedValueDomain {
***REMOVED******REMOVED******REMOVED***return domain.codedValues
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return []
***REMOVED***
***REMOVED***
***REMOVED***
