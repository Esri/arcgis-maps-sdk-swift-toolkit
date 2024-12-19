// Copyright 2023 Esri
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

import SwiftUI

/// A view shown at the top of a form. If the provided title is `nil`, no text is rendered.
struct FormHeader: View {
    @State private var formAssistantPhotoCaptureIsPresented = false
    
    @State private var formAssistantPhotoImportState: AttachmentImportState = .none
    
    @Binding var formAssistantPhoto: UIImage?
    
    /// The title defined for the form.
    let title: String
    
    var body: some View {
        HStack {
            WandButton {
                formAssistantPhotoCaptureIsPresented = true
            }
            .font(.title)
            .sheet(isPresented: $formAssistantPhotoCaptureIsPresented) {
                AttachmentCameraController(importState: $formAssistantPhotoImportState)
                    .edgesIgnoringSafeArea(.all)
            }
            Text(title)
                .font(.title)
                .fontWeight(.bold)
        }
        .onChange(formAssistantPhotoImportState) { newValue in
            guard case let .finalizing(newAttachmentImportData) = newValue else { return }
            formAssistantPhoto = UIImage(data: newAttachmentImportData.data)
        }
    }
}
