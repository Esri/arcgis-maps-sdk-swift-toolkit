***REMOVED***.

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

***REMOVED***/ A custom view implementing a SearchField.  It contains a search button, text field, delete text button,
***REMOVED***/ and a button to allow users to hide/show the search results list.
public struct SearchField: View {
***REMOVED******REMOVED***/ The current search query.
***REMOVED***public var currentQuery: Binding<String>

***REMOVED******REMOVED***/ The default placeholder displayed when `currentQuery` is empty.
***REMOVED***public var searchFieldPrompt: String = ""

***REMOVED******REMOVED***/ The visibility of the `showResults` button.
***REMOVED***public var isShowResultsHidden: Bool = true

***REMOVED******REMOVED***/ Binding allowing the user to toggle the visibility of the results list.
***REMOVED***public var showResults: Binding<Bool>? = nil
***REMOVED***
***REMOVED******REMOVED***/ The handler executed when the user submits a search, either via the `TextField`
***REMOVED******REMOVED***/ or the Search button.
***REMOVED***public var onCommit: () -> Void = { ***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED*** Search button
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***onCommit()
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "magnifyingglass.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(Color(uiColor: .opaqueSeparator))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Search text field
***REMOVED******REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED******REMOVED***"Search Query",
***REMOVED******REMOVED******REMOVED******REMOVED***text: currentQuery,
***REMOVED******REMOVED******REMOVED******REMOVED***prompt: Text(searchFieldPrompt)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit { onCommit() ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Delete text button
***REMOVED******REMOVED******REMOVED***if !currentQuery.wrappedValue.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentQuery.wrappedValue = ""
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(Color(.opaqueSeparator))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Show Results button
***REMOVED******REMOVED******REMOVED***if !isShowResultsHidden {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showResults?.wrappedValue.toggle()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "eye")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbolVariant(!(showResults?.wrappedValue ?? false) ? .none : .slash)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbolVariant(.fill)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(Color(.opaqueSeparator))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder()
***REMOVED***
***REMOVED***
