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
    /// - Parameters:
    ///   - currentAttachmentCount: The number of attachments the element currently has.
    ///   - element: The attachment form element displaying the menu.
    ///   - onAdd: The action to perform when an attachment is added.
    init(
        currentAttachmentCount: Int,
        element: AttachmentsFormElement,
        onAdd: (@MainActor (FeatureAttachment) -> Void)? = nil
    ) {
        self.currentAttachmentCount = currentAttachmentCount
        self.element = element
        self.onAdd = onAdd
    }
    
    /// The attachment customiztion options.
    @Environment(\.featureFormViewCustomization) var featureFormViewCustomization
    
    /// Performs camera authorization request handling.
    @State private var cameraRequester = CameraRequester()
    
#if os(iOS)
    /// The capture configuration to use with the attachments camera controller.
    @State private var captureConfiguration: AttachmentCameraController.Configuration?
    
    /// The capture configuration to use once camera permission has been authorized.
    @State private var pendingCaptureConfiguration: AttachmentCameraController.Configuration?
#endif // os(iOS)
    
    /// A Boolean value indicating whether the attachment file importer is presented.
    @State private var fileImporterIsPresented = false
    
    /// The current import state.
    @State private var importState: AttachmentImportState = .none
    
    /// A Boolean value indicating whether the microphone access alert is visible.
    @State private var microphoneAccessAlertIsPresented = false
    
    /// A Boolean value indicating whether the attachment photo picker is presented.
    @State private var photoPickerIsPresented = false
    
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
    
    @ViewBuilder
    private func takePhotoButton(input: ImageFormInput) -> some View {
#if os(iOS)
        Button {
            pendingCaptureConfiguration = .init(allowedFormats: .image, movieMaxDuration: nil)
            if cameraRequester.authorizationStatus == .authorized {
                captureConfiguration = pendingCaptureConfiguration.take()
            } else {
                cameraRequester.request()
            }
        } label: {
            Text(
                "Take Photo",
                bundle: .toolkitModule,
                comment: "A label for a button to capture a new photo."
            )
            Image(systemName: "camera")
        }
#endif // os(iOS)
    }
    
    @ViewBuilder
    private func takePhotoOrVideoButton(videoFormInput: VideoFormInput) -> some View {
#if os(iOS)
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
            Text(
                "Take Photo or Video",
                bundle: .toolkitModule,
                comment: "A label for a button to capture a new photo or video."
            )
            Image(systemName: "camera")
        }
