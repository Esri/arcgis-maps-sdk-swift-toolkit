***REMOVED*** Copyright 2022 Esri.

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

***REMOVED***/ A modifier which "selects" a button. If selected, the button will be displayed with the
***REMOVED***/ `BorderedProminentButtonStyle`. Otherwise, the button will be displayed with the
***REMOVED***/ `BorderedButtonStyle`.
struct ButtonSelectedModifier: ViewModifier {
***REMOVED******REMOVED***/ A Boolean value that indicates whether view should display as selected.
***REMOVED***let isSelected: Bool
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***if isSelected {
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(BorderedProminentButtonStyle())
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(BorderedButtonStyle())
***REMOVED***
***REMOVED***
***REMOVED***

extension Button {
***REMOVED******REMOVED***/ Button modifier used to denote the button is selected.
***REMOVED******REMOVED***/ - Parameter isSelected: `true` if the button is selected, `false` otherwise.
***REMOVED******REMOVED***/ - Returns: The modified button.
***REMOVED***func selected(
***REMOVED******REMOVED***_ isSelected: Bool = false
***REMOVED***) -> some View {
***REMOVED******REMOVED***modifier(ButtonSelectedModifier(isSelected: isSelected))
***REMOVED***
***REMOVED***
