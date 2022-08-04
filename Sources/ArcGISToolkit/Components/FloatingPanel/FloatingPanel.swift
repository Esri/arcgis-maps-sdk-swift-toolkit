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

***REMOVED***/ A floating panel is a view that overlays a view and supplies view-related
***REMOVED***/ content. For a map view, for instance, it could display a legend, bookmarks, search results, etc..
***REMOVED***/ Apple Maps, Google Maps, Windows 10, and Collector have floating panel
***REMOVED***/ implementations, sometimes referred to as a "bottom sheet".
***REMOVED***/
***REMOVED***/ Floating panels are non-modal and can be transient, only displaying
***REMOVED***/ information for a short period of time like identify results,
***REMOVED***/ or persistent, where the information is always displayed, for example a
***REMOVED***/ dedicated search panel. They will also be primarily simple containers
***REMOVED***/ that clients will fill with their own content.
struct FloatingPanel<Content>: View where Content: View {
***REMOVED***@Environment(\.horizontalSizeClass) private var horizontalSizeClass
***REMOVED***@Environment(\.verticalSizeClass) var verticalSizeClass
***REMOVED***
***REMOVED******REMOVED***/ The background color of the floating panel.
***REMOVED***let backgroundColor: Color
***REMOVED***
***REMOVED******REMOVED***/ The content shown in the floating panel.
***REMOVED***let content: Content
***REMOVED***
***REMOVED******REMOVED***/ The height of the handle area.
***REMOVED***let handleAreaHeight: CGFloat = 20
***REMOVED***
***REMOVED******REMOVED***/ Creates a `FloatingPanel`
***REMOVED******REMOVED***/ - Parameter backgroundColor: The background color of the floating panel.
***REMOVED******REMOVED***/ - Parameter detent: Controls the height of the panel.
***REMOVED******REMOVED***/ - Parameter isPresented: A Boolean value indicating if the view is presented.
***REMOVED******REMOVED***/ - Parameter content: The view shown in the floating panel.
***REMOVED***init(
***REMOVED******REMOVED***backgroundColor: Color,
***REMOVED******REMOVED***detent: Binding<FloatingPanelDetent>,
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***@ViewBuilder content: () -> Content
***REMOVED***) {
***REMOVED******REMOVED***self.backgroundColor = backgroundColor
***REMOVED******REMOVED***self.content = content()
***REMOVED******REMOVED***_activeDetent = detent
***REMOVED******REMOVED***_isPresented = isPresented
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A binding to the currently selected detent.
***REMOVED***@Binding private var activeDetent: FloatingPanelDetent
***REMOVED***
***REMOVED******REMOVED***/ The color of the handle.
***REMOVED***@State private var handleColor: Color = .defaultHandleColor
***REMOVED***
***REMOVED******REMOVED***/ The height of the content.
***REMOVED***@State private var height: CGFloat = .minHeight
***REMOVED***
***REMOVED******REMOVED***/ A binding to a Boolean value that determines whether the view is presented.
***REMOVED***@Binding private var isPresented: Bool
***REMOVED***
***REMOVED******REMOVED***/ The maximum allowed height of the content.
***REMOVED***@State private var maximumHeight: CGFloat = .infinity
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the panel should be configured for a compact environment.
***REMOVED***private var isCompact: Bool {
***REMOVED******REMOVED***horizontalSizeClass == .compact && verticalSizeClass == .regular
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***GeometryReader { geometryProxy in
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if isCompact && isPresented {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeHandleArea()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(minHeight: .zero, maxHeight: height - handleAreaHeight)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.bottom, isCompact ? 15 : .zero)
***REMOVED******REMOVED******REMOVED******REMOVED***if !isCompact && isPresented {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeHandleArea()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding(.bottom, isCompact ? 10 : .zero)
***REMOVED******REMOVED******REMOVED***.background(backgroundColor)
***REMOVED******REMOVED******REMOVED***.cornerRadius(10, corners: isCompact ? [.topLeft, .topRight] : [.allCorners])
***REMOVED******REMOVED******REMOVED***.shadow(radius: 10)
***REMOVED******REMOVED******REMOVED***.opacity(isPresented ? 1.0 : .zero)
***REMOVED******REMOVED******REMOVED***.padding([.leading, .top, .trailing], isCompact ? 0 : 10)
***REMOVED******REMOVED******REMOVED***.padding([.bottom], isCompact ? 0 : 50)
***REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED***width: geometryProxy.size.width,
***REMOVED******REMOVED******REMOVED******REMOVED***height: geometryProxy.size.height,
***REMOVED******REMOVED******REMOVED******REMOVED***alignment: isCompact ? .bottom : .top
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED***maximumHeight = $0.height
***REMOVED******REMOVED******REMOVED******REMOVED***if height > maximumHeight {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height = maximumHeight
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: activeDetent) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height = heightFor(detent: activeDetent)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: isPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***height = $0 ? heightFor(detent: activeDetent) : .zero
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height = heightFor(detent: activeDetent)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.animation(.default, value: isPresented)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var drag: some Gesture {
***REMOVED******REMOVED***DragGesture(minimumDistance: 0)
***REMOVED******REMOVED******REMOVED***.onChanged { value in
***REMOVED******REMOVED******REMOVED******REMOVED***handleColor = .activeHandleColor
***REMOVED******REMOVED******REMOVED******REMOVED***let proposedHeight: CGFloat
***REMOVED******REMOVED******REMOVED******REMOVED***if isCompact {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***proposedHeight = max(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.minHeight,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height - value.translation.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***proposedHeight = max(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.minHeight,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height + value.translation.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***height = min(proposedHeight, maximumHeight)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onEnded { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***handleColor = .defaultHandleColor
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height = heightFor(detent: closestDetent)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The detent that would produce a height that is closest to the current height
***REMOVED***var closestDetent: FloatingPanelDetent {
***REMOVED******REMOVED***return FloatingPanelDetent.allCases.min {
***REMOVED******REMOVED******REMOVED***abs(heightFor(detent: $0) - height) <
***REMOVED******REMOVED******REMOVED******REMOVED***abs(heightFor(detent: $1) - height)
***REMOVED*** ?? .half
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ - Parameter detent: The detent to use when calculating height
***REMOVED******REMOVED***/ - Returns: A height for the provided detent based on the current maximum height
***REMOVED***func heightFor(detent: FloatingPanelDetent) -> CGFloat {
***REMOVED******REMOVED***switch detent {
***REMOVED******REMOVED***case .summary:
***REMOVED******REMOVED******REMOVED***return max(.minHeight, maximumHeight * 0.15)
***REMOVED******REMOVED***case .half:
***REMOVED******REMOVED******REMOVED***return maximumHeight * 0.4
***REMOVED******REMOVED***case .full:
***REMOVED******REMOVED******REMOVED***return maximumHeight * 0.90
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Configures a handle area.
***REMOVED******REMOVED***/ - Returns: A configured handle area, suitable for placement in the panel.
***REMOVED***@ViewBuilder func makeHandleArea() -> some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***backgroundColor
***REMOVED******REMOVED******REMOVED***Handle(color: handleColor)
***REMOVED******REMOVED******REMOVED******REMOVED***.gesture(drag)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.vertical, 5)
***REMOVED***
***REMOVED******REMOVED***.frame(height: handleAreaHeight)
***REMOVED******REMOVED***.zIndex(1)
***REMOVED***
***REMOVED***

***REMOVED***/ The "Handle" view of the floating panel.
private struct Handle: View {
***REMOVED******REMOVED***/ The color of the handle.
***REMOVED***var color: Color
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***RoundedRectangle(cornerRadius: 4.0)
***REMOVED******REMOVED******REMOVED***.foregroundColor(color)
***REMOVED******REMOVED******REMOVED***.frame(width: 100, height: 8.0)
***REMOVED***
***REMOVED***

private extension CGFloat {
***REMOVED***static let minHeight: CGFloat = 66
***REMOVED***

private extension Color {
***REMOVED***static var defaultHandleColor: Color { .secondary ***REMOVED***
***REMOVED***static var activeHandleColor: Color { .primary ***REMOVED***
***REMOVED***

private struct RoundedCorners: Shape {
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
***REMOVED******REMOVED***/ Clips this view to its bounding frame, with the specified corner radius, on the specified corners.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - corners: The corners to be rounded.
***REMOVED******REMOVED***/ - Returns: A view that clips this view to its bounding frame with the specified corner radius and
***REMOVED******REMOVED***/ corners.
***REMOVED***func cornerRadius(
***REMOVED******REMOVED***_ radius: CGFloat,
***REMOVED******REMOVED***corners: UIRectCorner
***REMOVED***) -> some View {
***REMOVED******REMOVED***clipShape(RoundedCorners(
***REMOVED******REMOVED******REMOVED***corners: corners,
***REMOVED******REMOVED******REMOVED***radius: radius
***REMOVED******REMOVED***))
***REMOVED***
***REMOVED***
