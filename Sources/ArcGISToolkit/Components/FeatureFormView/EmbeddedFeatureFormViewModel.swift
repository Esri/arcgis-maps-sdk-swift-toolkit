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

@Observable
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
    var visibleElements = [FormElement]()
    
    /// The expression evaluation task.
    @ObservationIgnored
    private var evaluateTask: Task<Void, Never>?
    
    /// The feature form.
    private(set) var featureForm: FeatureForm
    
    /// The group of visibility tasks.
    @ObservationIgnored
    private var isVisibleTasks = [Task<Void, Never>]()
    
    /// Initializes a form view model.
    /// - Parameter featureForm: The feature form defining the editing experience.
    public init(featureForm: FeatureForm) {
        self.featureForm = featureForm
    }
    
    deinit {
        evaluateTask?.cancel()
        isVisibleTasks.forEach { task in
            task.cancel()
        }
        isVisibleTasks.removeAll()
    }
    
    /// Kick off tasks to monitor `isVisible` for each element.
    @MainActor
    private func initializeIsVisibleTasks() {
        isVisibleTasks.forEach { $0.cancel() }
        isVisibleTasks.removeAll()
        for element in featureForm.elements {
            let newTask = Task { [weak self] in
                for await _ in element.$isVisible {
                    guard !Task.isCancelled else { return }
                    self?.updateVisibleElements()
                }
            }
            isVisibleTasks.append(newTask)
        }
    }
    
    /// A detached task observing visibility changes.
    private func updateVisibleElements() {
        visibleElements = featureForm.elements.filter { $0.isVisible }
    }
    
    /// Performs an initial evaluation of all form expressions.
    @MainActor
    func initialEvaluation() async {
        _ = try? await featureForm.evaluateExpressions()
        initializeIsVisibleTasks()
    }
    
    /// Performs an evaluation of all form expressions.
    @MainActor
    func evaluateExpressions() {
        evaluateTask?.cancel()
        evaluateTask = Task {
            _ = try? await featureForm.evaluateExpressions()
        }
    }
}
