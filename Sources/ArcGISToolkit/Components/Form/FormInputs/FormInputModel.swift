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
import Combine
***REMOVED***

***REMOVED***/ A model for an input in a form.
***REMOVED***/
***REMOVED***/ - Since: 200.3
class FormInputModel: ObservableObject {
***REMOVED******REMOVED***/ A Boolean value indicating whether a value in the input is required.
***REMOVED***@Published var isRequired: Bool
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether a value in the input is editable.
***REMOVED***@Published var isEditable: Bool
***REMOVED***
***REMOVED******REMOVED***/ The value of the input.
***REMOVED***@Published var value: Any?
***REMOVED***
***REMOVED******REMOVED***/ The formatted value of the input.
***REMOVED***@Published var formattedValue: String
***REMOVED***
***REMOVED***private var element: FieldFormElement
***REMOVED***
***REMOVED***private var tasks = [Task<Void, Never>]()
***REMOVED***
***REMOVED***deinit {
***REMOVED******REMOVED***clearTasks()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form input model.
***REMOVED***public init(fieldFormElement: FieldFormElement) {
***REMOVED******REMOVED***element = fieldFormElement
***REMOVED******REMOVED***isRequired = element.isRequired
***REMOVED******REMOVED***isEditable = element.isEditable
***REMOVED******REMOVED***value = element.value
***REMOVED******REMOVED***formattedValue = element.formattedValue
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Kick off tasks to monitor required, editable and value.
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
***REMOVED***
***REMOVED******REMOVED***/ A detached task observing changes in the required state.
***REMOVED***private var observeIsRequiredTask: Task<Void, Never> {
***REMOVED******REMOVED***Task.detached { [unowned self] in
***REMOVED******REMOVED******REMOVED***for await isRequired in element.$isRequired {
***REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.isRequired = isRequired
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A detached task observing changes in the editable state.
***REMOVED***private var observeIsEditableTask: Task<Void, Never> {
***REMOVED******REMOVED***Task.detached { [unowned self] in
***REMOVED******REMOVED******REMOVED***for await isEditable in element.$isEditable {
***REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.isEditable = isEditable
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A detached task observing changes in the value.
***REMOVED***private var observeValueTask: Task<Void, Never> {
***REMOVED******REMOVED***Task.detached { [unowned self] in
***REMOVED******REMOVED******REMOVED***for await value in element.$value {
***REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.value = value
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.formattedValue = element.formattedValue
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
