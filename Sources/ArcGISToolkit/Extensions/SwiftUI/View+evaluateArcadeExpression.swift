***REMOVED*** Copyright 2023 Esri.

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

public extension View {
***REMOVED******REMOVED***/ Evaluates an arcade expression for a given dynamic entity, and re-evaluates it as the
***REMOVED******REMOVED***/ dynamic entity changes.
***REMOVED******REMOVED***/ - Remark: The supplied expression must contain a variable named $feature.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - arcadeExpression: The expression to evaluate when the dynamic entity changes.
***REMOVED******REMOVED***/   - dynamicEntity: The dynamic entity for which to monitor and evaluate an expression.
***REMOVED******REMOVED***/   - action: The closure called when the arcade expression is evaluated.
***REMOVED***func evaluateArcadeExpression(
***REMOVED******REMOVED***_ arcadeExpression: String,
***REMOVED******REMOVED***for dynamicEntity: DynamicEntity,
***REMOVED******REMOVED***perform action: @escaping (Result<ArcadeEvaluationResult, Error>) -> Void
***REMOVED***) -> some View {
***REMOVED******REMOVED***modifier(DynamicEntityExpressionObserverModifier(
***REMOVED******REMOVED******REMOVED***dynamicEntity: dynamicEntity,
***REMOVED******REMOVED******REMOVED***expression: arcadeExpression,
***REMOVED******REMOVED******REMOVED***onEvaluation: action
***REMOVED******REMOVED***))
***REMOVED***
***REMOVED***

private struct DynamicEntityExpressionObserverModifier: ViewModifier {
***REMOVED******REMOVED***/ The dynamic entity for which to monitor and evaluate an expression.
***REMOVED***private let dynamicEntity: DynamicEntity
***REMOVED******REMOVED***/ The expression to be evaluated when the dynamic entity changes.
***REMOVED***private let expression: String
***REMOVED******REMOVED***/ The closure called when the arcade expression is evaluated.
***REMOVED***private let onEvaluationAction: (Result<ArcadeEvaluationResult, Error>) -> Void
***REMOVED***
***REMOVED******REMOVED***/ Creates a dynamic entity evaluator view modifier. This view modifier evaluates
***REMOVED******REMOVED***/ an arcade expression for a given dynamic entity, and re-evaluates it as the
***REMOVED******REMOVED***/ dynamic entity changes.
***REMOVED******REMOVED***/ - Remark: The supplied expression must contain a variable named $feature.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - dynamicEntity: The dynamic entity for which to monitor and evaluate an expression.
***REMOVED******REMOVED***/   - expression: The expression to evaluate when the dynamic entity changes.
***REMOVED******REMOVED***/   - onEvaluation: The closure called when the arcade expression is evaluated.
***REMOVED***init(dynamicEntity: DynamicEntity, expression: String, onEvaluation action: @escaping (Result<ArcadeEvaluationResult, Error>) -> Void) {
***REMOVED******REMOVED***self.dynamicEntity = dynamicEntity
***REMOVED******REMOVED***self.expression = expression
***REMOVED******REMOVED***onEvaluationAction = action
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The id for the task that we use to observe changes to the dynamic entity.
***REMOVED***private var taskID: Int {
***REMOVED******REMOVED***var hasher = Hasher()
***REMOVED******REMOVED***hasher.combine(ObjectIdentifier(dynamicEntity))
***REMOVED******REMOVED***hasher.combine(expression)
***REMOVED******REMOVED***return hasher.finalize()
***REMOVED***
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.task(id: taskID) {
***REMOVED******REMOVED******REMOVED******REMOVED***let evaluator = ArcadeEvaluator(expression: ArcadeExpression(expression: expression), profile: .unrestricted)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Initial evaluation.
***REMOVED******REMOVED******REMOVED******REMOVED***if let observation = dynamicEntity.latestObservation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onEvaluationAction(await evaluator.evaluate(for: observation))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Evaluation as the dynamic entity changes.
***REMOVED******REMOVED******REMOVED******REMOVED***for await changes in dynamicEntity.changes {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard !changes.dynamicEntityWasPurged else { break ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let observation = changes.receivedObservation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onEvaluationAction(await evaluator.evaluate(for: observation))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

private extension ArcadeEvaluator {
***REMOVED******REMOVED***/ Evaluates the dynamic entity.
***REMOVED***func evaluate(for observation: DynamicEntityObservation) async -> Result<ArcadeEvaluationResult, Error> {
***REMOVED******REMOVED***await Result {
***REMOVED******REMOVED******REMOVED***try await evaluate(withProfileVariables: ["$feature": observation])
***REMOVED***
***REMOVED***
***REMOVED***
