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

#warning("""
Prototype only. Do not merge to main.
This will eventually be available on `element`.
""")

extension AttachmentsFormElement {
    /// True if the user can rename attachments added through this element.
    ///
    /// This value is currently derived from the design default until runtime
    /// support for this property is available.
    var allowUserRename: Bool {
        true
    }
    
    /// A string to identify the attachment(s).
    ///
    /// This is a compatibility alias for ``keyword``.
    var attachmentKeyword: String {
        keyword
    }
    
    /// True if attachment file names should be displayed.
    ///
    /// This value is currently derived from the design default until runtime
    /// support for this property is available.
    var displayFilename: Bool {
        false
    }
    
    /// The maximum number of attachments allowed for this element.
    ///
    /// ``UInt32.max`` is treated as no maximum.
    /// This value is currently derived from the design default until runtime
    /// support for this property is available.
    var maxAttachmentCount: UInt32 {
        UInt32.max
    }
    
    /// The minimum number of attachments required for this element.
    ///
    /// This value is currently derived from the design default until runtime
    /// support for this property is available.
    var minAttachmentCount: UInt32 {
        .zero
    }
    
    /// The input user interface to use for the element.
    ///
    /// This value is currently derived from the design default until runtime
    /// support for this property is available.
    var input: Any? {
        nil
    }
    
    /// True if uploaded attachments preserve their original file name.
    ///
    /// This value is currently derived from the design default until runtime
    /// support for this property is available.
    var useOriginalFilename: Bool {
        true
    }
    
    /// An array of validation errors for this element.
    ///
    /// This value is currently derived from the design default until runtime
    /// support for this property is available.
    var validationErrors: [Error] {
        []
    }
    
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
