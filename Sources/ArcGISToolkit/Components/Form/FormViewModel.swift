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
public class FormViewModel: ObservableObject {
***REMOVED******REMOVED***/ The geodatabase which holds the table and feature being edited in the form.
***REMOVED***@Published private var database: ServiceGeodatabase? = nil
***REMOVED***
***REMOVED******REMOVED***/ The featured being edited in the form.
***REMOVED***@Published private(set) var feature: ArcGISFeature? = nil
***REMOVED***
***REMOVED******REMOVED***/ The service feature table which holds the feature being edited in the form.
***REMOVED***@Published private var table: ServiceFeatureTable? = nil
***REMOVED***
***REMOVED******REMOVED***/ The structure of the form.
***REMOVED***@Published var formDefinition: FeatureFormDefinition? = nil
***REMOVED***
***REMOVED******REMOVED***/ The structure of the form.
***REMOVED***public var featureForm: FeatureForm? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***featureForm?.elements.forEach { element in
***REMOVED******REMOVED******REMOVED******REMOVED***tasks.append(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task.detached { [unowned self] in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await _ in element.$isVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("isRequired changed: \(isRequired) for \(element.label)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***visibleElements = featureForm!.elements.filter { $0.isVisible ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***visibleElements.removeAll()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***visibleElements.append(contentsOf: featureForm!.elements.filter { $0.isVisible ***REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("visibleElements.count: \(visibleElements.count)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("isRequired: \(isRequired); self.isRequired: \(isRequired == nil ? element.isRequired : isRequired) for \(element.label)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ The structure of the form.
***REMOVED***public var formElements = [FormElement]() {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***print("formElements: \(formElements)")
***REMOVED******REMOVED******REMOVED******REMOVED***clearTasks()
***REMOVED******REMOVED******REMOVED***print("model.formElements.didSet")
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***visibleElements.removeAll()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***visibleElements.append(contentsOf: formElements.filter { $0.isVisible ***REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formElements.forEach { element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***tasks.append(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task.detached { [unowned self] in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await isVisible in element.$isVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("isVisible changed: \(isVisible) for \(element.label)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***visibleElements.removeAll()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***visibleElements.append(contentsOf: formElements.filter { $0.isVisible ***REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("visibleElements: \(visibleElements)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ The name of the current focused field, if one exists.
***REMOVED***@Published var focusedFieldName: String?
***REMOVED***
***REMOVED***@Published var visibleElements = [FormElement]()
***REMOVED***
***REMOVED***private var tasks = [Task<Void, Never>]()
***REMOVED***
***REMOVED***var evalutateTask: Task<Void, Never>? = nil

***REMOVED***deinit {
***REMOVED******REMOVED***clearTasks()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Cancels and removes tasks.
***REMOVED***private func clearTasks() {
***REMOVED******REMOVED***tasks.forEach { task in
***REMOVED******REMOVED******REMOVED***task.cancel()
***REMOVED***
***REMOVED******REMOVED***tasks.removeAll()
***REMOVED***

***REMOVED******REMOVED***/ Initializes a form view model.
***REMOVED***public init() {***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***public func monitorIsVisible() async {

***REMOVED******REMOVED******REMOVED***await withTaskGroup(of: Void.self) { group in
***REMOVED******REMOVED******REMOVED******REMOVED***for element in featureForm.elements {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***group.addTask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await isVisible in $0.$isVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elements = featureForm.elements.filter { $0.isVisible ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***

***REMOVED******REMOVED***/ Prepares the feature for editing in the form.
***REMOVED******REMOVED***/ - Parameter feature: The feature to be edited in the form.
***REMOVED***public func startEditing(_ feature: ArcGISFeature) {
***REMOVED******REMOVED***self.feature = feature
***REMOVED******REMOVED***if let table = feature.table as? ServiceFeatureTable {
***REMOVED******REMOVED******REMOVED***self.database = table.serviceGeodatabase
***REMOVED******REMOVED******REMOVED***self.table = table
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Reverts any local edits that haven't yet been saved to service geodatabase.
***REMOVED***public func undoEdits() {
***REMOVED******REMOVED***print(#file, #function)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Submit the changes made to the form.
***REMOVED***public func submitChanges() async {
***REMOVED******REMOVED***guard let table, table.isEditable, let feature, let database else {
***REMOVED******REMOVED******REMOVED***print("A precondition to submit the changes wasn't met.")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***try? await table.update(feature)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard database.hasLocalEdits else {
***REMOVED******REMOVED******REMOVED***print("No submittable changes found.")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let results = try? await database.applyEdits()
***REMOVED******REMOVED***
***REMOVED******REMOVED***if results?.first?.editResults.first?.didCompleteWithErrors ?? false {
***REMOVED******REMOVED******REMOVED***print("An error occurred while submitting the changes.")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func outputIsVisible(featureForm: FeatureForm) {
***REMOVED******REMOVED***featureForm.elements.forEach { element in
***REMOVED******REMOVED******REMOVED***print("element: \(element.label) isVisible = \(element.isVisible)")
***REMOVED***
***REMOVED***
***REMOVED***
