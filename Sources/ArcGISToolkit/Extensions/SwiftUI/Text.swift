// Copyright 2023 Esri
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

extension Text {
    /// Localized text for the word "Done".
    static var done: Self {
        .init(
            "Done",
            bundle: .toolkitModule,
            comment: "A label for a button for the user to indicate completion of the current task."
        )
    }
    
    /// An error message explaining attachments with empty files (0 bytes) cannot be downloaded.
    static var emptyAttachmentDownloadErrorMessage: Self {
        .init(
            "Empty attachments cannot be downloaded.",
            bundle: .toolkitModule,
            comment: "An error message explaining attachments with empty files (0 bytes) cannot be downloaded."
        )
    }
    
    /// Localized text for the word "Required".
    static var required: Self {
        Text(
            "Required",
            bundle: .toolkitModule,
            comment: "A label indicating a field is required"
        )
    }
}
