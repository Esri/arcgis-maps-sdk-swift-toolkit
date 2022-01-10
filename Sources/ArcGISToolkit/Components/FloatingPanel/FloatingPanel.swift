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
***REMOVED******REMOVED***/ - Parameter content: The view shown in the floating panel.
***REMOVED***public init(@ViewBuilder content: () -> Content) {
***REMOVED******REMOVED***self.content = content()
***REMOVED***
***REMOVED***
***REMOVED***@State
***REMOVED***private var handleColor: Color = .defaultHandleColor
***REMOVED***
***REMOVED***@State
***REMOVED***private var height: CGFloat?
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(minHeight: .minHeight, maxHeight: height)
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***Handle(color: handleColor)
***REMOVED******REMOVED******REMOVED******REMOVED***.gesture(drag)
***REMOVED***
***REMOVED******REMOVED***.esriBorder()
***REMOVED***
***REMOVED***
***REMOVED***var drag: some Gesture {
***REMOVED******REMOVED***DragGesture(minimumDistance: 0)
***REMOVED******REMOVED******REMOVED***.onChanged { value in
***REMOVED******REMOVED******REMOVED******REMOVED***handleColor = .activeHandleColor
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Note:  There is a bug here where `height` can be set
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** larger than the displayed height.  This occurs by continuing
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** to drag down on the handle after the panel reaches it's max
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** height.  When that happens subsequent "drag up" operations
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** don't cause the panel to shrink immediately, but will
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** ultimately snap to the correct height.
***REMOVED******REMOVED******REMOVED******REMOVED***height = max(.minHeight, (height ?? 0) + value.translation.height)
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
