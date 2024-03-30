***REMOVED*** Copyright 2022 Esri
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

***REMOVED***/ A modifier which monitors UIResponder keyboard notifications.
***REMOVED***/
***REMOVED***/ This modifier makes it easy to monitor state changes of the device keyboard.
struct KeyboardStateChangedModifier: ViewModifier {
***REMOVED******REMOVED***/ The closure to perform when the keyboard state has changed.
***REMOVED***var action: (KeyboardState, CGFloat) -> Void
***REMOVED***
***REMOVED***@ViewBuilder func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) {
***REMOVED******REMOVED******REMOVED******REMOVED***action(.opening, ($0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).height)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) {
***REMOVED******REMOVED******REMOVED******REMOVED***action(.open, ($0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).height)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***action(.closing, .zero)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***action(.closed, .zero)
***REMOVED******REMOVED***
***REMOVED***
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
***REMOVED******REMOVED***/ Sets a closure to perform when the keyboard state has changed.
***REMOVED******REMOVED***/ - Parameter action: The closure to perform when the keyboard state has changed.
***REMOVED***@ViewBuilder func onKeyboardStateChanged(_ action: @escaping (KeyboardState, CGFloat) -> Void) -> some View {
***REMOVED******REMOVED***modifier(KeyboardStateChangedModifier(action: action))
***REMOVED***
***REMOVED***
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
***REMOVED******REMOVED***/ Adds an equal padding amount to the horizontal edges of this view if the target environment
***REMOVED******REMOVED***/ is Mac Catalyst.
***REMOVED******REMOVED***/ - Parameter length: An amount, given in points, to pad this view on the horizontal edges.
***REMOVED******REMOVED***/ If you set the value to nil, SwiftUI uses a platform-specific default amount.
***REMOVED******REMOVED***/ The default value of this parameter is nil.
***REMOVED******REMOVED***/ - Returns: A view that’s padded by the specified amount on the horizontal edges.
***REMOVED***func catalystPadding(_ length: CGFloat? = nil) -> some View {
***REMOVED******REMOVED***return self
***REMOVED******REMOVED******REMOVED***.padding(isMacCatalyst ? [.horizontal] : [], length)
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
***REMOVED******REMOVED***/ Performs the provided action when the view appears after a slight delay.
***REMOVED******REMOVED***/ - Tip: Occasionally delaying allows a sheet's presentation animation to work correctly.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - delay: The delay to wait before allow the task to proceed, in nanoseconds. Defaults to 1/4 second.
***REMOVED******REMOVED***/   - action: The action to perform after the delay.
***REMOVED***func delayedOnAppear(nanoseconds: UInt64 = 250_000_000, action: @MainActor @escaping () -> Void) -> some View {
***REMOVED******REMOVED***task { @MainActor in
***REMOVED******REMOVED******REMOVED***try? await Task.sleep(nanoseconds: nanoseconds)
***REMOVED******REMOVED******REMOVED***action()
***REMOVED***
***REMOVED***
***REMOVED***

extension View {
***REMOVED******REMOVED***/ Adds an action to perform when this view detects data emitted by the
***REMOVED******REMOVED***/ given async sequence. If `action` is `nil`, then the async sequence is not observed.
***REMOVED******REMOVED***/ The `action` closure is captured the first time the view appears.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - sequence: The async sequence to observe.
***REMOVED******REMOVED***/   - action: The action to perform when a value is emitted by `sequence`.
***REMOVED******REMOVED***/   The value emitted by `sequence` is passed as a parameter to `action`.
***REMOVED******REMOVED***/   The `action` is called on the `MainActor`.
***REMOVED******REMOVED***/ - Returns: A view that triggers `action` when `sequence` emits a value.
***REMOVED***@MainActor @ViewBuilder func onReceive<S>(
***REMOVED******REMOVED***_ sequence: S,
***REMOVED******REMOVED***perform action: ((S.Element) -> Void)?
***REMOVED***) -> some View where S: AsyncSequence {
***REMOVED******REMOVED***if let action {
***REMOVED******REMOVED******REMOVED***task {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for try await element in sequence {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(element)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** catch {***REMOVED***
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***
