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
    /// The attachment form element displaying the menu.
    private let element: AttachmentsFormElement
    
    /// Creates an `AttachmentImportMenu`
    /// - Parameter element: The attachment form element displaying the menu.
    /// - Parameter onAdd: The action to perform when an attachment is added.
    init(element: AttachmentsFormElement, onAdd: (@MainActor (FeatureAttachment) -> Void)? = nil) {
        self.element = element
        self.onAdd = onAdd
    }
    
    /// A Boolean value indicating whether the attachment camera controller is presented.
    @State private var cameraControllerIsPresented = false
    
    /// Performs camera authorization request handling.
    @State private var cameraRequester = CameraRequester()
    
    /// A Boolean value indicating whether the attachment file importer is presented.
    @State private var fileImporterIsPresented = false
    
    /// The current import state.
    @State private var importState: AttachmentImportState = .none
    
    /// A Boolean value indicating whether the microphone access alert is visible.
    @State private var microphoneAccessAlertIsPresented = false
    
    /// A Boolean value indicating whether the attachment photo picker is presented.
    @State private var photoPickerIsPresented = false
    
    /// <#Description#>
    @State private var selectedInput: _AttachmentsFormInput?
    
#warning("""
Prototype only. Do not merge to main. 
This will eventually be available on `element`.
""")
    @State private var inputs: [_AttachmentsFormInput] = [
        _AudioFormInput(),
        _DocumentFormInput(),
        _ImageFormInput(),
        _VideoFormInput()
    ]
    
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
    
    private func takeAudioButton(input: _AudioFormInput) -> some View {
        Button {
            selectedInput = input
        } label: {
            Text(takeAudioLabel)
            Image(systemName: "microphone.fill")
        }
        .disabled(true)
    }
    
    private func takePhotoButton(input: _ImageFormInput) -> some View {
        Button {
            if cameraRequester.authorizationStatus == .authorized {
                cameraControllerIsPresented = true
                selectedInput = input
            } else {
                cameraRequester.request()
            }
        } label: {
            Text(takePhotoLabel)
            Image(systemName: "camera.fill")
        }
        .disabled(isVision)
    }
    
    private func takeVideoButton(input: _VideoFormInput) -> some View {
        Button {
            if cameraRequester.authorizationStatus == .authorized {
                cameraControllerIsPresented = true
                selectedInput = input
            } else {
                cameraRequester.request()
            }
        } label: {
            Text(takeVideoLabel)
            Image(systemName: "video.fill")
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
    
    /// <#Description#>
    var allowedFileImporterTypes: [UTType] {
        var types = [UTType]()
        if inputs.contains(where: { $0 is _AudioFormInput }) {
            types.append(.audio)
        }
        if inputs.contains(where: { $0 is _DocumentFormInput }) {
            types.append(.item)
        }
        if inputs.contains(where: { $0 is _ImageFormInput }) {
            types.append(.image)
        }
        if inputs.contains(where: { $0 is _VideoFormInput }) {
            types.append(.video)
        }
        return types
    }
    
#warning("For testing only. Do not merge to main.")
    @State private var id = UUID()
    private func logInputs() {
        id = UUID()
        for input in inputs {
            print(input)
            switch input {
            case let audio as _AudioFormInput:
                print("\t", audio.inputMethod)
            case let image as _ImageFormInput:
                print("\t", image.inputMethod)
            case let video as _VideoFormInput:
                print("\t", video.inputMethod)
            default:
                break
            }
        }
        print("\n")
    }
    
    var body: some View {
        if importState.importInProgress {
            ProgressView()
                .progressViewStyle(.circular)
                .catalystPadding(5)
        }
        Menu {
            Group {
                if inputs.count >= 2 {
                    ForEach(inputs) { input in
                        switch input {
                        case let audioFormInput as _AudioFormInput:
                            takeAudioButton(input: audioFormInput)
                        case let imageFormInput as _ImageFormInput:
                            takePhotoButton(input: imageFormInput)
                        case let videoFormInput as _VideoFormInput:
                            takeVideoButton(input: videoFormInput)
                        default: EmptyView()
                        }
                    }
                    if inputs.contains(where: {$0 is _ImageFormInput || $0 is _VideoFormInput}) {
                        chooseFromLibraryButton()
                    }
                    chooseFromFilesButton()
                } else if let onlyInput = inputs.first {
                    switch onlyInput {
                    case let audioFormInput as _AudioFormInput:
                        switch audioFormInput.inputMethod {
                        case .any:
                            takeAudioButton(input: audioFormInput)
                            chooseFromFilesButton()
                        case .capture:
                            takeAudioButton(input: audioFormInput)
                        case .upload:
                            chooseFromFilesButton()
                        }
                    case is _DocumentFormInput:
                        chooseFromFilesButton()
                    case let imageFormInput as _ImageFormInput:
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
                    case let videoFormInput as _VideoFormInput:
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
            .id(id)
            
#warning("For testing only. Do not merge to main.")
            Section("Input Types") {
                Button("Audio") {
                    inputs.append(_AudioFormInput())
                }
                .disabled(inputs.contains(where: { $0 is _AudioFormInput }))
                Button("Document") {
                    inputs.append(_DocumentFormInput())
                }
                .disabled(inputs.contains(where: { $0 is _DocumentFormInput }))
                Button("Image") {
                    inputs.append(_ImageFormInput())
                }
                .disabled(inputs.contains(where: { $0 is _ImageFormInput }))
                Button("Video") {
                    inputs.append(_VideoFormInput())
                }
                .disabled(inputs.contains(where: { $0 is _VideoFormInput }))
                Button("🗑️ Remove All", role: .destructive) {
                    inputs.removeAll()
                }
                .disabled(inputs.isEmpty)
            }
            .menuActionDismissBehavior(.disabled)
            Section("Input Method") {
                if inputs.count == 1, let only = inputs.first {
                    switch only {
                    case let audioFormInput as _AudioFormInput:
                        Button("Any") { audioFormInput.inputMethod = .any; logInputs() }
                        Button("Capture") { audioFormInput.inputMethod = .capture; logInputs() }
                        Button("Upload") { audioFormInput.inputMethod = .upload; logInputs() }
                    case let imageFormInput as _ImageFormInput:
                        Button("Any") { imageFormInput.inputMethod = .any; logInputs() }
                        Button("Capture") { imageFormInput.inputMethod = .capture; logInputs() }
                        Button("Upload") { imageFormInput.inputMethod = .upload; logInputs() }
                    case let videoFormInput as _VideoFormInput:
                        Button("Any") { videoFormInput.inputMethod = .any; logInputs() }
                        Button("Capture") { videoFormInput.inputMethod = .capture; logInputs() }
                        Button("Upload") { videoFormInput.inputMethod = .upload; logInputs() }
                    default:
                        EmptyView()
                    }
                }
            }
            .menuActionDismissBehavior(.disabled)
            .onChange(of: inputs.count) { newValue in
                logInputs()
            }
        } label: {
            Text(
                "Add Attachment",
                bundle: .toolkitModule,
                comment: "A label for a button to add a new file attachment."
            )
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
        }
        .disabled(importState.importInProgress)
        .cameraRequester(cameraRequester)
        .alert(importFailureAlertTitle, isPresented: errorIsPresented) { } message: {
            Text(importFailureAlertMessage)
        }
        .onChange(of: cameraRequester.authorizationStatus) { _, status in
            if status == .authorized {
                cameraControllerIsPresented = true
            }
        }
#if targetEnvironment(macCatalyst)
        .menuStyle(.borderlessButton)
#endif
        .task(id: importState) {
            guard case let .finalizing(newAttachmentImportData) = importState else { return }
            
            if let data = newAttachmentImportData.data {
                let attachmentSize = Measurement(
                    value: Double(data.count),
                    unit: UnitInformationStorage.bytes
                )
                guard attachmentSize <= attachmentUploadSizeLimit else {
                    importState = .errored(.sizeLimitExceeded)
                    return
                }
                guard attachmentSize.value > .zero else {
                    importState = .errored(.emptyFilesNotSupported)
                    return
                }
            }
            
            let fileName: String
            if let presetFileName = newAttachmentImportData.fileName {
                fileName = presetFileName
            } else {
                do {
                    fileName = try await element.makeDefaultName(contentType: newAttachmentImportData.contentType)
                } catch {
                    fileName = "Unnamed Attachment"
                }
            }
            
            var newAttachment: FeatureAttachment? = nil
            if let url = newAttachmentImportData.filePath,
               url.startAccessingSecurityScopedResource() {
                newAttachment = try? await element.addAttachment(
                    named: fileName,
                    contentType: newAttachmentImportData.contentType,
                    fileURL: url
                )
                url.stopAccessingSecurityScopedResource()
            } else if let data = newAttachmentImportData.data {
                newAttachment = element.addAttachment(
                    name: fileName,
                    contentType: newAttachmentImportData.contentType,
                    data: data
                )
            }
            
            guard let newAttachment else {
                importState = .errored(.creationFailed)
                return
            }
            onAdd?(newAttachment)
            importState = .none
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
        .fullScreenCover(isPresented: $cameraControllerIsPresented) {
            if let selectedInput {
                AttachmentCameraController(
                    importState: $importState, isPresented: $cameraControllerIsPresented, input: selectedInput
                )
#if !targetEnvironment(macCatalyst) && !targetEnvironment(simulator)
                .onCameraCaptureModeChanged { captureMode in
                    if captureMode == .video && AVCaptureDevice.authorizationStatus(for: .audio) == .denied {
                        microphoneAccessAlertIsPresented = true
                    }
                }
#endif
                .alert(microphoneAccessWarningMessage, isPresented: $microphoneAccessAlertIsPresented) {
                    appSettingsButton
                    Button(role: .cancel) {} label: {
                        Text(recordVideoOnlyButtonLabel)
                    }
                }
            }
        }
#endif
        .modifier(
            AttachmentPhotoPicker(
                importState: $importState,
                photoPickerIsPresented: $photoPickerIsPresented,
                inputs: inputs
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
    
    /// A label for a button to capture new audio.
    var takeAudioLabel: String {
        .init(
            localized: "Record Audio",
            bundle: .toolkitModule,
            comment: "A label for a button to capture new audio."
        )
    }
    
    /// A label for a button to capture a new photo.
    var takePhotoLabel: String {
        .init(
            localized: "Take Photo",
            bundle: .toolkitModule,
            comment: "A label for a button to capture a new photo."
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
    var emptyFilesNotSupportedAlertMessage: String {
        .init(
            localized: "Empty files are not supported.",
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
    var genericImportFailureAlertMessage: String {
        .init(
            localized: "The selected attachment could not be imported.",
            bundle: .toolkitModule,
            comment: """
            A generic message for an alert that the selected file was not able
            to be imported as an attachment.
            """
        )
    }
    
    /// Returns a user facing error message for the present attachment import error.
    var importFailureAlertMessage: String {
        guard case .errored(let attachmentImportError) = importState else { return "" }
        return switch attachmentImportError {
        case .emptyFilesNotSupported:
            emptyFilesNotSupportedAlertMessage
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
    var sizeLimitExceededImportFailureAlertMessage: String {
        .init(
            localized: "The selected attachment exceeds the \(attachmentUploadSizeLimit.formatted()) limit.",
            bundle: .toolkitModule,
            comment: "An error message indicating the selected attachment exceeds the megabyte limit."
        )
    }
}

private extension AttachmentsFormElement {
    /// Creates a unique name for a new attachments with a file extension.
    /// - Parameter contentType: The kind of attachment to generate a name for.
    /// - Returns: A unique name for an attachment.
    func makeDefaultName(contentType: UTType) async throws -> String {
        let currentAttachments = try await attachments
        let root = (contentType.preferredMIMEType?.components(separatedBy: "/").first ?? "Attachment").capitalized
        var count = currentAttachments.filter { $0.contentType == contentType }.count
        var baseName: String
        repeat {
            count += 1
            baseName = "\(root)\(count)"
        } while( currentAttachments.filter { $0.name.deletingPathExtension == baseName }.count > 0 )
        if let fileExtension = contentType.preferredFilenameExtension {
            return "\(baseName).\(fileExtension)"
        } else {
            return baseName
        }
    }
}

private extension String {
    /// A filename with the extension removed.
    ///
    /// For example, "Photo.png" is returned as "Photo"
    var deletingPathExtension: String {
        (self as NSString).deletingPathExtension
    }
}

private extension URL {
    /// The type of data at the URL.
    var contentType: UTType? {
        UTType(filenameExtension: self.pathExtension)
    }
}
