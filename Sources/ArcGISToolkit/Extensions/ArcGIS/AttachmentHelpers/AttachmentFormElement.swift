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

extension AttachmentFormElement : AttachmentsFeatureElement {
***REMOVED******REMOVED***/ Indicates how to display the attachments.
***REMOVED***public var attachmentDisplayType: AttachmentsFeatureElementDisplayType {
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
***REMOVED******REMOVED******REMOVED***try await fetchAttachments()
***REMOVED******REMOVED******REMOVED***return attachments.map { $0 as FeatureAttachment ***REMOVED***
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

extension AttachmentFormElement {
***REMOVED******REMOVED***/ Creates a unique name for a new attachments, without a file extension.
***REMOVED******REMOVED***/ - Parameter attachmentKind: The kind of attachment to generate a name for.
***REMOVED******REMOVED***/ - Returns: A unique name for an attachment.
***REMOVED***func baseName(for attachmentKind: FeatureAttachmentKind) -> String {
***REMOVED******REMOVED******REMOVED*** get number of photos/videos
***REMOVED******REMOVED***var count = attachments.filter { $0.featureAttachmentKind == attachmentKind ***REMOVED***.count
***REMOVED******REMOVED***let root: String
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch attachmentKind {
***REMOVED******REMOVED***case .image:
***REMOVED******REMOVED******REMOVED***root = "Photo"
***REMOVED******REMOVED***case .video:
***REMOVED******REMOVED******REMOVED***root = "Video"
***REMOVED******REMOVED******REMOVED******REMOVED*** Add "Audio" type when available
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .audio:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***root = "Audio"
***REMOVED******REMOVED***case .document, .other:
***REMOVED******REMOVED******REMOVED***root = "Attachment"
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var baseName: String
***REMOVED******REMOVED***repeat {
***REMOVED******REMOVED******REMOVED***baseName = "\(root)\(count)"
***REMOVED******REMOVED******REMOVED***count = count + 1
***REMOVED*** while( attachments.filter {
***REMOVED******REMOVED******REMOVED***if let name = $0.name.split(separator: ".").first {
***REMOVED******REMOVED******REMOVED******REMOVED***return name == baseName
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED******REMOVED***.count > 0
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***return baseName
***REMOVED***
***REMOVED***
