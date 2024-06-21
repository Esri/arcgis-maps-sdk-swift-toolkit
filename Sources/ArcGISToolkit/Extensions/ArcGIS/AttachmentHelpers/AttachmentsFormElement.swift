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

extension AttachmentsFormElement : AttachmentsFeatureElement {
***REMOVED******REMOVED***/ Indicates how to display the attachments.
***REMOVED***public var attachmentsDisplayType: AttachmentsFeatureElementDisplayType {
***REMOVED******REMOVED******REMOVED*** Currently, Attachment Form Elements only support `Preview`.
***REMOVED******REMOVED***AttachmentsFeatureElementDisplayType.preview
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The list of attachments.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ The feature attachments associated with this element.
***REMOVED******REMOVED***/ This property will be empty if the element has not yet been evaluated.
***REMOVED***public var featureAttachments: [FeatureAttachment] {
***REMOVED******REMOVED***get async throws {
***REMOVED******REMOVED******REMOVED***try await attachments.map { $0 as FeatureAttachment ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A descriptive label that appears with the element. Can be an empty string.
***REMOVED***public var title: String {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***label
***REMOVED***
***REMOVED***
***REMOVED***
