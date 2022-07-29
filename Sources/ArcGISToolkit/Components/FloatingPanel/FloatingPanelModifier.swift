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
***REMOVED******REMOVED***/ Presents a dynamic view with a presentation style similar to that of a sheet in compact
***REMOVED******REMOVED***/ environments and a popover otherwise.
***REMOVED******REMOVED***/ The resulting view allows for interaction with background contents.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: <#isPresented description#>
***REMOVED******REMOVED***/   - content: <#content description#>
***REMOVED******REMOVED***/   - horizontalAlignment: <#horizontalAlignment description#>
***REMOVED******REMOVED***/   - detent: <#detent description#>
***REMOVED******REMOVED***/ - Returns: <#description#>
***REMOVED***func floatingPanel<Content>(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***backgroundColor: Color = Color(uiColor: .systemBackground),
***REMOVED******REMOVED***horizontalAlignment: HorizontalAlignment = .trailing,
***REMOVED******REMOVED***detent: Binding<FloatingPanelDetent>,
***REMOVED******REMOVED***_ content: @escaping () -> Content
***REMOVED***) -> some View where Content: View {
***REMOVED******REMOVED***modifier(
***REMOVED******REMOVED******REMOVED***FloatingPanelModifier(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED******REMOVED***backgroundColor: backgroundColor,
***REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: horizontalAlignment,
***REMOVED******REMOVED******REMOVED******REMOVED***detent: detent,
***REMOVED******REMOVED******REMOVED******REMOVED***innerContent: content()
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED***/ <#Description#>
private struct FloatingPanelModifier<InnerContent>: ViewModifier where InnerContent: View {
***REMOVED***@Environment(\.horizontalSizeClass) private var horizontalSizeClass
***REMOVED***@Environment(\.verticalSizeClass) var verticalSizeClass
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the environment is compact.
***REMOVED***private var isCompact: Bool {
***REMOVED******REMOVED***horizontalSizeClass == .compact && verticalSizeClass == .regular
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@Binding var isPresented: Bool
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let backgroundColor: Color
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let horizontalAlignment: HorizontalAlignment
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***var detent: Binding<FloatingPanelDetent>
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let innerContent: InnerContent
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.overlay(alignment: Alignment(horizontal: horizontalAlignment, vertical: .top)) {
***REMOVED******REMOVED******REMOVED******REMOVED***FloatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***backgroundColor: backgroundColor,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***detent: detent
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***innerContent
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.edgesIgnoringSafeArea(.bottom)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: isCompact ? .infinity : 400)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
