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

struct Joyslider: View {
***REMOVED***var onValueChangedAction: ((Double) -> Void)?
***REMOVED***
***REMOVED***@State private var offset: Double = 0
***REMOVED***@State private var factor: Double = 0
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offset = max(min(value.translation.width, halfWidth), -halfWidth)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***factor = offset / halfWidth
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onEnded { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isChanging = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation(.bouncy) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***offset = 0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.frame(height: Thumb.size + 4)
***REMOVED******REMOVED***.task(id: isChanging) {
***REMOVED******REMOVED******REMOVED***guard isChanging else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***while !Task.isCancelled {
***REMOVED******REMOVED******REMOVED******REMOVED***if #available(iOS 17, *) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try? await Task.sleep(for: .milliseconds(50))
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try? await Task.sleep(nanoseconds: 50_000_000)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if Task.isCancelled { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let change = factor
***REMOVED******REMOVED******REMOVED******REMOVED***onValueChangedAction?(change)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func onValueChanged(perform action: @escaping (Double) -> Void) -> Joyslider {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.onValueChangedAction = action
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

private struct Thumb: View {
***REMOVED***static let size: Double = 26
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

private struct Track: View {
***REMOVED***let offset: Double
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.offset(x: offset/2)
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
***REMOVED***static var systemFill: Color { Color(UIColor.systemFill) ***REMOVED***
***REMOVED***

#Preview {
***REMOVED***VStack {
***REMOVED******REMOVED***Slider(value: .constant(0.5))
***REMOVED******REMOVED***Joyslider()
***REMOVED******REMOVED***Slider(value: .constant(0.5))
***REMOVED***
***REMOVED***.padding()
***REMOVED***
