// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS
import QuickLook

/// A view displaying an `AttachmentsPopupElement`.
struct AttachmentsPopupElementView: View {
    /// The `PopupElement` to display.
    var popupElement: AttachmentsPopupElement
    
    /// The model for the view.
    @StateObject private var viewModel: AttachmentsPopupElementModel
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    /// A Boolean value denoting if the view should be shown as regular width.
    var isRegularWidth: Bool {
        !(horizontalSizeClass == .compact && verticalSizeClass == .regular)
    }
    
    /// A Boolean value specifying whether the attachments are currently being loaded.
    @State var loadingAttachments = false
    
    /// Creates a new `AttachmentsPopupElementView`.
    /// - Parameter popupElement: The `AttachmentsPopupElement`.
    init(popupElement: AttachmentsPopupElement) {
        self.popupElement = popupElement
        _viewModel = StateObject(
            wrappedValue: AttachmentsPopupElementModel()
        )
    }
    
    var body: some View {
        Group {
            if loadingAttachments {
                ProgressView()
                    .padding()
            } else if popupElement.attachments.count > 0 {
                Divider()
                VStack(alignment: .leading) {
                    PopupElementHeader(
                        title: popupElement.title,
                        description: popupElement.description
                    )
                    Divider()
                    
                    switch popupElement.displayType {
                    case .list:
                        AttachmentList(attachmentModels: viewModel.attachmentModels)
                    case.preview:
                        AttachmentPreview(attachmentModels: viewModel.attachmentModels)
                    case .auto:
                        if isRegularWidth {
                            AttachmentPreview(attachmentModels: viewModel.attachmentModels)
                        } else {
                            AttachmentList(attachmentModels: viewModel.attachmentModels)
                        }
                    }
                }
            }
        }
        .task {
            loadingAttachments = true
            try? await popupElement.fetchAttachments()
            let attachmentModels = popupElement.attachments.map { attachment in
                AttachmentModel(attachment: attachment)
            }
            viewModel.attachmentModels.append(contentsOf: attachmentModels)
            loadingAttachments = false
        }
    }
}
