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

***REMOVED***/ SwiftUI `TextEditor` and `TextField` views have different styling. `TextField`s have
***REMOVED***/ `textFieldStyle` and `TextEditor`s do not. This modifier allows for common styling.
struct FormTextEntryBorder: ViewModifier {
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.padding(2)
***REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: 5)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.secondary.opacity(0.5), lineWidth: 0.5)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

extension View {
***REMOVED******REMOVED***/ Adds a common padding and border around form field text elements.
***REMOVED***func formTextEntryBorder() -> some View {
***REMOVED******REMOVED***modifier(FormTextEntryBorder())
***REMOVED***
***REMOVED***
