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

internal import os

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
    @State private var cameraIsShowing = false
    
    /// A Boolean value indicating whether the attachment file importer is presented.
    @State private var fileImporterIsShowing = false
    
    /// The current import state.
    @State private var importState: AttachmentImportState = .none
    
    /// A Boolean value indicating whether the microphone access alert is visible.
    @State private var microphoneAccessAlertIsVisible = false
    
    /// A Boolean value indicating whether the attachment photo picker is presented.
    @State private var photoPickerIsPresented = false
    
    /// Performs camera authorization request handling.
    @StateObject private var cameraRequester = CameraRequester()
    
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
    
    @available(visionOS, unavailable)
    private func takePhotoOrVideoButton() -> Button<some View> {
        Button {
            Task {
                await cameraRequester.request {
                    cameraIsShowing = true
                } onAccessDenied: { }
            }
        } label: {
            Text(cameraButtonLabel)
            Image(systemName: "camera")
        }
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
            fileImporterIsShowing = true
        } label: {
            Text(filesButtonLabel)
            Image(systemName: "folder")
        }
    }
    
    var body: some View {
        if importState.importInProgress {
            ProgressView()
                .progressViewStyle(.circular)
                .catalystPadding(5)
        }
        Menu {
            // Show photo/video and library picker.
#if !os(visionOS)
            takePhotoOrVideoButton()
#endif
            chooseFromLibraryButton()
            // Always show file picker, no matter the input type.
            chooseFromFilesButton()
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .padding(5)
        }
        .disabled(importState.importInProgress)
        .cameraRequester(cameraRequester)
        .alert(importFailureAlertTitle, isPresented: errorIsPresented) { } message: {
            Text(importFailureAlertMessage)
        }
#if targetEnvironment(macCatalyst)
        .menuStyle(.borderlessButton)
#endif
        .task(id: importState) {
            guard case let .finalizing(newAttachmentImportData) = importState else { return }
            
            let attachmentSize = Measurement(
                value: Double(newAttachmentImportData.data.count),
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
            guard let newAttachment = element.addAttachment(
                name: fileName,
                contentType: newAttachmentImportData.contentType,
                data: newAttachmentImportData.data
            ) else {
                importState = .errored(.creationFailed)
                return
            }
            onAdd?(newAttachment)
            importState = .none
        }
        .fileImporter(isPresented: $fileImporterIsShowing, allowedContentTypes: [.item]) { result in
            importState = .importing
            switch result {
            case .success(let url):
                // gain access to the url resource and verify there's data.
                if url.startAccessingSecurityScopedResource(),
                   let contentType = url.contentType,
                   let data = FileManager.default.contents(atPath: url.path) {
                    importState = .finalizing(AttachmentImportData(contentType: contentType, data: data, fileName: url.lastPathComponent))
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
        .fullScreenCover(isPresented: $cameraIsShowing) {
            AttachmentCameraController(
                importState: $importState
            )
#if !targetEnvironment(macCatalyst) && !targetEnvironment(simulator)
            .onCameraCaptureModeChanged { captureMode in
                if captureMode == .video && AVCaptureDevice.authorizationStatus(for: .audio) == .denied {
                    microphoneAccessAlertIsVisible = true
                }
            }
#endif
            .alert(microphoneAccessWarningMessage, isPresented: $microphoneAccessAlertIsVisible) {
                appSettingsButton
                Button(role: .cancel) { } label: {
                    Text(recordVideoOnlyButtonLabel)
                }
            }
        }
#endif
        .modifier(
            AttachmentPhotoPicker(
                importState: $importState,
                photoPickerIsPresented: $photoPickerIsPresented
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
    
    /// A label for a button to capture a new photo or video.
    var cameraButtonLabel: String {
        .init(
            localized: "Take Photo or Video",
            bundle: .toolkitModule,
            comment: "A label for a button to capture a new photo or video."
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
