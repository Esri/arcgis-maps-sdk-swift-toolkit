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
***REMOVED******REMOVED***/ The height of a geo-view's attribution bar.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ When the panel is detached from the bottom of the screen (non-compact) this value allows
***REMOVED******REMOVED***/ the panel to be aligned correctly between the top of a geo-view and the top of the its
***REMOVED******REMOVED***/ attribution bar.
***REMOVED***let attributionBarHeight: CGFloat
***REMOVED******REMOVED***/ The background color of the floating panel.
***REMOVED***let backgroundColor: Color
***REMOVED******REMOVED***/ A binding to the currently selected detent.
***REMOVED***@Binding var selectedDetent: FloatingPanelDetent
***REMOVED******REMOVED***/ A binding to a Boolean value that determines whether the view is presented.
***REMOVED***@Binding var isPresented: Bool
***REMOVED******REMOVED***/ The content shown in the floating panel.
***REMOVED***let content: () -> Content
***REMOVED***
***REMOVED***@Environment(\.horizontalSizeClass) private var horizontalSizeClass
***REMOVED***@Environment(\.verticalSizeClass) private var verticalSizeClass
***REMOVED***
***REMOVED******REMOVED***/ The color of the handle.
***REMOVED***@State private var handleColor: Color = .defaultHandleColor
***REMOVED***
***REMOVED******REMOVED***/ The height of the content.
***REMOVED***@State private var height: CGFloat = .minHeight
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the keyboard is open.
***REMOVED***@State private var keyboardIsOpen = false
***REMOVED***
***REMOVED******REMOVED***/ The latest recorded drag gesture value.
***REMOVED***@State private var latestDragGesture: DragGesture.Value?
***REMOVED***
***REMOVED******REMOVED***/ The maximum allowed height of the content.
***REMOVED***@State private var maximumHeight: CGFloat = .zero
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the resignFirstResponder should be sent for the current
***REMOVED******REMOVED***/ drag gesture.
***REMOVED***@State private var shouldSendResign = true
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the panel should be configured for a compact environment.
***REMOVED***private var isCompact: Bool {
***REMOVED******REMOVED***horizontalSizeClass == .compact && verticalSizeClass == .regular
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { geometryProxy in
***REMOVED******REMOVED******REMOVED***VStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED***if isPresented {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isCompact {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeHandleView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***content()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: height)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipped()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !isCompact {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeHandleView()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Set frame width to infinity to prevent horizontal shrink on dismissal.
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED***.background(backgroundColor)
***REMOVED******REMOVED******REMOVED***.clipShape(
***REMOVED******REMOVED******REMOVED******REMOVED***RoundedCorners(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***corners: isCompact ? [.topLeft, .topRight] : .allCorners,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: 10
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.shadow(radius: 10)
***REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: .infinity,
***REMOVED******REMOVED******REMOVED******REMOVED***maxHeight: .infinity,
***REMOVED******REMOVED******REMOVED******REMOVED***alignment: isCompact ? .bottom : .top
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.animation(.easeInOut, value: isPresented)
***REMOVED******REMOVED******REMOVED***.animation(.default, value: attributionBarHeight)
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***maximumHeight = geometryProxy.size.height
***REMOVED******REMOVED******REMOVED******REMOVED***updateHeight()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: geometryProxy.size.height) { height in
***REMOVED******REMOVED******REMOVED******REMOVED***maximumHeight = height
***REMOVED******REMOVED******REMOVED******REMOVED***updateHeight()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: isPresented) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***updateHeight()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: selectedDetent) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***updateHeight()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***keyboardIsOpen = true
***REMOVED******REMOVED******REMOVED******REMOVED***updateHeight()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***keyboardIsOpen = false
***REMOVED******REMOVED******REMOVED******REMOVED***updateHeight()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** If non-compact, add uniform padding around all edges.
***REMOVED******REMOVED***.padding(.all, isCompact ? 0 : .externalPadding)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** If non-compact, and the keyboard isn't open add padding for the attribution bar.
***REMOVED******REMOVED***.padding(.bottom, !isCompact && !keyboardIsOpen ? attributionBarHeight : 0)
***REMOVED***
***REMOVED***
***REMOVED***var drag: some Gesture {
***REMOVED******REMOVED***DragGesture(minimumDistance: 0, coordinateSpace: .global)
***REMOVED******REMOVED******REMOVED***.onChanged {
***REMOVED******REMOVED******REMOVED******REMOVED***let deltaY = $0.location.y - (latestDragGesture?.location.y ?? $0.location.y)
***REMOVED******REMOVED******REMOVED******REMOVED***let proposedHeight = height + ((isCompact ? -1 : +1) * deltaY)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if shouldSendResign {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***shouldSendResign = false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***handleColor = .activeHandleColor
***REMOVED******REMOVED******REMOVED******REMOVED***height = min(max(.minHeight, proposedHeight), maximumHeight)
***REMOVED******REMOVED******REMOVED******REMOVED***latestDragGesture = $0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onEnded {
***REMOVED******REMOVED******REMOVED******REMOVED***let predictedEndLocation = $0.predictedEndLocation.y
***REMOVED******REMOVED******REMOVED******REMOVED***let inferredHeight = isCompact ? maximumHeight - predictedEndLocation : predictedEndLocation
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent = [.summary, .half, .full]
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.map { (detent: $0, height: heightFor(detent: $0)) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.min { abs(inferredHeight - $0.height) < abs(inferredHeight - $1.height) ***REMOVED***!
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.detent
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***updateHeight()
***REMOVED******REMOVED******REMOVED******REMOVED***handleColor = .defaultHandleColor
***REMOVED******REMOVED******REMOVED******REMOVED***latestDragGesture = nil
***REMOVED******REMOVED******REMOVED******REMOVED***shouldSendResign = true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Calculates the height for the `detent`.
***REMOVED******REMOVED***/ - Parameter detent: The detent to use when calculating height
***REMOVED******REMOVED***/ - Returns: A height for the provided detent based on the current maximum height
***REMOVED***func heightFor(detent: FloatingPanelDetent) -> CGFloat {
***REMOVED******REMOVED***switch detent {
***REMOVED******REMOVED***case .summary:
***REMOVED******REMOVED******REMOVED***return max(.minHeight, maximumHeight * 0.25)
***REMOVED******REMOVED***case .half:
***REMOVED******REMOVED******REMOVED***return maximumHeight * 0.5
***REMOVED******REMOVED***case .full:
***REMOVED******REMOVED******REMOVED***return maximumHeight
***REMOVED******REMOVED***case let .fraction(fraction):
***REMOVED******REMOVED******REMOVED***return min(maximumHeight, max(.minHeight, maximumHeight * fraction))
***REMOVED******REMOVED***case let .height(height):
***REMOVED******REMOVED******REMOVED***return min(maximumHeight, max(.minHeight, height))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates height to an appropriate value.
***REMOVED***func updateHeight() {
***REMOVED******REMOVED***let newHeight: CGFloat = {
***REMOVED******REMOVED******REMOVED***if !isPresented {
***REMOVED******REMOVED******REMOVED******REMOVED***return .zero
***REMOVED******REMOVED*** else if keyboardIsOpen {
***REMOVED******REMOVED******REMOVED******REMOVED***return heightFor(detent: .full)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return heightFor(detent: selectedDetent)
***REMOVED******REMOVED***
***REMOVED***()
***REMOVED******REMOVED***withAnimation { height = max(0, (newHeight - .handleFrameHeight))  ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Configures a handle view.
***REMOVED******REMOVED***/ - Returns: A configured handle view, suitable for placement in the panel.
***REMOVED***@ViewBuilder func makeHandleView() -> some View {
***REMOVED******REMOVED***Handle(color: handleColor)
***REMOVED******REMOVED******REMOVED***.background(backgroundColor)
***REMOVED******REMOVED******REMOVED***.frame(height: .handleFrameHeight)
***REMOVED******REMOVED******REMOVED***.gesture(drag)
***REMOVED******REMOVED******REMOVED***.zIndex(1)
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
***REMOVED******REMOVED***/ The amount of padding around the floating panel.
***REMOVED***static let externalPadding: CGFloat = 10
***REMOVED***
***REMOVED******REMOVED***/ THe height of the area containing the handle.
***REMOVED***static let handleFrameHeight: CGFloat = 30
***REMOVED***
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
