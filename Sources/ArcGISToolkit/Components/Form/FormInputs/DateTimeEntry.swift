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
***REMOVED***@State private var date = Date.now
***REMOVED***
***REMOVED***@State private var isEditing = false
***REMOVED***
***REMOVED***let element: FieldFeatureFormElement
***REMOVED***
***REMOVED***let input: DateTimePickerFeatureFormInput
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***FormElementHeader(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top], elementPadding)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if isEditing {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***doneButton
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***datePicker
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.datePickerStyle(.graphical)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField(element.label, text: Binding(get: { String(describing: date) ***REMOVED***, set: { _ in ***REMOVED***))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.formTextEntryStyle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(true)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isEditing = true
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let description = element.description {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.padding([.bottom], elementPadding)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***if let date = model.feature?.attributes[element.fieldName] as? Date {
***REMOVED******REMOVED******REMOVED******REMOVED***self.date = date
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: date) { newValue in
***REMOVED******REMOVED******REMOVED***model.feature?.setAttributeValue(newValue, forKey: element.fieldName)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder var datePicker: some View {
***REMOVED******REMOVED***if let min = input.min, let max = input.max {
***REMOVED******REMOVED******REMOVED***DatePicker(selection: $date, in: min...max, displayedComponents: displayedComponents) { EmptyView() ***REMOVED***
***REMOVED*** else if let min = input.min {
***REMOVED******REMOVED******REMOVED***DatePicker(selection: $date, in: min..., displayedComponents: displayedComponents) { EmptyView() ***REMOVED***
***REMOVED*** else if let max = input.max {
***REMOVED******REMOVED******REMOVED***DatePicker(selection: $date, in: ...max, displayedComponents: displayedComponents) { EmptyView() ***REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***DatePicker(selection: $date, displayedComponents: displayedComponents) { EmptyView() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var doneButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***withAnimation { isEditing = false ***REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Done",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button to save a date (and time if applicable) selection."
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var displayedComponents: DatePicker.Components {
***REMOVED******REMOVED***input.includeTime ? [.date, .hourAndMinute] : [.date]
***REMOVED***
***REMOVED***
