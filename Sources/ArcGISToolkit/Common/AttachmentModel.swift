// Copyright 2022 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import Combine
import QuickLook
import SwiftUI

/// A view model representing the combination of a `FeatureAttachment` and
/// an associated `UIImage` used as a thumbnail.
@MainActor class AttachmentModel: ObservableObject {
    /// The `FeatureAttachment`.
    let attachment: FeatureAttachment
    
    /// The thumbnail representing the attachment.
    @Published var thumbnail: UIImage? {
        didSet {
            systemImageName = nil
        }
    }
    
    /// The name of the system SF symbol used instead of `thumbnail`.
    @Published var systemImageName: String?
    
    /// The `LoadStatus` of the popup attachment.
    @Published var loadStatus: LoadStatus = .notLoaded
    
    /// A Boolean value specifying whether the thumbnails is using a
    /// system image or an image generated from the featire attachment.
    var usingSystemImage: Bool {
        systemImageName != nil
    }
    
    private var displayScale: CGFloat

    init(attachment: FeatureAttachment, displayScale: CGFloat) {
        self.attachment = attachment
        self.displayScale = displayScale
        
        switch attachment.featureAttachmentKind {
        case .image:
            systemImageName = "photo"
        case .video:
            systemImageName = "film"
        case .document, .other:
            systemImageName = "doc"
        @unknown default:
            systemImageName = "questionmark"
        }
    }
    
    /// Loads the popup attachment and generates a thumbnail image.
    /// - Parameter thumbnailSize: The size for the generated thumbnail.
    func load(thumbnailSize: CGSize = CGSize(width: 40, height: 40)) {
        Task {
            loadStatus = .loading
            try await attachment.load()
            if attachment.loadStatus == .failed || attachment.fileURL == nil {
                systemImageName = "exclamationmark.circle.fill"
                self.loadStatus = .failed
                return
            }
            
            var url = attachment.fileURL!
            if attachment is FormAttachment {
                //                self.thumbnail = try? await formAttachment.makeThumbnail(width: Int(thumbnailSize.width), height: Int(thumbnailSize.width))
                //                self.loadStatus = formAttachment.loadStatus
                
                // WORKAROUND - attachment.fileURL is just a GUID for FormAttachments
                // Note: this can be deleted when Apollo #635 - "FormAttachment.fileURL is not user-friendly" is fixed.
                var tmpURL = attachment.fileURL
                tmpURL = tmpURL?.deletingLastPathComponent()
                tmpURL = tmpURL?.appending(path: attachment.name)
                
                _ = FileManager.default.secureCopyItem(at: attachment.fileURL!, to: tmpURL!)
                url = tmpURL!
            }
            let request = QLThumbnailGenerator.Request(
                fileAt: url,
                //                fileAt: attachment.fileURL!,
                size: CGSize(width: thumbnailSize.width, height: thumbnailSize.height),
                scale: displayScale,
                representationTypes: .all)
            
            let generator = QLThumbnailGenerator.shared
            do {
                let thumbnail = try await generator.generateBestRepresentation(for: request)
                DispatchQueue.main.async {
                    self.thumbnail = thumbnail.uiImage
                }
            } catch {
                systemImageName = "exclamationmark.circle.fill"
            }
            self.loadStatus = self.attachment.loadStatus
        }
    }
}

extension AttachmentModel: Identifiable {}

extension AttachmentModel: Equatable {
    static func == (lhs: AttachmentModel, rhs: AttachmentModel) -> Bool {
        lhs.attachment === rhs.attachment &&
        lhs.thumbnail === rhs.thumbnail
    }
}
