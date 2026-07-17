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
import SwiftUI

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
    
    /// The max duration configured on the either the element's audio or video form input.
    ///
    /// If the element has both an audio and video form input, there will be no max duration configured.
    var maxDuration: Duration? {
        if let maxDuration = (inputs.first(where: { $0 is AudioFormInput }) as? AudioFormInput)?.maxDuration {
            return maxDuration
        } else if let maxDuration = (inputs.first(where: { $0 is VideoFormInput }) as? VideoFormInput)?.maxDuration {
            return maxDuration
        } else {
            return nil
        }
    }
    
    /// A descriptive label that appears with the element. Can be an empty string.
    var title: String {
        get {
            label
        }
    }
}

extension AttachmentsFormElement /* Validation error messages */ {
    var exceedsMaximumAttachmentDurationMessage: Text? {
        return if let maxDuration  {
            Text(
                "The media is too long. Maximum allowed duration is \(maxDuration.components.seconds) seconds.",
                bundle: .toolkitModule,
                comment: "A message indicating that no more attachments can be added because the maximum count has been reached."
            )
        } else {
            nil
        }
    }
    
    var incorrectAttachmentTypeMessage: Text {
        Text(
            "This file type is not supported.",
            bundle: .toolkitModule,
            comment: "A message indicating the type of the supplied attachment is not supported.."
        )
    }
    
    var maxFileSizeMessage: Text? {
        return if let maxFileSize = (inputs.first(where: { $0 is DocumentFormInput }) as? DocumentFormInput)?.maxFileSize {
            Text(
                "The file is too large. Maximum allowed file size is \(maxFileSize) MB.",
                bundle: .toolkitModule,
                comment: "A message indicating that no more attachments can be added because the maximum count has been reached."
            )
        } else {
            nil
        }
    }
    
    var maxAttachmentCountMessage: Text? {
        return if let maxAttachmentCount {
            Text(
                "The maximum number of attachments allowed is \(maxAttachmentCount).",
                bundle: .toolkitModule,
                comment: "A message indicating that no more attachments can be added because the maximum count has been reached."
            )
        } else {
            nil
        }
    }
    
    var minAttachmentCountMessage: Text? {
        return if let minAttachmentCount {
            if minAttachmentCount == 1 {
                Text(
                    "At least \(minAttachmentCount) attachment is required.",
                    bundle: .toolkitModule,
                    comment: "A message indicating the element requires at least one attachment."
                )
            } else {
                Text(
                    "At least \(minAttachmentCount) attachments are required.",
                    bundle: .toolkitModule,
                    comment: "A message indicating the element requires multiple attachments."
                )
            }
        } else {
            nil
        }
    }
}
