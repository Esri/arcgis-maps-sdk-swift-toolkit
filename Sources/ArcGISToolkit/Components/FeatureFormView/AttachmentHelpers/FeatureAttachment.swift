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
    
    /// The MIME content type of the ``PopupAttachment``.
    var contentType: String { get }
    
    /// The local temporary filepath where we store the attachment once it is loaded.
    var fileURL: URL? { get }
    
    /// A value indicating whether "loading" (fetching the data) can be accomplished without using the network.
    ///
    /// This is `true` if it just needs to pull the data from a database,
    /// `false` if the loading will cause a network request.
    var isLocal: Bool { get }
    
    /// The type of the ``PopupAttachment``.
    var featureAttachmentKind: FeatureAttachmentKind { get }
    
    /// The name of the ``PopupAttachment``.
    var name: String { get }
    
    /// The size of the ``PopupAttachment`` in bytes.
    var size: Int { get }
    
    // MARK: Methods
    //
    //    /// Creates asynchronously the full image for displaying the attachment in full screen or some UI larger than a thumbnail.
    //    ///
    //    /// This is only supported if the ``kind-swift.property`` is ``Kind-swift.enum/image``.
    //    /// - Returns: A task that represents the asynchronous operation. The task result contains the full image as an `UIImage`.
    //    public func makeFullImage() async throws -> UIImage {
    //        let coreFuture: CoreFuture<UIImage> = RT_PopupAttachment_createFullImageAsync(coreHandle, nil).toAPI()
    //        return try await coreFuture.getResult()
    //    }
    //
    //    /// Creates asynchronously a thumbnail image with the specified width and height.
    //    ///
    //    /// This is only supported if the ``kind-swift.property`` is ``Kind-swift.enum/image``.
    //    /// - Parameters:
    //    ///   - width: Width of the thumbnail.
    //    ///   - height: Height of the thumbnail.
    //    /// - Returns: A task that represents the asynchronous operation. The task result contains the thumbnail as an `UIImage`.
    //    public func makeThumbnail(width: Int, height: Int) async throws -> UIImage {
    //        let coreFuture: CoreFuture<UIImage> = RT_PopupAttachment_createThumbnailAsync(coreHandle, Int32(clamping: width), Int32(clamping: height), nil).toAPI()
    //        return try await coreFuture.getResult()
    //    }
    //
}

