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

***REMOVED***/ A modifier which displays a background and shadow for a view. Used to represent a selected view.
struct SelectedModifier: ViewModifier {
***REMOVED******REMOVED***/ `true` if the view should display as selected, `false` otherwise.
***REMOVED***var isSelected: Bool
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***let roundedRect = RoundedRectangle(cornerRadius: 4)
***REMOVED******REMOVED***if isSelected {
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED***.background(Color.secondary.opacity(0.8))
***REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(roundedRect)
***REMOVED******REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: Color.secondary.opacity(0.8),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: 2
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***content
***REMOVED***
***REMOVED***
***REMOVED***

extension View {
***REMOVED******REMOVED***/ Returns a new `View` that allows a parent `View` to be informed of a child view's size.
***REMOVED******REMOVED***/ - Parameter perform: The closure to be executed when the content size of the receiver
***REMOVED******REMOVED***/ changes.
***REMOVED******REMOVED***/ - Returns: A new `View`.
***REMOVED***func onSizeChange(perform: @escaping (CGSize) -> Void) -> some View {
***REMOVED******REMOVED***background(
***REMOVED******REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED******REMOVED***Color.clear
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.preference(key: SizePreferenceKey.self, value: geometry.size)
***REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.onPreferenceChange(SizePreferenceKey.self, perform: perform)
***REMOVED***

***REMOVED******REMOVED***/ View modifier used to denote the view is selected.
***REMOVED******REMOVED***/ - Parameter isSelected: `true` if the view is selected, `false` otherwise.
***REMOVED******REMOVED***/ - Returns: The view being modified.
***REMOVED***func selected(
***REMOVED******REMOVED***_ isSelected: Bool = false
***REMOVED***) -> some View {
***REMOVED******REMOVED***modifier(SelectedModifier(isSelected: isSelected))
***REMOVED***
***REMOVED***
