***REMOVED***
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

***REMOVED***/ A custom view implementing a SearchField. It contains a search button, text field, delete text button,
***REMOVED***/ and a button to allow users to hide/show the search results list.
@available(visionOS, unavailable)
public struct SearchField: View {
***REMOVED******REMOVED***/ Creates a `SearchField`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - query: The current search query.
***REMOVED******REMOVED***/   - prompt: The default placeholder displayed when `currentQuery` is empty.
***REMOVED******REMOVED***/   - isFocused: A Boolean value indicating whether the text field is focused or not.
***REMOVED******REMOVED***/   - isResultsButtonHidden: The visibility of the button used to toggle visibility of the results list.
***REMOVED******REMOVED***/   - isResultListHidden: Binding allowing the user to toggle the visibility of the results list.
***REMOVED***public init(
***REMOVED******REMOVED***query: Binding<String>,
***REMOVED******REMOVED***prompt: String = "",
***REMOVED******REMOVED***isFocused: FocusState<Bool>.Binding,
***REMOVED******REMOVED***isResultsButtonHidden: Bool = false,
***REMOVED******REMOVED***isResultListHidden: Binding<Bool>? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.query = query
***REMOVED******REMOVED***self.prompt = prompt
***REMOVED******REMOVED***self.isFocused = isFocused
***REMOVED******REMOVED***self.isResultsButtonHidden = isResultsButtonHidden
***REMOVED******REMOVED***self.isResultListHidden = isResultListHidden
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current search query.
***REMOVED***private var query: Binding<String>
***REMOVED***
***REMOVED******REMOVED***/ The default placeholder displayed when `currentQuery` is empty.
***REMOVED***private let prompt: String
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the text field is focused or not.
***REMOVED***private var isFocused: FocusState<Bool>.Binding
***REMOVED***
***REMOVED******REMOVED***/ The visibility of the button used to toggle visibility of the results list.
***REMOVED***private let isResultsButtonHidden: Bool
***REMOVED***
***REMOVED******REMOVED***/ Binding allowing the user to toggle the visibility of the results list.
***REMOVED***private var isResultListHidden: Binding<Bool>?
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED*** Search icon
***REMOVED******REMOVED******REMOVED***Image(systemName: "magnifyingglass.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(Color.secondary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Search text field
***REMOVED******REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED******REMOVED***text: query,
***REMOVED******REMOVED******REMOVED******REMOVED***prompt: Text(prompt)
***REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Search Query",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label in reference to a search query entered by the user."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.focused(isFocused)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Delete text button
***REMOVED******REMOVED******REMOVED***if !query.wrappedValue.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***XButton(.clear) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***query.wrappedValue = ""
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Show Results button
***REMOVED******REMOVED******REMOVED***if !isResultsButtonHidden {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isResultListHidden?.wrappedValue.toggle()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***systemName: (isResultListHidden?.wrappedValue ?? false) ?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"chevron.down" :
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"chevron.up"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(Color.secondary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder()
***REMOVED***
***REMOVED***
