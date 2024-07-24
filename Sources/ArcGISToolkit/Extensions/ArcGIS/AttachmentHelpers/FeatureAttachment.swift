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
import UIKit

/// The type of an attachment in a FeatureAttachment.
public enum FeatureAttachmentKind: Sendable {
    /// An attachment of another type.
    case other
    /// An image.
    case image
    /// A video.
    case video
    /// A document.
    case document
    /// An audio file.
    case audio
}

public protocol FeatureAttachment: Loadable {
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
    
    /// The size of the attachment.
    var measuredSize: Measurement<UnitInformationStorage> { get }
    
    // MARK: Methods
    //
    /// Creates asynchronously the full image for displaying the attachment in full screen or some UI larger than a thumbnail.
    ///
    /// This is only supported if ``FeatureAttachment/featureAttachmentKind`` is ``FeatureAttachmentKind/image``.
    /// - Returns: A task that represents the asynchronous operation. The task result contains the full image as an `UIImage`.
    func makeFullImage() async throws -> UIImage
    
    /// Creates asynchronously a thumbnail image with the specified width and height.
    ///
    /// This is only supported if ``FeatureAttachment/featureAttachmentKind`` is ``FeatureAttachmentKind/image``.
    /// - Parameters:
    ///   - width: Width of the thumbnail.
    ///   - height: Height of the thumbnail.
    /// - Returns: A task that represents the asynchronous operation. The task result contains the thumbnail as an `UIImage`.
    func makeThumbnail(width: Int, height: Int) async throws -> UIImage
}

extension FeatureAttachmentKind {
    /// Creates a feature attachment kind from a popup attachment kind.
    /// - Parameter kind: The popup attachment kind.
    init(kind: PopupAttachment.Kind) {
        self = switch kind {
        case .image: .image
        case .video: .video
        case .document: .document
        case .other: .other
        @unknown default: fatalError("Unknown case")
        }
    }
    
    /// Creates a feature attachment kind from a form attachment kind.
    /// - Parameter kind: The form attachment kind.
    init(kind: FormAttachment.Kind) {
        self = switch kind {
        case .other: .other
        case .image: .image
        case .video: .video
        case .document: .document
        case .audio: .audio
        @unknown default: fatalError("Unknown case")
        }
    }
}
