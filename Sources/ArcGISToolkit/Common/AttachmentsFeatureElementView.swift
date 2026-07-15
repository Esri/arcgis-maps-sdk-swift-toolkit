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

internal import os

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
    private var embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel?
    
    /// Models for the attachments held by the element.
    @State private var attachmentModels: Result<[AttachmentModel], Error>?
    /// A Boolean value indicating whether the input is editable.
    @State private var isEditable = false
    /// A Boolean value denoting whether the Disclosure Group is expanded.
    @State private var isExpanded = true
    /// The last locally added attachment.
    @State private var lastAttachmentAdded: AttachmentModel?
    
    /// Creates a new `AttachmentsFeatureElementView` for a Feature Form.
    /// - Parameter formElement: The `AttachmentsFeatureElement`.
    /// - Parameter formViewModel: The model for the feature form containing the element.
    init(formElement: AttachmentsFormElement, formViewModel: EmbeddedFeatureFormViewModel) {
        self.featureElement = formElement
        self.embeddedFeatureFormViewModel = formViewModel
    }
    
    /// Creates a new `AttachmentsFeatureElementView` for a Popup.
    /// - Parameter popupElement: The `AttachmentsFeatureElement`.
    init(popupElement: AttachmentsPopupElement) {
        self.featureElement = popupElement
        self.embeddedFeatureFormViewModel = nil
    }
    
    var body: some View {
        switch attachmentModels {
        case .none:
            ProgressView()
                .padding()
                .onAppear(perform: loadAttachments)
        case .success(let models):
            if let formElement {
                Group {
                    if models.isEmpty {
                        Text(
                            "No attachments",
                            bundle: .toolkitModule,
                            comment: """
                                A label indicating an element
                                contains no file attachments.
                                """
                        )
                    } else {
                        attachmentBody(attachmentModels: models)
                    }
                    if isEditable {
                        AttachmentImportMenu(
                            currentAttachmentCount: models.count,
                            element: formElement,
                            onAdd: onAdd
                        )
                    }
                }
                .onAttachmentIsEditableChange(of: formElement) { newIsEditable in
                    isEditable = newIsEditable
                }
            } else if !models.isEmpty {
                DisclosureGroup(isExpanded: $isExpanded) {
                    attachmentBody(attachmentModels: models)
                } label: {
                    PopupElementHeader(
                        title: featureElement.displayTitle,
                        description: featureElement.description
                    )
                    .catalystPadding(4)
                }
                .disclosureGroupPadding()
            }
        case .failure(_):
            Text(
                "Attachments failed to load.",
                bundle: .toolkitModule,
                comment: "The status text when attachments failed to load."
            )
        }
    }
    
    @ViewBuilder private func attachmentBody(attachmentModels: [AttachmentModel]) -> some View {
        switch featureElement.attachmentsDisplayType {
        case .list:
            AttachmentList(
                attachmentModels: attachmentModels
            )
        case .preview:
            AttachmentPreview(
                allowsRenamingByUser: allowsRenamingByUser,
                attachmentModels: attachmentModels,
                displaysFilename: displaysFilename,
                editControlsDisabled: !isEditable,
                lastAttachmentAdded: lastAttachmentAdded,
                onRename: onRename,
                onDelete: onDelete,
                proposedCellSize: thumbnailSize
            )
        case .auto:
            if isRegularWidth {
                AttachmentPreview(
                    allowsRenamingByUser: allowsRenamingByUser,
                    attachmentModels: attachmentModels,
                    displaysFilename: displaysFilename,
                    editControlsDisabled: !isEditable,
                    lastAttachmentAdded: lastAttachmentAdded,
                    onRename: onRename,
                    onDelete: onDelete,
                    proposedCellSize: thumbnailSize
                )
            } else {
                AttachmentList(
                    attachmentModels: attachmentModels
                )
            }
        }
    }
    
    /// Loads the attachments associated with this element.
    private func loadAttachments() {
        // Use an unstructured task to prevent cancellation from view-shift.
        // This can happen, for example, in FeatureFormView when the visibility
        // of other elements is resolved during loading and the attachments
        // element is pushed down below the fold.
        Task {
            do {
                let attachments = try await featureElement.featureAttachments
                let attachmentModels = attachments
                    .reversed()
                    .map {
                        AttachmentModel(
                            attachment: $0,
                            displayScale: displayScale,
                            thumbnailSize: thumbnailSize
                        )
                    }
                self.attachmentModels = .success(attachmentModels)
            } catch {
                Logger.attachmentsFeatureElementView.error(
                    "Attachments failed load. \(error.localizedDescription)"
                )
                attachmentModels = .failure(error)
            }
        }
    }
    
    /// Creates a model for the new attachment for display.
    /// - Parameter attachment: The added attachment.
    func onAdd(attachment: FeatureAttachment) -> Void {
        guard case .success(var models) = attachmentModels else { return }
        let newModel = AttachmentModel(
            attachment: attachment,
            displayScale: displayScale,
            thumbnailSize: thumbnailSize
        )
        models.insert(newModel, at: 0)
        withAnimation { attachmentModels = .success(models) }
        embeddedFeatureFormViewModel?.focusedElement = formElement
        embeddedFeatureFormViewModel?.evaluateExpressions()
        lastAttachmentAdded = newModel
    }
    
    /// Renames the attachment associated with the given model.
    /// - Parameters:
    ///   - attachmentModel: The model for the attachment to rename.
    ///   - newAttachmentName: The new attachment name.
    func onRename(attachmentModel: AttachmentModel, newAttachmentName: String) -> Void {
        if !allowsRenamingByUser {
            return
        }
        if let attachment = attachmentModel.attachment as? FormAttachment {
            attachment.name = newAttachmentName
            withAnimation { attachmentModel.sync() }
            embeddedFeatureFormViewModel?.focusedElement = formElement
            embeddedFeatureFormViewModel?.evaluateExpressions()
        }
    }
    
    /// Deletes the attachment associated with the given model.
    /// - Parameters:
    ///   - attachmentModel: The model for the attachment to delete.
    func onDelete(attachmentModel: AttachmentModel) -> Void {
        if let formElement, let attachment = attachmentModel.attachment as? FormAttachment {
            formElement.delete(attachment)
            guard case .success(var models) = attachmentModels else { return }
            models.removeAll { $0 === attachmentModel }
            withAnimation { attachmentModels = .success(models) }
            embeddedFeatureFormViewModel?.focusedElement = formElement
            embeddedFeatureFormViewModel?.evaluateExpressions()
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
    private var thumbnailSize: CGSize {
        switch featureElement.attachmentsDisplayType {
        case .list:
            CGSize(width: 40, height: 40)
        case .preview:
            CGSize(width: 120, height: 120)
        case .auto:
            if isRegularWidth {
                CGSize(width: 120, height: 120)
            } else {
                CGSize(width: 40, height: 40)
            }
        }
    }
    
    /// The model's element as an attachments form element.
    private var formElement: AttachmentsFormElement? {
        featureElement as? AttachmentsFormElement
    }
    
    /// A Boolean value indicating whether attachment filenames should be shown.
    private var displaysFilename: Bool {
        formElement?.displaysFilename ?? true
    }
    
    /// A Boolean value indicating whether users can rename attachments.
    private var allowsRenamingByUser: Bool {
        formElement?.allowsRenamingByUser ?? true
    }
    
    /// A Boolean value denoting if the view should be shown as regular width.
    private var isRegularWidth: Bool { !isPortraitOrientation }
}

extension View {
    /// Modifier for watching `AttachmentsFormElement.isEditable`.
    /// - Parameters:
    ///   - element: The attachment form element to watch for changes on.
    ///   - action: The action which watches for changes.
    /// - Returns: The modified view.
    @ViewBuilder
    func onAttachmentIsEditableChange(
        of element: AttachmentsFormElement,
        action: @escaping (_ newIsEditable: Bool) -> Void
    ) -> some View {
        self
            .task(id: ObjectIdentifier(element)) {
                for await isEditable in element.$isEditable {
                    action(isEditable)
                }
            }
    }
}
