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

import Foundation
***REMOVED***

public class FeatureAttachment {
***REMOVED******REMOVED***/ The type of attachments in a FeatureAttachment.
***REMOVED***public enum Kind {
***REMOVED******REMOVED******REMOVED***/ An image.
***REMOVED******REMOVED***case image
***REMOVED******REMOVED******REMOVED***/ A video.
***REMOVED******REMOVED***case video
***REMOVED******REMOVED******REMOVED***/ A document.
***REMOVED******REMOVED***case document
***REMOVED******REMOVED******REMOVED***/ An attachment of another type.
***REMOVED******REMOVED***case other
***REMOVED***
***REMOVED***
***REMOVED***let popupAttachment: PopupAttachment?
***REMOVED***let formAttachment: FormAttachment?
***REMOVED***
***REMOVED***init(popupAttachment: PopupAttachment) {
***REMOVED******REMOVED***self.popupAttachment = popupAttachment
***REMOVED******REMOVED***self.formAttachment = nil
***REMOVED***
***REMOVED***
***REMOVED***init(featureFormAttachment: FormAttachment) {
***REMOVED******REMOVED***self.popupAttachment = nil
***REMOVED******REMOVED***self.formAttachment = featureFormAttachment
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The underlying ``Attachment``.
***REMOVED***public var attachment: Attachment? {
***REMOVED******REMOVED***if let popupAttachment {
***REMOVED******REMOVED******REMOVED***return popupAttachment.attachment
***REMOVED*** else if let formAttachment {
***REMOVED******REMOVED******REMOVED***return formAttachment.attachment
***REMOVED***
***REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The MIME content type of the ``PopupAttachment``.
***REMOVED***public var contentType: String {
***REMOVED******REMOVED***if let popupAttachment {
***REMOVED******REMOVED******REMOVED***return popupAttachment.contentType
***REMOVED*** else if let formAttachment {
***REMOVED******REMOVED******REMOVED***return formAttachment.contentType
***REMOVED***
***REMOVED******REMOVED***return ""
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The local temporary filepath where we store the attachment once it is loaded.
***REMOVED***public var fileURL: URL? {
***REMOVED******REMOVED***if let popupAttachment {
***REMOVED******REMOVED******REMOVED***return popupAttachment.fileURL
***REMOVED*** else if let formAttachment {
***REMOVED******REMOVED******REMOVED***return formAttachment.fileURL
***REMOVED***
***REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A value indicating whether "loading" (fetching the data) can be accomplished without using the network.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This is `true` if it just needs to pull the data from a database,
***REMOVED******REMOVED***/ `false` if the loading will cause a network request.
***REMOVED***public var isLocal: Bool {
***REMOVED******REMOVED***if let popupAttachment {
***REMOVED******REMOVED******REMOVED***return popupAttachment.isLocal
***REMOVED*** else if let formAttachment {
***REMOVED******REMOVED******REMOVED***return formAttachment.isLocal
***REMOVED***
***REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The type of the ``PopupAttachment``.
***REMOVED***public var kind: Kind {
***REMOVED******REMOVED******REMOVED*** Need to map popup attachment.kind to Kind
***REMOVED******REMOVED***if let popupAttachment {
***REMOVED******REMOVED******REMOVED***return Kind(kind: popupAttachment.kind)
***REMOVED*** else if let formAttachment {
***REMOVED******REMOVED******REMOVED***return Kind(contentType: formAttachment.contentType)
***REMOVED***
***REMOVED******REMOVED***return Kind.other
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The name of the ``PopupAttachment``.
***REMOVED***public var name: String {
***REMOVED******REMOVED***if let popupAttachment {
***REMOVED******REMOVED******REMOVED***return popupAttachment.name
***REMOVED*** else if let formAttachment {
***REMOVED******REMOVED******REMOVED***return formAttachment.name
***REMOVED***
***REMOVED******REMOVED***return ""
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The size of the ``PopupAttachment`` in bytes.
***REMOVED***public var size: Int {
***REMOVED******REMOVED***if let popupAttachment {
***REMOVED******REMOVED******REMOVED***return popupAttachment.size
***REMOVED*** else if let formAttachment {
***REMOVED******REMOVED******REMOVED***return formAttachment.size
***REMOVED***
***REMOVED******REMOVED***return 0
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Methods
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***/ Creates asynchronously the full image for displaying the attachment in full screen or some UI larger than a thumbnail.
***REMOVED******REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED******REMOVED***/ This is only supported if the ``kind-swift.property`` is ``Kind-swift.enum/image``.
***REMOVED******REMOVED******REMOVED******REMOVED***/ - Returns: A task that represents the asynchronous operation. The task result contains the full image as an `UIImage`.
***REMOVED******REMOVED******REMOVED***public func makeFullImage() async throws -> UIImage {
***REMOVED******REMOVED******REMOVED******REMOVED***let coreFuture: CoreFuture<UIImage> = RT_PopupAttachment_createFullImageAsync(coreHandle, nil).toAPI()
***REMOVED******REMOVED******REMOVED******REMOVED***return try await coreFuture.getResult()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***/ Creates asynchronously a thumbnail image with the specified width and height.
***REMOVED******REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED******REMOVED***/ This is only supported if the ``kind-swift.property`` is ``Kind-swift.enum/image``.
***REMOVED******REMOVED******REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED******REMOVED******REMOVED***/   - width: Width of the thumbnail.
***REMOVED******REMOVED******REMOVED******REMOVED***/   - height: Height of the thumbnail.
***REMOVED******REMOVED******REMOVED******REMOVED***/ - Returns: A task that represents the asynchronous operation. The task result contains the thumbnail as an `UIImage`.
***REMOVED******REMOVED******REMOVED***public func makeThumbnail(width: Int, height: Int) async throws -> UIImage {
***REMOVED******REMOVED******REMOVED******REMOVED***let coreFuture: CoreFuture<UIImage> = RT_PopupAttachment_createThumbnailAsync(coreHandle, Int32(clamping: width), Int32(clamping: height), nil).toAPI()
***REMOVED******REMOVED******REMOVED******REMOVED***return try await coreFuture.getResult()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Loadable Protocol Conformance
***REMOVED***
***REMOVED******REMOVED******REMOVED***@Streamed
***REMOVED***public var loadStatus: LoadStatus {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***if let popupAttachment {
***REMOVED******REMOVED******REMOVED******REMOVED***return popupAttachment.loadStatus
***REMOVED******REMOVED*** else if let formAttachment {
***REMOVED******REMOVED******REMOVED******REMOVED***return formAttachment.loadStatus
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return .notLoaded
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@Streamed
***REMOVED***public private(set) var loadError: Swift.Error?
***REMOVED***
***REMOVED***public func load() async throws {
***REMOVED******REMOVED***if let popupAttachment {
***REMOVED******REMOVED******REMOVED***try await popupAttachment.load()
***REMOVED*** else if let formAttachment {
***REMOVED******REMOVED******REMOVED***try await formAttachment.load()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func retryLoad() async throws {
***REMOVED******REMOVED***if let popupAttachment {
***REMOVED******REMOVED******REMOVED***try await popupAttachment.retryLoad()
***REMOVED*** else if let formAttachment {
***REMOVED******REMOVED******REMOVED***try await formAttachment.retryLoad()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func cancelLoad() {
***REMOVED******REMOVED***if let popupAttachment {
***REMOVED******REMOVED******REMOVED***popupAttachment.cancelLoad()
***REMOVED*** else if let formAttachment {
***REMOVED******REMOVED******REMOVED***formAttachment.cancelLoad()
***REMOVED***
***REMOVED***
***REMOVED***

extension FeatureAttachment.Kind {
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
***REMOVED***init(contentType: String) {
***REMOVED******REMOVED***if contentType.contains("image") {
***REMOVED******REMOVED******REMOVED***self = .image
***REMOVED*** else if contentType.contains("video") {
***REMOVED******REMOVED******REMOVED***self = .video
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self = .document
***REMOVED***
***REMOVED***
***REMOVED***
