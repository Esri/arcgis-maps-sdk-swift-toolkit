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

import PhotosUI
import SwiftUI

/// A wrapper for the PhotosPicker API.
struct AttachmentPhotoPicker: ViewModifier {
    /// The item selected in the photos picker.
    @State private var item: PhotosPickerItem?
    
    /// The current import state.
    @Binding var importState: AttachmentImportState
    
    /// A Boolean value indicating whether the photos picker is presented.
    @Binding var photoPickerIsPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .photosPicker(
                isPresented: $photoPickerIsPresented,
                selection: $item,
                matching: .any(of: [
                    .images,
                    .videos
                ])
            )
            .task(id: item) {
                guard let item else { return }
                self.item = nil
                importState = .importing
                do {
                    guard let contentType = item.supportedContentTypes.first,
                          let data = try await item.loadTransferable(type: Data.self) else {
                        importState = .errored(.dataInaccessible)
                        return
                    }
                    importState = .finalizing(AttachmentImportData(contentType: contentType, data: data))
                } catch {
                    importState = .errored(.system(error.localizedDescription))
                }
            }
    }
}

extension PhotosPickerItem: @unchecked Swift.Sendable {}
