***REMOVED*** Copyright 2022 Esri
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
import Combine
import QuickLook
***REMOVED***

***REMOVED***/ A view model representing the combination of a `FeatureAttachment` and
***REMOVED***/ an associated `UIImage` used as a thumbnail.
@MainActor class AttachmentModel: ObservableObject {
***REMOVED******REMOVED***/ The `FeatureAttachment`.
***REMOVED***let attachment: FeatureAttachment
***REMOVED***
***REMOVED******REMOVED***/ The thumbnail representing the attachment.
***REMOVED***@Published var thumbnail: UIImage? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***systemImageName = nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The name of the system SF symbol used instead of `thumbnail`.
***REMOVED***@Published var systemImageName: String?
***REMOVED***
***REMOVED******REMOVED***/ The `LoadStatus` of the popup attachment.
***REMOVED***@Published var loadStatus: LoadStatus = .notLoaded
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether the thumbnails is using a
***REMOVED******REMOVED***/ system image or an image generated from the featire attachment.
***REMOVED***var usingSystemImage: Bool {
***REMOVED******REMOVED***systemImageName != nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The pixel density of the display on the intended device.
***REMOVED***private var displayScale: CGFloat
***REMOVED***
***REMOVED******REMOVED***/ Creates a view model representing the combination of a `FeatureAttachment` and
***REMOVED******REMOVED***/ an associated `UIImage` used as a thumbnail.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - attachment: The `FeatureAttachment`.
***REMOVED******REMOVED***/   - displayScale: The pixel density of the display on the intended device.
***REMOVED***init(attachment: FeatureAttachment, displayScale: CGFloat) {
***REMOVED******REMOVED***self.attachment = attachment
***REMOVED******REMOVED***self.displayScale = displayScale
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch attachment.featureAttachmentKind {
***REMOVED******REMOVED***case .image:
***REMOVED******REMOVED******REMOVED***systemImageName = "photo"
***REMOVED******REMOVED***case .video:
***REMOVED******REMOVED******REMOVED***systemImageName = "film"
***REMOVED******REMOVED***case .document, .other:
***REMOVED******REMOVED******REMOVED***systemImageName = "doc"
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***systemImageName = "questionmark"
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads the popup attachment and generates a thumbnail image.
***REMOVED******REMOVED***/ - Parameter thumbnailSize: The size for the generated thumbnail.
***REMOVED***func load(thumbnailSize: CGSize = CGSize(width: 40, height: 40)) {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***loadStatus = .loading
***REMOVED******REMOVED******REMOVED***try await attachment.load()
***REMOVED******REMOVED******REMOVED***if attachment.loadStatus == .failed || attachment.fileURL == nil {
***REMOVED******REMOVED******REMOVED******REMOVED***systemImageName = "exclamationmark.circle.fill"
***REMOVED******REMOVED******REMOVED******REMOVED***self.loadStatus = .failed
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var url = attachment.fileURL!
***REMOVED******REMOVED******REMOVED***if attachment is FormAttachment {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.thumbnail = try? await formAttachment.makeThumbnail(width: Int(thumbnailSize.width), height: Int(thumbnailSize.width))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.loadStatus = formAttachment.loadStatus
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** WORKAROUND - attachment.fileURL is just a GUID for FormAttachments
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Note: this can be deleted when Apollo #635 - "FormAttachment.fileURL is not user-friendly" is fixed.
***REMOVED******REMOVED******REMOVED******REMOVED***var tmpURL = attachment.fileURL
***REMOVED******REMOVED******REMOVED******REMOVED***tmpURL = tmpURL?.deletingLastPathComponent()
***REMOVED******REMOVED******REMOVED******REMOVED***tmpURL = tmpURL?.appending(path: attachment.name)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***_ = FileManager.default.secureCopyItem(at: attachment.fileURL!, to: tmpURL!)
***REMOVED******REMOVED******REMOVED******REMOVED***url = tmpURL!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let request = QLThumbnailGenerator.Request(
***REMOVED******REMOVED******REMOVED******REMOVED***fileAt: url,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fileAt: attachment.fileURL!,
***REMOVED******REMOVED******REMOVED******REMOVED***size: CGSize(width: thumbnailSize.width, height: thumbnailSize.height),
***REMOVED******REMOVED******REMOVED******REMOVED***scale: displayScale,
***REMOVED******REMOVED******REMOVED******REMOVED***representationTypes: .all)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let generator = QLThumbnailGenerator.shared
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***let thumbnail = try await generator.generateBestRepresentation(for: request)
***REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.thumbnail = thumbnail.uiImage
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***systemImageName = "exclamationmark.circle.fill"
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***self.loadStatus = self.attachment.loadStatus
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
