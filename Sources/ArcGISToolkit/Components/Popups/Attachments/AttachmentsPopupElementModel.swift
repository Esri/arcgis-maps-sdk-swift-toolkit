***REMOVED*** Copyright 2022 Esri.

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
import QuickLook

***REMOVED***/ The view model for an `AttachmentPopupElement`.
@MainActor class AttachmentsPopupElementModel: ObservableObject {
***REMOVED******REMOVED***/ The array of `AttachmentModels`, one for each popup attachment.
***REMOVED***@Published var attachmentModels = [AttachmentModel]()
***REMOVED***

***REMOVED***/ A view model representing the combination of a `PopupAttachment` and
***REMOVED***/ an associated `UIImage` used as a thumbnail.
@MainActor class AttachmentModel: ObservableObject {
***REMOVED******REMOVED***/ The `PopupAttachment`.
***REMOVED***@Published var attachment: PopupAttachment
***REMOVED***
***REMOVED******REMOVED***/ The thumbnail representing the attachment.
***REMOVED***@Published var thumbnail: UIImage? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***defaultSystemName = nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The name of the system SF symbol used instead of `thumbnail`.
***REMOVED***@Published var defaultSystemName: String?
***REMOVED***
***REMOVED******REMOVED***/ The `LoadStatus` of the popup attachment.
***REMOVED***@Published var loadStatus: LoadStatus = .notLoaded
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether the thumbnails is the default image
***REMOVED******REMOVED***/ or an image generated from the popup attachment.
***REMOVED***var usingDefaultImage: Bool {
***REMOVED******REMOVED***defaultSystemName != nil
***REMOVED***
***REMOVED***
***REMOVED***@Environment(\.displayScale) var displayScale
***REMOVED***
***REMOVED***init(attachment: PopupAttachment) {
***REMOVED******REMOVED***self.attachment = attachment
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch attachment.kind {
***REMOVED******REMOVED***case .image:
***REMOVED******REMOVED******REMOVED***defaultSystemName = "photo"
***REMOVED******REMOVED***case .video:
***REMOVED******REMOVED******REMOVED***defaultSystemName = "film"
***REMOVED******REMOVED***case .document, .other:
***REMOVED******REMOVED******REMOVED***defaultSystemName = "doc"
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***defaultSystemName = "questionmark"
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads the popup attachment and generates a thumbnail image.
***REMOVED******REMOVED***/ - Parameter thumbnailSize: The size for the generated thumbnail.
***REMOVED***func load(thumbnailSize: CGSize = CGSize(width: 40, height: 40)) {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***loadStatus = .loading
***REMOVED******REMOVED******REMOVED***try await self.attachment.load()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let request = QLThumbnailGenerator.Request(
***REMOVED******REMOVED******REMOVED******REMOVED***fileAt: attachment.fileURL,
***REMOVED******REMOVED******REMOVED******REMOVED***size: CGSize(width: thumbnailSize.width, height: thumbnailSize.height),
***REMOVED******REMOVED******REMOVED******REMOVED***scale: displayScale,
***REMOVED******REMOVED******REMOVED******REMOVED***representationTypes: .thumbnail)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let generator = QLThumbnailGenerator.shared
***REMOVED******REMOVED******REMOVED***generator.generateRepresentations(for: request) { [weak self] thumbnail, _, error in
***REMOVED******REMOVED******REMOVED******REMOVED***guard let self = self else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let thumbnail = thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.thumbnail = thumbnail.uiImage
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else if self.attachment.loadStatus == .failed {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.defaultSystemName = "exclamationmark.circle.fill"
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.loadStatus = self.attachment.loadStatus
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension AttachmentModel: Identifiable {***REMOVED***

extension AttachmentModel: Equatable {
***REMOVED***static func == (lhs: AttachmentModel, rhs: AttachmentModel) -> Bool {
***REMOVED******REMOVED***lhs.attachment === rhs.attachment &&
***REMOVED******REMOVED***lhs.thumbnail === rhs.thumbnail
***REMOVED***
***REMOVED***
