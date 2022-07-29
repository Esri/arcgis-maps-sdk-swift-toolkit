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
***REMOVED******REMOVED*** Note:  instead of the FloatingPanel being a view, it might be preferable
***REMOVED******REMOVED*** to have it be a view modifier, similar to how SwiftUI doesn't have a
***REMOVED******REMOVED*** SheetView, but a modifier that presents a sheet.
***REMOVED***
***REMOVED***@Environment(\.horizontalSizeClass) private var horizontalSizeClass
***REMOVED***
***REMOVED******REMOVED***/ The content shown in the floating panel.
***REMOVED***let content: Content
***REMOVED***
***REMOVED******REMOVED***/ Creates a `FloatingPanel`
***REMOVED******REMOVED***/ - Parameter content: The view shown in the floating panel.
***REMOVED******REMOVED***/ - Parameter detent: <#detent description#>
***REMOVED***init(
***REMOVED******REMOVED***detent: Binding<FloatingPanelDetent>,
***REMOVED******REMOVED***@ViewBuilder content: () -> Content
***REMOVED***) {
***REMOVED******REMOVED***self.content = content()
***REMOVED******REMOVED***_detent = detent
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The color of the handle.
***REMOVED***@State private var handleColor: Color = .defaultHandleColor
***REMOVED***
***REMOVED******REMOVED***/ The height of the content.
***REMOVED***@State private var height: CGFloat = .minHeight
***REMOVED***
***REMOVED******REMOVED***/ The maximum allowed height of the content.
***REMOVED***@State private var maximumHeight: CGFloat = .infinity
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@Binding var detent: FloatingPanelDetent
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the panel should be configured for a compact environment.
***REMOVED***private var isCompact: Bool {
***REMOVED******REMOVED***horizontalSizeClass == .compact
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***GeometryReader { geometryProxy in
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if isCompact {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Handle(color: handleColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.gesture(drag)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(minHeight: .minHeight, maxHeight: height)
***REMOVED******REMOVED******REMOVED******REMOVED***if !isCompact {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Handle(color: handleColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.gesture(drag)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding([.top, .bottom], 10)
***REMOVED******REMOVED******REMOVED***.background(Color(uiColor: .systemGroupedBackground))
***REMOVED******REMOVED******REMOVED***.cornerRadius(10, corners: isCompact ? [.topLeft, .topRight] : [.allCorners])
***REMOVED******REMOVED******REMOVED***.shadow(radius: 10)
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
***REMOVED******REMOVED******REMOVED***.onChange(of: detent) { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height = heightWithDetent
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height = heightWithDetent
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
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
***REMOVED***var closestDetent: FloatingPanelDetent {
***REMOVED******REMOVED***return FloatingPanelDetent.allCases.min { d1, d2 in
***REMOVED******REMOVED******REMOVED***abs(heightFor(detent: d1) - height) < abs(heightFor(detent: d2) - height)
***REMOVED*** ?? .half
***REMOVED***
***REMOVED***
***REMOVED***func heightFor(detent: FloatingPanelDetent) -> CGFloat {
***REMOVED******REMOVED***switch detent {
***REMOVED******REMOVED***case .min:
***REMOVED******REMOVED******REMOVED***return .minHeight
***REMOVED******REMOVED***case .oneQuarter:
***REMOVED******REMOVED******REMOVED***return maximumHeight * 0.25
***REMOVED******REMOVED***case .half:
***REMOVED******REMOVED******REMOVED***return maximumHeight * 0.5
***REMOVED******REMOVED***case .threeQuarters:
***REMOVED******REMOVED******REMOVED***return maximumHeight * 0.75
***REMOVED******REMOVED***case .max:
***REMOVED******REMOVED******REMOVED***return maximumHeight
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ - Returns: Displayable height given the current detent
***REMOVED***var heightWithDetent: CGFloat {
***REMOVED******REMOVED***return heightFor(detent: detent)
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
