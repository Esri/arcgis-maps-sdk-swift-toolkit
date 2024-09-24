***REMOVED*** Copyright 2022 Esri
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

public extension View {
***REMOVED******REMOVED***/ A floating panel is a view that overlays a view and supplies view-related
***REMOVED******REMOVED***/ content. For more information see <doc:FloatingPanel>.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - attributionBarHeight: The height of a geo-view's attribution bar.
***REMOVED******REMOVED***/   - backgroundColor: The background color of the floating panel.
***REMOVED******REMOVED***/   - selectedDetent: A binding to the currently selected detent.
***REMOVED******REMOVED***/   - horizontalAlignment: The horizontal alignment of the floating panel.
***REMOVED******REMOVED***/   - isPresented: A binding to a Boolean value that determines whether the view is presented.
***REMOVED******REMOVED***/   - maxWidth: The maximum width of the floating panel.
***REMOVED******REMOVED***/   - content: A closure that returns the content of the floating panel.
***REMOVED******REMOVED***/ - Returns: A dynamic view with a presentation style similar to that of a sheet in compact
***REMOVED******REMOVED***/ environments and a popover otherwise.
***REMOVED***@available(iOS 16.0, *)
***REMOVED***@available(macCatalyst 16.0, *)
***REMOVED***@available(visionOS, unavailable, message: "Use 'floatingPanel(attributionBarHeight:selectedDetent:horizontalAlignment:isPresented:maxWidth:_:)' instead.")
***REMOVED***func floatingPanel<Content>(
***REMOVED******REMOVED***attributionBarHeight: CGFloat = 0,
***REMOVED******REMOVED***backgroundColor: Color = Color(uiColor: .systemBackground),
***REMOVED******REMOVED***selectedDetent: Binding<FloatingPanelDetent>? = nil,
***REMOVED******REMOVED***horizontalAlignment: HorizontalAlignment = .trailing,
***REMOVED******REMOVED***isPresented: Binding<Bool> = .constant(true),
***REMOVED******REMOVED***maxWidth: CGFloat = 400,
***REMOVED******REMOVED***@ViewBuilder _ content: @escaping () -> Content
***REMOVED***) -> some View where Content: View {
***REMOVED******REMOVED***modifier(
***REMOVED******REMOVED******REMOVED***FloatingPanelModifier(
***REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight: attributionBarHeight,
***REMOVED******REMOVED******REMOVED******REMOVED***backgroundColor: backgroundColor,
***REMOVED******REMOVED******REMOVED******REMOVED***boundDetent: selectedDetent,
***REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: horizontalAlignment,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: maxWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***panelContent: content
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A floating panel is a view that overlays a view and supplies view-related
***REMOVED******REMOVED***/ content. For more information see <doc:FloatingPanel>.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - attributionBarHeight: The height of a geo-view's attribution bar.
***REMOVED******REMOVED***/   - selectedDetent: A binding to the currently selected detent.
***REMOVED******REMOVED***/   - horizontalAlignment: The horizontal alignment of the floating panel.
***REMOVED******REMOVED***/   - isPresented: A binding to a Boolean value that determines whether the view is presented.
***REMOVED******REMOVED***/   - maxWidth: The maximum width of the floating panel.
***REMOVED******REMOVED***/   - content: A closure that returns the content of the floating panel.
***REMOVED******REMOVED***/ - Returns: A dynamic view with a presentation style similar to that of a sheet in compact
***REMOVED******REMOVED***/ environments and a popover otherwise.
***REMOVED***@available(visionOS 2.0, *)
***REMOVED***@available(iOS, unavailable, message: "Use 'floatingPanel(attributionBarHeight:selectedDetent:horizontalAlignment:isPresented:maxWidth:_:)' instead.")
***REMOVED***@available(macCatalyst, unavailable, message: "Use 'floatingPanel(attributionBarHeight:selectedDetent:horizontalAlignment:isPresented:maxWidth:_:)' instead.")
***REMOVED***func floatingPanel<Content>(
***REMOVED******REMOVED***attributionBarHeight: CGFloat = 0,
***REMOVED******REMOVED***selectedDetent: Binding<FloatingPanelDetent>? = nil,
***REMOVED******REMOVED***horizontalAlignment: HorizontalAlignment = .trailing,
***REMOVED******REMOVED***isPresented: Binding<Bool> = .constant(true),
***REMOVED******REMOVED***maxWidth: CGFloat = 400,
***REMOVED******REMOVED***@ViewBuilder _ content: @escaping () -> Content
***REMOVED***) -> some View where Content: View {
***REMOVED******REMOVED***modifier(
***REMOVED******REMOVED******REMOVED***FloatingPanelModifier(
***REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight: attributionBarHeight,
***REMOVED******REMOVED******REMOVED******REMOVED***backgroundColor: nil,
***REMOVED******REMOVED******REMOVED******REMOVED***boundDetent: selectedDetent,
***REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: horizontalAlignment,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: maxWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***panelContent: content
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED***/ Overlays a floating panel on the parent content.
private struct FloatingPanelModifier<PanelContent>: ViewModifier where PanelContent: View {
***REMOVED***@Environment(\.isPortraitOrientation) var isPortraitOrientation
***REMOVED***
***REMOVED******REMOVED***/ The height of a geo-view's attribution bar.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ When the panel is detached from the bottom of the screen this value allows
***REMOVED******REMOVED***/ the panel to be aligned correctly between the top of a geo-view and the top of the
***REMOVED******REMOVED***/ its attribution bar.
***REMOVED***let attributionBarHeight: CGFloat
***REMOVED***
***REMOVED******REMOVED***/ The background color of the floating panel.
***REMOVED***let backgroundColor: Color?
***REMOVED***
***REMOVED******REMOVED***/ A user provided detent.
***REMOVED***let boundDetent: Binding<FloatingPanelDetent>?
***REMOVED***
***REMOVED******REMOVED***/ A managed detent when a user bound one isn't provided.
***REMOVED***@State private var managedDetent: FloatingPanelDetent = .half
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
***REMOVED***let panelContent: () -> PanelContent
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.overlay(alignment: Alignment(horizontal: horizontalAlignment, vertical: .top)) {
***REMOVED******REMOVED******REMOVED******REMOVED***FloatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight: attributionBarHeight,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***backgroundColor: backgroundColor,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: boundDetent ?? $managedDetent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***content: panelContent
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: isPortraitOrientation ? .infinity : maxWidth)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
