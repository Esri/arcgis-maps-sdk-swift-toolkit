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

***REMOVED***/ A modifier which adds a "search" button in a view, used to initiate an operation.
struct EsriSearchButtonViewModifier: ViewModifier {
***REMOVED***var action: () -> Void
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Button(
***REMOVED******REMOVED******REMOVED******REMOVED***action: action,
***REMOVED******REMOVED******REMOVED******REMOVED***label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "magnifyingglass.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(Color(uiColor: .opaqueSeparator))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***content
***REMOVED***
***REMOVED***
***REMOVED***

extension View {
***REMOVED***func esriSearchButton(_ action: @escaping () -> Void) -> some View {
***REMOVED******REMOVED***modifier(EsriSearchButtonViewModifier(action: action))
***REMOVED***
***REMOVED***
