***REMOVED*** Copyright 2024 Esri
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

@MainActor
extension View {
***REMOVED******REMOVED***/ Modifier for watching ``FeatureForm.titleChanged`` events.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - featureForm: The feature form to watch for changes on.
***REMOVED******REMOVED***/   - action: The action which watches for changes.
***REMOVED******REMOVED***/ - Returns: The modified view.
***REMOVED***func onTitleChange(
***REMOVED******REMOVED***of featureForm: FeatureForm,
***REMOVED******REMOVED***action: @escaping (_ newTitle: String) -> Void
***REMOVED***) -> some View {
***REMOVED******REMOVED***return self
***REMOVED******REMOVED******REMOVED***.task(id: ObjectIdentifier(featureForm)) {
***REMOVED******REMOVED******REMOVED******REMOVED***for await title in featureForm.$title {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(title)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
