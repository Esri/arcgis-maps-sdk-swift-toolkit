// Copyright 2023 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import SwiftUI

/// The `FeatureFormView` component enables users to edit field values of a feature using
/// pre-configured forms, either from the Web Map Viewer or the Fields Maps Designer.
///
/// ![An image of the FeatureFormView component](FeatureFormView)
///
/// Forms are currently only supported in maps. The form definition is stored
/// in the web map itself and contains a title, description, and a list of "form elements".
///
/// `FeatureFormView` supports the display of form elements created by
/// the Map Viewer or Field Maps Designer, including:
///
/// - Attachments Element - used to display and edit attachments.
/// - Field Element - used to edit a single field of a feature with a specific "input type".
/// - Group Element - used to group elements together. Group Elements
/// can be expanded, to show all enclosed elements, or collapsed, hiding
/// the elements it contains.
/// - Text Element - used to display read-only plain or Markdown-formatted text.
///
/// A Field Element has a single input type object. The following are the supported input types:
///
/// - Barcode - machine readable data
/// - Combo Box - long list of values in a coded value domain
/// - Date/Time - date/time picker
/// - Radio Buttons - short list of values in a coded value domain
/// - Switch - two mutually exclusive values
/// - Text Area - multi-line text area
/// - Text Box - single-line text box
///
/// **Features**
///
/// - Display a form editing view for a feature based on the feature form definition defined in a web map and obtained from either an `ArcGISFeature`, `ArcGISFeatureTable`, `FeatureLayer` or `SubtypeSublayer`.
/// - Uses native SwiftUI controls for editing, such as `TextEditor`, `TextField`, and `DatePicker` for consistent platform styling.
/// - Supports elements containing Arcade expression and automatically evaluates expressions for element visibility, editability, values, and "required" state.
/// - Add, delete, or rename feature attachments.
/// - Fully supports dark mode, as do all Toolkit components.
///
/// **Behavior**
///
/// The feature form view can be embedded in any type of container view including, as demonstrated in the
/// example, the Toolkit's `FloatingPanel`.
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to [FeatureFormExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/FeatureFormExampleView.swift)
/// in the project. To learn more about using the `FeatureFormView` see the <doc:FeatureFormViewTutorial>.
///
/// - Note: In order to capture video and photos as form attachments, your application will need
/// `NSCameraUsageDescription` and, `NSMicrophoneUsageDescription` entries in the
/// `Info.plist` file.
///
/// - Since: 200.4
@available(visionOS, unavailable)
public struct FeatureFormView: View {
    /// The view model for the form.
    @StateObject private var model: FormViewModel
    
    /// <#Description#>
    @State private var formAssistantOverlayIsPresented = false
    
    /// <#Description#>
    @State private var formAssistantPhoto: UIImage?
    
    /// <#Description#>
    @State private var formAssistantText = String.formAssistantDefaultMessage
    
    /// A Boolean value indicating whether initial expression evaluation is running.
    @State private var initialExpressionsAreEvaluating = true
    
    /// The title of the feature form view.
    @State private var title = ""
    
    /// The visibility of the form header.
    var headerVisibility: Visibility = .automatic
    
    /// The validation error visibility configuration of the form.
    var validationErrorVisibility: ValidationErrorVisibility = FormViewValidationErrorVisibility.defaultValue
    
    /// Initializes a form view.
    /// - Parameters:
    ///   - featureForm: The feature form defining the editing experience.
    public init(featureForm: FeatureForm) {
        _model = StateObject(wrappedValue: FormViewModel(featureForm: featureForm))
    }
    
    public var body: some View {
        if initialExpressionsAreEvaluating {
            initialBody
        } else {
            evaluatedForm
        }
    }
    
