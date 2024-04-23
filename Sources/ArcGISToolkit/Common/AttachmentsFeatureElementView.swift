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
    var featureElement: AttachmentsFeatureElement
    
    @Environment(\.isPortraitOrientation) var isPortraitOrientation
    
    @Environment(\.displayScale) var displayScale
    
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
    
    /// The current load state of the attachments.
    @State private var attachmentLoadingState: AttachmentLoadingState = .notLoaded
    
    /// Creates a new `AttachmentsFeatureElementView`.
    /// - Parameter featureElement: The `AttachmentsFeatureElement`.
    init(featureElement: AttachmentsFeatureElement) {
        self.featureElement = featureElement
    }
    
    /// A Boolean value denoting whether the Disclosure Group is expanded.
    @State private var isExpanded: Bool = true

    /// A boolean which determines whether attachment editing controls are enabled.
    /// Note that editing controls are only applicable when the display type is Preview.
    private var shouldEnableEditControls: Bool = false
    
    var body: some View {
        Group {
            switch attachmentLoadingState {
            case .notLoaded, .loading:
                ProgressView()
                    .padding()
            case .loaded(let attachmentModels):
                if shouldEnableEditControls {
                    // If editing is enabled, don't show attachments in
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
        .task {
            guard case .notLoaded = attachmentLoadingState else { return }
            attachmentLoadingState = .loading
            let attachments = (try? await featureElement.featureAttachments) ?? []
            
            let attachmentModels = attachments
                .reversed()
                .map { AttachmentModel(attachment: $0, displayScale: displayScale) }
            attachmentLoadingState = .loaded(attachmentModels)
        }
    }
    
    @ViewBuilder private func attachmentBody(attachmentModels: [AttachmentModel]) -> some View {
        switch featureElement.attachmentDisplayType {
        case .list:
            AttachmentList(attachmentModels: attachmentModels)
        case .preview:
            AttachmentPreview(
                attachmentModels: attachmentModels,
                shouldEnableEditControls: shouldEnableEditControls,
                onRename: onRename,
                onDelete: onDelete
            )
        case .auto:
            Group {
                if isRegularWidth {
                    AttachmentPreview(
                        attachmentModels: attachmentModels,
                        shouldEnableEditControls: shouldEnableEditControls,
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
            if shouldEnableEditControls,
               let element = featureElement as? AttachmentFormElement {
                AttachmentImportMenu(element: element)
            }
        }
    }
    
    /// Renames the given attachment.
    /// - Parameters:
    ///   - attachment: The attachment to rename.
    ///   - newAttachmentName: The new attachment name.
    /// - Returns: Nothing.
    func onRename(attachment: FeatureAttachment, newAttachmentName: String) async throws -> Void {
        if let element = featureElement as? AttachmentFormElement,
           let attachment = attachment as? FormAttachment {
            try await element.renameAttachment(attachment, name: newAttachmentName)
        }
    }
    
    /// Deletes the given attachment.
    /// - Parameters:
    ///   - attachment: The attachment to delete.
    /// - Returns: Nothing.
    func onDelete(attachment: FeatureAttachment) async throws -> Void {
        if let element = featureElement as? AttachmentFormElement,
           let attachment = attachment as? FormAttachment {
            try await element.deleteAttachment(attachment)
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
    /// Controls if the attachment editing controls should be enabled.
    /// - Parameter newShouldShowEditControls: The new value.
    /// - Returns: The `AttachmentsFeatureElementView`.
    public func shouldEnableEditControls(_ newShouldEnableEditControls: Bool) -> Self {
        var copy = self
        copy.shouldEnableEditControls = newShouldEnableEditControls
        return copy
    }
}
