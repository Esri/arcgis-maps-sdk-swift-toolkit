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

public extension View {
***REMOVED******REMOVED***/ A floating panel is a view that overlays a view and supplies view-related
***REMOVED******REMOVED***/ content. For a map view, for instance, it could display a legend, bookmarks, search results, etc..
***REMOVED******REMOVED***/ Apple Maps, Google Maps, Windows 10, and Collector have floating panel
***REMOVED******REMOVED***/ implementations, sometimes referred to as a "bottom sheet".
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Floating panels are non-modal and can be transient, only displaying
***REMOVED******REMOVED***/ information for a short period of time like identify results,
***REMOVED******REMOVED***/ or persistent, where the information is always displayed, for example a
***REMOVED******REMOVED***/ dedicated search panel. They will also be primarily simple containers
***REMOVED******REMOVED***/ that clients will fill with their own content.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ The floating panel allows for interaction with background contents, unlike native sheets or popovers.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - backgroundColor: The background color of the floating panel.
***REMOVED******REMOVED***/   - selectedDetent: A binding to the currently selected detent.
***REMOVED******REMOVED***/   - horizontalAlignment: The horizontal alignment of the floating panel.
***REMOVED******REMOVED***/   - isPresented: A binding to a Boolean value that determines whether the view is presented.
***REMOVED******REMOVED***/   - maxWidth: The maximum width of the floating panel.
***REMOVED******REMOVED***/   - content: A closure that returns the content of the floating panel.
***REMOVED******REMOVED***/ - Returns: A dynamic view with a presentation style similar to that of a sheet in compact
***REMOVED******REMOVED***/ environments and a popover otherwise.
***REMOVED***func floatingPanel<Content>(
***REMOVED******REMOVED***backgroundColor: Color = Color(uiColor: .systemBackground),
***REMOVED******REMOVED***selectedDetent: Binding<FloatingPanelDetent> = .constant(.half),
***REMOVED******REMOVED***horizontalAlignment: HorizontalAlignment = .trailing,
***REMOVED******REMOVED***isPresented: Binding<Bool> = .constant(true),
***REMOVED******REMOVED***maxWidth: CGFloat = 400,
***REMOVED******REMOVED***_ content: @escaping () -> Content
***REMOVED***) -> some View where Content: View {
***REMOVED******REMOVED***modifier(
***REMOVED******REMOVED******REMOVED***FloatingPanelModifier(
***REMOVED******REMOVED******REMOVED******REMOVED***backgroundColor: backgroundColor,
***REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: selectedDetent,
***REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: horizontalAlignment,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: maxWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***panelContent: content()
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED***/ Overlays a floating panel on the parent content.
private struct FloatingPanelModifier<PanelContent>: ViewModifier where PanelContent: View {
***REMOVED***@Environment(\.horizontalSizeClass) private var horizontalSizeClass
***REMOVED***@Environment(\.verticalSizeClass) var verticalSizeClass
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the environment is compact.
***REMOVED***private var isCompact: Bool {
***REMOVED******REMOVED***horizontalSizeClass == .compact && verticalSizeClass == .regular
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The background color of the floating panel.
***REMOVED***let backgroundColor: Color
***REMOVED***
***REMOVED******REMOVED***/ A binding to the currently selected detent.
***REMOVED***let selectedDetent: Binding<FloatingPanelDetent>
***REMOVED***
***REMOVED******REMOVED***/ The horizontal alignment of the floating panel.
***REMOVED***let horizontalAlignment: HorizontalAlignment
***REMOVED***
***REMOVED******REMOVED***/ A binding to a Boolean value that determines whether the view is presented.
***REMOVED***let isPresented: Binding<Bool>
***REMOVED***
***REMOVED******REMOVED***/ The maximum width of the floating panel.
***REMOVED***let maxWidth: CGFloat
***REMOVED***
***REMOVED******REMOVED***/ The content to be displayed within the floating panel.
***REMOVED***let panelContent: PanelContent
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.overlay(alignment: Alignment(horizontal: horizontalAlignment, vertical: .top)) {
***REMOVED******REMOVED******REMOVED******REMOVED***FloatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***backgroundColor: backgroundColor,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: selectedDetent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: isPresented
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***panelContent
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.ignoresSafeArea(.all, edges: .bottom)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: isCompact ? .infinity : maxWidth)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
