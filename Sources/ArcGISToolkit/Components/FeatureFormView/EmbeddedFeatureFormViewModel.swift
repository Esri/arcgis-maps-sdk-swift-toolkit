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

@MainActor @Observable
class EmbeddedFeatureFormViewModel {
    /// The current focused element, if one exists.
    var focusedElement: FormElement? {
        didSet {
            if let focusedElement, !previouslyFocusedElements.contains(focusedElement) {
                previouslyFocusedElements.append(focusedElement)
            }
        }
    }
    
    /// The currently presented feature form view.
    var presentedForm: FeatureFormView?
    
    /// The set of all elements which previously held focus.
    var previouslyFocusedElements = [FormElement]()
    
    /// The title of the feature form view.
    var title = ""
    
    /// The list of visible form elements.
    var visibleElements: [FormElement] {
        var elements = elementVisibility
            .filter(\.value)
            .map(\.key)
        if let attachmentsElement = featureForm.defaultAttachmentsElement {
            elements.append(attachmentsElement)
        }
        return elements
    }
    
    private var elementVisibility: [FormElement: Bool] = [:]
    
    /// The expression evaluation task.
    @ObservationIgnored
    private var evaluateTask: Task<Void, Never>?
    
    /// The feature form.
    private(set) var featureForm: FeatureForm
    
    /// The group of visibility tasks.
    @ObservationIgnored
    private var visibilityTask: Task<Void, Never>?
    
    /// Initializes a form view model.
    /// - Parameter featureForm: The feature form defining the editing experience.
    public init(featureForm: FeatureForm) {
        self.featureForm = featureForm
        evaluateExpressions()
        monitorVisibility()
    }
    
    deinit {
        evaluateTask?.cancel()
        visibilityTask?.cancel()
    }
    
    /// Performs an evaluation of all form expressions.
    func evaluateExpressions() {
        evaluateTask?.cancel()
        evaluateTask = Task {
            _ = try? await featureForm.evaluateExpressions()
        }
    }
    
    /// Starts a task group which monitors the visibility of each form element.
    private func monitorVisibility() {
        visibilityTask?.cancel()
        visibilityTask = Task { [weak self] in
            await withTaskGroup(of: Void.self) { group in
                for element in self?.featureForm.elements ?? [] {
                    group.addTask { [weak self] in
                        for await isVisible in element.$isVisible {
                            guard !Task.isCancelled else { return }
                            await MainActor.run { [weak self] in
                                self?.elementVisibility[element] = isVisible
                            }
                        }
                    }
                }
            }
        }
    }
}
