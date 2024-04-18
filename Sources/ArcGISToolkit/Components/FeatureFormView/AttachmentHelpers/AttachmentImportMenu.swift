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

/// The popup menu shown when the new attachment button is pressed.
struct AttachmentImportMenu: View {
    private let element: AttachmentFormElement
    
    init(element: AttachmentFormElement) {
        self.element = element
    }
    
    /// A Boolean value indicating whether the attachment camera controller is presented.
    @State private var cameraIsShowing = false
    
    /// A Boolean value indicating whether the attachment file importer is presented.
    @State private var fileImporterIsShowing = false
    
    /// A Boolean value indicating whether the attachment photo picker is presented.
    @State private var photosPickerIsShowing = false
    
    /// The new attachment data retrieved from the photos picker.
    @State private var newAttachmentData: Data?
    
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
                photosPickerIsShowing = true
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
        .task(id: newAttachmentData) {
            guard let newAttachmentData else { return }
            do {
                _ = try await element.addAttachment(
                    name: "Attachment \(element.attachments.count + 1)",
                    contentType: "image/png",
                    data: newAttachmentData
                )
            } catch {
                print("Error adding attachment: \(error)")
            }
            self.newAttachmentData = nil
        }
        .task(id: capturedImage) {
            guard let capturedImage, let data = capturedImage.pngData() else { return }
            newAttachmentData = data
            self.capturedImage = nil
        }
        .fileImporter(isPresented: $fileImporterIsShowing, allowedContentTypes: [.item]) { result in
            switch result {
            case .success(let url):
                guard let data = FileManager.default.contents(atPath: url.path) else {
                    print("File picker data was empty")
                    return
                }
                newAttachmentData = data
            case .failure(let error):
                print("Error importing from file importer: \(error)")
            }
        }
        .fullScreenCover(isPresented: $cameraIsShowing) {
            AttachmentCameraController(capturedImage: $capturedImage)
        }
        .modifier(
            AttachmentPhotoPicker(
                newAttachmentData: $newAttachmentData,
                photoPickerIsShowing: $photosPickerIsShowing
            )
        )
    }
}
