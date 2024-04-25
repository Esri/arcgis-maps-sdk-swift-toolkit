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
    
    /// Data used to create the attachment.
    private struct AttachmentData: Equatable {
        var data: Data
        var contentType: String
        var fileName: String = ""
    }
    
    /// The attachment form element displaying the menu.
    private let element: AttachmentFormElement
    
    /// Creates an `AttachmentImportMenu`
    /// - Parameter element: The attachment form element displaying the menu.
    init(element: AttachmentFormElement) {
        self.element = element
    }
    
    /// A Boolean value indicating whether the attachment camera controller is presented.
    @State private var cameraIsShowing = false
    
    /// A Boolean value indicating whether the attachment file importer is presented.
    @State private var fileImporterIsShowing = false
    
    /// A Boolean value indicating whether the attachment photo picker is presented.
    @State private var photoPickerIsPresented = false
    
    /// The new image attachment data retrieved from the photos picker.
    @State private var newAttachmentData: AttachmentData?
    
    /// The new image attachment data retrieved from the photos picker.
    @State private var newImageData: Data?
    
    /// The new attachment retrieved from the device's camera.
    @State private var capturedImage: UIImage?
    
    var body: some View {
        Menu {
            Button {
                cameraIsShowing = true
            } label: {
                Label("Take photo", systemImage: "camera")
                    .labelStyle(.titleAndIcon)
            }
            Button {
                photoPickerIsPresented = true
            } label: {
                Label("Add photo from library", systemImage: "photo")
                    .labelStyle(.titleAndIcon)
            }
            Button {
                fileImporterIsShowing = true
            } label: {
                Label("Add photo from files", systemImage: "folder")
                    .labelStyle(.titleAndIcon)
            }
        } label: {
            Image(systemName: "plus")
                .font(.title2)
        }
#if targetEnvironment(macCatalyst)
        .menuStyle(.borderlessButton)
#endif
        .task(id: newAttachmentData) {
            guard let newAttachmentData else { return }
            do {
                var fileName: String
                if !newAttachmentData.fileName.isEmpty {
                    fileName = newAttachmentData.fileName
                } else {
                    // This is probably not good and should be re-thought.
                    // Look at how the `AGSPopupAttachmentsViewController` handles this
                    // https://devtopia.esri.com/runtime/cocoa/blob/b788189d3d2eb43b7da8f9cc9af18ed2f3aa6925/api/iOS/Popup/ViewController/AGSPopupAttachmentsViewController.m#L755
                    // and
                    // https://devtopia.esri.com/runtime/cocoa/blob/b788189d3d2eb43b7da8f9cc9af18ed2f3aa6925/api/iOS/Popup/ViewController/AGSPopupAttachmentsViewController.m#L725
                    fileName = "Attachment \(element.attachments.count + 1).\(newAttachmentData.contentType.split(separator: "/").last!)"
                }
                _ = try await element.addAttachment(
                    // Can this be better? What does legacy do?
                    name: fileName,
                    contentType: newAttachmentData.contentType,
                    data: newAttachmentData.data
                )
            } catch {
                // TODO: Figure out error handling
                print("Error adding attachment: \(error)")
            }
            self.newAttachmentData = nil
        }
        .task(id: capturedImage) {
            guard let capturedImage, let data = capturedImage.pngData() else { return }
            newAttachmentData = AttachmentData(data: data, contentType: "image/png")
            self.capturedImage = nil
        }
        .task(id: newImageData) {
            guard let newImageData else { return }
            newAttachmentData = AttachmentData(data: newImageData, contentType: "image/png")
        }
        .fileImporter(isPresented: $fileImporterIsShowing, allowedContentTypes: [.item]) { result in
            switch result {
            case .success(let url):
                guard let data = FileManager.default.contents(atPath: url.path) else {
                    print("File picker data was empty")
                    return
                }
                newAttachmentData = AttachmentData(
                    data: data,
                    contentType: url.mimeType(),
                    fileName: url.lastPathComponent
                )
            case .failure(let error):
                print("Error importing from file importer: \(error)")
            }
        }
        .fullScreenCover(isPresented: $cameraIsShowing) {
            AttachmentCameraController(capturedImage: $capturedImage)
        }
        .modifier(
            AttachmentPhotoPicker(
                newAttachmentData: $newImageData,
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
