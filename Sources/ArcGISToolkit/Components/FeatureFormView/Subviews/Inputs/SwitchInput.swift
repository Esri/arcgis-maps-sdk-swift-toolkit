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
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the current value doesn't exist as an option in the domain.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ In this scenario a ``ComboBoxInput`` should be used instead.
***REMOVED***@State private var fallbackToComboBox = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the switch is toggled on or off.
***REMOVED***@State private var isOn = false
***REMOVED***
***REMOVED******REMOVED***/ The value represented by the switch.
***REMOVED***@State private var selectedValue: Bool?
***REMOVED***
***REMOVED******REMOVED***/ The element the input belongs to.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the field.
***REMOVED***private let input: SwitchFormInput
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for a switch input.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The field's parent element.
***REMOVED***init(element: FieldFormElement) {
***REMOVED******REMOVED***precondition(
***REMOVED******REMOVED******REMOVED***element.input is SwitchFormInput,
***REMOVED******REMOVED******REMOVED***"\(Self.self).\(#function) element's input must be \(SwitchFormInput.self)."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.input = element.input as! SwitchFormInput
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if fallbackToComboBox {
***REMOVED******REMOVED******REMOVED***ComboBoxInput(
***REMOVED******REMOVED******REMOVED******REMOVED***element: element,
***REMOVED******REMOVED******REMOVED******REMOVED***noValueLabel: .noValue,
***REMOVED******REMOVED******REMOVED******REMOVED***noValueOption: .show
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Toggle(isOn: $isOn) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(isOn ? input.onValue.name : input.offValue.name)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Switch")
***REMOVED******REMOVED******REMOVED***.formInputStyle(isTappable: false)
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***if element.formattedValue.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fallbackToComboBox = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(isOn) { isOn in
***REMOVED******REMOVED******REMOVED******REMOVED***element.updateValue(isOn ? input.onValue.code : input.offValue.code)
***REMOVED******REMOVED******REMOVED******REMOVED***model.evaluateExpressions()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED***isOn.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED***model.focusedElement = element
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onValueChange(of: element) { newValue, newFormattedValue in
***REMOVED******REMOVED******REMOVED******REMOVED***isOn = newFormattedValue == input.onValue.name
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
