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
import Foundation

extension AttachmentsFormElement: AttachmentsFeatureElement {
    /// Indicates how to display the attachments.
    ///
    /// - Note: Currently, ``AttachmentsFormElement`` only supports
    /// ``AttachmentsFeatureElementDisplayType/preview``.
    var attachmentsDisplayType: AttachmentsFeatureElementDisplayType {
        AttachmentsFeatureElementDisplayType.preview
    }
    
    /// The list of attachments.
    ///
    /// The feature attachments associated with this element.
    /// This property will be empty if the element has not yet been evaluated.
    var featureAttachments: [FeatureAttachment] {
        get async throws {
            try await attachments
        }
    }
    
    /// A descriptive label that appears with the element. Can be an empty string.
    var title: String {
        get {
            label
        }
    }
}

extension AttachmentsFormElement {
    /// Generates the attachment filename using the filename expression.
    ///
    /// This currently returns a toolkit-generated default name until runtime
    /// support for filename expression evaluation is available.
    func generateFilenameAsync() async throws -> String {
        let currentAttachments = try await attachments
        var count = currentAttachments.count
        var candidate: String
        repeat {
            count += 1
            candidate = "Attachment\(count)"
        } while currentAttachments.contains(where: { $0.name.deletingPathExtension == candidate })
        return candidate
    }
}

private extension String {
    /// A filename with the extension removed.
    var deletingPathExtension: String {
        (self as NSString).deletingPathExtension
    }
}
