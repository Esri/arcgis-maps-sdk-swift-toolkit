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

***REMOVED***/ A view shown at the top of a form.
struct FormHeader: View {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let backNavigationAction: (() -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The title defined for the form.
***REMOVED***let title: String
***REMOVED***
***REMOVED***init(title: String, backNavigationAction: (() -> Void)? = nil) {
***REMOVED******REMOVED***self.backNavigationAction = backNavigationAction
***REMOVED******REMOVED***self.title = title
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if let backNavigationAction {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Back", systemImage: "chevron.backward") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***backNavigationAction()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.labelStyle(.iconOnly)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.bold)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text.discard
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.opacity(<#T##opacity: Double##Double#>)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text.finish
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.opacity(<#T##opacity: Double##Double#>)
***REMOVED***
***REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***

private extension Text {
***REMOVED******REMOVED***/ A label for a button to discard edits to the feature form.
***REMOVED***static var discard: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Discard",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to discard edits to the feature form."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A label for a button to finish editing the feature form.
***REMOVED***static var finish: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Finish",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to finish editing the feature form."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
