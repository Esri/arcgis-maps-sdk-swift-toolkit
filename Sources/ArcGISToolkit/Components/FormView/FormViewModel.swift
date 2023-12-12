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
import Combine
import SwiftUI

/// - Since: 200.4
public class FormViewModel: ObservableObject {
    /// The feature form.
    private(set) var featureForm: FeatureForm
    
    /// The current focused element, if one exists.
    @MainActor @Published var focusedElement: FormElement?
    
    /// The expression evaluation task.
    private var evaluateTask: Task<Void, Never>?
    
    /// The group of visibility tasks.
    private var isVisibleTasks = [Task<Void, Never>]()
    
    /// The list of visible form elements.
    @MainActor @Published var visibleElements = [FormElement]()
    
    /// The list of expression evaluation errors.
    @MainActor @Published var expressionEvaluationErrors = [FormExpressionEvaluationError]()
    
    /// A Boolean value indicating whether evaluation is running.
    @MainActor @Published var isEvaluating = true
    
    /// Initializes a form view model.
    /// - Parameter featureForm: The feature form defining the editing experience.
    public init(featureForm: FeatureForm) {
        self.featureForm = featureForm
    }
    
    deinit {
        clearIsVisibleTasks()
        evaluateTask?.cancel()
    }
    
    /// Kick off tasks to monitor `isVisible` for each element.
    func initializeIsVisibleTasks() {
        clearIsVisibleTasks()
        
        // Kick off tasks to monitor isVisible for each element.
        featureForm.elements.forEach { element in
            let newTask = Task.detached { [unowned self] in
                for await _ in element.$isVisible {
                    await MainActor.run {
                        self.updateVisibleElements()
                    }
                }
            }
            isVisibleTasks.append(newTask)
        }
    }
    
    /// A detached task observing visibility changes.
    @MainActor private func updateVisibleElements() {
        visibleElements = featureForm.elements.filter { $0.isVisible }
    }
    
    /// Cancels and removes tasks.
    private func clearIsVisibleTasks() {
        isVisibleTasks.forEach { task in
            task.cancel()
        }
        isVisibleTasks.removeAll()
    }
    
    /// Performs an initial evaluation of all form expressions.
    @MainActor func initialEvaluation() async throws {
        let evaluationErrors = try? await featureForm.evaluateExpressions()
        expressionEvaluationErrors = evaluationErrors ?? []
        initializeIsVisibleTasks()
    }

    /// Performs an evaluation of all form expressions.
    @MainActor func evaluateExpressions() {
        evaluateTask?.cancel()
        isEvaluating = true
        evaluateTask = Task {
            let evaluationErrors = try? await featureForm.evaluateExpressions()
            await MainActor.run {
                expressionEvaluationErrors = evaluationErrors ?? []
                isEvaluating = false
            }
        }
    }
}
