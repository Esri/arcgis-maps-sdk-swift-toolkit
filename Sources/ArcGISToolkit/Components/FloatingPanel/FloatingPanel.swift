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
public struct FloatingPanel<Content>: View where Content: View {
***REMOVED******REMOVED*** Note:  instead of the FloatingPanel being a view, it might be preferable
***REMOVED******REMOVED*** to have it be a view modifier, similar to how SwiftUI doesn't have a
***REMOVED******REMOVED*** SheetView, but a modifier that presents a sheet.
***REMOVED***
***REMOVED******REMOVED***/ The content shown in the floating panel.
***REMOVED***let content: Content
***REMOVED***
***REMOVED******REMOVED***/ Creates a `FloatingPanel`
***REMOVED******REMOVED***/ - Parameter alignment: Alignment of the floating panel within the parent view.
***REMOVED******REMOVED***/ - Parameter initialHeight: The initial height given to the content of the floating panel.
***REMOVED******REMOVED***/ Default is 200.
***REMOVED******REMOVED***/ - Parameter width: The width given to the content of the floating panel. Default is 360.
***REMOVED******REMOVED***/ - Parameter content: The view shown in the floating panel.
***REMOVED***public init(
***REMOVED******REMOVED***alignment: Alignment,
***REMOVED******REMOVED***initialHeight: CGFloat = 200,
***REMOVED******REMOVED***width: CGFloat = 360,
***REMOVED******REMOVED***@ViewBuilder content: () -> Content
***REMOVED***) {
***REMOVED******REMOVED***self.alignment = alignment
***REMOVED******REMOVED***self.width = width
***REMOVED******REMOVED***self.content = content()
***REMOVED******REMOVED***_height = State(initialValue: initialHeight)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Alignment of the floating panel within the parent view.
***REMOVED***private let alignment: Alignment
***REMOVED***
***REMOVED******REMOVED***/ The width given to the content of the floating panel.
***REMOVED***private let width: CGFloat
***REMOVED***
***REMOVED******REMOVED***/ The color of the handle.
***REMOVED***@State private var handleColor: Color = .defaultHandleColor
***REMOVED***
***REMOVED******REMOVED***/ The height of the content.
***REMOVED***@State private var height: CGFloat
***REMOVED***
***REMOVED******REMOVED***/ The maximum allowed height of the content.
***REMOVED***@State private var maximumHeight: CGFloat = .infinity
***REMOVED***
***REMOVED******REMOVED***/ The vertical alignment of the floating panel with the parent view is `VerticalAlignment.top`
***REMOVED***private var isTopAligned: Bool {
***REMOVED******REMOVED***return alignment.vertical == .top
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***GeometryReader { geometryProxy in
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if isTopAligned {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(minHeight: .minHeight, maxHeight: height)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Handle(color: handleColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.gesture(drag)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Handle(color: handleColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.gesture(drag)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(minHeight: .minHeight, maxHeight: height)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(width: width)
***REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED***width: geometryProxy.size.width,
***REMOVED******REMOVED******REMOVED******REMOVED***height: geometryProxy.size.height,
***REMOVED******REMOVED******REMOVED******REMOVED***alignment: alignment
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED***maximumHeight = $0.height
***REMOVED******REMOVED******REMOVED******REMOVED***if height > maximumHeight {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height = maximumHeight
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
***REMOVED******REMOVED******REMOVED******REMOVED***if isTopAligned {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***proposedHeight = max(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.minHeight,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height + value.translation.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***proposedHeight = max(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.minHeight,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height - value.translation.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if proposedHeight <= maximumHeight {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height = proposedHeight
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onEnded { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***handleColor = .defaultHandleColor
***REMOVED******REMOVED***
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
