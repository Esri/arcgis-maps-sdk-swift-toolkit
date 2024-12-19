***REMOVED*** Copyright 2023 Esri
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

***REMOVED***/ The `FeatureFormView` component enables users to edit field values of a feature using
***REMOVED***/ pre-configured forms, either from the Web Map Viewer or the Fields Maps Designer.
***REMOVED***/
***REMOVED***/ ![An image of the FeatureFormView component](FeatureFormView)
***REMOVED***/
***REMOVED***/ Forms are currently only supported in maps. The form definition is stored
***REMOVED***/ in the web map itself and contains a title, description, and a list of "form elements".
***REMOVED***/
***REMOVED***/ `FeatureFormView` supports the display of form elements created by
***REMOVED***/ the Map Viewer or Field Maps Designer, including:
***REMOVED***/
***REMOVED***/ - Attachments Element - used to display and edit attachments.
***REMOVED***/ - Field Element - used to edit a single field of a feature with a specific "input type".
***REMOVED***/ - Group Element - used to group elements together. Group Elements
***REMOVED***/ can be expanded, to show all enclosed elements, or collapsed, hiding
***REMOVED***/ the elements it contains.
***REMOVED***/ - Text Element - used to display read-only plain or Markdown-formatted text.
***REMOVED***/
***REMOVED***/ A Field Element has a single input type object. The following are the supported input types:
***REMOVED***/
***REMOVED***/ - Barcode - machine readable data
***REMOVED***/ - Combo Box - long list of values in a coded value domain
***REMOVED***/ - Date/Time - date/time picker
***REMOVED***/ - Radio Buttons - short list of values in a coded value domain
***REMOVED***/ - Switch - two mutually exclusive values
***REMOVED***/ - Text Area - multi-line text area
***REMOVED***/ - Text Box - single-line text box
***REMOVED***/
***REMOVED***/ **Features**
***REMOVED***/
***REMOVED***/ - Display a form editing view for a feature based on the feature form definition defined in a web map and obtained from either an `ArcGISFeature`, `ArcGISFeatureTable`, `FeatureLayer` or `SubtypeSublayer`.
***REMOVED***/ - Uses native SwiftUI controls for editing, such as `TextEditor`, `TextField`, and `DatePicker` for consistent platform styling.
***REMOVED***/ - Supports elements containing Arcade expression and automatically evaluates expressions for element visibility, editability, values, and "required" state.
***REMOVED***/ - Add, delete, or rename feature attachments.
***REMOVED***/ - Fully supports dark mode, as do all Toolkit components.
***REMOVED***/
***REMOVED***/ **Behavior**
***REMOVED***/
***REMOVED***/ The feature form view can be embedded in any type of container view including, as demonstrated in the
***REMOVED***/ example, the Toolkit's `FloatingPanel`.
***REMOVED***/
***REMOVED***/ To see it in action, try out the [Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
***REMOVED***/ and refer to [FeatureFormExampleView.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/FeatureFormExampleView.swift)
***REMOVED***/ in the project. To learn more about using the `FeatureFormView` see the <doc:FeatureFormViewTutorial>.
***REMOVED***/
***REMOVED***/ - Note: In order to capture video and photos as form attachments, your application will need
***REMOVED***/ `NSCameraUsageDescription` and, `NSMicrophoneUsageDescription` entries in the
***REMOVED***/ `Info.plist` file.
***REMOVED***/
***REMOVED***/ - Since: 200.4
@available(visionOS, unavailable)
public struct FeatureFormView: View {
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@StateObject private var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var formAssistantOverlayIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var formAssistantPhoto: UIImage?
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var formAssistantText = String.formAssistantDefaultMessage
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether initial expression evaluation is running.
***REMOVED***@State private var initialExpressionsAreEvaluating = true
***REMOVED***
***REMOVED******REMOVED***/ The title of the feature form view.
***REMOVED***@State private var title = ""
***REMOVED***
***REMOVED******REMOVED***/ The visibility of the form header.
***REMOVED***var headerVisibility: Visibility = .automatic
***REMOVED***
***REMOVED******REMOVED***/ The validation error visibility configuration of the form.
***REMOVED***var validationErrorVisibility: ValidationErrorVisibility = FormViewValidationErrorVisibility.defaultValue
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form defining the editing experience.
***REMOVED***public init(featureForm: FeatureForm) {
***REMOVED******REMOVED***_model = StateObject(wrappedValue: FormViewModel(featureForm: featureForm))
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***if initialExpressionsAreEvaluating {
***REMOVED******REMOVED******REMOVED***initialBody
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***evaluatedForm
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var evaluatedForm: some View {
***REMOVED******REMOVED***ScrollViewReader { scrollViewProxy in
***REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !title.isEmpty && headerVisibility != .hidden {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FormHeader(formAssistantPhoto: $formAssistantPhoto, title: title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(model.visibleElements, id: \.self) { element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeElement(element)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let attachmentsElement = model.featureForm.defaultAttachmentsElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** The Toolkit currently only supports AttachmentsFormElements via the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** default attachments element. Once AttachmentsFormElements can be authored
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** this can call makeElement(_:) instead and makeElement(_:) should have a
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** case added for AttachmentsFormElement.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AttachmentsFeatureElementView(featureElement: attachmentsElement)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(model.focusedElement) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***if let focusedElement = model.focusedElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation { scrollViewProxy.scrollTo(focusedElement, anchor: .top) ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onTitleChange(of: model.featureForm) { newTitle in
***REMOVED******REMOVED******REMOVED******REMOVED***title = newTitle
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $formAssistantOverlayIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let formAssistantPhoto {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: formAssistantPhoto)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Resizable must come first
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Lock the aspect ratio
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Clip the shape
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 30))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Pad the outer edges, leave text at the bottom un-padded
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.leading, .top, .trailing], 30)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "wand.and.sparkles")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.pulseEffect()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbolRenderingMode(.palette)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(formAssistantText)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.heavy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, maxHeight: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED***.background(ColorWheel())
***REMOVED******REMOVED******REMOVED******REMOVED***.edgesIgnoringSafeArea(.all)
***REMOVED******REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task(id: formAssistantPhoto) {
***REMOVED******REMOVED******REMOVED******REMOVED***defer {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formAssistantPhoto = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formAssistantText = String.formAssistantDefaultMessage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formAssistantOverlayIsPresented = false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***guard let formAssistantPhoto else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***formAssistantOverlayIsPresented = true
***REMOVED******REMOVED******REMOVED******REMOVED***model.formAssistantFields.removeAll()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Build a Requester
***REMOVED******REMOVED******REMOVED******REMOVED***let openAIRequester = Requester()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Get photo overview
***REMOVED******REMOVED******REMOVED******REMOVED***let photoResponse = await openAIRequester.makeImageRequest(formAssistantPhoto, detail: .high)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***formAssistantText = String.formAssistantProcessingMessage
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Prepare text question
***REMOVED******REMOVED******REMOVED******REMOVED***let fieldFormElements = model.featureForm.elements.compactMap { $0 as? FieldFormElement ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let correlations = Dictionary(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***uniqueKeysWithValues: fieldFormElements.enumerated().map { key, value in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***("\(key + 1)", value)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***let questions = fieldFormElements.map {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !$0.description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***$0.description
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***$0.label
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let formattedQuestions = joinQuestions(questions)
***REMOVED******REMOVED******REMOVED******REMOVED***let question = makeTextQuestion(imageResponse: photoResponse, questions: formattedQuestions)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Get question response
***REMOVED******REMOVED******REMOVED******REMOVED***let questionResponse = await openAIRequester.makeTextRequest(request: question)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Fill out form fields
***REMOVED******REMOVED******REMOVED******REMOVED***let decoder = JSONDecoder()
***REMOVED******REMOVED******REMOVED******REMOVED***let data = questionResponse.data(using: .utf8)!
***REMOVED******REMOVED******REMOVED******REMOVED***let answers: [String: String]
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***answers = try decoder.decode([String:String].self, from: data)
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("JSON Decoding Error:", error.localizedDescription)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***answers = [:]
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***var numberAnswered = 0
***REMOVED******REMOVED******REMOVED******REMOVED***correlations.forEach { key, fieldFormElement in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let answer = answers[key], !answer.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***numberAnswered += 1
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fieldFormElement.updateValue(answer.capitalized)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.formAssistantFields.append(fieldFormElement)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
#if os(iOS)
***REMOVED******REMOVED***.scrollDismissesKeyboard(.immediately)
#endif
***REMOVED******REMOVED***.environment(\.validationErrorVisibility, validationErrorVisibility)
***REMOVED******REMOVED***.environmentObject(model)
***REMOVED***
***REMOVED***

@available(visionOS, unavailable)
extension FeatureFormView {
***REMOVED***func makeTextQuestion(imageResponse: String, questions: String) -> String {
***REMOVED******REMOVED***"""
***REMOVED******REMOVED***Given the following textual description of an object please answer the following questions about the object in JSON using the question numbers as keys.
***REMOVED******REMOVED***If a question is not answerable, leave its answer blank.
***REMOVED******REMOVED***Exclude Markdown formatting around the JSON.
***REMOVED******REMOVED***
***REMOVED******REMOVED***The description:
***REMOVED******REMOVED***\(imageResponse)
***REMOVED******REMOVED***
***REMOVED******REMOVED***The questions:
***REMOVED******REMOVED***\(questions)
***REMOVED******REMOVED***"""
***REMOVED***
***REMOVED***
***REMOVED***func joinQuestions(_ questions: [String]) -> String {
***REMOVED******REMOVED***var result = ""
***REMOVED******REMOVED***var q = 1
***REMOVED******REMOVED***questions.forEach { question in
***REMOVED******REMOVED******REMOVED***let terminator = q == questions.count ? "" : "\n\n"
***REMOVED******REMOVED******REMOVED***result.append("\(q). \(question)\(terminator)")
***REMOVED******REMOVED******REMOVED***q += 1
***REMOVED***
***REMOVED******REMOVED***return result
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes UI for a form element.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeElement(_ element: FormElement) -> some View {
***REMOVED******REMOVED***switch element {
***REMOVED******REMOVED***case let element as FieldFormElement:
***REMOVED******REMOVED******REMOVED***makeFieldElement(element)
***REMOVED******REMOVED***case let element as GroupFormElement:
***REMOVED******REMOVED******REMOVED***GroupView(element: element, viewCreator: { internalMakeElement($0) ***REMOVED***)
***REMOVED******REMOVED***case let element as TextFormElement:
***REMOVED******REMOVED******REMOVED***makeTextElement(element)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes UI for a field form element or a text form element.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func internalMakeElement(_ element: FormElement) -> some View {
***REMOVED******REMOVED***switch element {
***REMOVED******REMOVED***case let element as FieldFormElement:
***REMOVED******REMOVED******REMOVED***makeFieldElement(element)
***REMOVED******REMOVED***case let element as TextFormElement:
***REMOVED******REMOVED******REMOVED***makeTextElement(element)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes UI for a field form element including a divider beneath it.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeFieldElement(_ element: FieldFormElement) -> some View {
***REMOVED******REMOVED***if !(element.input is UnsupportedFormInput) {
***REMOVED******REMOVED******REMOVED***InputWrapper(element: element)
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes UI for a text form element including a divider beneath it.
***REMOVED******REMOVED***/ - Parameter element: The element to generate UI for.
***REMOVED***@ViewBuilder func makeTextElement(_ element: TextFormElement) -> some View {
***REMOVED******REMOVED***TextFormElementView(element: element)
***REMOVED******REMOVED***Divider()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The progress view to be shown while initial expression evaluation is running.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This avoids flashing elements that may immediately be set hidden or have
***REMOVED******REMOVED***/ values change as a result of initial expression evaluation.
***REMOVED***var initialBody: some View {
***REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***await model.initialEvaluation()
***REMOVED******REMOVED******REMOVED******REMOVED***initialExpressionsAreEvaluating = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

struct ColorWheel: View {
***REMOVED***@State private var angle = Angle(degrees: 0)
***REMOVED***var body: some View {
***REMOVED******REMOVED***AngularGradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .red], center: .center)
***REMOVED******REMOVED******REMOVED***.frame(width: 1000, height: 1000)
***REMOVED******REMOVED******REMOVED***.rotationEffect(angle)
***REMOVED******REMOVED******REMOVED***.blur(radius: 125)
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***angle = Angle(degrees: 360)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

extension String {
***REMOVED***static var formAssistantDefaultMessage: Self {
***REMOVED******REMOVED***"Examining photo…"
***REMOVED***
***REMOVED***
***REMOVED***static var formAssistantProcessingMessage: Self {
***REMOVED******REMOVED***"Answering form questions…"
***REMOVED***
***REMOVED***

private extension View {
***REMOVED***@ViewBuilder
***REMOVED***func pulseEffect() -> some View {
***REMOVED******REMOVED***if #available(iOS 18.0, *) {
***REMOVED******REMOVED******REMOVED***self.symbolEffect(.pulse, options: .repeat(.continuous))
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***
