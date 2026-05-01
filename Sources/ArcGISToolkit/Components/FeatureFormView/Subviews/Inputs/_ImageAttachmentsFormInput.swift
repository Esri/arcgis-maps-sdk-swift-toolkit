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

import ArcGIS

/// A prototype implementation for the image attachments form input class.
class _ImageAttachmentsFormInput {
    /// <#Description#>
    var inputMethod: InputMethod
    
    /// Number of pixels on the longest edge depending on orientation.
    ///
    /// Larger images will be resized and aspect ratio is maintained. If not specified, images will not be
    /// resized.
    var maxImageSize: Int? = nil
    
    init(inputMethod: InputMethod, maxImageSize: Int? = nil) {
        self.inputMethod = inputMethod
        self.maxImageSize = maxImageSize
    }
    
    enum InputMethod {
        case any
        case capture
        case upload
    }
}
