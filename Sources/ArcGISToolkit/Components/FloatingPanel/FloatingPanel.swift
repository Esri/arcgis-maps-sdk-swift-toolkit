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
***REMOVED******REMOVED***/ Creates a `FloatingPanel`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - backgroundColor: The background color of the floating panel.
***REMOVED******REMOVED***/   - selectedDetent: Controls the height of the panel.
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating if the view is presented.
***REMOVED******REMOVED***/   - content: The view shown in the floating panel.
***REMOVED***init(
***REMOVED******REMOVED***backgroundColor: Color,
***REMOVED******REMOVED***selectedDetent: Binding<FloatingPanelDetent>,
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***@ViewBuilder content: () -> Content
***REMOVED***) {
***REMOVED******REMOVED***self.backgroundColor = backgroundColor
***REMOVED******REMOVED***self.selectedDetent = selectedDetent
***REMOVED******REMOVED***self.isPresented = isPresented
***REMOVED******REMOVED***self.content = content()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A binding to the currently selected detent.
***REMOVED***private var selectedDetent: Binding<FloatingPanelDetent>
***REMOVED***
***REMOVED******REMOVED***/ The color of the handle.
***REMOVED***@State private var handleColor: Color = .defaultHandleColor
***REMOVED***
***REMOVED******REMOVED***/ The height of the content.
***REMOVED***@State private var height: CGFloat = .minHeight
***REMOVED***
***REMOVED******REMOVED***/ A binding to a Boolean value that determines whether the view is presented.
***REMOVED***private var isPresented: Binding<Bool>
***REMOVED***
***REMOVED******REMOVED***/ The latest recorded drag gesture value.
***REMOVED***@State var latestDragGesture: DragGesture.Value?
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
***REMOVED******REMOVED******REMOVED***VStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED***if isCompact && isPresented.wrappedValue {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeHandleView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: height)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipped()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.bottom, isPresented.wrappedValue ? (isCompact ? 25 : 10) : .zero)
***REMOVED******REMOVED******REMOVED******REMOVED***if !isCompact && isPresented.wrappedValue {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeHandleView()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.background(backgroundColor)
***REMOVED******REMOVED******REMOVED***.clipShape(
***REMOVED******REMOVED******REMOVED******REMOVED***RoundedCorners(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***corners: isCompact ? [.topLeft, .topRight] : [.allCorners],
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: 10
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.shadow(radius: 10)
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
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height = isPresented.wrappedValue ? heightFor(detent: selectedDetent.wrappedValue) : .zero
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: isPresented.wrappedValue) { isPresented in
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height = isPresented ? heightFor(detent: selectedDetent.wrappedValue) : .zero
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: selectedDetent.wrappedValue) { selectedDetent in
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height = heightFor(detent: selectedDetent)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.padding([.leading, .top, .trailing], isCompact ? 0 : 10)
***REMOVED******REMOVED***.padding([.bottom], isCompact ? 0 : 50)
***REMOVED***
***REMOVED***
***REMOVED***var drag: some Gesture {
***REMOVED******REMOVED***DragGesture(minimumDistance: 0, coordinateSpace: .global)
***REMOVED******REMOVED******REMOVED***.onChanged {
***REMOVED******REMOVED******REMOVED******REMOVED***let deltaY = $0.location.y - (latestDragGesture?.location.y ?? $0.location.y)
***REMOVED******REMOVED******REMOVED******REMOVED***let proposedHeight = height + ((isCompact ? -1 : +1) * deltaY)
***REMOVED******REMOVED******REMOVED******REMOVED***handleColor = .activeHandleColor
***REMOVED******REMOVED******REMOVED******REMOVED***height = min(max(.minHeight, proposedHeight), maximumHeight)
***REMOVED******REMOVED******REMOVED******REMOVED***latestDragGesture = $0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onEnded {
***REMOVED******REMOVED******REMOVED******REMOVED***let deltaY = $0.location.y - latestDragGesture!.location.y
***REMOVED******REMOVED******REMOVED******REMOVED***let deltaTime = $0.time.timeIntervalSince(latestDragGesture!.time)
***REMOVED******REMOVED******REMOVED******REMOVED***let velocity = deltaY / deltaTime
***REMOVED******REMOVED******REMOVED******REMOVED***let speed = abs(velocity)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let newDetent = bestDetent(given: height, travelingAt: velocity)
***REMOVED******REMOVED******REMOVED******REMOVED***let targetHeight = heightFor(detent: newDetent)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let distanceAhead = abs(height - targetHeight)
***REMOVED******REMOVED******REMOVED******REMOVED***let travelTime = min(0.35, distanceAhead / speed)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation(.easeOut(duration: travelTime)) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent.wrappedValue = newDetent
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height = targetHeight
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***handleColor = .defaultHandleColor
***REMOVED******REMOVED******REMOVED******REMOVED***latestDragGesture = nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines the best detent based on the provided metrics.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - currentHeight: The height target for the detent.
***REMOVED******REMOVED***/   - velocity: The velocity of travel to the new detent.
***REMOVED******REMOVED***/ - Returns: The best detent based on the provided metrics.
***REMOVED***func bestDetent(given currentHeight: CGFloat, travelingAt velocity: Double) -> FloatingPanelDetent {
***REMOVED******REMOVED***let lowSpeedThreshold = 100.0
***REMOVED******REMOVED***let highSpeedThreshold = 2000.0
***REMOVED******REMOVED***let isExpanding = (isCompact && velocity <= 0) || (!isCompact && velocity > 0)
***REMOVED******REMOVED***let speed = abs(velocity)
***REMOVED******REMOVED***let allDetents = [FloatingPanelDetent.summary, .full, .half]
***REMOVED******REMOVED******REMOVED***.map { (detent: $0, height: heightFor(detent: $0)) ***REMOVED***
***REMOVED******REMOVED******REMOVED*** If the speed was low, choose the closest detent, regardless of direction.
***REMOVED******REMOVED***guard speed > lowSpeedThreshold else {
***REMOVED******REMOVED******REMOVED***return allDetents.min {
***REMOVED******REMOVED******REMOVED******REMOVED***abs(currentHeight - $0.height) < abs(currentHeight - $1.height)
***REMOVED******REMOVED***?.detent ?? selectedDetent.wrappedValue
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Generate a new set of detents, filtering out those that would produce a height in the
***REMOVED******REMOVED******REMOVED*** opposite direction of the gesture, and sorting them in order of closest to furthest from
***REMOVED******REMOVED******REMOVED*** the current height.
***REMOVED******REMOVED***let candidateDetents = allDetents
***REMOVED******REMOVED******REMOVED***.filter { (detent, height) in
***REMOVED******REMOVED******REMOVED******REMOVED***if isExpanding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return height >= currentHeight
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return height < currentHeight
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.sorted {
***REMOVED******REMOVED******REMOVED******REMOVED***if isExpanding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return $0.1 < $1.1
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return $1.1 < $0.1
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** If the gesture had high speed, select the last candidate detent (the one that would
***REMOVED******REMOVED******REMOVED*** produce the greatest size difference from the current height). Otherwise, choose the
***REMOVED******REMOVED******REMOVED*** first candidate detent (the one that would produce the least size difference from the
***REMOVED******REMOVED******REMOVED*** current height).
***REMOVED******REMOVED***if speed >= highSpeedThreshold {
***REMOVED******REMOVED******REMOVED***return candidateDetents.last?.0 ?? selectedDetent.wrappedValue
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return candidateDetents.first?.0 ?? selectedDetent.wrappedValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Calculates the height for the `detent`.
***REMOVED******REMOVED***/ - Parameter detent: The detent to use when calculating height
***REMOVED******REMOVED***/ - Returns: A height for the provided detent based on the current maximum height
***REMOVED***func heightFor(detent: FloatingPanelDetent) -> CGFloat {
***REMOVED******REMOVED***switch detent {
***REMOVED******REMOVED***case .summary:
***REMOVED******REMOVED******REMOVED***return max(.minHeight, maximumHeight * 0.15)
***REMOVED******REMOVED***case .half:
***REMOVED******REMOVED******REMOVED***return maximumHeight * 0.4
***REMOVED******REMOVED***case .full:
***REMOVED******REMOVED******REMOVED***return maximumHeight * (isCompact ? 0.90 : 1.0)
***REMOVED******REMOVED***case let .fraction(fraction):
***REMOVED******REMOVED******REMOVED***return min(maximumHeight, max(.minHeight, maximumHeight * fraction))
***REMOVED******REMOVED***case let .height(height):
***REMOVED******REMOVED******REMOVED***return min(maximumHeight, max(.minHeight, height))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Configures a handle view.
***REMOVED******REMOVED***/ - Returns: A configured handle view, suitable for placement in the panel.
***REMOVED***@ViewBuilder func makeHandleView() -> some View {
***REMOVED******REMOVED***Handle(color: handleColor)
***REMOVED******REMOVED******REMOVED***.background(backgroundColor)
***REMOVED******REMOVED******REMOVED***.frame(height: 30)
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
