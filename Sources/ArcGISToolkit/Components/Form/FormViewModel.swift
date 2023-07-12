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
import FormsPlugin
***REMOVED***

public class FormViewModel: ObservableObject {
***REMOVED******REMOVED***/ The structure of the form.
***REMOVED***@Published var formDefinition: FeatureFormDefinition?
***REMOVED***
***REMOVED******REMOVED***/ The featured being edited in the form.
***REMOVED***@Published private(set) var feature: ArcGISFeature?
***REMOVED***
***REMOVED******REMOVED***/ Initializes a form view model.
***REMOVED***public init() {***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Prepares the feature for editing in the form.
***REMOVED******REMOVED***/ - Parameter feature: The feature to be edited in the form.
***REMOVED***public func startEditing(_ feature: ArcGISFeature) {
***REMOVED******REMOVED***self.feature = feature
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Notifies the model that the form is no longer visible.
***REMOVED******REMOVED***/ - Note: This should only be called once the form view has been removed from the view
***REMOVED******REMOVED***/ hierarchy.
***REMOVED***public func didHide() {
***REMOVED******REMOVED***feature = nil
***REMOVED***
***REMOVED***
