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
import AVFoundation
import SwiftUI
import UniformTypeIdentifiers

/// The context menu shown when the new attachment button is pressed.
struct AttachmentImportMenu: View {
    /// The current number of attachments the element has.
    private let currentAttachmentCount: Int
    /// The attachment form element displaying the menu.
    private let element: AttachmentsFormElement
    
    /// Creates an `AttachmentImportMenu`
    /// - Parameter currentAttachmentCount: The number of attachments the element currently has.
    /// - Parameter element: The attachment form element displaying the menu.
    /// - Parameter onAdd: The action to perform when an attachment is added.
    init(
        currentAttachmentCount: Int,
        element: AttachmentsFormElement,
        onAdd: (@MainActor (FeatureAttachment) -> Void)? = nil
    ) {
        self.currentAttachmentCount = currentAttachmentCount
        self.element = element
        self.onAdd = onAdd
    }
    
    /// Performs camera authorization request handling.
    @State private var cameraRequester = CameraRequester()
    
    /// The capture configuration to use with the attachments camera controller.
    @State private var captureConfiguration: AttachmentCameraController.Configuration?
    
    /// A Boolean value indicating whether the attachment file importer is presented.
    @State private var fileImporterIsPresented = false
    
    /// The current import state.
    @State private var importState: AttachmentImportState = .none
    
    /// A Boolean value indicating whether the microphone access alert is visible.
    @State private var microphoneAccessAlertIsPresented = false
    
    /// The capture configuration to use once camera permission has been authorized.
    @State private var pendingCaptureConfiguration: AttachmentCameraController.Configuration?
    
    /// A Boolean value indicating whether the attachment photo picker is presented.
    @State private var photoPickerIsPresented = false
    
#if os(visionOS)
    let isVision = true
#else
    let isVision = false
#endif
    
    /// The maximum attachment size limit.
    let attachmentUploadSizeLimit = Measurement(
        value: 999,
        unit: UnitInformationStorage.megabytes
    )
    
    /// The action to perform when an attachment is added.
    let onAdd: (@MainActor (FeatureAttachment) -> Void)?
    
    /// A Boolean value indicating if the error alert is presented.
    var errorIsPresented: Binding<Bool> {
        Binding {
            importState.isErrored
        } set: { newIsPresented in
            if !newIsPresented {
                importState = .none
            }
        }
    }
    
    private func takePhotoButton(input: ImageFormInput) -> some View {
        Button {
            pendingCaptureConfiguration = .init(allowedFormats: .image, movieMaxDuration: nil)
            if cameraRequester.authorizationStatus == .authorized {
                captureConfiguration = pendingCaptureConfiguration.take()
            } else {
                cameraRequester.request()
            }
        } label: {
            Text(takePhotoLabel)
            Image(systemName: "camera")
        }
        .disabled(isVision)
    }
    
    @available(visionOS, unavailable)
    private func takePhotoOrVideoButton(videoFormInput: VideoFormInput) -> Button<some View> {
        Button {
            pendingCaptureConfiguration = .init(
                allowedFormats: .imageAndMovie,
                movieMaxDuration: videoFormInput.maxDuration
            )
            if cameraRequester.authorizationStatus == .authorized {
                captureConfiguration = pendingCaptureConfiguration.take()
            } else {
                cameraRequester.request()
            }
        } label: {
            Text(takePhotoOrVideoLabel)
            Image(systemName: "camera")
        }
    }
    
    private func takeVideoButton(input: VideoFormInput) -> some View {
        Button {
            pendingCaptureConfiguration = .init(allowedFormats: .movie, movieMaxDuration: input.maxDuration)
            if cameraRequester.authorizationStatus == .authorized {
                captureConfiguration = pendingCaptureConfiguration.take()
            } else {
                cameraRequester.request()
            }
        } label: {
            Text(takeVideoLabel)
            Image(systemName: "video")
        }
        .disabled(isVision)
    }
    
    private func chooseFromLibraryButton() -> Button<some View> {
        Button {
            photoPickerIsPresented = true
        } label: {
            Text(libraryButtonLabel)
            Image(systemName: "photo")
        }
    }
    
    private func chooseFromFilesButton() -> Button<some View> {
        Button {
            fileImporterIsPresented = true
        } label: {
            Text(filesButtonLabel)
            Image(systemName: "folder")
        }
    }
    
