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
***REMOVED***

***REMOVED***/ A view displaying the elements of a single Popup.
public struct PopupView: View {
***REMOVED******REMOVED***/ Creates a `PopupView` with the given popup.
***REMOVED******REMOVED***/ - Parameters
***REMOVED******REMOVED***/***REMOVED*** popup: The popup to display.
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating if the view is presented.
***REMOVED***public init(popup: Popup, isPresented: Binding<Bool>? = nil) {
***REMOVED******REMOVED***self.popup = popup
***REMOVED******REMOVED***self.isPresented = isPresented
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `Popup` to display.
***REMOVED***private var popup: Popup
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether a "close" button should be shown or not. If the "close"
***REMOVED******REMOVED***/ button is shown, you should pass in the `isPresented` argument to the initializer,
***REMOVED******REMOVED***/ so that the the "close" button can close the view.
***REMOVED***private var showCloseButton = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the popup's elements have been evaluated via
***REMOVED******REMOVED***/ the `popup.evaluateExpressions()` method.
***REMOVED***@State private var isPopupEvaluated: Bool? = nil

***REMOVED******REMOVED***/ The results of calling the `popup.evaluateExpressions()` method.
***REMOVED***@State private var expressionEvaluations: [PopupExpressionEvaluation]? = nil
***REMOVED***
***REMOVED******REMOVED***/ A binding to a Boolean value that determines whether the view is presented.
***REMOVED***private var isPresented: Binding<Bool>?

***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if !popup.title.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(popup.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.bold)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***if showCloseButton {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(action: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented?.wrappedValue = false
***REMOVED******REMOVED******REMOVED******REMOVED***, label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top, .bottom, .trailing], 4)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if let isPopupEvaluated = isPopupEvaluated {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if isPopupEvaluated {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PopupElementScrollView(popup: popup)
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Popup evaluation failed.")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Evaluating popup expressions...")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***expressionEvaluations = try await popup.evaluateExpressions()
***REMOVED******REMOVED******REMOVED******REMOVED***isPopupEvaluated = true
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***isPopupEvaluated = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct PopupElementScrollView: View {
***REMOVED******REMOVED***var popup: Popup
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(Array(popup.evaluatedElements.enumerated()), id: \.offset) { index, popupElement in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch popupElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case let popupElement as AttachmentsPopupElement:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentsPopupElementView(popupElement: popupElement)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case let popupElement as FieldsPopupElement:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FieldsPopupElementView(popupElement: popupElement)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case let popupElement as MediaPopupElement:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***MediaPopupElementView(popupElement: popupElement)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case let popupElement as TextPopupElement:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextPopupElementView(popupElement: popupElement)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension PopupView {
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
