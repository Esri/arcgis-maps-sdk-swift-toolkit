***REMOVED*** Copyright 2025 Esri
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
***REMOVED***

struct OnDemandMapAreaSelectorView: View {
***REMOVED******REMOVED***/ The maximum size of the area selector view.
***REMOVED***@State private var maxRect: CGRect = .zero
***REMOVED***
***REMOVED******REMOVED***/ A Binding to the CGRect of the selected area.
***REMOVED***@Binding var selectedRect: CGRect
***REMOVED***
***REMOVED******REMOVED***/ The safe area insets of the view.
***REMOVED***@State private var safeAreaInsets = EdgeInsets()
***REMOVED***
***REMOVED******REMOVED***/ The rectangle for the area selector view handles.
***REMOVED***private var handlesRect: CGRect {
***REMOVED******REMOVED***selectedRect.insetBy(dx: -2, dy: -2)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The corner radius of the area selector view.
***REMOVED***static let cornerRadius: CGFloat = 16
***REMOVED***
***REMOVED******REMOVED***/ The minimum width of the selected area.
***REMOVED***static let minimumWidth: CGFloat = 50
***REMOVED***
***REMOVED******REMOVED***/ The minimum height of the selected area.
***REMOVED***static let minimumHeight: CGFloat  = 50
***REMOVED***
***REMOVED******REMOVED***/ Top right handle position.
***REMOVED***private var topRight: CGPoint { CGPoint(x: selectedRect.maxX, y: selectedRect.minY) ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Top left handle position.
***REMOVED***private var topLeft: CGPoint { CGPoint(x: selectedRect.minX, y: selectedRect.minY) ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Bottom left handle position.
***REMOVED***private var bottomLeft: CGPoint { CGPoint(x: selectedRect.minX, y: selectedRect.maxY) ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Bottom right handle position.
***REMOVED***private var bottomRight: CGPoint { CGPoint(x: selectedRect.maxX, y: selectedRect.maxY) ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The orientation for a handle that resizes the selector view.
***REMOVED***enum HandleOrientation {
***REMOVED******REMOVED***case topLeft, topRight, bottomLeft, bottomRight
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED***dimmedMaskedView
***REMOVED******REMOVED******REMOVED******REMOVED***.edgesIgnoringSafeArea(.all)
***REMOVED******REMOVED******REMOVED******REMOVED***.allowsHitTesting(false)
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay { handles ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onChange(safeAreaInsets) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateMaxRect(geometry: geometry)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.edgesIgnoringSafeArea(.all)
***REMOVED******REMOVED***.onGeometryChange(for: EdgeInsets.self, of: \.safeAreaInsets) { safeAreaInsets in
***REMOVED******REMOVED******REMOVED***self.safeAreaInsets = safeAreaInsets
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The darker dimmed background view that shows the selected area masked.
***REMOVED***@ViewBuilder private var dimmedMaskedView: some View {
***REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED***.fill(.black.opacity(0.2))
***REMOVED******REMOVED******REMOVED***.reverseMask {
***REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: OnDemandMapAreaSelectorView.cornerRadius, style: .continuous)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: selectedRect.width, height: selectedRect.height)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.position(selectedRect.center)
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***RoundedRectangle(cornerRadius: OnDemandMapAreaSelectorView.cornerRadius, style: .continuous)
***REMOVED******REMOVED******REMOVED***.stroke(.white, lineWidth: 4)
***REMOVED******REMOVED******REMOVED***.frame(width: selectedRect.width, height: selectedRect.height)
***REMOVED******REMOVED******REMOVED***.position(selectedRect.center)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view for the handles that allow resizing the selected area.
***REMOVED***@ViewBuilder private var handles: some View {
***REMOVED******REMOVED***Handle(orientation: .topLeft, position: topLeft) { handleOrientation, location in
***REMOVED******REMOVED******REMOVED***resize(for: handleOrientation, location: location)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***Handle(orientation: .topRight, position: topRight) { handleOrientation, location in
***REMOVED******REMOVED******REMOVED***resize(for: handleOrientation, location: location)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***Handle(orientation: .bottomLeft, position: bottomLeft) { handleOrientation, location in
***REMOVED******REMOVED******REMOVED***resize(for: handleOrientation, location: location)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***Handle(orientation: .bottomRight, position: bottomRight) { handleOrientation, location in
***REMOVED******REMOVED******REMOVED***resize(for: handleOrientation, location: location)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the maximum rectangle for a change to the safe area insets.
***REMOVED***private func updateMaxRect(geometry: GeometryProxy) {
***REMOVED******REMOVED***let frame = CGRect(
***REMOVED******REMOVED******REMOVED***x: safeAreaInsets.leading,
***REMOVED******REMOVED******REMOVED***y: safeAreaInsets.top,
***REMOVED******REMOVED******REMOVED***width: geometry.size.width - safeAreaInsets.trailing - safeAreaInsets.leading,
***REMOVED******REMOVED******REMOVED***height: geometry.size.height - safeAreaInsets.bottom - safeAreaInsets.top
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Use default insets of 50 unless we cannot because of the size
***REMOVED******REMOVED******REMOVED*** of the frame being too small.
***REMOVED******REMOVED***var defaultInsets: CGFloat = 50
***REMOVED******REMOVED***if frame.width < defaultInsets || frame.height < defaultInsets {
***REMOVED******REMOVED******REMOVED***defaultInsets = min(frame.width * 0.1, frame.height * 0.1)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***maxRect = frame.insetBy(dx: defaultInsets, dy: defaultInsets)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Set the selected rectangle to the intersection of the max rect and the
***REMOVED******REMOVED******REMOVED***/ current selected rect.
***REMOVED******REMOVED***selectedRect = CGRectIntersection(maxRect, selectedRect)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ If that resulting rect is empty or less than the minimum dimensions,
***REMOVED******REMOVED******REMOVED***/ then set the selected rect to the max rectangle.
***REMOVED******REMOVED***if selectedRect.isEmpty
***REMOVED******REMOVED******REMOVED***|| selectedRect.width < Self.minimumWidth
***REMOVED******REMOVED******REMOVED***|| selectedRect.height < Self.minimumHeight {
***REMOVED******REMOVED******REMOVED***selectedRect = maxRect
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Resizes the area selectpor view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - handleOrientation: The handle orientation.
***REMOVED******REMOVED***/   - location: The location of the drag gesture.
***REMOVED***private func resize(for handleOrientation: HandleOrientation, location: CGPoint) {
***REMOVED******REMOVED******REMOVED*** Resize the rect.
***REMOVED******REMOVED***let rectangle: CGRect
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch handleOrientation {
***REMOVED******REMOVED***case .topLeft:
***REMOVED******REMOVED******REMOVED***let minX = location.x
***REMOVED******REMOVED******REMOVED***let maxX = selectedRect.maxX
***REMOVED******REMOVED******REMOVED***let minY = location.y
***REMOVED******REMOVED******REMOVED***let maxY = selectedRect.maxY
***REMOVED******REMOVED******REMOVED***rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
***REMOVED******REMOVED***case .topRight:
***REMOVED******REMOVED******REMOVED***let minX = selectedRect.minX
***REMOVED******REMOVED******REMOVED***let maxX = location.x
***REMOVED******REMOVED******REMOVED***let minY = location.y
***REMOVED******REMOVED******REMOVED***let maxY = selectedRect.maxY
***REMOVED******REMOVED******REMOVED***rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
***REMOVED******REMOVED***case .bottomLeft:
***REMOVED******REMOVED******REMOVED***let minX = location.x
***REMOVED******REMOVED******REMOVED***let maxX = selectedRect.maxX
***REMOVED******REMOVED******REMOVED***let minY = selectedRect.minY
***REMOVED******REMOVED******REMOVED***let maxY = location.y
***REMOVED******REMOVED******REMOVED***rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
***REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED***case .bottomRight:
***REMOVED******REMOVED******REMOVED***let minX = selectedRect.minX
***REMOVED******REMOVED******REMOVED***let maxX = location.x
***REMOVED******REMOVED******REMOVED***let minY = selectedRect.minY
***REMOVED******REMOVED******REMOVED***let maxY = location.y
***REMOVED******REMOVED******REMOVED***rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
***REMOVED******REMOVED******REMOVED***break
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Keep rectangle within the maximum rect.
***REMOVED******REMOVED***var corrected = CGRectIntersection(maxRect, rectangle)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Keep rectangle outside the minimum rect.
***REMOVED******REMOVED***corrected = CGRectUnion(corrected, minimumRect(for: handleOrientation))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Update selection.
***REMOVED******REMOVED***selectedRect = corrected
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Calculates the minimum rect size for a drag point handle using the adjacent handle position.
***REMOVED******REMOVED***/ - Parameter handleOrientation: The handle orientation.
***REMOVED******REMOVED***/ - Returns: The minimum rect for a handle.
***REMOVED***private func minimumRect(for handleOrientation: HandleOrientation) -> CGRect {
***REMOVED******REMOVED***switch handleOrientation {
***REMOVED******REMOVED***case .topLeft:
***REMOVED******REMOVED******REMOVED******REMOVED*** Anchor is opposite corner.
***REMOVED******REMOVED******REMOVED***return CGRect(
***REMOVED******REMOVED******REMOVED******REMOVED***x: selectedRect.maxX - Self.minimumWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***y: selectedRect.maxY - Self.minimumHeight,
***REMOVED******REMOVED******REMOVED******REMOVED***width: Self.minimumWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***height: Self.minimumHeight
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .topRight:
***REMOVED******REMOVED******REMOVED***return CGRect(
***REMOVED******REMOVED******REMOVED******REMOVED***x: selectedRect.minX,
***REMOVED******REMOVED******REMOVED******REMOVED***y: selectedRect.maxY - Self.minimumHeight,
***REMOVED******REMOVED******REMOVED******REMOVED***width: Self.minimumWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***height: Self.minimumHeight
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .bottomLeft:
***REMOVED******REMOVED******REMOVED***return CGRect(
***REMOVED******REMOVED******REMOVED******REMOVED***x: selectedRect.maxX - Self.minimumWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***y: selectedRect.minY,
***REMOVED******REMOVED******REMOVED******REMOVED***width: Self.minimumWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***height: Self.minimumHeight
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .bottomRight:
***REMOVED******REMOVED******REMOVED***return CGRect(
***REMOVED******REMOVED******REMOVED******REMOVED***x: selectedRect.minX,
***REMOVED******REMOVED******REMOVED******REMOVED***y: selectedRect.minY,
***REMOVED******REMOVED******REMOVED******REMOVED***width: Self.minimumWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***height: Self.minimumHeight
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The handle view for the map area selector.
***REMOVED***struct Handle: View {
***REMOVED******REMOVED******REMOVED***/ The handle orientation.
***REMOVED******REMOVED***let orientation: HandleOrientation
***REMOVED******REMOVED******REMOVED***/ The position of the handle.
***REMOVED******REMOVED***let position: CGPoint
***REMOVED******REMOVED******REMOVED***/ The closure to call when the map area selector should be resized.
***REMOVED******REMOVED***let resize: (HandleOrientation, CGPoint) -> Void
***REMOVED******REMOVED******REMOVED***/ The gesture state of the drag gesture.
***REMOVED******REMOVED***@GestureState var gestureState: State = .started
***REMOVED******REMOVED******REMOVED***/ The types of gesture states.
***REMOVED******REMOVED***enum State {
***REMOVED******REMOVED******REMOVED***case started, changed
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***HandleShape(
***REMOVED******REMOVED******REMOVED******REMOVED***orientation: orientation,
***REMOVED******REMOVED******REMOVED******REMOVED***cornerRadius: OnDemandMapAreaSelectorView.cornerRadius
***REMOVED******REMOVED******REMOVED***)
#if os(visionOS)
***REMOVED******REMOVED******REMOVED***.stroke(.ultraThinMaterial, style: StrokeStyle(lineWidth: 5, lineCap: .round))
#else
***REMOVED******REMOVED******REMOVED***.stroke(.ultraThickMaterial, style: StrokeStyle(lineWidth: 5, lineCap: .round))
***REMOVED******REMOVED******REMOVED***.environment(\.colorScheme, .light)
#endif
***REMOVED******REMOVED******REMOVED***.contentShape(RoundedRectangle(cornerRadius: 8))
***REMOVED******REMOVED******REMOVED***.frame(width: 36, height: 36)
***REMOVED******REMOVED******REMOVED***.hoverEffect()
***REMOVED******REMOVED******REMOVED***.position(position)
***REMOVED******REMOVED******REMOVED***.gesture(
***REMOVED******REMOVED******REMOVED******REMOVED***DragGesture()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.updating($gestureState) { value, state, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch state {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .started:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***state = .changed
#if !os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UISelectionFeedbackGenerator().selectionChanged()
#endif
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .changed:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***resize(orientation, value.location)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The rounded corner shape for drawing a handle.
***REMOVED***struct HandleShape: Shape {
***REMOVED******REMOVED******REMOVED***/ The handle orientation.
***REMOVED******REMOVED***let orientation: HandleOrientation
***REMOVED******REMOVED******REMOVED***/ The corner radius.
***REMOVED******REMOVED***let cornerRadius: CGFloat
***REMOVED******REMOVED******REMOVED***/ The offset padding.
***REMOVED******REMOVED***let offset: CGFloat = 2
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Add a rounded corner for the handle.
***REMOVED******REMOVED***func path(in rect: CGRect) -> Path {
***REMOVED******REMOVED******REMOVED***var path = Path()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***switch orientation {
***REMOVED******REMOVED******REMOVED***case .topLeft:
***REMOVED******REMOVED******REMOVED******REMOVED***let offsetPosition = rect.center.offsetBy(dx: -offset, dy: -offset)
***REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: offsetPosition.x, y: offsetPosition.y + cornerRadius))
***REMOVED******REMOVED******REMOVED******REMOVED***path.addQuadCurve(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***to: CGPoint(x: offsetPosition.x + cornerRadius, y: offsetPosition.y),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***control: CGPoint(x: offsetPosition.x, y: offsetPosition.y)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***case .topRight:
***REMOVED******REMOVED******REMOVED******REMOVED***let offsetPosition = rect.center.offsetBy(dx: offset, dy: -offset)
***REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: offsetPosition.x - cornerRadius, y: offsetPosition.y))
***REMOVED******REMOVED******REMOVED******REMOVED***path.addQuadCurve(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***to: CGPoint(x: offsetPosition.x, y: offsetPosition.y + cornerRadius),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***control: CGPoint(x: offsetPosition.x, y: offsetPosition.y)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***case .bottomLeft:
***REMOVED******REMOVED******REMOVED******REMOVED***let offsetPosition = rect.center.offsetBy(dx: -offset, dy: offset)
***REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: offsetPosition.x + cornerRadius, y: offsetPosition.y))
***REMOVED******REMOVED******REMOVED******REMOVED***path.addQuadCurve(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***to: CGPoint(x: offsetPosition.x, y: offsetPosition.y - cornerRadius),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***control: CGPoint(x: offsetPosition.x, y: offsetPosition.y)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***case .bottomRight:
***REMOVED******REMOVED******REMOVED******REMOVED***let offsetPosition = rect.center.offsetBy(dx: offset, dy: offset)
***REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: offsetPosition.x, y: offsetPosition.y - cornerRadius))
***REMOVED******REMOVED******REMOVED******REMOVED***path.addQuadCurve(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***to: CGPoint(x: offsetPosition.x - cornerRadius, y: offsetPosition.y),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***control: CGPoint(x: offsetPosition.x, y: offsetPosition.y)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return path
***REMOVED***
***REMOVED***
***REMOVED***

private extension View {
***REMOVED******REMOVED***/ A reverse mask overlay.
***REMOVED***func reverseMask<Mask: View>(
***REMOVED******REMOVED***alignment: Alignment = .center,
***REMOVED******REMOVED***@ViewBuilder _ mask: () -> Mask
***REMOVED***) -> some View {
***REMOVED******REMOVED***self.mask {
***REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(alignment: alignment) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mask()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.blendMode(.destinationOut)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension CGPoint {
***REMOVED******REMOVED***/ Offests a point by a given x and y amount.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - dx: The x offset.
***REMOVED******REMOVED***/   - dy: The y offset.
***REMOVED***func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
***REMOVED******REMOVED***return CGPoint(x: x + dx, y: y + dy)
***REMOVED***
***REMOVED***

private extension CGRect {
***REMOVED******REMOVED***/ The center point of the rectangle.
***REMOVED***var center: CGPoint {
***REMOVED******REMOVED***CGPoint(x: midX, y: midY)
***REMOVED***
***REMOVED***
