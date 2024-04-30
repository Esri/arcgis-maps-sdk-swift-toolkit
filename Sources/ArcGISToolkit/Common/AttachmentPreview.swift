// Copyright 2022 Esri
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

/// A view displaying a list of attachments in a "carousel", with a thumbnail and title.
struct AttachmentPreview: View {
    /// The models for the attachments displayed in the list.
    var attachmentModels: [AttachmentModel]
    
    /// The name for the existing attachment being edited.
    @State private var currentAttachmentName = ""
    
    /// The model for an attachment the user has requested be deleted.
    @State private var deletedAttachmentModel: AttachmentModel?
    
    /// The model for an attachment with the user has requested be renamed.
    @State private var renamedAttachmentModel: AttachmentModel?
    
    /// The new name the user has provided for the attachment.
    @State private var newAttachmentName = ""
    
    /// The action to perform when the attachment is deleted.
    let onDelete: ((AttachmentModel) async throws -> Void)?
    
    /// The action to perform when the attachment is renamed.
    let onRename: ((AttachmentModel, String) async throws -> Void)?
    
    /// A Boolean value indicating the user has requested that the attachment be renamed.
    @State private var renameDialogueIsShowing = false
    
    /// A Boolean value which determines if the attachment editing controls should be disabled.
    let editControlsDisabled: Bool
    
    init(
        attachmentModels: [AttachmentModel],
        editControlsDisabled: Bool = true,
        onRename: ((AttachmentModel, String) async throws -> Void)? = nil,
        onDelete: ((AttachmentModel) async throws -> Void)? = nil
    ) {
        self.attachmentModels = attachmentModels
        self.onRename = onRename
        self.onDelete = onDelete
        self.editControlsDisabled = editControlsDisabled
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(attachmentModels) { attachmentModel in
                    AttachmentCell(attachmentModel: attachmentModel)
                        .contextMenu {
                            if !editControlsDisabled {
                                Button {
                                    renamedAttachmentModel = attachmentModel
                                    newAttachmentName = attachmentModel.attachment.name
                                    renameDialogueIsShowing = true
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    deletedAttachmentModel = attachmentModel
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                }
            }
        }
        .alert("Rename attachment", isPresented: $renameDialogueIsShowing) {
            TextField("New name", text: $newAttachmentName)
            Button("Cancel", role: .cancel) { }
            Button("Ok") {
                Task {
                    if let renamedAttachmentModel {
                        try? await onRename?(renamedAttachmentModel, newAttachmentName)
                    }
                }
            }
        }
        .task(id: deletedAttachmentModel) {
            guard let deletedAttachmentModel else { return }
            try? await onDelete?(deletedAttachmentModel)
            self.deletedAttachmentModel = nil
        }
    }
    
    /// A view representing a single cell in an `AttachmentPreview`.
    struct AttachmentCell: View  {
        /// The model representing the attachment to display.
        @ObservedObject var attachmentModel: AttachmentModel
        
        /// The url of the the attachment, used to display the attachment via `QuickLook`.
        @State private var url: URL?
        
        var body: some View {
            VStack(alignment: .center) {
                ZStack {
                    if attachmentModel.loadStatus != .loading {
                        ThumbnailView(
                            attachmentModel: attachmentModel,
                            size: attachmentModel.usingSystemImage ?
                            CGSize(width: 36, height: 36) :
                                attachmentModel.thumbnailSize
                        )
                        if attachmentModel.loadStatus == .loaded {
                            VStack {
                                Spacer()
                                ThumbnailViewFooter(
                                    attachmentModel: attachmentModel,
                                    size: attachmentModel.thumbnailSize
                                )
                            }
                        }
                    } else {
                        ProgressView()
                            .padding(8)
                            .background(Material.thin, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                if attachmentModel.attachment.loadStatus != .loaded {
                    Text(attachmentModel.name)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .padding([.leading, .trailing], 4)
                    HStack(alignment: .bottom) {
                        Spacer()
                        Text(Int64(attachmentModel.attachment.size), format: .byteCount(style: .file))
                        Image(systemName: "square.and.arrow.down")
                        Spacer()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .font(.caption)
            .frame(width: 120, height: 120)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onTapGesture {
                if attachmentModel.attachment.loadStatus == .loaded {
                    // Set the url to trigger `.quickLookPreview`.

                    // WORKAROUND - attachment.fileURL is just a GUID for FormAttachments
                    // Note: this can be deleted when Apollo #635 - "FormAttachment.fileURL is not user-friendly" is fixed.
                    var tmpURL =  attachmentModel.attachment.fileURL
                    if let formAttachment = attachmentModel.attachment as? FormAttachment {
                        tmpURL = tmpURL?.deletingLastPathComponent()
                        tmpURL = tmpURL?.appending(path: formAttachment.name)
                        
                        _ = FileManager.default.secureCopyItem(at: attachmentModel.attachment.fileURL!, to: tmpURL!)
                    }
                    url = tmpURL
                } else if attachmentModel.attachment.loadStatus == .notLoaded {
                    // Load the attachment model with the given size.
                    attachmentModel.load()
                }
            }
            .quickLookPreview($url)
        }
    }
}

extension FileManager {
    /// - Note: This can be deleted when Apollo #635 - "FormAttachment.fileURL is not user-friendly" is fixed.
    func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
}

/// A view displaying details for popup media.
struct ThumbnailViewFooter: View {
    /// The popup media to display.
    @ObservedObject var attachmentModel: AttachmentModel
    
    /// The size of the media's frame.
    let size: CGSize
    
    var body: some View {
        ZStack {
            let gradient = Gradient(colors: [.black, .black.opacity(0.15)])
            Rectangle()
                .fill(
                    LinearGradient(gradient: gradient, startPoint: .bottom, endPoint: .top)
                )
                .frame(height: size.height * 0.25)
            HStack {
                if !attachmentModel.name.isEmpty {
                    Text(attachmentModel.name)
                        .foregroundColor(.white)
                        .font(.caption)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding([.leading, .trailing], 6)
        }
    }
}
