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

    /// The latest generated filename from the prototype test action.
    @State private var generatedName: String?

    /// The latest generation error from the prototype test action.
    @State private var generationError: String?
    
    /// The maximum attachment download size limit.
    private let attachmentDownloadSizeLimit = Measurement(
        value: 999,
        unit: UnitInformationStorage.megabytes
    )
    
    /// The models for the attachments displayed in the list.
    private let attachmentModels: [AttachmentModel]
    
    /// A Boolean value which determines if the attachment editing controls should be disabled.
    private let editControlsDisabled: Bool

    /// A Boolean value indicating whether users can rename attachments.
    private let allowUserRename: Bool

    /// A Boolean value indicating whether users can delete attachments.
    private let allowDeleteAttachments: Bool

    /// A Boolean value indicating whether attachment filenames are displayed.
    private let displaysFilename: Bool

    /// Shared prototype options that can override preview and import behavior.
    @ObservedObject private var prototypeAttachmentOptions: AttachmentPrototypeOptions

    /// Defaults used when enabling prototype options.
    private let prototypeAttachmentOptionDefaults: AttachmentPrototypeOptions.Defaults?

    /// The form element used for prototype actions that require form APIs.
    private let prototypeOptionsFormElement: AttachmentsFormElement?
    
    /// The last locally added attachment.
    private let lastAttachmentAdded: AttachmentModel?
    
    /// The action to perform when the attachment is deleted.
    private let onDelete: (@MainActor (AttachmentModel) -> Void)?
    
    /// The action to perform when the attachment is renamed.
    private let onRename: (@MainActor (AttachmentModel, String) -> Void)?
    
    /// The proposed size of each attachment preview cell.
    private let proposedCellSize: CGSize
    
    init(
        attachmentModels: [AttachmentModel],
        editControlsDisabled: Bool = true,
        allowUserRename: Bool = true,
        allowDeleteAttachments: Bool = true,
        displaysFilename: Bool = true,
        prototypeAttachmentOptions: AttachmentPrototypeOptions = .init(),
        prototypeAttachmentOptionDefaults: AttachmentPrototypeOptions.Defaults? = nil,
        prototypeOptionsFormElement: AttachmentsFormElement? = nil,
        lastAttachmentAdded: AttachmentModel? = nil,
        onRename: (@MainActor (AttachmentModel, String) -> Void)? = nil,
        onDelete: (@MainActor (AttachmentModel) -> Void)? = nil,
        proposedCellSize: CGSize
    ) {
        self.attachmentModels = attachmentModels
        self.proposedCellSize = proposedCellSize
        self.editControlsDisabled = editControlsDisabled
        self.allowUserRename = allowUserRename
        self.allowDeleteAttachments = allowDeleteAttachments
        self.displaysFilename = displaysFilename
        self.prototypeAttachmentOptions = prototypeAttachmentOptions
        self.prototypeAttachmentOptionDefaults = prototypeAttachmentOptionDefaults
        self.prototypeOptionsFormElement = prototypeOptionsFormElement
        self.lastAttachmentAdded = lastAttachmentAdded
        self.onRename = onRename
        self.onDelete = onDelete
    }

    private var effectiveAllowUserRename: Bool {
        prototypeAttachmentOptions.isEnabled ? prototypeAttachmentOptions.allowUserRename : allowUserRename
    }

    private var effectiveDisplaysFilename: Bool {
        prototypeAttachmentOptions.isEnabled ? prototypeAttachmentOptions.displayFilename : displaysFilename
    }
    
    var body: some View {
        Carousel { computedCellSize in
            makeCarouselContent(for: computedCellSize)
                .transition(.asymmetric(insertion: .slide, removal: .scale))
        }
        .cellBaseWidth(proposedCellSize.width)
        .leftScrollTrigger(lastAttachmentAdded?.id)
    }

    /// - Note: Contextual actions are disabled for empty attachments as deletion and rename
    /// operations cannot be applied successfully to the ServiceGeodatabase or ServiceFeatureTable.
    ///
    /// - Note: The rename contextual action is disabled for attachments greater than the attachment download
    /// size limit as rename operations trigger a download which currently has adverse memory implications.
    func makeCarouselContent(for size: CGSize) -> some View {
        ForEach(attachmentModels) { attachmentModel in
            AttachmentCell(
                attachmentModel: attachmentModel,
                attachmentDownloadSizeLimit: attachmentDownloadSizeLimit,
                cellSize: size,
                displaysFilename: effectiveDisplaysFilename
            )
                .contextMenu {
                    if !editControlsDisabled && !attachmentModel.attachment.measuredSize.value.isZero {
                        if effectiveAllowUserRename,
                           attachmentModel.attachment.measuredSize <= attachmentDownloadSizeLimit {
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
                        if allowDeleteAttachments {
                            Button.delete {
                                deletedAttachmentModel = attachmentModel
                            }
                        }
                    }

                    if prototypeOptionsFormElement != nil {
                        prototypeAttachmentOptionsMenu
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
            TextField(String.newName, text: $newAttachmentName)
                .autocorrectionDisabled()
            Button.cancel {}
            Button.ok {
                Task {
                    if let renamedAttachmentModel {
                        let currentName = renamedAttachmentModel.name
                        if let separatorIndex = currentName.lastIndex(of: ".") {
                            let fileExtension = String(currentName[currentName.index(after: separatorIndex)...])
                            onRename?(renamedAttachmentModel, [newAttachmentName, fileExtension].joined(separator: "."))
                        } else {
                            onRename?(renamedAttachmentModel, newAttachmentName)
                        }
                    }
                }
            }
        }
        .task(id: deletedAttachmentModel?.id) {
            guard let deletedAttachmentModel else { return }
            onDelete?(deletedAttachmentModel)
            self.deletedAttachmentModel = nil
        }
    }

    @ViewBuilder
    private var prototypeAttachmentOptionsMenu: some View {
        Section("Prototype Attachment Options") {
            Toggle(
                "Allow User Rename",
                isOn: Binding(
                    get: { prototypeAttachmentOptions.allowUserRename },
                    set: { isEnabled in
                        enablePrototypeOptionsIfNeeded()
                        prototypeAttachmentOptions.allowUserRename = isEnabled
                        if !isEnabled {
                            prototypeAttachmentOptions.customFilename = ""
                        }
                    }
                )
            )

            Toggle(
                "Display Filename",
                isOn: Binding(
                    get: { prototypeAttachmentOptions.displayFilename },
                    set: { newValue in
                        enablePrototypeOptionsIfNeeded()
                        prototypeAttachmentOptions.displayFilename = newValue
                    }
                )
            )
            Toggle(
                "Use Original Filename",
                isOn: Binding(
                    get: { prototypeAttachmentOptions.useOriginalFilename },
                    set: { newValue in
                        enablePrototypeOptionsIfNeeded()
                        prototypeAttachmentOptions.useOriginalFilename = newValue
                    }
                )
            )
            Toggle(
                "Enforce Attachment Count Limits",
                isOn: Binding(
                    get: { prototypeAttachmentOptions.enforceAttachmentCountLimits },
                    set: { newValue in
                        enablePrototypeOptionsIfNeeded()
                        prototypeAttachmentOptions.enforceAttachmentCountLimits = newValue
                    }
                )
            )

            if prototypeAttachmentOptions.enforceAttachmentCountLimits {
                Button("Min Attachment Count: \(prototypeAttachmentOptions.minAttachmentCount)") {
                    enablePrototypeOptionsIfNeeded()
                    prototypeAttachmentOptions.minAttachmentCount += 1
                }
                Button("Decrease Min Attachment Count") {
                    enablePrototypeOptionsIfNeeded()
                    if prototypeAttachmentOptions.minAttachmentCount > 0 {
                        prototypeAttachmentOptions.minAttachmentCount -= 1
                    }
                }
                .disabled(prototypeAttachmentOptions.minAttachmentCount == 0)

                Button("Max Attachment Count: \(prototypeAttachmentOptions.maxAttachmentCount)") {
                    enablePrototypeOptionsIfNeeded()
                    prototypeAttachmentOptions.maxAttachmentCount += 1
                }
                Button("Decrease Max Attachment Count") {
                    enablePrototypeOptionsIfNeeded()
                    if prototypeAttachmentOptions.maxAttachmentCount > 1 {
                        prototypeAttachmentOptions.maxAttachmentCount -= 1
                    }
                }
                .disabled(prototypeAttachmentOptions.maxAttachmentCount <= 1)
            }

            if let prototypeOptionsFormElement {
                Button("Test generateFilenameAsync()") {
                    Task {
                        do {
                            let name = try await prototypeOptionsFormElement.generateFilenameAsync()
                            generatedName = name
                            generationError = nil
                        } catch {
                            generatedName = nil
                            generationError = error.localizedDescription
                        }
                    }
                }

                if let generatedName {
                    Text("Generated: \(generatedName)")
                }
                if let generationError {
                    Text("Error: \(generationError)")
                }
            }
        }
        .menuActionDismissBehavior(.enabled)
    }

    private func enablePrototypeOptionsIfNeeded() {
        guard !prototypeAttachmentOptions.isEnabled else { return }
        if let prototypeAttachmentOptionDefaults {
            prototypeAttachmentOptions.apply(defaults: prototypeAttachmentOptionDefaults)
        }
        prototypeAttachmentOptions.isEnabled = true
    }
    
    /// A view representing a single cell in an `AttachmentPreview`.
    struct AttachmentCell: View  {
        /// The model representing the attachment to display.
        @ObservedObject var attachmentModel: AttachmentModel
        
        /// A Boolean value indicating whether the empty download alert is presented.
        @State private var emptyDownloadAlertIsPresented = false
        
        /// A Boolean value indicating if the attachment is loading.
        @State private var isLoading = false
        
        /// A Boolean value indicating whether the maximum size download alert is presented.
        @State private var maximumSizeDownloadExceededAlertIsPresented = false
        
        /// The url of the the attachment, used to display the attachment via `QuickLook`.
        @State private var url: URL?
        
        /// The maximum attachment download size limit.
        let attachmentDownloadSizeLimit: Measurement<UnitInformationStorage>
        
        /// The size of the cell.
        let cellSize: CGSize

        /// A Boolean value indicating whether attachment filenames are displayed.
        let displaysFilename: Bool
        
        var body: some View {
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
                                ThumbnailViewFooter(
                                    attachmentModel: attachmentModel,
                                    displaysFilename: displaysFilename,
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
            .onTapGesture {
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
            // On visionOS, quick look preview will close (sometimes it comes back) a sheet presenting
            // the feature form.
            // See thread here: https://developer.apple.com/forums/thread/773599
            .quickLookPreview($url)
            .alert(String.emptyAttachmentDownloadErrorMessage, isPresented: $emptyDownloadAlertIsPresented) { }
            .alert(maximumSizeDownloadExceededErrorMessage, isPresented: $maximumSizeDownloadExceededAlertIsPresented) { }
            .hoverEffect()
            .task(id: isLoading) {
                guard isLoading else { return }
                defer { isLoading = false }
                await attachmentModel.load()
            }
        }
    }
}

/// A view displaying details for popup media.
struct ThumbnailViewFooter: View {
    /// The popup media to display.
    @ObservedObject var attachmentModel: AttachmentModel

    /// A Boolean value indicating whether attachment filenames are displayed.
    let displaysFilename: Bool
    
    /// The size of the media's frame.
    let size: CGSize
    
    private var shouldShowFooter: Bool {
        displaysFilename && !attachmentModel.name.isEmpty
    }

    var body: some View {
        if shouldShowFooter {
            ZStack {
                let gradient = Gradient(colors: [.black, .black.opacity(0.15)])
                Rectangle()
                    .fill(.linearGradient(gradient, startPoint: .bottom, endPoint: .top))
                    .frame(height: size.height * 0.25)
                HStack {
                    Text(attachmentModel.name)
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

private extension AttachmentPreview.AttachmentCell {
    /// An error message explaining attachments larger than the provided maximum cannot be downloaded.
    var maximumSizeDownloadExceededErrorMessage: Text {
        .init(
            "Attachments larger than \(attachmentDownloadSizeLimit, format: .byteCount(style: .file)) cannot be downloaded.",
            bundle: .toolkitModule,
            comment: "An error message explaining attachments larger than the provided maximum cannot be downloaded."
        )
    }
}

private extension String {
    static var newName: Self {
        .init(
            localized: "New name",
            bundle: .toolkitModule,
            comment: "A label in reference to the new name of a file, shown in a file rename interface."
        )
    }
}
