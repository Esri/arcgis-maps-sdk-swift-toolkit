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

***REMOVED***/ A view shown at the bottom of a form with buttons to cancel or submit the form.
struct FormFooter: View {
***REMOVED******REMOVED***/ The closure to execute when the submit button is pressed.
***REMOVED***let onSubmit: () -> Void
***REMOVED***
***REMOVED******REMOVED***/ The closure to execute when the cancel button is pressed.
***REMOVED***let onCancel: () -> Void
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***makeCancelButton()
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.horizontal])
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***makeSubmitButton()
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.horizontal])
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A button to cancel a form.
***REMOVED***func makeCancelButton() -> some View {
***REMOVED******REMOVED***Button(role: .cancel) {
***REMOVED******REMOVED******REMOVED***onCancel()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Cancel",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button to cancel a form."
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A button to submit a form.
***REMOVED***func makeSubmitButton() -> some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***onSubmit()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Submit",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button to submit changes in a form."
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.borderedProminent)
***REMOVED***
***REMOVED***
