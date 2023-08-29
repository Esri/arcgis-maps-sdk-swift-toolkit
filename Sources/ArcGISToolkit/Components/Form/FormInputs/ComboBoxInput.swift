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

struct ComboBoxInput: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED***private var featureForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ The field's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the field.
***REMOVED***private let input: ComboBoxFormInput
***REMOVED***
***REMOVED***@State private var value: Bool?
***REMOVED***
***REMOVED***enum Flavor: String, CaseIterable, Identifiable {
***REMOVED******REMOVED***case chocolate, vanilla, strawberry
***REMOVED******REMOVED***var id: Self { self ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@State private var selectedName: String?
***REMOVED***
***REMOVED******REMOVED***@State private var switchState: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for a Switch input.
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
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***FormElementHeader(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Need to figure out $selectedValue, given that codedValue.code is an "Object"
***REMOVED******REMOVED******REMOVED******REMOVED*** CodedValue is equatable and hashable, so maybe that's enough??
***REMOVED******REMOVED******REMOVED***Picker("element.label", selection: $selectedName) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("coded values go here")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(element.codedValues) { codedValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(codedValue.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.tag(codedValue.code)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Picker("Flavor", selection: $selectedFlavor) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Chocolate").tag(Flavor.chocolate)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Vanilla").tag(Flavor.vanilla)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Strawberry").tag(Flavor.strawberry)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.pickerStyle(.menu)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***footer
***REMOVED***
***REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED***.onAppear {
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
***REMOVED******REMOVED***/ The message shown below the date editor and viewer.
***REMOVED***@ViewBuilder var footer: some View {
***REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED***
***REMOVED***
