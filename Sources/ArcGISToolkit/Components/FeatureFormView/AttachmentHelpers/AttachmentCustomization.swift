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

import UIKit
public import UniformTypeIdentifiers

/// A struct allowing clients to customize attachment data prior to adding an attachment to `AttachmentFormElement`.
/// Adding the attachment to `AttachmentFormElement` is still handled by the `FeatureFormView` Toolkit component.
public struct AttachmentCustomization {
    /// Creates an attachment customization structure.
    /// - Parameter action: The action called when the user selects an attachment to add.
    public init(
        action: @escaping (UTType, Data?, URL?) -> (Data?, URL?)
    ) {
        self.action = action
    }
    
    /// The action initiated when the user is in the process of adding a new attachment. Because attachments can be loaded
    /// from a file, from the user's Photo Library, or taken as an image or video from the camers, the actual data representing
    /// that attachment can be either in the form of `Data` or an on-disk file represented by a `URL`.
    /// - Parameters:
    /// - The UTType of the attachment. This allows clients to only perform actions on specific types of attachments,
    /// such as images, videos, audio files, etc.
    /// - Data? - The data of the attachment.
    /// - URL? - The URL of the file to be added.
    /// Note: only one of `Data?` or `URL?` will be non-nil and is dependent on the source of the attachment,
    /// such as camera, photo library, or file.
    /// - Returns: The data or URL representing the newly modified attachment data. This should be the same UTType as the
    /// argument to `action` and should match the the format of that passed in, either `Data` or `URL`.
    let action:  ((UTType, Data?, URL?) -> (Data?, URL?))
}
