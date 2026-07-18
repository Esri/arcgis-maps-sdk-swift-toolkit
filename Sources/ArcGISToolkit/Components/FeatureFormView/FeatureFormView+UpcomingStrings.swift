// Copyright 2026 Esri
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

import SwiftUI

/// The following extension is for translation purposes only. This file will be removed and the implementations
/// will be moved into place as part of https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/pull/1437.
extension Text /* Upcoming */ {
    static var attachFile: Self {
        .init(
            "Attach File",
            bundle: .toolkitModule,
            comment: "A label for a button to choose an file from the user's files."
        )
    }
    
    static var choosePhoto: Self {
        .init(
            "Choose Photo",
            bundle: .toolkitModule,
            comment: "A label for a button to choose a photo from the user's photo library."
        )
    }
    
    static var choosePhotoOrVideo: Self {
        .init(
            "Choose Photo or Video",
            bundle: .toolkitModule,
            comment: "A label for a button to choose a photo or video from the user's photo library."
        )
    }
    
    static var chooseVideo: Self {
        .init(
            "Choose Video",
            bundle: .toolkitModule,
            comment: "A label for a button to choose a video from the user's photo library."
        )
    }
    
    static var exceedsMaximumAttachmentDurationMessage: Self? {
        let maxDuration = Duration.seconds(1)
        return .init(
            "The media is too long. Maximum allowed duration is ^[\(maxDuration.components.seconds) seconds](inflect: true).",
            bundle: .toolkitModule,
            comment: "A message indicating that the attachment's duration exceeds the allowed maximum."
        )
    }
    
    static var incorrectAttachmentTypeMessage: Self {
        .init(
            "This file type is not supported.",
            bundle: .toolkitModule,
            comment: "A message indicating the type of the supplied attachment is not supported."
        )
    }
    
    func maxAttachmentCountMessage(max: Int) -> Self {
        return .init(
            "The maximum number of attachments allowed is \(max).",
            bundle: .toolkitModule,
            comment: "A message indicating that no more attachments can be added because the maximum count has been reached."
        )
    }
    
    static var maxFileSizeMessage: Self? {
        let maxFileSize: Measurement<UnitInformationStorage> = .init(value: 1, unit: .megabytes)
        return .init(
            "The file is too large. Maximum allowed file size is \(maxFileSize) MB.",
            bundle: .toolkitModule,
            comment: "A message indicating that the attachment's size exceeds the allowed maximum."
        )
    }
    
    func minAttachmentCountMessage(min: Int) -> Self {
        if min == 1 {
            return .init(
                "At least \(min) attachment is required.",
                bundle: .toolkitModule,
                comment: "A message indicating the element requires at least one attachment."
            )
        } else {
            return .init(
                "At least \(min) attachments are required.",
                bundle: .toolkitModule,
                comment: "A message indicating the element requires multiple attachments."
            )
        }
    }
    
    static var takePhoto: Self {
        .init(
            "Take Photo",
            bundle: .toolkitModule,
            comment: "A label for a button to capture a new photo."
        )
    }
    
    static var takeVideo: Self {
        .init(
            "Take Video",
            bundle: .toolkitModule,
            comment: "A label for a button to capture a new video."
        )
    }
}
