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

***REMOVED***/ A model for an input in a form.
***REMOVED***/
***REMOVED***/ - Since: 200.4
@MainActor class FormInputModel: ObservableObject {
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
***REMOVED***private var observationTask: Task<Void, Never>?

***REMOVED***deinit {
***REMOVED******REMOVED***observationTask?.cancel()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form input model.
***REMOVED***init(fieldFormElement: FieldFormElement) {
***REMOVED******REMOVED***element = fieldFormElement
***REMOVED******REMOVED***isRequired = element.isRequired
***REMOVED******REMOVED***isEditable = element.isEditable
***REMOVED******REMOVED***value = element.value
***REMOVED******REMOVED***formattedValue = element.formattedValue
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Kick off tasks to monitor required, editable and value.
***REMOVED******REMOVED***observationTask = Task.detached { [unowned self] in
***REMOVED******REMOVED******REMOVED***await withTaskGroup(of: Void.self) { group in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Observe isRequired changes.
***REMOVED******REMOVED******REMOVED******REMOVED***group.addTask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await isRequired in await self.element.$isRequired {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard !Task.isCancelled else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.isRequired = isRequired
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Observe isEditable changes.
***REMOVED******REMOVED******REMOVED******REMOVED***group.addTask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await isEditable in await self.element.$isEditable {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard !Task.isCancelled else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.isEditable = isEditable
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Observe value changes.
***REMOVED******REMOVED******REMOVED******REMOVED***group.addTask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await value in await self.element.$value {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard !Task.isCancelled else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.value = value
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.formattedValue = self.element.formattedValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