    /// The list of allowed UTTypes based on the list of available inputs.
    ///
    /// - Note: `UTType.text` represents all text-encoded data, including text with markup and
    /// source code such as: .txt, .rtf, .html, .xml, .md, .csv, .tsv, .swift, or .js.
    private var allowedFileImporterTypes: [UTType] {
        var types = [UTType]()
        if element.inputs.contains(where: { $0 is AudioFormInput }) {
            types.append(.audio)
        }
        if element.inputs.contains(where: { $0 is DocumentFormInput }) {
            types.append(contentsOf: [
                .pdf, .zip, .text, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .`7z`
            ])
        }
        if element.inputs.contains(where: { $0 is ImageFormInput }) {
            types.append(.image)
        }
        if element.inputs.contains(where: { $0 is VideoFormInput }) {
            types.append(.video)
        }
        return types
    }
    
    /// A Boolean value indicating whether users can add more attachments.
    private var hasReachedMaximumAttachmentCount: Bool {
        guard let max = element.maxAttachmentCount else { return false }
        return currentAttachmentCount >= max
    }
    
    /// A Boolean value indicating whether the element is below its minimum attachment count.
    private var isBelowMinimumAttachmentCount: Bool {
        guard let min = element.minAttachmentCount else { return false }
        return currentAttachmentCount < min
    }
    