extension FeatureAttachmentKind {
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
//public class FeatureAttachment {
//    /// The type of attachments in a FeatureAttachment.
//    public enum Kind {
//        /// An image.
//        case image
//        /// A video.
//        case video
//        /// A document.
//        case document
//        /// An attachment of another type.
//        case other
//    }
//    
//    let popupAttachment: PopupAttachment?
//    let formAttachment: FormAttachment?
//    
//    init(popupAttachment: PopupAttachment) {
//        self.popupAttachment = popupAttachment
//        self.formAttachment = nil
//    }
//    
//    init(featureFormAttachment: FormAttachment) {
//        self.popupAttachment = nil
//        self.formAttachment = featureFormAttachment
//    }
//    
//    /// The underlying ``Attachment``.
//    public var attachment: Attachment? {
//        if let popupAttachment {
//            return popupAttachment.attachment
//        } else if let formAttachment {
//            return formAttachment.attachment
//        }
//        return nil
//    }
//    
//    /// The MIME content type of the ``PopupAttachment``.
//    public var contentType: String {
//        if let popupAttachment {
//            return popupAttachment.contentType
//        } else if let formAttachment {
//            return formAttachment.contentType
//        }
//        return ""
//    }
//    
//    /// The local temporary filepath where we store the attachment once it is loaded.
//    public var fileURL: URL? {
//        if let popupAttachment {
//            return popupAttachment.fileURL
//        } else if let formAttachment {
//            return formAttachment.fileURL
//        }
//        return nil
//    }
//    
//    /// A value indicating whether "loading" (fetching the data) can be accomplished without using the network.
//    ///
//    /// This is `true` if it just needs to pull the data from a database,
//    /// `false` if the loading will cause a network request.
//    public var isLocal: Bool {
//        if let popupAttachment {
//            return popupAttachment.isLocal
//        } else if let formAttachment {
//            return formAttachment.isLocal
//        }
//        return false
//    }
//    
//    /// The type of the ``PopupAttachment``.
//    public var kind: Kind {
//        // Need to map popup attachment.kind to Kind
//        if let popupAttachment {
//            return Kind(kind: popupAttachment.kind)
//        } else if let formAttachment {
//            return Kind(contentType: formAttachment.contentType)
//        }
//        return Kind.other
//    }
//    
//    /// The name of the ``PopupAttachment``.
//    public var name: String {
//        if let popupAttachment {
//            return popupAttachment.name
//        } else if let formAttachment {
//            return formAttachment.name
//        }
//        return ""
//    }
//    
//    /// The size of the ``PopupAttachment`` in bytes.
//    public var size: Int {
//        if let popupAttachment {
//            return popupAttachment.size
//        } else if let formAttachment {
//            return formAttachment.size
//        }
//        return 0
//    }
//    
//    // MARK: Methods
//    //
//    //    /// Creates asynchronously the full image for displaying the attachment in full screen or some UI larger than a thumbnail.
//    //    ///
//    //    /// This is only supported if the ``kind-swift.property`` is ``Kind-swift.enum/image``.
//    //    /// - Returns: A task that represents the asynchronous operation. The task result contains the full image as an `UIImage`.
//    //    public func makeFullImage() async throws -> UIImage {
//    //        let coreFuture: CoreFuture<UIImage> = RT_PopupAttachment_createFullImageAsync(coreHandle, nil).toAPI()
//    //        return try await coreFuture.getResult()
//    //    }
//    //
//    //    /// Creates asynchronously a thumbnail image with the specified width and height.
//    //    ///
//    //    /// This is only supported if the ``kind-swift.property`` is ``Kind-swift.enum/image``.
//    //    /// - Parameters:
//    //    ///   - width: Width of the thumbnail.
//    //    ///   - height: Height of the thumbnail.
//    //    /// - Returns: A task that represents the asynchronous operation. The task result contains the thumbnail as an `UIImage`.
//    //    public func makeThumbnail(width: Int, height: Int) async throws -> UIImage {
//    //        let coreFuture: CoreFuture<UIImage> = RT_PopupAttachment_createThumbnailAsync(coreHandle, Int32(clamping: width), Int32(clamping: height), nil).toAPI()
//    //        return try await coreFuture.getResult()
//    //    }
//    //
//    
//    // MARK: Loadable Protocol Conformance
//    
//    //    @Streamed
//    public var loadStatus: LoadStatus {
//        get {
//            if let popupAttachment {
//                return popupAttachment.loadStatus
//            } else if let formAttachment {
//                return formAttachment.loadStatus
//            }
//            return .notLoaded
//        }
//    }
//    
//    @Streamed
//    public private(set) var loadError: Swift.Error?
//    
//    public func load() async throws {
//        if let popupAttachment {
//            try await popupAttachment.load()
//        } else if let formAttachment {
//            try await formAttachment.load()
//        }
//    }
//    
//    public func retryLoad() async throws {
//        if let popupAttachment {
//            try await popupAttachment.retryLoad()
//        } else if let formAttachment {
//            try await formAttachment.retryLoad()
//        }
//    }
//    
//    public func cancelLoad() {
//        if let popupAttachment {
//            popupAttachment.cancelLoad()
//        } else if let formAttachment {
//            formAttachment.cancelLoad()
//        }
//    }
//}
//
//extension FeatureAttachment.Kind {
//    init(kind: PopupAttachment.Kind) {
//        switch kind {
//        case .image:
//            self = .image
//        case .video:
//            self = .video
//        case .document:
//            self = .document
//        case .other:
//            self = .other
//        }
//    }
//    
//    init(contentType: String) {
//        if contentType.contains("image") {
//            self = .image
//        } else if contentType.contains("video") {
//            self = .video
//        } else {
//            self = .document
//        }
//    }
//}
