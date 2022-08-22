// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS
import QuickLook

/// The view model for
@MainActor class AttachmentsPopupElementModel: ObservableObject {
    @Published var attachmentModels = [AttachmentModel]()
}

/// A view model representing the combination of a `PopupAttachment` and
/// an associated `UIImage` used as a thumbnail.
@MainActor class AttachmentModel: ObservableObject {
    @Published var attachment: PopupAttachment
    @Published var thumbnail: UIImage? {
        didSet {
            usingDefaultImage = false
        }
    }
    @Published var loadStatus: LoadStatus = .notLoaded
    var usingDefaultImage: Bool
    
    @Environment(\.displayScale) var displayScale
    
    init(attachment: PopupAttachment) {
        self.attachment = attachment
        
        switch attachment.kind {
        case .image:
            thumbnail = UIImage(systemName: "photo")
        case .video:
            thumbnail = UIImage(systemName: "film")
        case .document, .other:
            thumbnail = UIImage(systemName: "doc")
        }
        usingDefaultImage = true
    }
    
    
    
    func load(thumbnailSize: CGSize = CGSize(width: 40, height: 40)) {
        Task {
            loadStatus = .loading
            try await self.attachment.load()
            
            let request = QLThumbnailGenerator.Request(
                fileAt: attachment.fileURL,
                size: CGSize(width: thumbnailSize.width, height: thumbnailSize.height),
                scale: displayScale,
                representationTypes: .thumbnail)
            
            let generator = QLThumbnailGenerator.shared
            generator.generateRepresentations(for: request) { [weak self] thumbnail, _, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let thumbnail = thumbnail {
                        self.thumbnail = thumbnail.uiImage
                    }
                    else if self.attachment.loadStatus == .failed {
                        self.thumbnail = UIImage(systemName: "exclamationmark.circle.fill")
                        self.usingDefaultImage = true
                    }
                    
                    self.loadStatus = self.attachment.loadStatus
                }
            }
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
