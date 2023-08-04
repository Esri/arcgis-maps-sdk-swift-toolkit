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
***REMOVED***@Published private var database: ServiceGeodatabase?
***REMOVED***
***REMOVED******REMOVED***/ The featured being edited in the form.
***REMOVED***@Published private(set) var feature: ArcGISFeature?
***REMOVED***
***REMOVED******REMOVED***/ The service feature table which holds the feature being edited in the form.
***REMOVED***@Published private var table: ServiceFeatureTable?
***REMOVED***
***REMOVED******REMOVED***/ The structure of the form.
***REMOVED***@Published var formDefinition: FeatureFormDefinition?
***REMOVED***
***REMOVED******REMOVED***/ The name of the current focused field, if one exists.
***REMOVED***@Published var focusedFieldName: String?
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view model.
***REMOVED***public init() {***REMOVED***
***REMOVED***
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