#endif // os(iOS)
    }
    
    @ViewBuilder
    private func takeVideoButton(input: VideoFormInput) -> some View {
#if os(iOS)
        Button {
            pendingCaptureConfiguration = .init(allowedFormats: .movie, movieMaxDuration: input.maxDuration)
            if cameraRequester.authorizationStatus == .authorized {
                captureConfiguration = pendingCaptureConfiguration.take()
            } else {
                cameraRequester.request()
            }
        } label: {
            Text(
                "Take Video",
                bundle: .toolkitModule,
                comment: "A label for a button to capture a new video."
            )
            Image(systemName: "video")
        }
#endif // os(iOS)
    }
    
    private func choosePhotoButton() -> Button<some View> {
        Button {
            photoPickerIsPresented = true
        } label: {
            Text(
                "Choose Photo",
                bundle: .toolkitModule,
                comment: "A label for a button to choose a photo from the user's photo library."
            )
            Image(systemName: "photo.on.rectangle")
        }
    }
    
    private func choosePhotoOrVideoButton() -> Button<some View> {
        Button {
            photoPickerIsPresented = true
        } label: {
            Text(
                "Choose Photo or Video",
                bundle: .toolkitModule,
                comment: "A label for a button to choose a photo or video from the user's photo library."
            )
            Image(systemName: "photo.on.rectangle")
        }
    }
    
    private func chooseVideoButton() -> Button<some View> {
        Button {
            photoPickerIsPresented = true
        } label: {
            Text(
                "Choose Video",
                bundle: .toolkitModule,
                comment: "A label for a button to choose a video from the user's photo library."
            )
            Image(systemName: "photo.on.rectangle")
        }
    }
    
    private func attachFileButton() -> Button<some View> {
        Button {
            fileImporterIsPresented = true
        } label: {
            Text(
                "Attach File",
                bundle: .toolkitModule,
                comment: "A label for a button to choose a file from the user's files."
            )
            Image(systemName: "document")
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
    
    var body: some View {
        if importState.importInProgress {
            ProgressView()
                .progressViewStyle(.circular)
                .catalystPadding(5)
        }
        if let min = element.minAttachmentCount, currentAttachmentCount < min {
            element.minAttachmentCountMessage
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        if let max = element.maxAttachmentCount, currentAttachmentCount >= max {
            element.maxAttachmentCountMessage
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            menu
        }
    }
    
    var menu: some View {
        Menu {
            if element.inputs.count >= 2 {
                if element.inputs.contains(where: { $0 is ImageFormInput }),
                   let videoFormInput = element.inputs.first(where: { $0 is VideoFormInput }) as? VideoFormInput {
                    takePhotoOrVideoButton(videoFormInput: videoFormInput)
                    choosePhotoOrVideoButton()
                } else if let imageFormInput = element.inputs.first(where: { $0 is ImageFormInput }) as? ImageFormInput {
                    takePhotoButton(input: imageFormInput)
                    choosePhotoButton()
                } else if let videoFormInput = element.inputs.first(where: { $0 is VideoFormInput }) as? VideoFormInput {
                    takeVideoButton(input: videoFormInput)
                    chooseVideoButton()
                }
                attachFileButton()
            } else if let onlyInput = element.inputs.first {
                switch onlyInput {
                    case let audioFormInput as AudioFormInput:
                        switch audioFormInput.method {
                            case .capture:
                                EmptyView()
                            default:
                                attachFileButton()
                        }
                    case is DocumentFormInput:
                        attachFileButton()
                    case let imageFormInput as ImageFormInput:
                        switch imageFormInput.method {
                            case .any:
                                takePhotoButton(input: imageFormInput)
                                choosePhotoButton()
                                attachFileButton()
                            case .capture:
                                takePhotoButton(input: imageFormInput)
                            case .upload:
                                choosePhotoButton()
                                attachFileButton()
                            @unknown default:
                                EmptyView()
                        }
                    case let videoFormInput as VideoFormInput:
                        switch videoFormInput.method {
                            case .any:
                                takeVideoButton(input: videoFormInput)
                                chooseVideoButton()
                                attachFileButton()
                            case .capture:
                                takeVideoButton(input: videoFormInput)
                            case .upload:
                                chooseVideoButton()
                                attachFileButton()
                            @unknown default:
                                EmptyView()
                        }
                    default:
                        EmptyView()
                }
            }
            // On iOS simulators there is no reliable way to programmatically
            // close the menu so we provide an explicit Cancel button when testing.
            if CommandLine.arguments.contains("-testCase") {
                Button.cancel {}
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .disabled(importState.importInProgress)
        .cameraRequester(cameraRequester)
        .alert(importFailureAlertTitle, isPresented: errorIsPresented) {} message: {
            importFailureAlertMessage
        }
#if os(iOS)
        .onChange(of: cameraRequester.authorizationStatus) { _, status in
            if status == .authorized {
                captureConfiguration = pendingCaptureConfiguration.take()
            }
        }
#endif // os(iOS)
#if targetEnvironment(macCatalyst)
        .menuStyle(.borderlessButton)
#endif
        .task(id: importState) {
            guard case let .finalizing(newAttachmentImportData) = importState else { return }
            let uploadResult: Result<FormAttachment, Error>
            switch (newAttachmentImportData.fileName, newAttachmentImportData.data, newAttachmentImportData.filePath) {
                case let (.some(name), .some(data), .none):
                    var customizedData: Data?
                    if let customization = featureFormViewCustomization,
                        let result = customization.addAttachmentAction?(
                            newAttachmentImportData.contentType,
                            data,
                            nil
                        ) {
                        if result.0 != nil {
                            customizedData = result.0
                        }
                    }
                    let newData = customizedData
                    uploadResult = await Result {
                        try await element.addAttachment(
                            contentType: newAttachmentImportData.contentType,
                            data: newData ?? data,
                            name: name
                        )
                    }
                case let (.none, .some(data), .none):
                    var customizedData: Data?
                    if let customization = featureFormViewCustomization,
                       let result = customization.addAttachmentAction?(
                            newAttachmentImportData.contentType,
                            data,
                            nil
                       ) {
                        if result.0 != nil {
                            customizedData = result.0
                        }
                    }
                    let newData = customizedData
                    uploadResult = await Result {
                        try await element.addAttachment(
                            contentType: newAttachmentImportData.contentType,
                            data: newData ?? data
                        )
                    }
                case let (.some(name), .none, .some(path)):
                    _ = path.startAccessingSecurityScopedResource()
                    defer { path.stopAccessingSecurityScopedResource() }
                    var customizedPath: URL?
                    if let customization = featureFormViewCustomization,
                       let result = customization.addAttachmentAction?(
                            newAttachmentImportData.contentType,
                            nil,
                            path
                       ) {
                        if result.0 != nil {
                            customizedPath = result.1
                        }
                    }
                    let newPath = customizedPath ?? path
                    uploadResult = await Result {
                        try await element.addAttachment(contentType: newAttachmentImportData.contentType, fileURL: newPath, name: name)
                    }
                case let (.none, .none, .some(path)):
                    _ = path.startAccessingSecurityScopedResource()
                    defer { path.stopAccessingSecurityScopedResource() }
                    var customizedPath: URL?
                    if let customization = featureFormViewCustomization,
                       let result = customization.addAttachmentAction?(
                            newAttachmentImportData.contentType,
                            nil,
                            path
                       ) {
                        if result.0 != nil {
                            customizedPath = result.1
                        }
                    }
                    let newPath = customizedPath ?? path
                    uploadResult = await Result {
                        try await element.addAttachment(contentType: newAttachmentImportData.contentType, fileURL: newPath)
                    }
                default:
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
            }
        }
        .fileImporter(isPresented: $fileImporterIsPresented, allowedContentTypes: allowedFileImporterTypes) { result in
            importState = .importing
            switch result {
                case .success(let url):
                    if url.startAccessingSecurityScopedResource(),
                       let contentType = url.contentType {
                        importState = .finalizing(
                            .init(contentType: contentType, fileName: url.lastPathComponent, filePath: url)
                        )
                    } else {
                        importState = .errored(.dataInaccessible)
                    }
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
                    Text(
                        "Record video only",
                        bundle: .toolkitModule,
                        comment: "A button allowing users to proceed to record a video while acknowledging audio will not be captured."
                    )
                }
            }
        }
#endif // os(iOS)
        .attachmentPhotoPicker(
            isPresented: $photoPickerIsPresented,
            importState: $importState,
            inputs: element.inputs
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
    
    /// An error message indicating the selected attachment is an empty file and not supported.
    var emptyFilesNotSupportedAlertMessage: Text {
        .init(
            "Empty files are not supported.",
            bundle: .toolkitModule,
            comment: "An error message indicating the selected attachment is an empty file and not supported."
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
    var importFailureAlertMessage: Text? {
        guard case .errored(let attachmentImportError) = importState else { return nil }
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
                    default:
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
    
    /// A warning message indicating microphone access has been disabled for the current application in the system settings.
    var microphoneAccessWarningMessage: String {
        .init(
            localized: "Microphone access has been disabled in Settings.",
            bundle: .toolkitModule,
            comment: "A warning message indicating microphone access has been disabled for the current application in the system settings."
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
