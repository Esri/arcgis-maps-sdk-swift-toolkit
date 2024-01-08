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
@MainActor public class FormViewModel: ObservableObject {
    /// The feature form.
    private(set) var featureForm: FeatureForm
    
    /// The current focused element, if one exists.
    @Published var focusedElement: FormElement?
    
    /// The expression evaluation task.
    private var evaluateTask: Task<Void, Never>?
    
    /// The visibility tasks group.
    private var isVisibleTask: Task<Void, Never>?
    
    /// The list of visible form elements.
    @Published var visibleElements = [FormElement]()
    
    /// The list of expression evaluation errors.
    @Published var expressionEvaluationErrors = [FormExpressionEvaluationError]()
    
    /// A Boolean value indicating whether evaluation is running.
    @Published var isEvaluating = true
    
    /// Initializes a form view model.
    /// - Parameter featureForm: The feature form defining the editing experience.
    public init(featureForm: FeatureForm) {
        self.featureForm = featureForm
    }
    
    deinit {
        evaluateTask?.cancel()
        isVisibleTask?.cancel()
    }
    
    /// Kick off tasks to monitor `isVisible` for each element.
    private func initializeIsVisibleTasks() {
        isVisibleTask = Task.detached { [unowned self] in
            await withTaskGroup(of: Void.self) { group in
                for element in await self.featureForm.elements {
                    group.addTask {
                        for await _ in element.$isVisible {
                            guard !Task.isCancelled else { return }
                            await self.updateVisibleElements()
                        }
                    }
                }
            }
        }
    }
    
    /// A detached task observing visibility changes.
    private func updateVisibleElements() {
        visibleElements = featureForm.elements.filter { $0.isVisible }
    }
    
    /// Performs an initial evaluation of all form expressions.
    func initialEvaluation() async {
        let evaluationErrors = try? await featureForm.evaluateExpressions()
        expressionEvaluationErrors = evaluationErrors ?? []
        initializeIsVisibleTasks()
    }
    
    /// Performs an evaluation of all form expressions.
    func evaluateExpressions() {
        evaluateTask?.cancel()
        isEvaluating = true
        evaluateTask = Task {
            let evaluationErrors = try? await featureForm.evaluateExpressions()
            expressionEvaluationErrors = evaluationErrors ?? []
            isEvaluating = false
        }
    }
    
    var validationErrors: [String : [Error]] {
        featureForm.validationErrors
    }
}
