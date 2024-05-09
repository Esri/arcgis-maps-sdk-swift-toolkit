// Copyright 2024 Esri
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

extension AttachmentFormElement : AttachmentsFeatureElement {
    /// Indicates how to display the attachments.
    public var attachmentDisplayType: AttachmentsFeatureElementDisplayType {
        // Currently, Attachment Form Elements only support `Preview`.
        AttachmentsFeatureElementDisplayType.preview
    }
    
    /// The list of attachments.
    ///
    /// The feature attachments associated with this element.
    /// This property will be empty if the element has not yet been evaluated.
    public var featureAttachments: [FeatureAttachment] {
        get async throws {
            try await fetchAttachments()
            return attachments.map { $0 as FeatureAttachment }
        }
    }
    
    /// A descriptive label that appears with the element. Can be an empty string.
    public var title: String {
        get {
            label
        }
    }
}

extension AttachmentFormElement {
    /// Creates a unique name for a new attachments, without a file extension.
    /// - Parameter attachmentKind: The kind of attachment to generate a name for.
    /// - Returns: A unique name for an attachment.
    func baseName(for attachmentKind: FeatureAttachmentKind) -> String {
        // get number of photos/videos
        var count = attachments.filter { $0.featureAttachmentKind == attachmentKind }.count
        let root: String
        
        switch attachmentKind {
        case .image:
            root = "Photo"
        case .video:
            root = "Video"
            // Add "Audio" type when available
            //        case .audio:
            //            root = "Audio"
        case .document, .other:
            root = "Attachment"
        }
        
        var baseName: String
        repeat {
            baseName = "\(root)\(count)"
            count = count + 1
        } while( attachments.filter {
            if let name = $0.name.split(separator: ".").first {
                return name == baseName
            }
            return false
        }
            .count > 0
        )
        
        return baseName
    }
}
