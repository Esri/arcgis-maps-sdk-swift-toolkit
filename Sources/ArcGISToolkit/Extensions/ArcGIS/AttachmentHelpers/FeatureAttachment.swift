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
import UIKit

/// The type of attachments in a FeatureAttachment.
public enum FeatureAttachmentKind {
    /// An image.
    case image
    /// A video.
    case video
    /// A document.
    case document
    /// An attachment of another type.
    case other
}

public protocol FeatureAttachment: Loadable {    
    /// The underlying ``Attachment``.
    var attachment: Attachment? { get }
    
    /// The MIME content type of the attachment.
    var contentType: String { get }
    
    /// The type of the attachment.
    var featureAttachmentKind: FeatureAttachmentKind { get }

    /// The local temporary filepath where we store the attachment once it is loaded.
    var fileURL: URL? { get }
    
    /// A value indicating whether "loading" (fetching the data) can be accomplished without using the network.
    ///
    /// This is `true` if it just needs to pull the data from a database,
    /// `false` if the loading will cause a network request.
    var isLocal: Bool { get }
    
    /// The name of the attachment.
    var name: String { get }
    
    /// The size of the attachment in bytes.
    var size: Int { get }
    
    // MARK: Methods
    //
    /// Creates asynchronously the full image for displaying the attachment in full screen or some UI larger than a thumbnail.
    ///
    /// This is only supported if the ``kind-swift.property`` is ``Kind-swift.enum/image``.
    /// - Returns: A task that represents the asynchronous operation. The task result contains the full image as an `UIImage`.
    func makeFullImage() async throws -> UIImage
    
    /// Creates asynchronously a thumbnail image with the specified width and height.
    ///
    /// This is only supported if the ``kind-swift.property`` is ``Kind-swift.enum/image``.
    /// - Parameters:
    ///   - width: Width of the thumbnail.
    ///   - height: Height of the thumbnail.
    /// - Returns: A task that represents the asynchronous operation. The task result contains the thumbnail as an `UIImage`.
    func makeThumbnail(width: Int, height: Int) async throws -> UIImage
}

extension FeatureAttachmentKind {
    /// Caretes a feature attachment kind from a popup attachment kind.
    /// - Parameter kind: The popup attachment kind.
    init(kind: PopupAttachment.Kind) {
        switch kind {
        case .image:
            self = .image
        case .video:
            self = .video
        case .document:
            self = .document
        case .other:
            self = .other
        }
    }
    
    /// Creates a feature attachment kind from a MIME type.
    /// - Parameter contentType: The content type to convert.
    init(contentType: String) {
        if contentType.contains("image") {
            self = .image
        } else if contentType.contains("video") {
            self = .video
        } else {
            self = .document
        }
    }
}