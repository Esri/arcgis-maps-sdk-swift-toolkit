***REMOVED*** Copyright 2024 Esri
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

***REMOVED***/ A slider that acts similar to a joystick controller.
***REMOVED***/ The slider provides delta values as they change between -1...1.
struct Joyslider: View {
***REMOVED***private var onChangedAction: ((Double) -> Void)?
***REMOVED***private var onEndedAction: (() -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The x offset of the thumb in points.
***REMOVED***@State private var offset: Double = 0
***REMOVED******REMOVED***/ A factor between -1 and 1 that specifies the current percentage of the thumb's position.
***REMOVED***@State private var factor: Double = 0
***REMOVED******REMOVED***/ A Boolean value indicating if the user is dragging the thumb.
***REMOVED***@State private var isChanging = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Track(offset: offset, factor: factor)
***REMOVED******REMOVED******REMOVED******REMOVED***Thumb()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.offset(x: offset)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.gesture(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DragGesture(minimumDistance: 0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChanged { value in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isChanging = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let halfWidth = (geometry.size.width / 2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offset = value.translation.width.clamped(to: -halfWidth...halfWidth)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***factor = offset / halfWidth
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onEnded { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isChanging = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation(.bouncy.speed(1.5)) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offset = 0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onEndedAction?()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.frame(height: Thumb.size + 4)
***REMOVED******REMOVED***.task(id: isChanging) {
***REMOVED******REMOVED******REMOVED******REMOVED*** This task block executes whenever isChanging property changes.
***REMOVED******REMOVED******REMOVED******REMOVED*** If isChanging is `false`, then return.
***REMOVED******REMOVED******REMOVED***guard isChanging else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Run a loop while the Task is not cancelled.
***REMOVED******REMOVED******REMOVED***while !Task.isCancelled {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Sleep for 50 milliseconds.
***REMOVED******REMOVED******REMOVED******REMOVED***try? await Task.sleep(for: .milliseconds(50))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If task is cancelled after sleeping, return.
***REMOVED******REMOVED******REMOVED******REMOVED***if Task.isCancelled { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Otherwise change the value.
***REMOVED******REMOVED******REMOVED******REMOVED***onChangedAction?(factor)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Specifies an action to perform when the value changes.
***REMOVED***func onChanged(perform action: @escaping (Double) -> Void) -> Joyslider {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.onChangedAction = action
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Specifies an action to perform when the value stops changing.
***REMOVED***func onEnded(perform action: @escaping () -> Void) -> Joyslider {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.onEndedAction = action
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

***REMOVED***/ Thumb view for the joyslider.
private struct Thumb: View {
***REMOVED******REMOVED***/ The size of the thumb.
***REMOVED***static let size: Double = 26
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED***.stroke(Color.accentColor, lineWidth: 2)
***REMOVED******REMOVED******REMOVED***.frame(width: Self.size, height: Self.size)
***REMOVED******REMOVED******REMOVED***.background {
***REMOVED******REMOVED******REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: Self.size, height: Self.size)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.background)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.shadow(color: .secondary.opacity(0.5), radius: 5, x: 0, y: 2)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ Track view for the joyslider.
private struct Track: View {
***REMOVED******REMOVED***/ The x offset of the thumb in points.
***REMOVED***let offset: Double
***REMOVED******REMOVED***/ A factor between -1 and 1 that specifies the current percentage of the thumb's position.
***REMOVED***let factor: Double
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***Capsule(style: .continuous)
***REMOVED******REMOVED******REMOVED******REMOVED***.fill(Color.systemFill)
***REMOVED******REMOVED******REMOVED***if offset != 0 {
***REMOVED******REMOVED******REMOVED******REMOVED***Capsule(style: .continuous)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fill(fill)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: abs(offset))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.offset(x: offset / 2)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.frame(height: 4)
***REMOVED***
***REMOVED***
***REMOVED***var fill: some ShapeStyle {
***REMOVED******REMOVED***if offset >= 0 {
***REMOVED******REMOVED******REMOVED***return LinearGradient(
***REMOVED******REMOVED******REMOVED******REMOVED***gradient: Gradient(colors: [.clear, .accentColor]),
***REMOVED******REMOVED******REMOVED******REMOVED***startPoint: .leading,
***REMOVED******REMOVED******REMOVED******REMOVED***endPoint: .trailing
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return LinearGradient(
***REMOVED******REMOVED******REMOVED******REMOVED***gradient: Gradient(colors: [.clear, .accentColor]),
***REMOVED******REMOVED******REMOVED******REMOVED***startPoint: .trailing,
***REMOVED******REMOVED******REMOVED******REMOVED***endPoint: .leading
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

private extension Color {
***REMOVED******REMOVED***/ The system fill color.
***REMOVED***static var systemFill: Color { Color(UIColor.systemFill) ***REMOVED***
***REMOVED***
