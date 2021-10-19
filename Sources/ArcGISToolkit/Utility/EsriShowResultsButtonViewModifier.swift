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

***REMOVED***/ A modifier which adds a "show results" button in a view, used to hide/show another view.
struct EsriShowResultsButtonViewModifier: ViewModifier {
***REMOVED***var isEnabled: Bool
***REMOVED***@Binding var isHidden: Bool
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***if isEnabled {
***REMOVED******REMOVED******REMOVED******REMOVED***Button(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action: { isHidden.toggle() ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "eye")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbolVariant(isHidden ? .none : .slash)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbolVariant(.fill)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(Color(.opaqueSeparator))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension View {
***REMOVED***func esriShowResultsButton(
***REMOVED******REMOVED***isEnabled: Bool,
***REMOVED******REMOVED***isHidden: Binding<Bool>
***REMOVED***) -> some View {
***REMOVED******REMOVED***modifier(EsriShowResultsButtonViewModifier(
***REMOVED******REMOVED******REMOVED***isEnabled: isEnabled,
***REMOVED******REMOVED******REMOVED***isHidden: isHidden
***REMOVED******REMOVED***))
***REMOVED***
***REMOVED***
