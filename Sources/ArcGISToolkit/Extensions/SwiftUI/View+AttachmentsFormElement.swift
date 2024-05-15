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

extension View {
***REMOVED******REMOVED***/ Modifier for watching `AttachmentsFormElement.attachments`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The form element to watch for changes on.
***REMOVED******REMOVED***/   - action: The action which watches for changes.
***REMOVED******REMOVED***/ - Returns: The modified view.
***REMOVED***func onAttachmentsChange(
***REMOVED******REMOVED***of element: AttachmentsFormElement,
***REMOVED******REMOVED***action: @escaping ((_ newAttachments: [FormAttachment]) -> Void)
***REMOVED***) -> some View {
***REMOVED******REMOVED***return self
***REMOVED******REMOVED******REMOVED***.task(id: ObjectIdentifier(element)) {
***REMOVED******REMOVED******REMOVED******REMOVED***for await attachments in element.$attachments {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(attachments)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
