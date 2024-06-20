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
import OSLog
import SwiftUI
import UniformTypeIdentifiers

/// The context menu shown when the new attachment button is pressed.
struct AttachmentImportMenu: View {
    
    /// The attachment form element displaying the menu.
    private let element: AttachmentsFormElement
    
    /// Creates an `AttachmentImportMenu`
    /// - Parameter element: The attachment form element displaying the menu.
    /// - Parameter onAdd: The action to perform when an attachment is added.
    init(element: AttachmentsFormElement, onAdd: ((FeatureAttachment) -> Void)? = nil) {
        self.element = element
        self.onAdd = onAdd
    }
    
    /// A Boolean value indicating whether the attachment camera controller is presented.
    @State private var cameraIsShowing = false
    
    /// A Boolean value indicating whether the attachment file importer is presented.
    @State private var fileImporterIsShowing = false
    
    /// The current import state.
    @State private var importState: AttachmentImportState = .none
    
    /// A Boolean value indicating whether the attachment photo picker is presented.
    @State private var photoPickerIsPresented = false
    
    /// The maximum attachment size limit.
    let attachmentSizeLimit = Measurement(
        value: 50,
        unit: UnitInformationStorage.megabytes
    )
    
    /// The action to perform when an attachment is added.
    let onAdd: ((FeatureAttachment) -> Void)?
    
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
    
    private func takePhotoOrVideoButton() -> Button<some View> {
       Button {
            cameraIsShowing = true
        } label: {
            Label {
                Text(cameraButtonLabel)
            } icon: {
                Image(systemName: "camera")
            }
            .labelStyle(.titleAndIcon)
        }
    }
    
    private func chooseFromLibraryButton() -> Button<some View> {
       Button {
            photoPickerIsPresented = true
        } label: {
            Label {
                Text(libraryButtonLabel)
            } icon: {
                Image(systemName: "photo")
            }
            .labelStyle(.titleAndIcon)
        }
    }
    
    private func chooseFromFilesButton() -> Button<some View> {
       Button {
            fileImporterIsShowing = true
        } label: {
            Label {
                Text(filesButtonLabel)
            } icon: {
                Image(systemName: "folder")
            }
            .labelStyle(.titleAndIcon)
        }
    }
    
    var body: some View {
        if importState.importInProgress {
            ProgressView()
                .progressViewStyle(.circular)
        }
        Menu {
            // Show photo/video and library picker.
            takePhotoOrVideoButton()
            chooseFromLibraryButton()
            // Always show file picker, no matter the input type.
            chooseFromFilesButton()
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .padding(5)
        }
        .disabled(importState.importInProgress)
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
            guard attachmentSize <= attachmentSizeLimit else {
                importState = .errored(.sizeLimitExceeded)
                return
            }
            
            defer { importState = .none }
            let fileName: String
            if let presetFileName = newAttachmentImportData.fileName {
                fileName = presetFileName
            } else {
                let attachmentNumber = element.attachments.count + 1
                if let fileExtension = newAttachmentImportData.fileExtension {
                    fileName = "Attachment \(attachmentNumber).\(fileExtension)"
                } else {
                    fileName = "Attachment \(attachmentNumber)"
                }
            }
            let newAttachment = element.addAttachment(
                // Can this be better? What does legacy do?
                name: fileName,
                contentType: newAttachmentImportData.contentType,
                data: newAttachmentImportData.data
            )
            onAdd?(newAttachment)
        }
        .fileImporter(isPresented: $fileImporterIsShowing, allowedContentTypes: [.item]) { result in
            importState = .importing
            switch result {
            case .success(let url):
                // gain access to the url resource and verify there's data.
                if url.startAccessingSecurityScopedResource(),
                   let data = FileManager.default.contents(atPath: url.path) {
                    importState = .finalizing(
                        AttachmentImportData(
                            data: data,
                            contentType: url.mimeType(),
                            fileName: url.lastPathComponent
                        )
                    )
                } else {
                    importState = .errored(.dataInaccessible)
                }
                
                // release access
                url.stopAccessingSecurityScopedResource()
            case .failure(let error):
                importState = .errored(.system(error.localizedDescription))
            }
        }
        .fullScreenCover(isPresented: $cameraIsShowing) {
            AttachmentCameraController(
                importState: $importState
            )
        }
        .modifier(
            AttachmentPhotoPicker(
                importState: $importState,
                photoPickerIsPresented: $photoPickerIsPresented
            )
        )
    }
}

extension URL {
    /// The Mime type based on the path extension.
    /// - Returns: The Mime type string.
    public func mimeType() -> String {
        if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
}

private extension AttachmentImportMenu {
    /// A label for a button to capture a new photo or video.
    var cameraButtonLabel: String {
        .init(
            localized: "Take Photo or Video",
            bundle: .toolkitModule,
            comment: "A label for a button to capture a new photo or video."
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
    
    /// An error message indicated the selected attachment exceeds the megabyte limit.
    var sizeLimitExceededImportFailureAlertMessage: String {
        .init(
            localized: "The selected attachment exceeds the \(attachmentSizeLimit.formatted()) limit.",
            bundle: .toolkitModule,
            comment: "An error message indicated the selected attachment exceeds the megabyte limit."
        )
    }
}
