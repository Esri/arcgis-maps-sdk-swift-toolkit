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
***REMOVED******REMOVED***/ A Boolean value that indicates whether view should display as selected.
***REMOVED***var isSelected: Bool
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***if isSelected {
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED***.background(Color.secondary.opacity(0.8))
***REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 4))
***REMOVED******REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: .secondary.opacity(0.8),
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.preference(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***key: SizePreferenceKey.self, value: geometry.size
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.onPreferenceChange(SizePreferenceKey.self, perform: perform)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ View modifier used to denote the view is selected.
***REMOVED******REMOVED***/ - Parameter isSelected: `true` if the view is selected, `false` otherwise.
***REMOVED******REMOVED***/ - Returns: The modified view.
***REMOVED***func selected(
***REMOVED******REMOVED***_ isSelected: Bool = false
***REMOVED***) -> some View {
***REMOVED******REMOVED***modifier(SelectedModifier(isSelected: isSelected))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a new view with medium presentation detents, if presentation
***REMOVED******REMOVED***/ detents are supported (iOS 16 and up).
***REMOVED***func mediumPresentationDetents() -> some View {
***REMOVED******REMOVED***if #available(iOS 16.0, *) {
***REMOVED******REMOVED******REMOVED***return self
***REMOVED******REMOVED******REMOVED******REMOVED***.presentationDetents([.medium])
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return self
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Performs the provided action after a slight delay.
***REMOVED******REMOVED***/ - Tip: Occasionally delaying allows a sheet's presentation animation to work correctly.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - delay: The delay to wait before allow the task to proceed, in nanoseconds. Defaults to 1/4 second.
***REMOVED******REMOVED***/   - action: The action to perform after the delay.
***REMOVED***func delayedTask(nanoseconds: UInt64 = 250_000_000, action: @escaping () -> Void) -> some View {
***REMOVED******REMOVED***task {
***REMOVED******REMOVED******REMOVED***try? await Task.sleep(nanoseconds: nanoseconds)
***REMOVED******REMOVED******REMOVED***action()
***REMOVED***
***REMOVED***
***REMOVED***
