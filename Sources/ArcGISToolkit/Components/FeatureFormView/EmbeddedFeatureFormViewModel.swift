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
import Observation

private import os

@MainActor @Observable
final class EmbeddedFeatureFormViewModel {
    /// The models for fetching association filter results for each utility associations form element in the form.
    var associationsFilterResultsModels: [UtilityAssociationsFormElement: AssociationsFilterResultsModel] = [:]
    
    /// The phrase used to filter which elements are visible when running UI tests.
    var elementFilterPhrase = ""
    
    /// The current focused element, if one exists.
    var focusedElement: FormElement? {
        didSet {
            if let focusedElement, !previouslyFocusedElements.contains(focusedElement) {
                previouslyFocusedElements.append(focusedElement)
            }
        }
    }
    
    /// A Boolean value indicating whether the associated form has edits.
    var hasEdits = false {
        didSet {
            if !hasEdits {
                previouslyFocusedElements.removeAll()
            }
        }
    }
    
    /// The set of all elements which previously held focus.
    var previouslyFocusedElements = [FormElement]()
    
    /// The title of the feature form view.
    var title = ""
    
    /// The list of visible form elements.
    ///
    /// - SeeAlso: `visibleElementsFlattened`
    var visibleElements: [FormElement] {
        var elements = featureForm
            .elements
            .filter { elementVisibility[$0, default: false] }
        if let attachmentsElement = featureForm.defaultAttachmentsElement {
            elements.append(attachmentsElement)
        }
        return elementFilterPhrase.isEmpty
        ? elements
        : elements.filter {
            $0.label.localizedCaseInsensitiveContains(elementFilterPhrase)
        }
    }
    
    /// The list of visible form elements and inner visible group elements.
    ///
    /// - SeeAlso: `visibleElements`
    var visibleElementsFlattened: [FormElement] {
        visibleElements
            .flatMap {
                switch $0 {
                case let group as GroupFormElement:
                    return group.elements.filter(\.isVisible)
                default:
                    return [$0]
                }
            }
    }
    
    /// The feature form.
    let featureForm: FeatureForm
    
    /// <#Description#>
    var autoFilledElements = [String]()
    /// <#Description#>
    var languageModelIsProcessing = false
    /// <#Description#>
    var voiceObservationInProgress = false
    
    /// A dictionary of each form element and whether or not it is visible.
    private var elementVisibility: [FormElement: Bool] = [:]
    
    /// The expression evaluation task.
    @ObservationIgnored
    private var evaluateTask: Task<Void, Never>?
    
    /// <#Description#>
    @ObservationIgnored
    private var languageModelAdapter: EmbeddedFeatureFormView.LanguageModelAdapter?
    
    /// <#Description#>
    @ObservationIgnored
    private var speechRecognizer: SpeechRecognizer?
    
    /// The group of visibility tasks.
    @ObservationIgnored
    private var visibilityTask: Task<Void, Never>?
    
    /// A task to monitor whether the form has edits.
    @ObservationIgnored
    private var monitorEditsTask: Task<Void, Never>?
    
    /// Initializes a form view model.
    /// - Parameter featureForm: The feature form defining the editing experience.
    public init(featureForm: FeatureForm) {
        self.featureForm = featureForm
        evaluateExpressions()
        monitorEdits()
        monitorVisibility()
    }
    
    deinit {
        evaluateTask?.cancel()
        monitorEditsTask?.cancel()
        visibilityTask?.cancel()
    }
    
    @available(iOS 26.0, *)
    func autoFillForm() async {
        voiceObservationInProgress = false
        languageModelIsProcessing = true
        speechRecognizer?.stopTranscribing()
        
        guard let transcript = speechRecognizer?.transcript else {
            Logger.featureFormView.info("No observation collected.")
            return
        }
        Logger.featureFormView.info("Auto-filling form.")
        
        func runQuestions() async {
            guard let formResponse = try? await languageModelAdapter?.generateResponse(transcript: transcript) else { return }
            let unfilledElements: [FieldFormElement] = visibleElementsFlattened
                .compactMap { $0 as? FieldFormElement }
                .filter { !autoFilledElements.contains($0.fieldName) }
            formResponse.elementResponses.forEach { elementResponse in
                if elementResponse.answered, !elementResponse.answer.isEmpty,
                   let element = unfilledElements.first(where: { $0.fieldName == elementResponse.fieldName }) {
                    if !element.codedValues.isEmpty {
                        if let code = element.codedValues.first(where: { "\($0.code ?? "")" == elementResponse.answer })?.code {
                            element.updateValue(code)
                        } else if let code = element.codedValues.first(where: { $0.name.lowercased() == elementResponse.answer.lowercased() })?.code {
                            element.updateValue(code)
                        }
                    } else {
                        element.convertAndUpdateValue(elementResponse.answer)
                    }
                    autoFilledElements.append(element.fieldName)
                }
            }
            _ = try? await featureForm.evaluateExpressions()
        }
        
        await runQuestions()
        languageModelIsProcessing = false
    }
    
    func collectVoiceObservation() {
        if speechRecognizer == nil {
            speechRecognizer = SpeechRecognizer()
        }
        speechRecognizer?.resetTranscript()
        voiceObservationInProgress = true
        speechRecognizer?.startTranscribing()
        // Prewarm the language model.
        languageModelAdapter = EmbeddedFeatureFormView.LanguageModelAdapter(formModel: self)
    }
    
    /// Performs an evaluation of all form expressions.
    func evaluateExpressions() {
        evaluateTask?.cancel()
        evaluateTask = Task {
            if let errors = try? await featureForm.evaluateExpressions(), !errors.isEmpty {
                for evaluationError in errors {
                    Logger.featureFormView.error(
                        "Error evaluating expression: \(evaluationError.error.localizedDescription)"
                    )
                }
            }
        }
    }
    
    /// <#Description#>
    func onEditsDiscarded() {
        autoFilledElements.removeAll()
    }
    
    /// Starts a task to monitor whether the associated form has edits.
    private func monitorEdits() {
        monitorEditsTask?.cancel()
        monitorEditsTask = Task { [weak self] in
            guard !Task.isCancelled, let featureForm = self?.featureForm else { return }
            for await hasEdits in featureForm.$hasEdits.dropFirst() {
                self?.hasEdits = hasEdits
            }
        }
    }
    
    /// Starts a task group which monitors the visibility of each form element.
    private func monitorVisibility() {
        visibilityTask?.cancel()
        visibilityTask = Task { [weak self] in
            await withTaskGroup { group in
                for element in self?.featureForm.elements ?? [] {
                    group.addTask { @MainActor @Sendable [weak self] in
                        for await isVisible in element.$isVisible {
                            guard !Task.isCancelled else { return }
                            self?.elementVisibility[element] = isVisible
                        }
                    }
                }
            }
        }
    }
}
