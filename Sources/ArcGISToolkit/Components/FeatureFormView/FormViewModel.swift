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
***REMOVED***

@Observable
class FormViewModel {
***REMOVED******REMOVED***/ The current focused element, if one exists.
***REMOVED***var focusedElement: FormElement? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***if let focusedElement, !previouslyFocusedElements.contains(focusedElement) {
***REMOVED******REMOVED******REMOVED******REMOVED***previouslyFocusedElements.append(focusedElement)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The currently presented feature form view.
***REMOVED***var presentedForm: FeatureFormView?
***REMOVED***
***REMOVED******REMOVED***/ The set of all elements which previously held focus.
***REMOVED***var previouslyFocusedElements = [FormElement]()
***REMOVED***
***REMOVED******REMOVED***/ The title of the feature form view.
***REMOVED***var title = ""
***REMOVED***
***REMOVED******REMOVED***/ The list of visible form elements.
***REMOVED***var visibleElements = [FormElement]()
***REMOVED***
***REMOVED******REMOVED***/ The expression evaluation task.
***REMOVED***private var evaluateTask: Task<Void, Never>?
***REMOVED***
***REMOVED******REMOVED***/ The feature form.
***REMOVED***private(set) var featureForm: FeatureForm
***REMOVED***
***REMOVED******REMOVED***/ The group of visibility tasks.
***REMOVED***private var isVisibleTasks = [Task<Void, Never>]()
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view model.
***REMOVED******REMOVED***/ - Parameter featureForm: The feature form defining the editing experience.
***REMOVED***public init(featureForm: FeatureForm) {
***REMOVED******REMOVED***self.featureForm = featureForm
***REMOVED***
***REMOVED***
***REMOVED***deinit {
***REMOVED******REMOVED***evaluateTask?.cancel()
***REMOVED******REMOVED***isVisibleTasks.forEach { task in
***REMOVED******REMOVED******REMOVED***task.cancel()
***REMOVED***
***REMOVED******REMOVED***isVisibleTasks.removeAll()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Kick off tasks to monitor `isVisible` for each element.
***REMOVED***@MainActor
***REMOVED***private func initializeIsVisibleTasks() {
***REMOVED******REMOVED***for element in featureForm.elements {
***REMOVED******REMOVED******REMOVED***let newTask = Task { /*@MainActor [self] in*/
***REMOVED******REMOVED******REMOVED******REMOVED***for await _ in element.$isVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***/*self.*/updateVisibleElements()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***isVisibleTasks.append(newTask)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A detached task observing visibility changes.
***REMOVED***private func updateVisibleElements() {
***REMOVED******REMOVED***visibleElements = featureForm.elements.filter { $0.isVisible ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Performs an initial evaluation of all form expressions.
***REMOVED***@MainActor
***REMOVED***func initialEvaluation() async {
***REMOVED******REMOVED***_ = try? await featureForm.evaluateExpressions()
***REMOVED******REMOVED***initializeIsVisibleTasks()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Performs an evaluation of all form expressions.
***REMOVED***@MainActor
***REMOVED***func evaluateExpressions() {
***REMOVED******REMOVED***evaluateTask?.cancel()
***REMOVED******REMOVED***evaluateTask = Task {
***REMOVED******REMOVED******REMOVED***_ = try? await featureForm.evaluateExpressions()
***REMOVED***
***REMOVED***
***REMOVED***
