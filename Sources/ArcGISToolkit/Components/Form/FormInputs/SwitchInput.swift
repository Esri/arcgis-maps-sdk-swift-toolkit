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

***REMOVED***/ A view for boolean style input.
***REMOVED***/
***REMOVED***/ The switch represents two mutually exclusive values, such as: yes/no, on/off, true/false.
struct SwitchInput: View {
***REMOVED***@Environment(\.formElementPadding) var elementPadding
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the current value doesn't exist as an option in the domain.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ In this scenario a ``ComboBoxInput`` should be used instead.
***REMOVED***@State private var fallbackToComboBox = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether a value is required but missing.
***REMOVED***@State private var requiredValueMissing = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the switch is toggled on or off.
***REMOVED***@State private var switchState: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ The value represented by the switch.
***REMOVED***@State private var selectedValue: Bool?
***REMOVED***
***REMOVED******REMOVED***/ The field's parent element.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The feature form containing the input.
***REMOVED***private var featureForm: FeatureForm?
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the field.
***REMOVED***private let input: SwitchFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for a switch input.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form containing the input.
***REMOVED******REMOVED***/   - element: The field's parent element.
***REMOVED******REMOVED***/   - input: The input configuration of the field.
***REMOVED***init(featureForm: FeatureForm?, element: FieldFormElement, input: SwitchFormInput) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.input = input
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if fallbackToComboBox {
***REMOVED******REMOVED******REMOVED***ComboBoxInput(
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm: featureForm,
***REMOVED******REMOVED******REMOVED******REMOVED***element: element,
***REMOVED******REMOVED******REMOVED******REMOVED***noValueLabel: .noValue,
***REMOVED******REMOVED******REMOVED******REMOVED***noValueOption: .show
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***InputHeader(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED******REMOVED******REMOVED***Toggle(switchState ? input.onValue.name : input.offValue.name, isOn: $switchState)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.toggleStyle(.switch)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.horizontal], 5)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.formInputStyle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Switch")
***REMOVED******REMOVED******REMOVED******REMOVED***InputFooter(element: element, requiredValueMissing: requiredValueMissing)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***if element.value.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fallbackToComboBox = true
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switchState = isOn
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: switchState) { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED***let codedValue = newValue ? input.onValue : input.offValue
***REMOVED******REMOVED******REMOVED******REMOVED***featureForm?.feature.setAttributeValue(codedValue.code, forKey: element.fieldName)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension SwitchInput {
***REMOVED******REMOVED***/ A Boolean value indicating whether the switch is toggled on or off.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Element values are provided as Strings whereas input on/off value codes may be a number of
***REMOVED******REMOVED***/ types. We must cast the element value string to the correct type to perform an accurate check.
***REMOVED***var isOn: Bool {
***REMOVED******REMOVED***switch input.onValue.code {
***REMOVED******REMOVED***case let value as Double:
***REMOVED******REMOVED******REMOVED***return Double(element.value) == value
***REMOVED******REMOVED***case let value as Float:
***REMOVED******REMOVED******REMOVED***return Float(element.value) == value
***REMOVED******REMOVED***case let value as Int:
***REMOVED******REMOVED******REMOVED***return Int(element.value) == value
***REMOVED******REMOVED***case let value as Int8:
***REMOVED******REMOVED******REMOVED***return Int8(element.value) == value
***REMOVED******REMOVED***case let value as Int16:
***REMOVED******REMOVED******REMOVED***return Int16(element.value) == value
***REMOVED******REMOVED***case let value as Int32:
***REMOVED******REMOVED******REMOVED***return Int32(element.value) == value
***REMOVED******REMOVED***case let value as Int64:
***REMOVED******REMOVED******REMOVED***return Int64(element.value) == value
***REMOVED******REMOVED***case let value as String:
***REMOVED******REMOVED******REMOVED***return element.value == value
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED***
