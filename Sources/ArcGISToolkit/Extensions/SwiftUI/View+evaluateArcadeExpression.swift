// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS

public extension View {
    /// Evaluates an arcade expression for a given dynamic entity, and re-evaluates it as the
    /// dynamic entity changes.
    /// - Remark: The supplied expression must contain a variable named $feature.
    /// - Parameters:
    ///   - arcadeExpression: The expression to evaluate when the dynamic entity changes.
    ///   - dynamicEntity: The dynamic entity for which to monitor and evaluate an expression.
    ///   - action: The closure called when the arcade expression is evaluated.
    func evaluateArcadeExpression(
        _ arcadeExpression: String,
        for dynamicEntity: DynamicEntity,
        perform action: @escaping (Result<ArcadeEvaluationResult, Error>) -> Void
    ) -> some View {
        modifier(DynamicEntityExpressionObserverModifier(
            dynamicEntity: dynamicEntity,
            expression: arcadeExpression,
            onEvaluation: action
        ))
    }
}

private struct DynamicEntityExpressionObserverModifier: ViewModifier {
    /// The dynamic entity for which to monitor and evaluate an expression.
    private let dynamicEntity: DynamicEntity
    /// The expression to be evaluated when the dynamic entity changes.
    private let expression: String
    /// The closure called when the arcade expression is evaluated.
    private let onEvaluationAction: (Result<ArcadeEvaluationResult, Error>) -> Void
    
    /// Creates a dynamic entity evaluator view modifier. This view modifier evaluates
    /// an arcade expression for a given dynamic entity, and re-evaluates it as the
    /// dynamic entity changes.
    /// - Remark: The supplied expression must contain a variable named $feature.
    /// - Parameters:
    ///   - dynamicEntity: The dynamic entity for which to monitor and evaluate an expression.
    ///   - expression: The expression to evaluate when the dynamic entity changes.
    ///   - onEvaluation: The closure called when the arcade expression is evaluated.
    init(dynamicEntity: DynamicEntity, expression: String, onEvaluation action: @escaping (Result<ArcadeEvaluationResult, Error>) -> Void) {
        self.dynamicEntity = dynamicEntity
        self.expression = expression
        onEvaluationAction = action
    }
    
    /// The id for the task that we use to observe changes to the dynamic entity.
    private var taskID: Int {
        var hasher = Hasher()
        hasher.combine(ObjectIdentifier(dynamicEntity))
        hasher.combine(expression)
        return hasher.finalize()
    }
    
    func body(content: Content) -> some View {
        content
            .task(id: taskID) {
                let evaluator = ArcadeEvaluator(expression: ArcadeExpression(expression: expression), profile: .unrestricted)
                // Initial evaluation.
                if let observation = dynamicEntity.latestObservation {
                    onEvaluationAction(await evaluator.evaluate(for: observation))
                }
                // Evaluation as the dynamic entity changes.
                for await changes in dynamicEntity.changes {
                    guard !changes.dynamicEntityWasPurged else { break }
                    if let observation = changes.receivedObservation {
                        onEvaluationAction(await evaluator.evaluate(for: observation))
                    }
                }
            }
    }
}

private extension ArcadeEvaluator {
    /// Evaluates the dynamic entity.
    func evaluate(for observation: DynamicEntityObservation) async -> Result<ArcadeEvaluationResult, Error> {
        await Result {
            try await evaluate(withProfileVariables: ["$feature": observation])
        }
    }
}
