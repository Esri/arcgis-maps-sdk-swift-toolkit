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

extension View {
    /// Modifier for watching `AttachmentsFormElement.isEditable`.
    /// - Parameters:
    ///   - element: The attachment form element to watch for changes on.
    ///   - action: The action which watches for changes.
    /// - Returns: The modified view.
    @ViewBuilder func onAttachmentIsEditableChange(
        of element: AttachmentsFeatureElement,
        action: @escaping (_ newIsEditable: Bool) -> Void
    ) -> some View {
        if let attachmentsFormElement = element as? AttachmentsFormElement {
            self
                .task(id: ObjectIdentifier(attachmentsFormElement)) {
                    for await isEditable in attachmentsFormElement.$isEditable {
                        action(isEditable)
                    }
                }
        } else {
            self
        }
    }
}
