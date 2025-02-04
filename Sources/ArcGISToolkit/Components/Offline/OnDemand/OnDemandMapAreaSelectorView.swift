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
***REMOVED***
***REMOVED***let mapViewProxy: MapViewProxy

***REMOVED***let envelope: Envelope
***REMOVED***
***REMOVED***let cordnerRadius: CGFloat = 16

***REMOVED***@State var boundingRect: CGRect
***REMOVED***
***REMOVED***@State var insetRect: CGRect = .zero
***REMOVED***
***REMOVED***@State private var initialRect: CGRect = .zero
***REMOVED***
***REMOVED***let minimumSize = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
***REMOVED******REMOVED***
***REMOVED***@State private var topLeft: CGPoint = .zero
***REMOVED***
***REMOVED***@State private var topRight: CGPoint = .zero
***REMOVED***
***REMOVED***@State private var bottomLeft: CGPoint = .zero
***REMOVED***
***REMOVED***@State private var bottomRight: CGPoint = .zero
***REMOVED***
***REMOVED***enum DragPoint {
***REMOVED******REMOVED***case topLeft, topRight, bottomLeft, bottomRight
***REMOVED***
***REMOVED***
***REMOVED***init(mapViewProxy: MapViewProxy, envelope: Envelope) {
***REMOVED******REMOVED***self.mapViewProxy = mapViewProxy
***REMOVED******REMOVED***self.envelope = envelope
***REMOVED******REMOVED***self.boundingRect = mapViewProxy.viewRect(fromEnvelope: envelope) ?? minimumSize
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: cordnerRadius, style: .continuous)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fill(.black.opacity(0.10))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.reverseMask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: cordnerRadius, style: .continuous)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: boundingRect.width, height: boundingRect.height)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.position(boundingRect.center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangleWithRoundedCorners(cornerRadius: cordnerRadius, style: .continuous)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.ultraThickMaterial, style: StrokeStyle(lineWidth: 6, lineCap: .butt))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: insetRect.width, height: insetRect.height)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.position(insetRect.center)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: cordnerRadius, style: .continuous)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.white, lineWidth: 4)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: boundingRect.width, height: boundingRect.height)
***REMOVED******REMOVED******REMOVED******REMOVED***.position(boundingRect.center)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.ignoresSafeArea()
***REMOVED******REMOVED******REMOVED***.allowsHitTesting(false)
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***initialRect = boundingRect
***REMOVED******REMOVED******REMOVED******REMOVED***insetRect = boundingRect.insetBy(dx: -2, dy: -2)
***REMOVED******REMOVED******REMOVED******REMOVED***updateHandles()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Handle(position: topLeft, color: .blue) {
***REMOVED******REMOVED******REMOVED******REMOVED***resize(for: .topLeft, location: $0)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Handle(position: topRight, color: .green) {
***REMOVED******REMOVED******REMOVED******REMOVED***resize(for: .topRight, location: $0)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Handle(position: bottomLeft, color: .yellow) {
***REMOVED******REMOVED******REMOVED******REMOVED***resize(for: .bottomLeft, location: $0)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Handle(position: bottomRight, color: .pink) {
***REMOVED******REMOVED******REMOVED******REMOVED***resize(for: .bottomRight, location: $0)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func validate(rect: CGRect) -> Bool {
***REMOVED******REMOVED***if rect.width < 50 || rect.height < 50 {
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if rect.width > initialRect.width || rect.height > initialRect.height {
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***return true
***REMOVED***
***REMOVED***
***REMOVED***private func resize(for handle: DragPoint, location: CGPoint) -> Void {
***REMOVED******REMOVED******REMOVED*** Resize the rect.
***REMOVED******REMOVED***let rectangle: CGRect
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch handle {
***REMOVED******REMOVED***case .topLeft:
***REMOVED******REMOVED******REMOVED***let minX = location.x
***REMOVED******REMOVED******REMOVED***let maxX = boundingRect.maxX
***REMOVED******REMOVED******REMOVED***let minY = location.y
***REMOVED******REMOVED******REMOVED***let maxY = boundingRect.maxY
***REMOVED******REMOVED******REMOVED***rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
***REMOVED******REMOVED***case .topRight:
***REMOVED******REMOVED******REMOVED***let minX = boundingRect.minX
***REMOVED******REMOVED******REMOVED***let maxX = location.x
***REMOVED******REMOVED******REMOVED***let minY = location.y
***REMOVED******REMOVED******REMOVED***let maxY = boundingRect.maxY
***REMOVED******REMOVED******REMOVED***rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
***REMOVED******REMOVED***case .bottomLeft:
***REMOVED******REMOVED******REMOVED***let minX = location.x
***REMOVED******REMOVED******REMOVED***let maxX = boundingRect.maxX
***REMOVED******REMOVED******REMOVED***let minY = boundingRect.minY
***REMOVED******REMOVED******REMOVED***let maxY = location.y
***REMOVED******REMOVED******REMOVED***rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
***REMOVED******REMOVED***case .bottomRight:
***REMOVED******REMOVED******REMOVED***let minX = boundingRect.minX
***REMOVED******REMOVED******REMOVED***let maxX = location.x
***REMOVED******REMOVED******REMOVED***let minY = boundingRect.minY
***REMOVED******REMOVED******REMOVED***let maxY = location.y
***REMOVED******REMOVED******REMOVED***rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Validate proposed resized rectangle.
***REMOVED******REMOVED***guard validate(rect: rectangle) else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Update bounding rect for valid proposed resize.
***REMOVED******REMOVED***boundingRect = rectangle
***REMOVED******REMOVED***
***REMOVED******REMOVED***insetRect = boundingRect.insetBy(dx: -2, dy: -2)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Now update handles for new bounding rect.
***REMOVED******REMOVED***updateHandles()
***REMOVED***
***REMOVED***
***REMOVED***private func updateHandles() {
***REMOVED******REMOVED***topRight = CGPoint(x: boundingRect.maxX, y: boundingRect.minY)
***REMOVED******REMOVED***topLeft = CGPoint(x: boundingRect.minX, y: boundingRect.minY)
***REMOVED******REMOVED***bottomLeft = CGPoint(x: boundingRect.minX, y: boundingRect.maxY)
***REMOVED******REMOVED***bottomRight = CGPoint(x: boundingRect.maxX, y: boundingRect.maxY)
***REMOVED***
***REMOVED***
***REMOVED***struct Handle: View {
***REMOVED******REMOVED***let position: CGPoint
***REMOVED******REMOVED***let color: Color
***REMOVED******REMOVED***let resize: (CGPoint) -> Void
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***Color.clear
***REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(Rectangle())
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 44, height: 44)
***REMOVED******REMOVED******REMOVED******REMOVED***.position(position)
***REMOVED******REMOVED******REMOVED******REMOVED***.gesture(DragGesture(coordinateSpace: .local)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChanged { value in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***resize(value.location)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct RoundedRectangleWithRoundedCorners: Shape {
***REMOVED******REMOVED***var cornerRadius: CGFloat
***REMOVED******REMOVED***
***REMOVED******REMOVED***var style: RoundedCornerStyle
***REMOVED******REMOVED***
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
***REMOVED***public func reverseMask<Mask: View>(
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
