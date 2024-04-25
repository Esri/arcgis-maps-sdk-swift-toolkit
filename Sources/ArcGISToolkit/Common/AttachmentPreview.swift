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
    /// The attachment models displayed in the list.
    var attachmentModels: [AttachmentModel]
    
    /// The name for the existing attachment being edited.
    @State private var currentAttachmentName = ""

    /// A Boolean value indicating the user has requested that the attachment be deleted.
    @State private var deletionWillStart: Bool = false
    
    /// The attachment with the new name the user has provided.
    @State private var editedAttachment: FeatureAttachment?
    
    /// The new name the user has provided for the attachment.
    @State private var newAttachmentName = ""

    let onDelete: ((FeatureAttachment) async throws -> Void)?
    
    let onRename: ((FeatureAttachment, String) async throws -> Void)?
    
    /// A Boolean value indicating the user has requested that the attachment be renamed.
    @State private var renameDialogueIsShowing = false
    
    /// Determines if the attachment editing controls should be enabled.
    let shouldEnableEditControls: Bool
    
    init(
        attachmentModels: [AttachmentModel],
        shouldEnableEditControls: Bool = false,
        onRename: ((FeatureAttachment, String) async throws -> Void)? = nil,
        onDelete: ((FeatureAttachment) async throws -> Void)? = nil
    ) {
        self.attachmentModels = attachmentModels
        self.onRename = onRename
        self.onDelete = onDelete
        self.shouldEnableEditControls = shouldEnableEditControls
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(attachmentModels) { attachmentModel in
                    AttachmentCell(attachmentModel: attachmentModel)
                        .contextMenu {
                            if shouldEnableEditControls {
                                Button {
                                    editedAttachment = attachmentModel.attachment
                                    newAttachmentName = attachmentModel.attachment.name
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
                        }
                }
            }
        }
        .alert("Rename attachment", isPresented: $renameDialogueIsShowing) {
            TextField("New name", text: $newAttachmentName)
            Button("Cancel", role: .cancel) { }
            Button("Ok") {
                Task {
                    if let editedAttachment {
                        try? await onRename?(editedAttachment, newAttachmentName)
                    }
                }
            }
        }
        .task(id: deletionWillStart) {
            guard deletionWillStart else { return }
            if let editedAttachment {
                try? await onDelete?(editedAttachment)
            }
        }
    }
    
    /// A view representing a single cell in an `AttachmentPreview`.
    struct AttachmentCell: View  {
        /// The model representing the attachment to display.
        @ObservedObject var attachmentModel: AttachmentModel
        
        /// The url of the the attachment, used to display the attachment via `QuickLook`.
        @State var url: URL?
        
        var body: some View {
            VStack(alignment: .center) {
                ZStack {
                    if attachmentModel.loadStatus != .loading {
                        ThumbnailView(
                            attachmentModel: attachmentModel,
                            size: attachmentModel.usingSystemImage ?
                            CGSize(width: 36, height: 36) :
                                CGSize(width: 120, height: 120)
                        )
//                        if !attachmentModel.usingDefaultImage {
                        if attachmentModel.loadStatus == .loaded {
                            VStack {
                                Spacer()
                                ThumbnailViewFooter(
                                    attachmentModel: attachmentModel,
                                    size: CGSize(width: 120, height: 120)
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
                    Text(attachmentModel.attachment.name)
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
                    attachmentModel.load(thumbnailSize: CGSize(width: 120, height: 120))
                }
            }
            .quickLookPreview($url)
        }
    }
}

// Note: this can be deleted when Apollo #635 - "FormAttachment.fileURL is not user-friendly" is fixed.
extension FileManager {
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
    let attachmentModel: AttachmentModel
    
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
                if !attachmentModel.attachment.name.isEmpty {
                    Text(attachmentModel.attachment.name)
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
