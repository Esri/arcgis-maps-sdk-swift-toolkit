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

public enum PartialSheetPreset {
***REMOVED***case min, mid, max
***REMOVED***

***REMOVED***/ A partial sheet is a view that overlays a view and supplies view-related
***REMOVED***/ content.
***REMOVED***/
***REMOVED***/ A partial sheet offers an advantage over a native sheet in that it allows user interaction with any view
***REMOVED***/ behind it.
public struct PartialSheet<Content: View>: View {
***REMOVED******REMOVED***/ Records the drag gesture for new height calculations.
***REMOVED***@State private var dragTranslation: CGFloat = .zero
***REMOVED***
***REMOVED******REMOVED***/ The color of the handle.
***REMOVED***@State private var handleColor: Color = .defaultHandleColor
***REMOVED***
***REMOVED******REMOVED***/ Allows the user to drag the sheet to a specific height.
***REMOVED***@State private var yOffset: CGFloat = 0
***REMOVED***
***REMOVED******REMOVED***/ Allows the parent to control the height of the sheet.
***REMOVED***@Binding var preset: PartialSheetPreset?
***REMOVED***
***REMOVED******REMOVED***/ The content shown in the floating panel.
***REMOVED***private let content: Content
***REMOVED***
***REMOVED******REMOVED***/ Creates a `FloatingPanel`
***REMOVED******REMOVED***/ - Parameter content: The view shown in the floating panel.
***REMOVED***public init(preset: Binding<PartialSheetPreset?>, @ViewBuilder content: () -> Content) {
***REMOVED******REMOVED***self.content = content()
***REMOVED******REMOVED***_preset = preset
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines the current of the sheet, either from the preset value or `yOffset`.
***REMOVED***private func heightFromPreset(with geometryProxy: GeometryProxy) -> CGFloat {
***REMOVED******REMOVED***switch preset {
***REMOVED******REMOVED***case .min:
***REMOVED******REMOVED******REMOVED***return 200.0
***REMOVED******REMOVED***case .mid:
***REMOVED******REMOVED******REMOVED***return geometryProxy.size.height / 2.0
***REMOVED******REMOVED***case .max:
***REMOVED******REMOVED******REMOVED***return geometryProxy.size.height - 50.0
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return yOffset
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***GeometryReader { geometryProxy in
***REMOVED******REMOVED******REMOVED***return VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Handle(color: handleColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.gesture(drag)
***REMOVED******REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED***.frame(height: heightFromPreset(with: geometryProxy))
***REMOVED******REMOVED******REMOVED***.background(Color(uiColor: .systemGroupedBackground))
***REMOVED******REMOVED******REMOVED***.cornerRadius(
***REMOVED******REMOVED******REMOVED******REMOVED***15,
***REMOVED******REMOVED******REMOVED******REMOVED***corners: [.topLeft, .topRight]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.shadow(radius: 10)
***REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED***maxHeight: .infinity,
***REMOVED******REMOVED******REMOVED******REMOVED***alignment: .bottom
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.edgesIgnoringSafeArea(.bottom)
***REMOVED******REMOVED******REMOVED***.animation(.default, value: preset)
***REMOVED******REMOVED******REMOVED***.onChange(of: dragTranslation) { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED***preset = nil
***REMOVED******REMOVED******REMOVED******REMOVED***yOffset = max(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***200,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***min(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geometryProxy.size.height - 50,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***yOffset - newValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private var drag: some Gesture {
***REMOVED******REMOVED***DragGesture(minimumDistance: 0)
***REMOVED******REMOVED******REMOVED***.onChanged { value in
***REMOVED******REMOVED******REMOVED******REMOVED***handleColor = .activeHandleColor
***REMOVED******REMOVED******REMOVED******REMOVED***dragTranslation = value.translation.height
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onEnded { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***handleColor = .defaultHandleColor
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

private struct RoundedCorner: Shape {
***REMOVED***var corners: UIRectCorner
***REMOVED***
***REMOVED***var radius: CGFloat
***REMOVED***
***REMOVED***func path(in rect: CGRect) -> Path {
***REMOVED******REMOVED***let path = UIBezierPath(
***REMOVED******REMOVED******REMOVED***roundedRect: rect,
***REMOVED******REMOVED******REMOVED***byRoundingCorners: corners,
***REMOVED******REMOVED******REMOVED***cornerRadii: CGSize(
***REMOVED******REMOVED******REMOVED******REMOVED***width: radius,
***REMOVED******REMOVED******REMOVED******REMOVED***height: radius
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return Path(path.cgPath)
***REMOVED***
***REMOVED***

private extension View {
***REMOVED***func cornerRadius(
***REMOVED******REMOVED***_ radius: CGFloat,
***REMOVED******REMOVED***corners: UIRectCorner
***REMOVED***) -> some View {
***REMOVED******REMOVED***clipShape(RoundedCorner(
***REMOVED******REMOVED******REMOVED***corners: corners,
***REMOVED******REMOVED******REMOVED***radius: radius
***REMOVED******REMOVED***))
***REMOVED***
***REMOVED***
