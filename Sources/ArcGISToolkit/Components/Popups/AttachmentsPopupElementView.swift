// Copyright 2022 Esri
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
import ArcGIS
import QuickLook

/// A view displaying an `AttachmentsPopupElement`.
struct AttachmentsPopupElementView: View {
    /// The `PopupElement` to display.
    var popupElement: AttachmentsPopupElement
    
    @Environment(\.isPortraitOrientation) var isPortraitOrientation
    
    /// A Boolean value denoting if the view should be shown as regular width.
    var isRegularWidth: Bool {
        !isPortraitOrientation
    }
    
    /// The states of loading attachments.
    private enum AttachmentLoadingState {
        /// Attachments have not been loaded.
        case notLoaded
        /// Attachments are being loaded.
        case loading
        /// Attachments have been loaded.
        case loaded([AttachmentModel])
    }
    
    @State private var attachmentLoadingState: AttachmentLoadingState = .notLoaded
    
    /// Creates a new `AttachmentsPopupElementView`.
    /// - Parameter popupElement: The `AttachmentsPopupElement`.
    init(popupElement: AttachmentsPopupElement) {
        self.popupElement = popupElement
    }
    
    @State private var isExpanded: Bool = true
    
    var body: some View {
        Group {
            switch attachmentLoadingState {
            case .notLoaded, .loading:
                ProgressView()
                    .padding()
            case .loaded(let attachmentModels):
                if !attachmentModels.isEmpty {
                    DisclosureGroup(isExpanded: $isExpanded) {
                        switch popupElement.displayType {
                        case .list:
                            AttachmentList(attachmentModels: attachmentModels)
                        case .preview:
                            AttachmentPreview(attachmentModels: attachmentModels)
                        case .auto:
                            if isRegularWidth {
                                AttachmentPreview(attachmentModels: attachmentModels)
                            } else {
                                AttachmentList(attachmentModels: attachmentModels)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    } label: {
                        PopupElementHeader(
                            title: popupElement.displayTitle,
                            description: popupElement.description
                        )
                        .catalystPadding(4)
                    }
                }
            }
        }
        .task {
            guard case .notLoaded = attachmentLoadingState else { return }
            attachmentLoadingState = .loading
            let attachments = (try? await popupElement.attachments) ?? []
            let attachmentModels = attachments
                .reversed()
                .map { AttachmentModel(attachment: $0) }
            attachmentLoadingState = .loaded(attachmentModels)
        }
    }
}

private extension AttachmentsPopupElement {
    /// Provides a default title to display if `title` is empty.
    var displayTitle: String {
        title.isEmpty ? String(
            localized: "Attachments",
            bundle: .toolkitModule,
            comment: "A label in reference to attachments in a popup."
        ) : title
    }
}
