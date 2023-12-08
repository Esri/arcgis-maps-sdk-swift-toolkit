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
public class FormViewModel: ObservableObject {
***REMOVED******REMOVED***/ The featured being edited in the form.
***REMOVED***private(set) var feature: ArcGISFeature
***REMOVED***
***REMOVED******REMOVED***/ The feature form.
***REMOVED***private(set) var featureForm: FeatureForm
***REMOVED***
***REMOVED******REMOVED***/ The current focused element, if one exists.
***REMOVED***@MainActor @Published var focusedElement: FormElement?
***REMOVED***
***REMOVED******REMOVED***/ The expression evaluation task.
***REMOVED***private var evaluateTask: Task<Void, Never>?
***REMOVED***
***REMOVED******REMOVED***/ The group of visibility tasks.
***REMOVED***private var isVisibleTasks = [Task<Void, Never>]()
***REMOVED***
***REMOVED******REMOVED***/ The list of visible form elements.
***REMOVED***@MainActor @Published var visibleElements = [FormElement]()
***REMOVED***
***REMOVED******REMOVED***/ The list of expression evaluation errors.
***REMOVED***@MainActor @Published var expressionEvaluationErrors = [FormExpressionEvaluationError]()
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether evaluation is running.
***REMOVED***@MainActor @Published var isEvaluating = true

***REMOVED******REMOVED***/ Initializes a form view model.
***REMOVED***public init(feature: ArcGISFeature, featureForm: FeatureForm) {
***REMOVED******REMOVED***self.feature = feature
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED***
***REMOVED***
***REMOVED***deinit {
***REMOVED******REMOVED***clearIsVisibleTasks()
***REMOVED******REMOVED***evaluateTask?.cancel()
***REMOVED***
***REMOVED***
***REMOVED***func initializeIsVisibleTasks() {
***REMOVED******REMOVED***clearIsVisibleTasks()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Kick off tasks to monitor isVisible for each element.
***REMOVED******REMOVED***featureForm.elements.forEach { element in
***REMOVED******REMOVED******REMOVED***let newTask = Task.detached { [unowned self] in
***REMOVED******REMOVED******REMOVED******REMOVED***for await _ in element.$isVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.updateVisibleElements()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***isVisibleTasks.append(newTask)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A detached task observing visibility changes.
***REMOVED***@MainActor private func updateVisibleElements() {
***REMOVED******REMOVED***visibleElements = featureForm.elements.filter { $0.isVisible ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Cancels and removes tasks.
***REMOVED***private func clearIsVisibleTasks() {
***REMOVED******REMOVED***isVisibleTasks.forEach { task in
***REMOVED******REMOVED******REMOVED***task.cancel()
***REMOVED***
***REMOVED******REMOVED***isVisibleTasks.removeAll()
***REMOVED***
***REMOVED***
***REMOVED***@MainActor func initialEvaluation() async throws {
***REMOVED******REMOVED***let evaluationErrors = try? await featureForm.evaluateExpressions()
***REMOVED******REMOVED***expressionEvaluationErrors = evaluationErrors ?? []
***REMOVED******REMOVED***initializeIsVisibleTasks()
***REMOVED***

***REMOVED***@MainActor func evaluateExpressions() {
***REMOVED******REMOVED***evaluateTask?.cancel()
***REMOVED******REMOVED***isEvaluating = true
***REMOVED******REMOVED***evaluateTask = Task {
***REMOVED******REMOVED******REMOVED***let evaluationErrors = try? await featureForm.evaluateExpressions()
***REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED***expressionEvaluationErrors = evaluationErrors ?? []
***REMOVED******REMOVED******REMOVED******REMOVED***isEvaluating = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
