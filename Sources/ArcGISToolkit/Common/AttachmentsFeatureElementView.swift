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

import ArcGIS
import QuickLook
import SwiftUI

/// A view displaying an `AttachmentsFeatureElement`.
struct AttachmentsFeatureElementView: View {
    /// The `AttachmentsFeatureElement` to display.
    let featureElement: AttachmentsFeatureElement
    
    @Environment(\.isPortraitOrientation) var isPortraitOrientation
    
    @Environment(\.displayScale) var displayScale
    
    /// The view model for a form.
    ///
    /// - Note: This property is only present when
    /// `featureElement` is an `AttachmentsFormElement`.
    @EnvironmentObject var formViewModel: FormViewModel
    
    /// A Boolean value indicating whether the input is editable.
    @State private var isEditable = false
    
    /// A Boolean value denoting if the view should be shown as regular width.
    var isRegularWidth: Bool {
        !isPortraitOrientation
    }
    
    /// The state of the attachment models.
    private enum AttachmentModelsState {
        /// Attachment models have not been initialized.
        case notInitialized
        /// Attachments are being fetched and wrapped with models.
        case initializing
        /// Attachments have been fetched and wrapped with models.
        case initialized([AttachmentModel])
    }
    
    /// The current state of the attachment models.
    @State private var attachmentModelsState: AttachmentModelsState = .notInitialized
    
    /// Creates a new `AttachmentsFeatureElementView`.
    /// - Parameter featureElement: The `AttachmentsFeatureElement`.
    init(featureElement: AttachmentsFeatureElement) {
        self.featureElement = featureElement
    }
    
    /// A Boolean value denoting whether the Disclosure Group is expanded.
    @State private var isExpanded = true
    
    var body: some View {
        Group {
            switch attachmentModelsState {
            case .notInitialized, .initializing:
                ProgressView()
                    .padding()
            case .initialized(let attachmentModels):
                if isShowingAttachmentsFormElement {
                    // If showing a form element, don't show attachments in
                    // a disclosure group, but also ALWAYS show
                    // the list of attachments, even if there are none.
                    attachmentHeader
                    attachmentBody(attachmentModels: attachmentModels)
                } else if !attachmentModels.isEmpty {
                    DisclosureGroup(isExpanded: $isExpanded) {
                        attachmentBody(attachmentModels: attachmentModels)
                    } label: {
                        attachmentHeader
                            .catalystPadding(4)
                    }
                }
            }
        }
        .onAttachmentIsEditableChange(of: featureElement) { newIsEditable in
            isEditable = newIsEditable
        }
        .task {
            guard case .notInitialized = attachmentModelsState else { return }
            attachmentModelsState = .initializing
            let attachments = (try? await featureElement.featureAttachments) ?? []
            
            var attachmentModels = attachments
                .map {
                    AttachmentModel(
                        attachment: $0,
                        displayScale: displayScale,
                        thumbnailSize: thumbnailSize
                    )
                }
            
            if !isShowingAttachmentsFormElement {
                // Reverse attachment models array if we're not displaying
                // via an AttachmentsFormElement.
                // This allows attachments in a non-editing context to
                // display in the same order as the online Map Viewer.
                attachmentModels = attachmentModels.reversed()
            }
            attachmentModelsState = .initialized(attachmentModels)
        }
    }
    
    @ViewBuilder private func attachmentBody(attachmentModels: [AttachmentModel]) -> some View {
        switch featureElement.attachmentsDisplayType {
        case .list:
            AttachmentList(attachmentModels: attachmentModels)
        case .preview:
            AttachmentPreview(
                attachmentModels: attachmentModels,
                editControlsDisabled: !isEditable,
                onRename: onRename,
                onDelete: onDelete
            )
        case .auto:
            Group {
                if isRegularWidth {
                    AttachmentPreview(
                        attachmentModels: attachmentModels,
                        editControlsDisabled: !isEditable,
                        onRename: onRename,
                        onDelete: onDelete
                    )
                } else {
                    AttachmentList(attachmentModels: attachmentModels)
                }
            }
        @unknown default:
            EmptyView()
        }
    }
    
    private var attachmentHeader: some View {
        HStack {
            PopupElementHeader(
                title: featureElement.displayTitle,
                description: featureElement.description
            )
            Spacer()
            if isEditable,
               let element = featureElement as? AttachmentsFormElement {
                AttachmentImportMenu(element: element)
            }
        }
    }
    
    /// Creates a model for the new attachment for display.
    /// - Parameter attachment: The added attachment.
    private func onAdd(attachment: FeatureAttachment) -> Void {
        guard case .initialized(var models) = attachmentModelsState else { return }
        let newModel = AttachmentModel(
            attachment: attachment,
            displayScale: displayScale,
            thumbnailSize: thumbnailSize
        )
        newModel.load()
        models.insert(newModel, at: 0)
        attachmentModelsState = .initialized(models)
    }
    
    /// Deletes the attachment model for the given attachment.
    /// - Parameter attachment: The deleted form attachment.
    private func onDelete(attachmentModel: AttachmentModel) -> Void {
        guard case .initialized(var models) = attachmentModelsState else { return }
        models.removeAll { $0.attachment as? FormAttachment === attachment }
        attachmentModelsState = .initialized(models)
    }
    
    /// Synchronizes the model for the renamed attachment.
    /// - Parameter attachment: The renamed form attachment.
    private func onRename(_ attachment: FormAttachment) -> Void {
        guard case .initialized(let models) = attachmentModelsState else { return }
        if let model = models.first(where: { $0.attachment as? FormAttachment === attachment }) {
            model.sync()
        }
    }
}

private extension AttachmentsFeatureElement {
    /// Provides a default title to display if `title` is empty.
    var displayTitle: String {
        title.isEmpty ? String(
            localized: "Attachments",
            bundle: .toolkitModule,
            comment: "A label in reference to attachments."
        ) : title
    }
}

extension AttachmentsFeatureElementView {
    /// The size of thumbnail images, based on the attachment display type
    /// and the current size class of the view.
    var thumbnailSize: CGSize {
        // Set thumbnail size
        let thumbnailSize: CGSize
        switch featureElement.attachmentsDisplayType {
        case .list:
            thumbnailSize = CGSize(width: 40, height: 40)
        case .preview:
            thumbnailSize = CGSize(width: 120, height: 120)
        case .auto:
            if isRegularWidth {
                thumbnailSize = CGSize(width: 120, height: 120)
            } else {
                thumbnailSize = CGSize(width: 40, height: 40)
            }
        @unknown default:
            thumbnailSize = CGSize(width: 120, height: 120)
        }
        return thumbnailSize
    }
    
    /// A Boolean value indicating whether the feature Element
    /// is an `AttachmentsFormElement`.
    var isShowingAttachmentsFormElement: Bool {
        featureElement is AttachmentsFormElement
    }
}

extension View {
    /// Modifier for watching `AttachmentsFormElement.isEditable`.
    /// - Parameters:
    ///   - element: The attachment form element to watch for changes on.
    ///   - action: The action which watches for changes.
    /// - Returns: The modified view.
    @ViewBuilder func onAttachmentIsEditableChange(
        of element: AttachmentsFeatureElement,
        action: @escaping (_ newIsEditable: Bool) -> Void
    ) -> some View {
        if let attachmentsFormElement = element as? AttachmentsFormElement {
            self
                .task(id: ObjectIdentifier(attachmentsFormElement)) {
                    for await isEditable in attachmentsFormElement.$isEditable {
                        action(isEditable)
                    }
                }
        } else {
            self
        }
    }
}
