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
    private let attachmentModels: [AttachmentModel]
    /// The last locally added attachment.
    private let lastAttachmentAdded: AttachmentModel?
    /// The proposed size of each attachment preview cell.
    private let proposedCellSize: CGSize
    
    init(
        attachmentModels: [AttachmentModel],
        lastAttachmentAdded: AttachmentModel? = nil,
        proposedCellSize: CGSize
    ) {
        self.attachmentModels = attachmentModels
        self.lastAttachmentAdded = lastAttachmentAdded
        self.proposedCellSize = proposedCellSize
    }
    
    var body: some View {
        Carousel { computedCellSize in
            makeCarouselContent(for: computedCellSize)
                .transition(.asymmetric(insertion: .slide, removal: .scale))
        }
        .cellBaseWidth(proposedCellSize.width)
        .leftScrollTrigger(lastAttachmentAdded?.id)
    }
    
    func makeCarouselContent(for size: CGSize) -> some View {
        ForEach(attachmentModels) { attachmentModel in
            Cell(
                attachmentModel: attachmentModel,
                cellSize: size
            )
        }
    }
    
    /// A view representing a single cell in an `AttachmentPreview`.
    struct Cell: View  {
        /// The model representing the attachment to display.
        @ObservedObject var attachmentModel: AttachmentModel
        
        /// The size of the cell.
        let cellSize: CGSize
        
        @Environment(\.allowsRenamingByUser) private var allowsRenamingByUser
        @Environment(\.displaysFilename) private var displaysFilename
        @Environment(\.editControlsEnabled) private var editControlsEnabled
        @Environment(\.formElement) private var formElement
        @Environment(\.onDelete) private var onDelete
        @Environment(\.onRename) private var onRename
        
        /// The maximum attachment download size limit.
        private let attachmentDownloadSizeLimit = Measurement(
            value: 999,
            unit: UnitInformationStorage.megabytes
        )
        
        /// A Boolean value indicating whether the empty download alert is presented.
        @State private var emptyDownloadAlertIsPresented = false
        /// A Boolean value indicating if the attachment is loading.
        @State private var isLoading = false
        /// A Boolean value indicating whether the maximum size download alert is presented.
        @State private var maximumSizeDownloadExceededAlertIsPresented = false
        /// The new name the user has provided for the attachment.
        @State private var newAttachmentName = ""
        /// The model for an attachment the user has requested be renamed.
        @State private var renamedAttachmentModel: AttachmentModel?
        /// A Boolean value indicating the user has requested that the attachment be renamed.
        @State private var renameDialogueIsShowing = false
        /// The url of the the attachment, used to display the attachment via `QuickLook`.
        @State private var url: URL?
        
        var body: some View {
            Menu {
                // The deletion and rename actions are disabled for empty
                // attachments as these operations cannot be applied
                // successfully to the ServiceGeodatabase or ServiceFeatureTable.
                if editControlsEnabled && !attachmentModel.attachment.measuredSize.value.isZero {
                    if allowsRenamingByUser,
                       attachmentModel.attachment.measuredSize <= attachmentDownloadSizeLimit {
                        // The rename action is disabled for attachments greater
                        // than the attachment download size limit as these
                        // operations trigger a download which currently has
                        // adverse memory implications.
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
                                Text.rename
                            } icon: {
                                Image(systemName: "pencil")
                            }
                        }
                    }
                    Button.delete {
                        onDelete?(attachmentModel)
                    }
                }
            } label: {
                thumbnail
            } primaryAction: {
                guard !isLoading else { return }
                if attachmentModel.loadStatus == .loaded {
                    // Set the url to trigger `.quickLookPreview`.
                    url = attachmentModel.attachment.fileURL
                } else if attachmentModel.attachment.measuredSize.value.isZero {
                    emptyDownloadAlertIsPresented = true
                } else if attachmentModel.attachment.measuredSize > attachmentDownloadSizeLimit {
                    maximumSizeDownloadExceededAlertIsPresented = true
                } else if attachmentModel.loadStatus == .notLoaded {
                    // Load the attachment model with the given size.
                    isLoading = true
                }
            }
            .accessibilityIdentifier("AttachmentPreview-Cell-\(attachmentModel.name)")
            .buttonStyle(.plain)
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
                .autocorrectionDisabled()
                Button.cancel {}
                Button.ok {
                    guard let renamedAttachmentModel else { return }
                    let currentName = renamedAttachmentModel.name
                    if let separatorIndex = currentName.lastIndex(of: ".") {
                        let fileExtension = String(currentName[currentName.index(after: separatorIndex)...])
                        onRename?(renamedAttachmentModel, [newAttachmentName, fileExtension].joined(separator: "."))
                    } else {
                        onRename?(renamedAttachmentModel, newAttachmentName)
                    }
                }
            }
            .alert(
                Text.emptyAttachmentDownloadErrorMessage,
                isPresented: $emptyDownloadAlertIsPresented
            ) {}
            .alert(
                Text(
                    "Attachments larger than \(attachmentDownloadSizeLimit, format: .byteCount(style: .file)) cannot be downloaded.",
                    bundle: .toolkitModule,
                    comment: "An error message explaining attachments larger than the provided maximum cannot be downloaded."
                ),
                isPresented: $maximumSizeDownloadExceededAlertIsPresented
            ) {}
            // On visionOS, quick look preview will close (sometimes it comes back) a sheet presenting
            // the feature form.
            // See thread here: https://developer.apple.com/forums/thread/773599
            .quickLookPreview($url)
            .task(id: isLoading) {
                guard isLoading else { return }
                defer { isLoading = false }
                await attachmentModel.load()
            }
        }
        
        var thumbnail: some View {
            VStack(alignment: .center) {
                ZStack {
                    if attachmentModel.loadStatus != .loading {
                        ThumbnailView(
                            attachmentModel: attachmentModel,
                            size: attachmentModel.usingSystemImage ? CGSize(width: 36, height: 36) : cellSize
                        )
                        if attachmentModel.loadStatus == .loaded {
                            VStack {
                                Spacer()
                                Footer(
                                    displaysFilename: displaysFilename,
                                    name: attachmentModel.name,
                                    size: attachmentModel.thumbnailSize
                                )
                            }
                        }
                    } else {
                        ProgressView()
                            .padding(8)
                    }
                }
                if attachmentModel.loadStatus != .loaded {
                    if displaysFilename {
                        Text(attachmentModel.name)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding([.leading, .trailing], 4)
                    }
                    HStack(alignment: .bottom) {
                        Spacer()
                        Text(attachmentModel.attachment.measuredSize, format: .byteCount(style: .file))
                        Image(systemName: "square.and.arrow.down")
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .font(.caption)
            .frame(width: cellSize.width, height: cellSize.height)
            .background(Color.gray.opacity(0.2))
            .clipShape(.rect(cornerRadius: 8))
            .hoverEffect()
        }
        
        /// A view representing a footer in an `AttachmentPreview.Cell`.
        struct Footer: View {
            /// A Boolean value indicating whether attachment filenames are displayed.
            let displaysFilename: Bool
            /// The name of the attachment.
            let name: String
            /// The size of the media's frame.
            let size: CGSize
            
            var body: some View {
                if displaysFilename && !name.isEmpty {
                    ZStack {
                        let gradient = Gradient(colors: [.black, .black.opacity(0.15)])
                        Rectangle()
                            .fill(.linearGradient(gradient, startPoint: .bottom, endPoint: .top))
                            .frame(height: size.height * 0.25)
                        HStack {
                            Text(name)
                                .foregroundStyle(.white)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding([.leading, .trailing], 6)
                    }
                }
            }
        }
    }
}
