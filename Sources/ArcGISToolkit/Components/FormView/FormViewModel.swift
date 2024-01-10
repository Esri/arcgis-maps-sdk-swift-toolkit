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
import Combine
***REMOVED***

***REMOVED***/ - Since: 200.4
@MainActor public class FormViewModel: ObservableObject {
***REMOVED******REMOVED***/ The feature form.
***REMOVED***private(set) var featureForm: FeatureForm
***REMOVED***
***REMOVED******REMOVED***/ The current focused element, if one exists.
***REMOVED***@Published var focusedElement: FormElement? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***if let focusedElement, !previouslyFocusedFields.contains(focusedElement) {
***REMOVED******REMOVED******REMOVED******REMOVED***previouslyFocusedFields.append(focusedElement)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The expression evaluation task.
***REMOVED***private var evaluateTask: Task<Void, Never>?
***REMOVED***
***REMOVED******REMOVED***/ The visibility tasks group.
***REMOVED***private var isVisibleTask: Task<Void, Never>?
***REMOVED***
***REMOVED******REMOVED***/ The list of visible form elements.
***REMOVED***@Published var visibleElements = [FormElement]()
***REMOVED***
***REMOVED******REMOVED***/ The list of expression evaluation errors.
***REMOVED***@Published var expressionEvaluationErrors = [FormExpressionEvaluationError]()
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether evaluation is running.
***REMOVED***@Published var isEvaluating = true
***REMOVED***
***REMOVED***@Published var previouslyFocusedFields = [FormElement]()
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view model.
***REMOVED******REMOVED***/ - Parameter featureForm: The feature form defining the editing experience.
***REMOVED***public init(featureForm: FeatureForm) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED***
***REMOVED***
***REMOVED***deinit {
***REMOVED******REMOVED***evaluateTask?.cancel()
***REMOVED******REMOVED***isVisibleTask?.cancel()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Kick off tasks to monitor `isVisible` for each element.
***REMOVED***private func initializeIsVisibleTasks() {
***REMOVED******REMOVED***isVisibleTask = Task.detached { [unowned self] in
***REMOVED******REMOVED******REMOVED***await withTaskGroup(of: Void.self) { group in
***REMOVED******REMOVED******REMOVED******REMOVED***for element in await self.featureForm.elements {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***group.addTask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await _ in element.$isVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard !Task.isCancelled else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await self.updateVisibleElements()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A detached task observing visibility changes.
***REMOVED***private func updateVisibleElements() {
***REMOVED******REMOVED***visibleElements = featureForm.elements.filter { $0.isVisible ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Performs an initial evaluation of all form expressions.
***REMOVED***func initialEvaluation() async {
***REMOVED******REMOVED***let evaluationErrors = try? await featureForm.evaluateExpressions()
***REMOVED******REMOVED***expressionEvaluationErrors = evaluationErrors ?? []
***REMOVED******REMOVED***initializeIsVisibleTasks()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Performs an evaluation of all form expressions.
***REMOVED***func evaluateExpressions() {
***REMOVED******REMOVED***evaluateTask?.cancel()
***REMOVED******REMOVED***isEvaluating = true
***REMOVED******REMOVED***evaluateTask = Task {
***REMOVED******REMOVED******REMOVED***let evaluationErrors = try? await featureForm.evaluateExpressions()
***REMOVED******REMOVED******REMOVED***expressionEvaluationErrors = evaluationErrors ?? []
***REMOVED******REMOVED******REMOVED***isEvaluating = false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var validationErrors: [String : [Error]] {
***REMOVED******REMOVED***featureForm.validationErrors
***REMOVED***
***REMOVED***