    var evaluatedForm: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack(alignment: .leading) {
                    if !title.isEmpty && headerVisibility != .hidden {
                        FormHeader(formAssistantPhoto: $formAssistantPhoto, title: title)
                        Divider()
                    }
                    ForEach(model.visibleElements, id: \.self) { element in
                        makeElement(element)
                    }
                    if let attachmentsElement = model.featureForm.defaultAttachmentsElement {
                        // The Toolkit currently only supports AttachmentsFormElements via the
                        // default attachments element. Once AttachmentsFormElements can be authored
                        // this can call makeElement(_:) instead and makeElement(_:) should have a
                        // case added for AttachmentsFormElement.
                        AttachmentsFeatureElementView(featureElement: attachmentsElement)
                    }
                }
            }
            .onChange(model.focusedElement) { _ in
                if let focusedElement = model.focusedElement {
                    withAnimation { scrollViewProxy.scrollTo(focusedElement, anchor: .top) }
                }
            }
            .onTitleChange(of: model.featureForm) { newTitle in
                title = newTitle
            }
            .sheet(isPresented: $formAssistantOverlayIsPresented) {
                Group {
                    if let formAssistantPhoto {
                        VStack {
                            Image(uiImage: formAssistantPhoto)
                                // Resizable must come first
                                .resizable()
                                // Lock the aspect ratio
                                .aspectRatio(contentMode: .fit)
                                // Clip the shape
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                // Pad the outer edges, leave text at the bottom un-padded
                                .padding([.leading, .top, .trailing], 30)
                            HStack {
                                Image(systemName: "wand.and.sparkles")
                                    .pulseEffect()
                                    .symbolRenderingMode(.palette)
                                Text(formAssistantText)
                            }
                            .fontWeight(.heavy)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(ColorWheel())
                .edgesIgnoringSafeArea(.all)
                .interactiveDismissDisabled()
            }
            .task(id: formAssistantPhoto) {
                defer {
                    formAssistantPhoto = nil
                    formAssistantText = String.formAssistantDefaultMessage
                    formAssistantOverlayIsPresented = false
                }
                guard let formAssistantPhoto else { return }
                formAssistantOverlayIsPresented = true
                model.formAssistantFields.removeAll()
                
                // Build a Requester
                let openAIRequester = Requester()
                
                // Get photo overview
                let photoResponse = await openAIRequester.makeImageRequest(formAssistantPhoto, detail: .high)
                
                formAssistantText = String.formAssistantProcessingMessage
                
                // Prepare text question
                let fieldFormElements = model.featureForm.elements.compactMap { $0 as? FieldFormElement }
                let correlations = Dictionary(
                    uniqueKeysWithValues: fieldFormElements.enumerated().map { key, value in
                            ("\(key + 1)", value)
                    }
                )
                let questions = fieldFormElements.map {
                    if !$0.description.isEmpty {
                        $0.description
                    } else {
                        $0.label
                    }
                }
                let formattedQuestions = joinQuestions(questions)
                let question = makeTextQuestion(imageResponse: photoResponse, questions: formattedQuestions)
                
                // Get question response
                let questionResponse = await openAIRequester.makeTextRequest(request: question)
                
                // Fill out form fields
                let decoder = JSONDecoder()
                let data = questionResponse.data(using: .utf8)!
                let answers: [String: String]
                do {
                    answers = try decoder.decode([String:String].self, from: data)
                } catch {
                    print("JSON Decoding Error:", error.localizedDescription)
                    answers = [:]
                }
                var numberAnswered = 0
                correlations.forEach { key, fieldFormElement in
                    if let answer = answers[key], !answer.isEmpty {
                        numberAnswered += 1
                        fieldFormElement.updateValue(answer.capitalized)
                        model.formAssistantFields.append(fieldFormElement)
                    }
                }
            }
        }
#if os(iOS)
        .scrollDismissesKeyboard(.immediately)
#endif
        .environment(\.validationErrorVisibility, validationErrorVisibility)
        .environmentObject(model)
    }
}

@available(visionOS, unavailable)
extension FeatureFormView {
    func makeTextQuestion(imageResponse: String, questions: String) -> String {
        """
        Given the following textual description of an object please answer the following questions about the object in JSON using the question numbers as keys.
        If a question is not answerable, leave its answer blank.
        Exclude Markdown formatting around the JSON.
        
        The description:
        \(imageResponse)
        
        The questions:
        \(questions)
        """
    }
    
    func joinQuestions(_ questions: [String]) -> String {
        var result = ""
        var q = 1
        questions.forEach { question in
            let terminator = q == questions.count ? "" : "\n\n"
            result.append("\(q). \(question)\(terminator)")
            q += 1
        }
        return result
    }
    
    /// Makes UI for a form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeElement(_ element: FormElement) -> some View {
        switch element {
        case let element as FieldFormElement:
            makeFieldElement(element)
        case let element as GroupFormElement:
            GroupView(element: element, viewCreator: { internalMakeElement($0) })
        case let element as TextFormElement:
            makeTextElement(element)
        default:
            EmptyView()
        }
    }
    
    /// Makes UI for a field form element or a text form element.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func internalMakeElement(_ element: FormElement) -> some View {
        switch element {
        case let element as FieldFormElement:
            makeFieldElement(element)
        case let element as TextFormElement:
            makeTextElement(element)
        default:
            EmptyView()
        }
    }
    
    /// Makes UI for a field form element including a divider beneath it.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeFieldElement(_ element: FieldFormElement) -> some View {
        if !(element.input is UnsupportedFormInput) {
            InputWrapper(element: element)
            Divider()
        }
    }
    
    /// Makes UI for a text form element including a divider beneath it.
    /// - Parameter element: The element to generate UI for.
    @ViewBuilder func makeTextElement(_ element: TextFormElement) -> some View {
        TextFormElementView(element: element)
        Divider()
    }
    
    /// The progress view to be shown while initial expression evaluation is running.
    ///
    /// This avoids flashing elements that may immediately be set hidden or have
    /// values change as a result of initial expression evaluation.
    var initialBody: some View {
        ProgressView()
            .task {
                await model.initialEvaluation()
                initialExpressionsAreEvaluating = false
            }
    }
}

struct ColorWheel: View {
    @State private var angle = Angle(degrees: 0)
    var body: some View {
        AngularGradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .red], center: .center)
            .frame(width: 1000, height: 1000)
            .rotationEffect(angle)
            .blur(radius: 125)
            .onAppear {
                withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                    angle = Angle(degrees: 360)
                }
            }
    }
}

extension String {
    static var formAssistantDefaultMessage: Self {
        "Examining photo…"
    }
    
    static var formAssistantProcessingMessage: Self {
        "Answering form questions…"
    }
}

private extension View {
    @ViewBuilder
    func pulseEffect() -> some View {
        if #available(iOS 18.0, *) {
            self.symbolEffect(.pulse, options: .repeat(.continuous))
        } else {
            self
        }
    }
}
