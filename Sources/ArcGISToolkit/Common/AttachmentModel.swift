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
@preconcurrency import QuickLook
***REMOVED***

internal import os

***REMOVED***/ A view model representing the combination of a `FeatureAttachment` and
***REMOVED***/ an associated `UIImage` used as a thumbnail.
@available(visionOS, unavailable)
@MainActor class AttachmentModel: ObservableObject {
***REMOVED******REMOVED***/ The `FeatureAttachment`.
***REMOVED***nonisolated let attachment: FeatureAttachment
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
***REMOVED******REMOVED***/ The `LoadStatus` of the feature attachment.
***REMOVED***@Published var loadStatus: LoadStatus = .notLoaded
***REMOVED***
***REMOVED******REMOVED***/ The name of the attachment.
***REMOVED***@Published var name: String
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether the thumbnails is using a
***REMOVED******REMOVED***/ system image or an image generated from the feature attachment.
***REMOVED***var usingSystemImage: Bool {
***REMOVED******REMOVED***systemImageName != nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The pixel density of the display on the intended device.
***REMOVED***private let displayScale: CGFloat
***REMOVED***
***REMOVED******REMOVED***/ The desired size of the thumbnail image.
***REMOVED***let thumbnailSize: CGSize
***REMOVED***
***REMOVED******REMOVED***/ Creates a view model representing the combination of a `FeatureAttachment` and
***REMOVED******REMOVED***/ an associated `UIImage` used as a thumbnail.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - attachment: The `FeatureAttachment`.
***REMOVED******REMOVED***/   - displayScale: The pixel density of the display on the intended device.
***REMOVED******REMOVED***/   - thumbnailSize: The desired size of the thumbnail image.
***REMOVED***init(
***REMOVED******REMOVED***attachment: FeatureAttachment,
***REMOVED******REMOVED***displayScale: CGFloat,
***REMOVED******REMOVED***thumbnailSize: CGSize
***REMOVED***) {
***REMOVED******REMOVED***self.attachment = attachment
***REMOVED******REMOVED***self.displayScale = displayScale
***REMOVED******REMOVED***self.name = attachment.name
***REMOVED******REMOVED***self.thumbnailSize = thumbnailSize
***REMOVED******REMOVED***
***REMOVED******REMOVED***if attachment.isLocal {
***REMOVED******REMOVED******REMOVED***load()
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***systemImageName = switch attachment.featureAttachmentKind {
***REMOVED******REMOVED******REMOVED***case .image: "photo"
***REMOVED******REMOVED******REMOVED***case .video: "film"
***REMOVED******REMOVED******REMOVED***case .audio: "waveform"
***REMOVED******REMOVED******REMOVED***case .document: "doc"
***REMOVED******REMOVED******REMOVED***case .other: "questionmark"
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads the attachment and generates a thumbnail image.
***REMOVED******REMOVED***/ - Parameter thumbnailSize: The size for the generated thumbnail.
***REMOVED***func load() {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***loadStatus = .loading
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try await attachment.load()
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***Logger.attachmentsFeatureElementView.error("Attachment loading failed \(error.localizedDescription)")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***sync()
***REMOVED******REMOVED******REMOVED***if loadStatus == .failed || attachment.fileURL == nil {
***REMOVED******REMOVED******REMOVED******REMOVED***systemImageName = "exclamationmark.circle.fill"
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let request = QLThumbnailGenerator.Request(
***REMOVED******REMOVED******REMOVED******REMOVED***fileAt: attachment.fileURL!,
***REMOVED******REMOVED******REMOVED******REMOVED***size: thumbnailSize,
***REMOVED******REMOVED******REMOVED******REMOVED***scale: displayScale,
***REMOVED******REMOVED******REMOVED******REMOVED***representationTypes: .all
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***let thumbnail = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation { self.thumbnail = thumbnail.uiImage ***REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***systemImageName = "exclamationmark.circle.fill"
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Synchronizes published properties with attachment metadata.
***REMOVED***func sync() {
***REMOVED******REMOVED***name = attachment.name
***REMOVED******REMOVED***loadStatus = attachment.loadStatus
***REMOVED***
***REMOVED***

@available(visionOS, unavailable)
extension AttachmentModel: Identifiable {***REMOVED***
