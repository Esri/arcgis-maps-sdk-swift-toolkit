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

import Foundation
import ArcGIS

/// Indicates how to display the attachments. If `list` is specified, attachments show as links. If `preview` is specified, attachments expand to the width of the pop-up. Setting the value to `auto` allows applications to choose the most suitable default experience for their application.
public enum AttachmentsFeatureElementDisplayType {
    /// Show attachments as links.
    case list
    /// Attachments expand to the width of the pop-up.
    case preview
    /// Allows applications to choose the most suitable default experience for their application.
    case auto
}

public protocol AttachmentsFeatureElement {
    /// A string value describing the element in detail. Can be an empty string.
    var description: String { get }
    
    /// Indicates how to display the attachments.
    /// If `list` is specified, attachments show as links. If `preview` is specified, attachments expand to the width of the pop-up. Setting the value to `auto` allows applications to choose the most suitable default experience for their application.
    var attachmentDisplayType: AttachmentsFeatureElementDisplayType { get }
    
    /// A string value indicating what the element represents. Can be an empty string.
    var title: String { get set }
    
    /// The list of attachments.
    ///
    /// This property will be empty if ``PopupElement/isEvaluated`` is `false`.
    var featureAttachments: [FeatureAttachment] { get async throws }
}

/// Represents an element of type attachments that is displayed in a pop-up or feature form.
//public final class AttachmentsFeatureElementxx {
//    // MARK: Nested Types
//    
//    /// Indicates how to display the attachments. If `list` is specified, attachments show as links. If `preview` is specified, attachments expand to the width of the pop-up. Setting the value to `auto` allows applications to choose the most suitable default experience for their application.
//    public enum DisplayType {
//        /// Show attachments as links.
//        case list
//        /// Attachments expand to the width of the pop-up.
//        case preview
//        /// Allows applications to choose the most suitable default experience for their application.
//        case auto
//    }
//    
//    //    public let displayType: DisplayType
//    public let attachmentsPopupElement: AttachmentsPopupElement?
//    public let attachmentFormElement: AttachmentFormElement?
//    
//    // MARK: Inits
//    
//    /// Creates a new attachments pop-up element with the given ``DisplayType-swift.enum``.
//    /// - Parameter displayType: Indicates how to display the attachments.
//    public init(attachmentsPopupElement: AttachmentsPopupElement) {
//        self.attachmentsPopupElement = attachmentsPopupElement
//        self.attachmentFormElement = nil
//    }
//    
//    public init(attachmentFormElement: AttachmentFormElement) {
//        self.attachmentsPopupElement = nil
//        self.attachmentFormElement = attachmentFormElement
//    }
//    
//    // MARK: Properties
//    
//    /// A string value describing the element in detail. Can be an empty string.
//    public var description: String {
//        if let attachmentsPopupElement {
//            return attachmentsPopupElement.description
//        } else if let attachmentFormElement {
//            return attachmentFormElement.description
//        }
//        return ""
//    }
//    
//    /// Indicates how to display the attachments.
//    /// If `list` is specified, attachments show as links. If `preview` is specified, attachments expand to the width of the pop-up. Setting the value to `auto` allows applications to choose the most suitable default experience for their application.
//    public var displayType: DisplayType {
//        if let attachmentsPopupElement {
//            return .preview//DisplayType(kind: attachmentsPopupElement.displayType)
//        }
//        return .preview
//    }
//    
//    /// A string value indicating what the element represents. Can be an empty string.
//    public var title: String {
//        if let attachmentsPopupElement {
//            return attachmentsPopupElement.title
//        } else if let attachmentFormElement {
//            return attachmentFormElement.label
//        }
//        return ""
//    }
//    
//    
//    /// The list of attachments.
//    ///
//    /// This property will be empty if ``PopupElement/isEvaluated`` is `false`.
//    var attachments: [FeatureAttachment] {
//        get async throws {
//            if let attachmentsPopupElement {
//                let attachments = try await attachmentsPopupElement.attachments
//                return attachments.map { FeatureAttachment(popupAttachment: $0) }
//            } else if let attachmentFormElement {
//                try await attachmentFormElement.fetchAttachments()
//                let attachments = attachmentFormElement.attachments
////                let attachments = try await attachmentFormElement.attachments
//                return attachments.map { FeatureAttachment(featureFormAttachment: $0) }
//            }
//            return []
//        }
//    }
//}

extension AttachmentsFeatureElementDisplayType {
    init(kind: AttachmentsPopupElement.DisplayType) {
        switch kind {
        case .list:
            self = .list
        case .preview:
            self = .preview
        case .auto:
            self = .auto
        }
    }
}
