***REMOVED*** Copyright 2023 Esri.
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   http:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import Combine
***REMOVED***

***REMOVED***/ A model for a group element in a form.
***REMOVED***/
***REMOVED***/ - Since: 200.3
class GroupElementModel: ObservableObject {
***REMOVED******REMOVED***/ The group of visibility tasks.
***REMOVED***private var isVisibleTasks = [Task<Void, Never>]()
***REMOVED***
***REMOVED******REMOVED***/ The list of visible form elements.
***REMOVED***@Published var visibleElements = [FormElement]()
***REMOVED***
***REMOVED***@Binding var isExpanded: Bool
***REMOVED***
***REMOVED***private let groupElement: GroupFormElement
***REMOVED***
***REMOVED***init(groupElement: GroupFormElement) {
***REMOVED******REMOVED***self.groupElement = groupElement
***REMOVED******REMOVED***_isExpanded = .init(get: { groupElement.initialState != .collapsed ***REMOVED***, set: { _ in ***REMOVED***)
***REMOVED******REMOVED***initializeIsVisibleTasks()
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
***REMOVED******REMOVED***/ A detached task observing visibility changes.
***REMOVED***private func updateVisibleElements() {
***REMOVED******REMOVED***visibleElements = groupElement.formElements.filter { $0.isVisible ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func initializeIsVisibleTasks() {
***REMOVED******REMOVED***clearIsVisibleTasks()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Kick off tasks to monitor isVisible for each element.
***REMOVED******REMOVED***groupElement.formElements.forEach { element in
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
