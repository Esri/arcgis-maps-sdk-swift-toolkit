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
import UIKit

***REMOVED***/ The type of an attachment in a FeatureAttachment.
public enum FeatureAttachmentKind {
***REMOVED******REMOVED***/ An attachment of another type.
***REMOVED***case other
***REMOVED******REMOVED***/ An image.
***REMOVED***case image
***REMOVED******REMOVED***/ A video.
***REMOVED***case video
***REMOVED******REMOVED***/ A document.
***REMOVED***case document
***REMOVED******REMOVED***/ An audio file.
***REMOVED***case audio
***REMOVED***

public protocol FeatureAttachment: Loadable {
***REMOVED******REMOVED***/ The underlying `Attachment`.
***REMOVED***var attachment: Attachment? { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The MIME content type of the attachment.
***REMOVED***var contentType: String { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The type of the attachment.
***REMOVED***var featureAttachmentKind: FeatureAttachmentKind { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The local temporary filepath where we store the attachment once it is loaded.
***REMOVED***var fileURL: URL? { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A value indicating whether "loading" (fetching the data) can be accomplished without using the network.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This is `true` if it just needs to pull the data from a database,
***REMOVED******REMOVED***/ `false` if the loading will cause a network request.
***REMOVED***var isLocal: Bool { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The name of the attachment.
***REMOVED***var name: String { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The size of the attachment in bytes.
***REMOVED***var size: Int { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Methods
***REMOVED******REMOVED***
***REMOVED******REMOVED***/ Creates asynchronously the full image for displaying the attachment in full screen or some UI larger than a thumbnail.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This is only supported if ``FeatureAttachment/featureAttachmentKind`` is ``FeatureAttachmentKind/image``.
***REMOVED******REMOVED***/ - Returns: A task that represents the asynchronous operation. The task result contains the full image as an `UIImage`.
***REMOVED***func makeFullImage() async throws -> UIImage
***REMOVED***
***REMOVED******REMOVED***/ Creates asynchronously a thumbnail image with the specified width and height.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This is only supported if ``FeatureAttachment/featureAttachmentKind`` is ``FeatureAttachmentKind/image``.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - width: Width of the thumbnail.
***REMOVED******REMOVED***/   - height: Height of the thumbnail.
***REMOVED******REMOVED***/ - Returns: A task that represents the asynchronous operation. The task result contains the thumbnail as an `UIImage`.
***REMOVED***func makeThumbnail(width: Int, height: Int) async throws -> UIImage
***REMOVED***

extension FeatureAttachmentKind {
***REMOVED******REMOVED***/ Creates a feature attachment kind from a popup attachment kind.
***REMOVED******REMOVED***/ - Parameter kind: The popup attachment kind.
***REMOVED***init(kind: PopupAttachment.Kind) {
***REMOVED******REMOVED***switch kind {
***REMOVED******REMOVED***case .image:
***REMOVED******REMOVED******REMOVED***self = .image
***REMOVED******REMOVED***case .video:
***REMOVED******REMOVED******REMOVED***self = .video
***REMOVED******REMOVED***case .document:
***REMOVED******REMOVED******REMOVED***self = .document
***REMOVED******REMOVED***case .other:
***REMOVED******REMOVED******REMOVED***self = .other
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a feature attachment kind from a popup attachment kind.
***REMOVED******REMOVED***/ - Parameter kind: The popup attachment kind.
***REMOVED***init(kind: FormAttachment.Kind) {
***REMOVED******REMOVED***switch kind {
***REMOVED******REMOVED***case .other:
***REMOVED******REMOVED******REMOVED***self = .other
***REMOVED******REMOVED***case .image:
***REMOVED******REMOVED******REMOVED***self = .image
***REMOVED******REMOVED***case .video:
***REMOVED******REMOVED******REMOVED***self = .video
***REMOVED******REMOVED***case .document:
***REMOVED******REMOVED******REMOVED***self = .document
***REMOVED******REMOVED***case .audio:
***REMOVED******REMOVED******REMOVED***self = .audio
***REMOVED***
***REMOVED***
***REMOVED***
