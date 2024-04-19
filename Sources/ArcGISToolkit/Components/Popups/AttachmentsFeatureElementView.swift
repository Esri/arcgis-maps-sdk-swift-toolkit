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

/// A view displaying an `AttachmentsFeatureElementView`.
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
    
    @State private var attachmentLoadingState: AttachmentLoadingState = .notLoaded
    
    /// Creates a new `AttachmentsFeatureElementView`.
    /// - Parameter featureElement: The `AttachmentsFeatureElement`.
    init(featureElement: AttachmentsFeatureElement) {
        self.featureElement = featureElement
    }
    
    @State private var isExpanded: Bool = true

    /// A boolean which determines whether attachment editing controls are enabled.
    private var shouldEnableEditControls: Bool = false
    
    var body: some View {
        Group {
            switch attachmentLoadingState {
            case .notLoaded, .loading:
                ProgressView()
                    .padding()
            case .loaded(let attachmentModels):
                if shouldEnableEditControls {
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
            var attachments = (try? await featureElement.featureAttachments) ?? []
            print("attachment count: \(attachments.count)")
            
//            try? await addDemoAttachments()
//            
//            attachments = (try? await featureElement.attachments) ?? []
//            print("attachment count: \(attachments.count)")
            
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
    
    func onRename(attachment: FeatureAttachment, newAttachmentName: String) async throws -> Void {
        if let element = featureElement as? AttachmentFormElement,
           let attachment = attachment.formAttachment {
            try await element.renameAttachment(attachment, name: newAttachmentName)
        }
    }
    
    func onDelete(attachment: FeatureAttachment) async throws -> Void {
        if let element = featureElement as? AttachmentFormElement,
           let attachment = attachment.formAttachment {
            try await element.deleteAttachment(attachment)
        }
    }

    private func addDemoAttachments() async throws {
        do {
            let data = UIImage(named: "forest.jpg")!.jpegData(compressionQuality: 1.0)!
//            let data = UIImage(named: "forest.jpg")!.pngData()!
            print("data: \(data); size: \(data.count)")
//            arcgisFeature.addAttachment(withName: "Attachment.png", contentType: "png", data: data) { [weak self] (attachment:AGSAttachment?, error:Error?) -> Void in
//            
//            var url = URL(filePath: "/Users/mark1113_1/Development/PopupAttachmentTestFiles/forest.jpg")
//            let image = UIImage(contentsOfFile: url.absoluteString)
//            print("image = \(image)")
//            var data = try? Data(contentsOf: url)
            let attachment = try await (featureElement as? AttachmentFormElement)?.addAttachment(
                name: "forest",
                contentType: "image/jpg",
                data: data
            )
            print("added one attachment")
//            url = URL(filePath: "/Users/mark1113_1/Development/PopupAttachmentTestFiles/DeadLaptop.mov")
//            data = try? Data(contentsOf: url)
//            try await featureElement.attachmentFormElement?.addAttachment(
//                name: "Dead Laptop",
//                contentType: "quicktime",
//                data: data
//            )
//            print("added two attachment")
//            url = URL(filePath: "/Users/mark1113_1/Development/PopupAttachmentTestFiles/Barefoot Contessa | Emily's English Roasted Potatoes | Recipes.pdf")
//            data = try? Data(contentsOf: url)
//            try await featureElement.attachmentFormElement?.addAttachment(
//                name: "Emily's English Roasted Potatoes",
//                contentType: "pdf",
//                data: data
//            )
//            print("added three attachment")
//            url = URL(filePath: "/Users/mark1113_1/Development/PopupAttachmentTestFiles/sample3.mp3")
//            data = try? Data(contentsOf: url)
//            try await featureElement.attachmentFormElement?.addAttachment(
//                name: "sample3",
//                contentType: "mp3",
//                data: data
//            )
//            print("added four attachment")
        } catch {
            print("error adding attachment: \(error.localizedDescription)")
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
