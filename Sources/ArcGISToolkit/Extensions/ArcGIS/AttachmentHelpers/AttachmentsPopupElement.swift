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

extension AttachmentsPopupElement: AttachmentsFeatureElement {
    /// Indicates how to display the attachments.
    public var attachmentsDisplayType: AttachmentsFeatureElementDisplayType {
        AttachmentsFeatureElementDisplayType(kind: displayType)
    }
    
    /// The feature attachments associated with this element. This property will be empty if the element has not yet been evaluated.
    public var featureAttachments: [FeatureAttachment] {
        get async throws {
            try await attachments.map { $0 as FeatureAttachment }
        }
    }
}