    var body: some View {
        if importState.importInProgress {
            ProgressView()
                .progressViewStyle(.circular)
                .catalystPadding(5)
        }
        if isBelowMinimumAttachmentCount, let minimum = element.minAttachmentCount {
            element.minAttachmentCountMessage
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        if hasReachedMaximumAttachmentCount, element.maxAttachmentCount != nil {
            element.maxAttachmentCountMessage
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            menu
        }
    }
    
    var menu: some View {
        Menu {
            Group {
                if element.inputs.count >= 2 {
                    if let _ = element.inputs.first(where: { $0 is ImageFormInput }),
                       let videoFormInput = element.inputs.first(where: { $0 is VideoFormInput }) as? VideoFormInput {
                        takePhotoOrVideoButton(videoFormInput: videoFormInput)
                    } else if let imageFormInput = element.inputs.first(where: { $0 is ImageFormInput }) as? ImageFormInput {
                        takePhotoButton(input: imageFormInput)
                    } else if let videoFormInput = element.inputs.first(where: { $0 is VideoFormInput }) as? VideoFormInput {
                        takeVideoButton(input: videoFormInput)
                    }
                    if element.inputs.contains(where: {$0 is ImageFormInput || $0 is VideoFormInput}) {
                        chooseFromLibraryButton()
                    }
                    chooseFromFilesButton()
                } else if let onlyInput = element.inputs.first {
                    switch onlyInput {
                    case let audioFormInput as AudioFormInput:
                        switch audioFormInput.inputMethod {
                        case .capture:
                            EmptyView()
                        default:
                            chooseFromFilesButton()
                        }
                    case is DocumentFormInput:
                        chooseFromFilesButton()
                    case let imageFormInput as ImageFormInput:
                        switch imageFormInput.inputMethod {
                        case .any:
                            takePhotoButton(input: imageFormInput)
                            chooseFromLibraryButton()
                            chooseFromFilesButton()
                        case .capture:
                            takePhotoButton(input: imageFormInput)
                        case .upload:
                            chooseFromLibraryButton()
                            chooseFromFilesButton()
                        }
                    case let videoFormInput as VideoFormInput:
                        switch videoFormInput.inputMethod {
                        case .any:
                            takeVideoButton(input: videoFormInput)
                            chooseFromLibraryButton()
                            chooseFromFilesButton()
                        case .capture:
                            takeVideoButton(input: videoFormInput)
                        case .upload:
                            chooseFromLibraryButton()
                            chooseFromFilesButton()
                        }
                    default:
                        EmptyView()
                    }
                }
            }
        } label: {
            Label {
                Text(
                    "Add Attachment",
                    bundle: .toolkitModule,
                    comment: "A label for a button to add a new file attachment."
                )
            } icon: {
                Image(systemName: "plus.circle.fill")
            }
        }
        .disabled(importState.importInProgress)
        .cameraRequester(cameraRequester)
        .alert(importFailureAlertTitle, isPresented: errorIsPresented) {} message: {
            importFailureAlertMessage
        }
        .onChange(of: cameraRequester.authorizationStatus) { _, status in
            if status == .authorized {
                captureConfiguration = pendingCaptureConfiguration.take()
            }
        }
#if targetEnvironment(macCatalyst)
        .menuStyle(.borderlessButton)
#endif
        .task(id: importState) {
            guard case let .finalizing(newAttachmentImportData) = importState else { return }
            
            let fileName: String
            if element.usesOriginalFilename,
               let originalName = newAttachmentImportData.fileName,
               !originalName.isEmpty {
                fileName = originalName
            } else {
                do {
                    fileName = try await element.generateFilenameAsync()
                } catch {
                    // Keep "Use Original Filename" meaningful even when generation fails.
                    if element.usesOriginalFilename,
                       let originalName = newAttachmentImportData.fileName,
                       !originalName.isEmpty {
                        fileName = originalName
                    } else {
                        fileName = "Attachment-\(UUID().uuidString.prefix(8))"
                    }
                }
            }
            
            let uploadResult: Result<FormAttachment, Error>
            if let url = newAttachmentImportData.filePath,
               url.startAccessingSecurityScopedResource() {
                uploadResult = await Result {
                    try await element.addAttachment(
                        contentType: newAttachmentImportData.contentType,
                        fileURL: url,
                        name: fileName
                    )
                }
                url.stopAccessingSecurityScopedResource()
            } else if let data = newAttachmentImportData.data {
                uploadResult = await Result {
                    try await element.addAttachment(
                        contentType: newAttachmentImportData.contentType,
                        data: data,
                        name: fileName
                    )
                }
            } else {
                uploadResult = .failure(AttachmentImportError.creationFailed)
            }
            
            switch uploadResult {
            case let .success(newAttachment):
                onAdd?(newAttachment)
                importState = .none
            case let .failure(error):
                if let featureFormError = error as? FeatureFormError {
                    importState = .errored(.featureFormError(featureFormError))
                } else {
                    importState = .errored(.creationFailed)
                }
                
                return
            }
        }
        .fileImporter(isPresented: $fileImporterIsPresented, allowedContentTypes: allowedFileImporterTypes) { result in
            importState = .importing
            switch result {
            case .success(let url):
                // gain access to the url resource.
                if url.startAccessingSecurityScopedResource(),
                   let contentType = url.contentType {
                    importState = .finalizing(AttachmentImportData(contentType: contentType, fileName: url.lastPathComponent, filePath: url))
                } else {
                    importState = .errored(.dataInaccessible)
                }
                
                // release access
                url.stopAccessingSecurityScopedResource()
            case .failure(let error):
                importState = .errored(.system(error.localizedDescription))
            }
        }
#if os(iOS)
        .fullScreenCover(item: $captureConfiguration) { _ in
            AttachmentCameraController(
                importState: $importState,
                configuration: $captureConfiguration
            )
#if !targetEnvironment(macCatalyst) && !targetEnvironment(simulator)
            .onCameraCaptureModeChanged { captureMode in
                if captureMode == .video && AVCaptureDevice.authorizationStatus(for: .audio) == .denied {
                    microphoneAccessAlertIsPresented = true
                }
            }
#endif // !targetEnvironment(macCatalyst) && !targetEnvironment(simulator)
            .alert(microphoneAccessWarningMessage, isPresented: $microphoneAccessAlertIsPresented) {
                appSettingsButton
                Button(role: .cancel) {} label: {
                    Text(recordVideoOnlyButtonLabel)
                }
            }
        }
#endif // os(iOS)
        .modifier(
            AttachmentPhotoPicker(
                importState: $importState,
                photoPickerIsPresented: $photoPickerIsPresented,
                inputs: element.inputs
            )
        )
    }
}

private extension AttachmentImportMenu {
    /// A button that redirects the user to the application's entry in the iOS system Settings application.
    var appSettingsButton: some View {
        Button(String.settings) {
            Task { await UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) }
        }
    }
    
    /// A label for a button to capture a new photo.
    var takePhotoLabel: String {
        .init(
            localized: "Take Photo",
            bundle: .toolkitModule,
            comment: "A label for a button to capture a new photo."
        )
    }
    
    /// A label for a button to capture a new photo or video.
    var takePhotoOrVideoLabel: String {
        .init(
            localized: "Take Photo or Video",
            bundle: .toolkitModule,
            comment: "A label for a button to capture a new photo or video."
        )
    }
    
