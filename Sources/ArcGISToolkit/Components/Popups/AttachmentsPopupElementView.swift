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

// TODO: look at notes and follow up

// TODO: Add alert for when attachments fail to load...
// TODO: Move classes into separate file; maybe structs too.

struct AttachmentsPopupElementView: View {
    var popupElement: AttachmentsPopupElement
    @StateObject private var viewModel: AttachmentsPopupElementModel
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    /// A Boolean value denoting if the view should be shown as regular width.
    var isRegularWidth: Bool {
        !(horizontalSizeClass == .compact && verticalSizeClass == .regular)
    }
    
    @State var loadingAttachments = true
    
    init(popupElement: AttachmentsPopupElement) {
        self.popupElement = popupElement
        _viewModel = StateObject(
            wrappedValue: AttachmentsPopupElementModel()
        )
    }
    
    // TODO: Move VStack into final else so that we won't show anything if there are no attachments?????
    var body: some View {
        VStack(alignment: .leading) {
            PopupElementHeader(
                title: popupElement.title,
                description: popupElement.description
            )
            Divider()
            if loadingAttachments {
                ProgressView()
                    .padding()
            } else if popupElement.attachments.count == 0 {
                Text("No attachments.")
                    .padding()
            }
            else {
                switch popupElement.displayType {
                case .list:
                    AttachmentList(attachmentModels: viewModel.attachmentModels)
//                    AttachmentPreview(attachmentModels: viewModel.attachmentModels)
                case.preview:
//                    AttachmentList(attachmentModels: viewModel.attachmentModels)
                    AttachmentPreview(attachmentModels: viewModel.attachmentModels)
                case .auto:
                    if isRegularWidth {
//                        AttachmentList(attachmentModels: viewModel.attachmentModels)
                        AttachmentPreview(attachmentModels: viewModel.attachmentModels)
                    } else {
                        AttachmentList(attachmentModels: viewModel.attachmentModels)
                        AttachmentPreview(attachmentModels: viewModel.attachmentModels)
                    }
                }
            }
        }
        .task {
            try? await popupElement.fetchAttachments()
            let attachmentModels = popupElement.attachments.map { attachment in
                AttachmentModel(attachment: attachment)
            }
            viewModel.attachmentModels.append(contentsOf: attachmentModels)
            loadingAttachments = false
        }
    }
}
