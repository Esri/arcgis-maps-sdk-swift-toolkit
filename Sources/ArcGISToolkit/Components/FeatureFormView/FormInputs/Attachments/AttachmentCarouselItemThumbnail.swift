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

/// The UI for a single attachment in a set of attachments within an attachment form element.
struct AttachmentCarouselItemThumbnail: View {
    /// The form element containing the attachment.
    private let element: AttachmentFormElement
    
    /// The attachment represented by the item.
    private let formAttachment: FormAttachment
    
    /// A Boolean value indicating whether the user requested the attachment's preview.
    @State private var attachmentPreviewWasRequested = false
    
    /// A Boolean value indicating the user has requested that the attachment be deleted.
    @State private var deletionWillStart: Bool = false
    
    /// A Boolean value indicating the user has requested that the attachment be renamed.
    @State private var renameDialogueIsShowing = false
    
    /// The attachment data.
    ///
    /// Attachment data is provided asynchronously meaning there can be a short period where the data is
    /// not present and we need to display alternative UI.
    @State private var data: Data?
    
    /// Any error encountered while retrieving the attachment's data.
    @State private var error: Error?
    
    /// The new name the user has provided for the attachment.
    @State private var newAttachmentName = ""
    
    /// Creates UI to display a single form attachment.
    /// - Parameter element: The form element containing the attachment.
    /// - Parameter formAttachment: The attachment to be displayed.
    init(element: AttachmentFormElement, formAttachment: FormAttachment) {
        self.element = element
        self.formAttachment = formAttachment
    }
    
    var body: some View {
        Group {
            if !attachmentPreviewWasRequested {
                Button {
                    attachmentPreviewWasRequested = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title3)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.thinMaterial)
                }
            } else if let data, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .contextMenu {
                        Button {
                            newAttachmentName = formAttachment.name
                            renameDialogueIsShowing = true
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            deletionWillStart = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            } else if data != nil || error != nil {
                // Data was present but a UIImage wasn't initialized or an error
                // was present.
                Image(systemName: "exclamationmark")
            } else {
                // No data or error was present.
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .alert("Rename attachment", isPresented: $renameDialogueIsShowing) {
            TextField("New name", text: $newAttachmentName)
            Button("Cancel", role: .cancel) { }
            Button("Ok") {
                formAttachment.setName(name: newAttachmentName)
            }
        }
        .task(id: attachmentPreviewWasRequested) {
            do {
                data = try await formAttachment.attachment?.data
            } catch {
                self.error = error
            }
        }
        .task(id: deletionWillStart) {
            guard deletionWillStart else { return }
            await element.deleteAttachment(attachment: formAttachment)
        }
    }
}
