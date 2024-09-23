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

***REMOVED***/ Displays a group form element and manages the visibility of the elements within the group.
@MainActor
struct GroupView<Content>: View where Content: View {
***REMOVED******REMOVED***/ A Boolean value indicating whether the group is expanded or collapsed.
***REMOVED***@State private var isExpanded = false
***REMOVED***
***REMOVED******REMOVED***/ The group of visibility tasks.
***REMOVED***@State private var isVisibleTasks = [Task<Void, Never>]()
***REMOVED***
***REMOVED******REMOVED***/ The list of visible group elements.
***REMOVED***@State private var visibleElements = [FormElement]()
***REMOVED***
***REMOVED******REMOVED***/ The group form element.
***REMOVED***let element: GroupFormElement
***REMOVED***
***REMOVED******REMOVED***/ The closure to perform to build an element in the group.
***REMOVED***let viewCreator: (FieldFormElement) -> Content
***REMOVED***
***REMOVED******REMOVED***/ Filters the group's elements by visibility.
***REMOVED***private func updateVisibleElements() {
***REMOVED******REMOVED***visibleElements = element.elements.filter { $0.isVisible ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***DisclosureGroup(isExpanded: $isExpanded) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(visibleElements, id: \.label) { formElement in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let element = formElement as? FieldFormElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewCreator(element)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.leading, 16)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Header(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.catalystPadding(4)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***isExpanded = element.initialState == .expanded
***REMOVED******REMOVED******REMOVED***for element in element.elements {
***REMOVED******REMOVED******REMOVED******REMOVED***let newTask = Task { @MainActor [self] in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await _ in element.$isVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.updateVisibleElements()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***isVisibleTasks.append(newTask)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED***isVisibleTasks.forEach { task in
***REMOVED******REMOVED******REMOVED******REMOVED***task.cancel()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***isVisibleTasks.removeAll()
***REMOVED***
***REMOVED***
***REMOVED***

extension GroupView {
***REMOVED******REMOVED***/ A view displaying a label and description of a `GroupFormElement`.
***REMOVED***struct Header: View {
***REMOVED******REMOVED***let element: GroupFormElement
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Text views with empty text still take up some vertical space in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** a view, so conditionally check for an empty title and description.
***REMOVED******REMOVED******REMOVED******REMOVED***if !element.label.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(element.label)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.primary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if !element.description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(element.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("\(element.label) Description")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
#if targetEnvironment(macCatalyst)
***REMOVED******REMOVED******REMOVED***.padding(.leading, 4)
#endif
***REMOVED***
***REMOVED***
***REMOVED***
