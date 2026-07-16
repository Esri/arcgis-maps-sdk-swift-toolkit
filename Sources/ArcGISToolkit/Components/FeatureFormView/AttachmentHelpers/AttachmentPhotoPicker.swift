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
import PhotosUI
import SwiftUI

extension View {
    /// Presents a Photos picker that selects a PhotosPickerItem from a given photo library.
    /// - Parameters:
    ///   - isPresented: The binding to whether the Photos picker should be shown.
    ///   - importState: The `AttachmentImportState` to provide the selection to.
    ///   - inputs: The attachment form inputs present in the element the picker is on.
    func attachmentPhotoPicker(
        isPresented: Binding<Bool>,
        importState: Binding<AttachmentImportState>,
        inputs: [AttachmentsFormInput]
    ) -> some View {
        modifier(
            AttachmentPhotoPicker(
                importState: importState,
                isPresented: isPresented,
                inputs: inputs
            )
        )
    }
}

/// A view that displays a Photos picker for choosing attachments from the photo library. The selected item is
/// written to the bound `AttachmentImportState`.
struct AttachmentPhotoPicker: ViewModifier {
    /// The current import state.
    @Binding var importState: AttachmentImportState
    /// A Boolean value indicating whether the photos picker is presented.
    @Binding var isPresented: Bool
    
    let inputs: [AttachmentsFormInput]
    
    /// The item selected in the photos picker.
    @State private var item: PhotosPickerItem?
    
    var filter: PHPickerFilter? {
        var inputFilters = [PHPickerFilter]()
        if inputs.contains(where: { $0 is ImageFormInput }) {
            inputFilters.append(.images)
        }
        if inputs.contains(where: { $0 is VideoFormInput }) {
            inputFilters.append(.videos)
        }
        if inputFilters.isEmpty { return nil }
        return .any(of: inputFilters)
    }
    
    func body(content: Content) -> some View {
        content
            .photosPicker(
                isPresented: $isPresented,
                selection: $item,
                matching: filter
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
                    importState = await .finalizing(.init(contentType: contentType, data: data))
                } catch {
                    importState = .errored(.system(error.localizedDescription))
                }
            }
    }
}
