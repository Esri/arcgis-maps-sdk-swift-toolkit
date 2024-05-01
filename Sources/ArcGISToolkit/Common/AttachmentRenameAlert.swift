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

import SwiftUI

/// The contents of an alert to rename an attachment.
struct AttachmentRenameAlert: View {
    /// The model for the attachment the user has requested be renamed.
    let attachmentModel: AttachmentModel
    
    /// The action to perform when the attachment is renamed.
    let onRename: (AttachmentModel, String) async throws -> Void
    
    /// The attachment's file extension.
    @State private var fileExtension: String?
    
    /// The attachment's new name.
    @State private var newName = ""
    
    var body: some View {
        Group {
            TextField("New name", text: $newName)
            Button("Cancel", role: .cancel) { }
            Button("Ok") {
                Task {
                    if let fileExtension {
                        try? await onRename(attachmentModel, [newName, fileExtension].joined(separator: "."))
                    } else {
                        try? await onRename(attachmentModel, newName)
                    }
                    fileExtension = nil
                    newName.removeAll()
                }
            }
        }
        .task(id: attachmentModel) {
            let currentName = attachmentModel.name
            if let separatorIndex = currentName.lastIndex(of: ".") {
                newName = String(currentName[..<separatorIndex])
                fileExtension = String(currentName[currentName.index(after: separatorIndex)...])
            } else {
                newName = attachmentModel.name
            }
        }
    }
}