    /// A label for a button to capture a new video.
    var takeVideoLabel: String {
        .init(
            localized: "Take Video",
            bundle: .toolkitModule,
            comment: "A label for a button to capture a new video."
        )
    }
    
    /// An error message indicating the selected attachment is an empty file and not supported.
    var emptyFilesNotSupportedAlertMessage: Text {
        .init(
            "Empty files are not supported.",
            bundle: .toolkitModule,
            comment: "An error message indicating the selected attachment is an empty file and not supported."
        )
    }
    
    /// A label for a button to choose an file from the user's files.
    var filesButtonLabel: String {
        .init(
            localized: "Choose From Files",
            bundle: .toolkitModule,
            comment: "A label for a button to choose an file from the user's files."
        )
    }
    
    /// A generic message for an alert that the selected file was not able to be imported as an attachment.
    var genericImportFailureAlertMessage: Text {
        .init(
            "The selected attachment could not be imported.",
            bundle: .toolkitModule,
            comment: """
            A generic message for an alert that the selected file was not able
            to be imported as an attachment.
            """
        )
    }
    
    /// Returns a user facing error message for the present attachment import error.
    var importFailureAlertMessage: Text {
        guard case .errored(let attachmentImportError) = importState else { return Text("") }
        return switch attachmentImportError {
        case .emptyFilesNotSupported:
            emptyFilesNotSupportedAlertMessage
        case .featureFormError(let featureFormError):
            switch featureFormError {
            case .exceedsMaximumAttachmentCount:
                element.maxAttachmentCountMessage ?? genericImportFailureAlertMessage
            case .exceedsMaximumAttachmentSize:
                element.maxFileSizeMessage ?? genericImportFailureAlertMessage
            case .incorrectAttachmentType:
                element.incorrectAttachmentTypeMessage
            case .exceedsMaximumAttachmentDuration:
                element.exceedsMaximumAttachmentDurationMessage ?? genericImportFailureAlertMessage
            @unknown default:
                genericImportFailureAlertMessage
            }
        case .sizeLimitExceeded:
            sizeLimitExceededImportFailureAlertMessage
        default:
            genericImportFailureAlertMessage
        }
    }
    
    /// A title for an alert that the selected file was not able to be imported as an attachment.
    var importFailureAlertTitle: String {
        .init(
            localized: "Error importing attachment",
            bundle: .toolkitModule,
            comment: """
            A title for an alert that the selected file was not able to be
            imported as an attachment.
            """
        )
    }
    
    /// A label for a button to choose a photo or video from the user's photo library.
    var libraryButtonLabel: String {
        .init(
            localized: "Choose From Library",
            bundle: .toolkitModule,
            comment: "A label for a button to choose a photo or video from the user's photo library."
        )
    }
    
    /// A warning message indicating microphone access has been disabled for the current application in the system settings.
    var microphoneAccessWarningMessage: String {
        .init(
            localized: "Microphone access has been disabled in Settings.",
            bundle: .toolkitModule,
            comment: "A warning message indicating microphone access has been disabled for the current application in the system settings."
        )
    }
    
    /// A button allowing users to proceed to record a video while acknowledging audio will not be captured.
    var recordVideoOnlyButtonLabel: String {
        .init(
            localized: "Record video only",
            bundle: .toolkitModule,
            comment: "A button allowing users to proceed to record a video while acknowledging audio will not be captured."
        )
    }
    
    /// An error message indicating the selected attachment exceeds the megabyte limit.
    var sizeLimitExceededImportFailureAlertMessage: Text {
        .init(
            "The selected attachment exceeds the \(attachmentUploadSizeLimit.formatted()) limit.",
            bundle: .toolkitModule,
            comment: "An error message indicating the selected attachment exceeds the megabyte limit."
        )
    }
}

private extension URL {
    /// The type of data at the URL.
    var contentType: UTType? {
        UTType(filenameExtension: self.pathExtension)
    }
}

private extension UTType {
    static var doc: Self { .init(filenameExtension: "doc")! }
    static var docx: Self { .init(filenameExtension: "docx")! }
    static var ppt: Self { .init(filenameExtension: "ppt")! }
    static var pptx: Self { .init(filenameExtension: "pptx")! }
    static var xls: Self { .init(filenameExtension: "xls")! }
    static var xlsx: Self { .init(filenameExtension: "xlsx")! }
    static var `7z`: Self { .init(filenameExtension: "7z")! }
}
