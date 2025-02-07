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
***REMOVED******REMOVED***/ The top left corner point of the area selector view.
***REMOVED***@State private var topLeft: CGPoint = .zero
***REMOVED***
***REMOVED******REMOVED***/ The top right corner point of the area selector view.
***REMOVED***@State private var topRight: CGPoint = .zero
***REMOVED***
***REMOVED******REMOVED***/ The bottom left corner point of the area selector view.
***REMOVED***@State private var bottomLeft: CGPoint = .zero
***REMOVED***
***REMOVED******REMOVED***/ The bottom right corner point of the area selector view.
***REMOVED***@State private var bottomRight: CGPoint = .zero
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
***REMOVED***private let cordnerRadius: CGFloat = 16
***REMOVED***
***REMOVED******REMOVED***/ The location for a handle that resizes the selector view.
***REMOVED***private enum HandleLocation {
***REMOVED******REMOVED***case topLeft, topRight, bottomLeft, bottomRight
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fill(.black.opacity(0.10))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.reverseMask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: selectedRect.width, height: selectedRect.height)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.position(selectedRect.center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***RoundedCorners(cornerRadius: cordnerRadius)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.ultraThickMaterial, style: StrokeStyle(lineWidth: 6, lineCap: .butt))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: handlesRect.width, height: handlesRect.height)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.position(handlesRect.center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: cordnerRadius, style: .continuous)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.white, lineWidth: 4)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: selectedRect.width, height: selectedRect.height)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.position(selectedRect.center)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.ignoresSafeArea()
***REMOVED******REMOVED******REMOVED******REMOVED***.allowsHitTesting(false)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Handle(position: topLeft) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***resize(for: .topLeft, location: $0)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Handle(position: topRight) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***resize(for: .topRight, location: $0)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Handle(position: bottomLeft) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***resize(for: .bottomLeft, location: $0)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Handle(position: bottomRight) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***resize(for: .bottomRight, location: $0)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: safeAreaInsets) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***let frame = CGRect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: safeAreaInsets.leading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: safeAreaInsets.top,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: geometry.size.width - safeAreaInsets.trailing - safeAreaInsets.leading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height: geometry.size.height - safeAreaInsets.bottom - safeAreaInsets.top
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***maxRect = frame
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.insetBy(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dx: 50,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dy: 50
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***selectedRect = maxRect
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***updateHandles()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.edgesIgnoringSafeArea(.all)
***REMOVED******REMOVED***.onGeometryChange(for: EdgeInsets.self, of: \.safeAreaInsets) { safeAreaInsets in
***REMOVED******REMOVED******REMOVED***self.safeAreaInsets = safeAreaInsets
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Resizes the area selectpor view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - handle: The handle location.
***REMOVED******REMOVED***/   - location: The location of the drag gesture.
***REMOVED***private func resize(for handle: HandleLocation, location: CGPoint) {
***REMOVED******REMOVED******REMOVED*** Resize the rect.
***REMOVED******REMOVED***let rectangle: CGRect
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch handle {
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
***REMOVED******REMOVED***corrected = CGRectUnion(corrected, minimumRect(forHandle: handle))
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectedRect = corrected
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Now update handles for new bounding rect.
***REMOVED******REMOVED***updateHandles()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Calculates the minimum rect size for a drag point handle using the adjacent handle position.
***REMOVED******REMOVED***/ - Parameter handle: The handle location.
***REMOVED******REMOVED***/ - Returns: The minimum rect for a handle.
***REMOVED***private func minimumRect(forHandle handle: HandleLocation) -> CGRect {
***REMOVED******REMOVED***let maxWidth: CGFloat = 50
***REMOVED******REMOVED***let maxHeight: CGFloat  = 50
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch handle {
***REMOVED******REMOVED***case .topLeft:
***REMOVED******REMOVED******REMOVED******REMOVED*** Anchor is opposite corner.
***REMOVED******REMOVED******REMOVED***return CGRect(
***REMOVED******REMOVED******REMOVED******REMOVED***x: selectedRect.maxX - maxWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***y: selectedRect.maxY - maxHeight,
***REMOVED******REMOVED******REMOVED******REMOVED***width: maxWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***height: maxHeight
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .topRight:
***REMOVED******REMOVED******REMOVED***return CGRect(
***REMOVED******REMOVED******REMOVED******REMOVED***x: selectedRect.minX,
***REMOVED******REMOVED******REMOVED******REMOVED***y: selectedRect.maxY - maxHeight,
***REMOVED******REMOVED******REMOVED******REMOVED***width: maxWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***height: maxHeight
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .bottomLeft:
***REMOVED******REMOVED******REMOVED***return CGRect(
***REMOVED******REMOVED******REMOVED******REMOVED***x: selectedRect.maxX - maxWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***y: selectedRect.minY,
***REMOVED******REMOVED******REMOVED******REMOVED***width: maxWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***height: maxHeight
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .bottomRight:
***REMOVED******REMOVED******REMOVED***return CGRect(
***REMOVED******REMOVED******REMOVED******REMOVED***x: selectedRect.minX,
***REMOVED******REMOVED******REMOVED******REMOVED***y: selectedRect.minY,
***REMOVED******REMOVED******REMOVED******REMOVED***width: maxWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***height: maxHeight
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the handle locations using the boudning rect.
***REMOVED***private func updateHandles() {
***REMOVED******REMOVED***topRight = CGPoint(x: selectedRect.maxX, y: selectedRect.minY)
***REMOVED******REMOVED***topLeft = CGPoint(x: selectedRect.minX, y: selectedRect.minY)
***REMOVED******REMOVED***bottomLeft = CGPoint(x: selectedRect.minX, y: selectedRect.maxY)
***REMOVED******REMOVED***bottomRight = CGPoint(x: selectedRect.maxX, y: selectedRect.maxY)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The handle view for the map area selector.
***REMOVED***struct Handle: View {
***REMOVED******REMOVED******REMOVED***/ The position of the handle.
***REMOVED******REMOVED***let position: CGPoint
***REMOVED******REMOVED******REMOVED***/ The closure to call when the map area selector should be resized.
***REMOVED******REMOVED***let resize: (CGPoint) -> Void
***REMOVED******REMOVED******REMOVED***/ The gesture state of the drag gesture.
***REMOVED******REMOVED***@GestureState var gestureState: State = .started
***REMOVED******REMOVED******REMOVED***/ The types of gesture states.
***REMOVED******REMOVED***enum State {
***REMOVED******REMOVED******REMOVED***case started, changed
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***Color.clear
***REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(Rectangle())
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 44, height: 44)
***REMOVED******REMOVED******REMOVED******REMOVED***.position(position)
***REMOVED******REMOVED******REMOVED******REMOVED***.gesture(DragGesture(coordinateSpace: .local)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.updating($gestureState) { value, state, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch state {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .started:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***state = .changed
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UISelectionFeedbackGenerator().selectionChanged()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .changed:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***resize(value.location)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view that displays rounded corners for a rectangle view.
***REMOVED***struct RoundedCorners: Shape {
***REMOVED******REMOVED******REMOVED***/ The corner radius.
***REMOVED******REMOVED***let cornerRadius: CGFloat
***REMOVED******REMOVED******REMOVED***/ The padding to add to the corner shape.
***REMOVED******REMOVED***let padding = CGFloat(4)
***REMOVED******REMOVED***
***REMOVED******REMOVED***func path(in rect: CGRect) -> Path {
***REMOVED******REMOVED******REMOVED***var path = Path()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Add the rounded corners
***REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
***REMOVED******REMOVED******REMOVED***path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
***REMOVED******REMOVED******REMOVED***path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius + padding), control: CGPoint(x: rect.maxX, y: rect.minY))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
***REMOVED******REMOVED******REMOVED***path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius - padding, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
***REMOVED******REMOVED******REMOVED***path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius), control: CGPoint(x: rect.minX, y: rect.maxY))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return path
***REMOVED***
***REMOVED***
***REMOVED***

private extension View {
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

private extension CGRect {
***REMOVED***var center: CGPoint {
***REMOVED******REMOVED***CGPoint(x: midX, y: midY)
***REMOVED***
***REMOVED***
