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
***REMOVED***

***REMOVED***/ The `PopupView` component will display a popup for an individual feature. This includes showing
***REMOVED***/ the feature's title, attributes, custom description, media, and attachments. The new online Map
***REMOVED***/ Viewer allows users to create a popup definition by assembling a list of “popup elements”.
***REMOVED***/ `PopupView` will support the display of popup elements created by the Map Viewer, including:
***REMOVED***/ Text, Fields, Attachments, and Media (Images and Charts).
***REMOVED***/
***REMOVED***/ Thanks to the backwards compatibility support in the API, it will also work with the legacy
***REMOVED***/ popup definitions created by the classic Map Viewer. It does not support editing.
***REMOVED***/
***REMOVED***/ | iPhone | iPad |
***REMOVED***/ | ------ | ---- |
***REMOVED***/ | ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/203422507-66b6c6dc-a6c3-4040-b996-9c0da8d4e580.png) | ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/203422665-c4759c1f-5863-4251-94df-ed7a06ac7a8f.png) |
***REMOVED***/
***REMOVED***/ > Note: Attachment previews are not available when running on Mac (regardless of Xcode version).
***REMOVED***/
***REMOVED***/ **Features**
***REMOVED***/
***REMOVED***/ - Display a popup for a feature based on the popup definition defined in a web map.
***REMOVED***/ - Supports image refresh intervals on image popup media, refreshing the image at a given
***REMOVED***/ interval defined in the popup element.
***REMOVED***/ - Supports elements containing Arcade expression and automatically evaluates expressions.
***REMOVED***/ - Displays media (images and charts) full-screen.
***REMOVED***/ - Supports hyperlinks in text, media, and fields elements.
***REMOVED***/ - Fully supports dark mode, as do all Toolkit components.
***REMOVED***/ - Supports auto-refresh for popups where the geo element is a dynamic entity.
***REMOVED***/
***REMOVED***/ **Behavior**
***REMOVED***/
***REMOVED***/ The popup view can display an optional "close" button, allowing the user to dismiss the view.
***REMOVED***/ The popup view can be embedded in any type of container view including, as demonstrated in the
***REMOVED***/ example, the Toolkit's `FloatingPanel`.
***REMOVED***/
***REMOVED***/ To see it in action, try out the [Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
***REMOVED***/ and refer to
***REMOVED***/ [PopupExampleView.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/PopupExampleView.swift)
***REMOVED***/ in the project. To learn more about using the `PopupView` see the <doc:PopupViewTutorial>.
public struct PopupView: View {
***REMOVED******REMOVED***/ Creates a `PopupView` with the given popup.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - popup: The popup to display.
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating if the view is presented.
***REMOVED***public init(popup: Popup, isPresented: Binding<Bool>? = nil) {
***REMOVED******REMOVED***self.popup = popup
***REMOVED******REMOVED***self.isPresented = isPresented
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `Popup` to display.
***REMOVED***private let popup: Popup
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether a "close" button should be shown or not. If the "close"
***REMOVED******REMOVED***/ button is shown, you should pass in the `isPresented` argument to the initializer,
***REMOVED******REMOVED***/ so that the the "close" button can close the view.
***REMOVED***var showCloseButton = false
***REMOVED***
***REMOVED******REMOVED***/ The visibility of the popup title.
***REMOVED***private var titleVisibility: TitleVisibility = .visible
***REMOVED***
***REMOVED******REMOVED***/ The result of evaluating the popup expressions.
***REMOVED***@State private var evaluation: Evaluation?
***REMOVED***
***REMOVED******REMOVED***/ A binding to a Boolean value that determines whether the view is presented.
***REMOVED***private var isPresented: Binding<Bool>?
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if !popup.title.isEmpty && titleVisibility == .visible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(popup.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.bold)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***if showCloseButton {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(String.close, systemImage: "xmark") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented?.wrappedValue = false
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.labelStyle(.iconOnly)
#if !os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top, .bottom, .trailing], 4)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbolVariant(.circle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
#endif
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if let evaluation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let error = evaluation.error {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Popup evaluation failed: \(error.localizedDescription)",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** An error message shown when a popup cannot be displayed. The
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** variable provides additional data.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PopupElementList(popupElements: evaluation.elements)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .center, spacing: 10) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Evaluating popup expressions",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label indicating popup expressions are being evaluated."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task(id: ObjectIdentifier(popup)) {
***REMOVED******REMOVED******REMOVED******REMOVED*** Initial evaluation for a newly assigned popup.
***REMOVED******REMOVED******REMOVED***evaluation = nil
***REMOVED******REMOVED******REMOVED***await evaluateExpressions()
***REMOVED***
***REMOVED******REMOVED***.task(id: ObjectIdentifier(popup)) {
***REMOVED******REMOVED******REMOVED******REMOVED*** If the popup is showing for a dynamic entity, then observe
***REMOVED******REMOVED******REMOVED******REMOVED*** the changes and update the popup accordingly.
***REMOVED******REMOVED******REMOVED***guard let dynamicEntity = popup.geoElement as? DynamicEntity else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***for await changes in dynamicEntity.changes {
***REMOVED******REMOVED******REMOVED******REMOVED***if changes.dynamicEntityWasPurged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if changes.receivedObservation != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await evaluateExpressions()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Evaluates the arcade expressions and updates the evaluation property.
***REMOVED***private func evaluateExpressions() async {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***_ = try await popup.evaluateExpressions()
***REMOVED******REMOVED******REMOVED***evaluation = Evaluation(elements: popup.evaluatedElements)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***evaluation = Evaluation(error: error)
***REMOVED***
***REMOVED***
***REMOVED***

extension PopupView {
***REMOVED***private struct PopupElementList: View {
***REMOVED******REMOVED***let popupElements: [PopupElement]
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***List(popupElements) { popupElement in
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch popupElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case let popupElement as AttachmentsPopupElement:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentsFeatureElementView(featureElement: popupElement)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case let popupElement as FieldsPopupElement:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FieldsPopupElementView(popupElement: popupElement)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case let popupElement as MediaPopupElement:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***MediaPopupElementView(popupElement: popupElement)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case let popupElement as TextPopupElement:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextPopupElementView(popupElement: popupElement)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED***
***REMOVED***
***REMOVED***

extension PopupView {
***REMOVED******REMOVED***/ An object used to hold the result of evaluating the expressions of a popup.
***REMOVED***private final class Evaluation {
***REMOVED******REMOVED******REMOVED***/ The evaluated elements.
***REMOVED******REMOVED***let elements: [PopupElement]
***REMOVED******REMOVED******REMOVED***/ The error that occurred during evaluation, if any.
***REMOVED******REMOVED***let error: Error?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates an evaluation.
***REMOVED******REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED******REMOVED***/   - elements: The evaluated elements.
***REMOVED******REMOVED******REMOVED***/   - error: The error that occurred during evaluation, if any.
***REMOVED******REMOVED***init(elements: [PopupElement] = [], error: Error? = nil) {
***REMOVED******REMOVED******REMOVED***self.elements = elements
***REMOVED******REMOVED******REMOVED***self.error = error
***REMOVED***
***REMOVED***
***REMOVED***

extension PopupView {
***REMOVED******REMOVED***/ The visibility of the popup title.
***REMOVED******REMOVED***/ - Since: 200.6
***REMOVED***public enum TitleVisibility: Sendable {
***REMOVED******REMOVED******REMOVED***/ The popup title is hidden.
***REMOVED******REMOVED***case hidden
***REMOVED******REMOVED******REMOVED***/ The popup title is visible.
***REMOVED******REMOVED***case visible
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Specifies the visibility of the popup title.
***REMOVED******REMOVED***/ - Parameter visibility: The visibility of the popup title.
***REMOVED******REMOVED***/ - Since: 200.6
***REMOVED***public func popupTitle(_ visibility: TitleVisibility) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.titleVisibility = visibility
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Specifies whether a "close" button should be shown to the right of the popup title. If the "close"
***REMOVED******REMOVED***/ button is shown, you should pass in the `isPresented` argument to the `PopupView`
***REMOVED******REMOVED***/ initializer, so that the the "close" button can close the view.
***REMOVED******REMOVED***/ Defaults to `false`.
***REMOVED******REMOVED***/ - Parameter newShowCloseButton: The new value.
***REMOVED******REMOVED***/ - Returns: A new `PopupView`.
***REMOVED***public func showCloseButton(_ newShowCloseButton: Bool) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.showCloseButton = newShowCloseButton
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
