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

***REMOVED***/ - Since: 200.2
public class FormInputModel: ObservableObject {
***REMOVED***@Published var isVisible: Bool
***REMOVED***@Published var isRequired: Bool
***REMOVED***@Published var isEditable: Bool
***REMOVED***@Published var value: String

***REMOVED***private var element: FieldFormElement
***REMOVED***
***REMOVED***private var tasks = [Task<Void, Never>]()
***REMOVED***
***REMOVED***deinit {
***REMOVED******REMOVED***clearTasks()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view model.
***REMOVED***public init(fieldFormElement: FieldFormElement) {
***REMOVED******REMOVED***element = fieldFormElement
***REMOVED******REMOVED***isVisible = element.isVisible
***REMOVED******REMOVED***isRequired = element.isRequired
***REMOVED******REMOVED***isEditable = element.isEditable
***REMOVED******REMOVED***value = element.value

***REMOVED******REMOVED******REMOVED*** Kick off tasks to monitor autoPan, locations, and satellites.
***REMOVED******REMOVED***tasks.append(
***REMOVED******REMOVED******REMOVED***contentsOf: [
***REMOVED******REMOVED******REMOVED******REMOVED***observeIsRequiredTask,
***REMOVED******REMOVED******REMOVED******REMOVED***observeIsEditableTask,
***REMOVED******REMOVED******REMOVED******REMOVED***observeValueTask
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***)

***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Cancels and removes tasks.
***REMOVED***private func clearTasks() {
***REMOVED******REMOVED***tasks.forEach { task in
***REMOVED******REMOVED******REMOVED***task.cancel()
***REMOVED***
***REMOVED******REMOVED***tasks.removeAll()
***REMOVED***

***REMOVED******REMOVED***/ A detached task observing location display autoPan changes.
***REMOVED***private var observeIsRequiredTask: Task<Void, Never> {
***REMOVED******REMOVED***Task.detached { [unowned self] in
***REMOVED******REMOVED******REMOVED***for await isRequired in element.$isRequired {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("isRequired changed: \(isRequired) for \(element.label)")
***REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.isRequired = isRequired
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A detached task observing location display autoPan changes.
***REMOVED***private var observeIsEditableTask: Task<Void, Never> {
***REMOVED******REMOVED***Task.detached { [unowned self] in
***REMOVED******REMOVED******REMOVED***for await isEditable in element.$isEditable {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("isEditable changed: \(isEditable) (oldvalue: \(element.isEditable)) for \(element.label)")
***REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.isEditable = isEditable
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A detached task observing location display autoPan changes.
***REMOVED***private var observeValueTask: Task<Void, Never> {
***REMOVED******REMOVED***Task.detached { [unowned self] in
***REMOVED******REMOVED******REMOVED***for await value in element.$value {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("value changed: \(value) for \(element.label)")
***REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.value = value
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***await withTaskGroup(of: Void.self) { group in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for element in featureForm.elements {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***group.addTask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await isVisible in $0.$isVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elements = featureForm.elements.filter { $0.isVisible ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***public func outputIsVisible(featureForm: FeatureForm) {
***REMOVED******REMOVED***featureForm.elements.forEach { element in
***REMOVED******REMOVED******REMOVED***print("element: \(element.label) isVisible = \(element.isVisible)")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***internal func evaluateExpressions(model: FormViewModel, featureForm: FeatureForm) {
***REMOVED******REMOVED***model.evalutateTask?.cancel()
***REMOVED******REMOVED***model.evalutateTask = Task {
***REMOVED******REMOVED******REMOVED***try? await featureForm.evaluateExpressions()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.outputIsVisible(featureForm: featureForm!)
***REMOVED******REMOVED******REMOVED******REMOVED***print("evaluation completed; element.isVisible = \(element.isVisible)")
***REMOVED***

***REMOVED***
***REMOVED***
