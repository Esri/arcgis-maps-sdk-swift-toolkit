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
    /// The attachment feature element displaying the attachments.
    private let element: AttachmentsFeatureElement
    
    /// The models for the attachments displayed in the list.
    var attachmentModels: [AttachmentModel]
    
    /// The name for the existing attachment being edited.
    @State private var currentAttachmentName = ""
    
    /// The model for an attachment the user has requested be deleted.
    @State private var deletedAttachmentModel: AttachmentModel?
    
    /// The new name the user has provided for the attachment.
    @State private var newAttachmentName = ""
    
    /// The model for an attachment the user has requested be renamed.
    @State private var renamedAttachmentModel: AttachmentModel?
    
    /// A Boolean value indicating the user has requested that the attachment be renamed.
    @State private var renameDialogueIsShowing = false
    
    /// A Boolean value which determines if the attachment editing controls should be disabled.
    let editControlsDisabled: Bool
    
    init(
        element: AttachmentsFeatureElement,
        attachmentModels: [AttachmentModel],
        editControlsDisabled: Bool = true
    ) {
        self.element = element
        self.attachmentModels = attachmentModels
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
                                    renameDialogueIsShowing = true
                                    if let separatorIndex = attachmentModel.name.lastIndex(of: ".") {
                                        newAttachmentName = String(attachmentModel.name[..<separatorIndex])
                                    } else {
                                        newAttachmentName = attachmentModel.name
                                    }
                                } label: {
                                    Label {
                                        Text(
                                            "Rename",
                                            bundle: .toolkitModule,
                                            comment: "A label for a button to rename an attachment."
                                        )
                                    } icon: {
                                        Image(systemName: "pencil")
                                    }
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
        .alert(
            Text(
                "Rename attachment",
                bundle: .toolkitModule,
                comment: "A label in reference to the action of renaming a file, shown in a file rename interface."
            ),
            isPresented: $renameDialogueIsShowing
        ) {
            TextField(text: $newAttachmentName) {
                Text(
                    "New name",
                    bundle: .toolkitModule,
                    comment: "A label in reference to the new name of a file, shown in a file rename interface."
                )
            }
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                Task {
                    if let renamedAttachmentModel,
                       let element = element as? AttachmentsFormElement,
                       let attachment = renamedAttachmentModel.attachment as? FormAttachment {
                        let currentName = renamedAttachmentModel.name
                        if let separatorIndex = currentName.lastIndex(of: ".") {
                            let fileExtension = String(currentName[currentName.index(after: separatorIndex)...])
                            try? await element.renameAttachment(
                                attachment,
                                name: [newAttachmentName, fileExtension].joined(separator: ".")
                            )
                        } else {
                            try? await element.renameAttachment(
                                attachment,
                                name: newAttachmentName
                            )
                        }
                    }
                }
            }
        }
        .task(id: deletedAttachmentModel) {
            guard let deletedAttachmentModel else { return }
            if let element = element as? AttachmentsFormElement, let attachment = deletedAttachmentModel.attachment as? FormAttachment {
                try? await element.deleteAttachment(attachment)
            }
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
                    url = attachmentModel.attachment.fileURL
                } else if attachmentModel.attachment.loadStatus == .notLoaded {
                    // Load the attachment model with the given size.
                    attachmentModel.load()
                }
            }
            .quickLookPreview($url)
        }
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
