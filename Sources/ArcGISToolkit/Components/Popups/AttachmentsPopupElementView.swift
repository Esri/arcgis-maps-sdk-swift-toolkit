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

@MainActor class AttachmentImage: ObservableObject {
    @Published var attachment: PopupAttachment
    @Published var image: UIImage?
    @Published var loadStatus: LoadStatus = .notLoaded
    
    init(attachment: PopupAttachment, image: UIImage? = nil) {
        self.attachment = attachment
        self.image = image
    }
    
    func load() async throws {
        loadStatus = .loading
        try? await self.attachment.load()
        loadStatus = self.attachment.loadStatus
    }
}

extension AttachmentImage: Identifiable {}

extension AttachmentImage: Equatable {
    static func == (lhs: AttachmentImage, rhs: AttachmentImage) -> Bool {
        lhs.attachment === rhs.attachment &&
        lhs.image === rhs.image
    }
}

@MainActor class AttachmentModel: ObservableObject {
    @Published var attachmentImages = [AttachmentImage]()
}

struct AttachmentsPopupElementView: View {
    var popupElement: AttachmentsPopupElement
    @StateObject private var viewModel: AttachmentModel
    
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
            wrappedValue: AttachmentModel()
        )
    }
    
    // TODO: Move VStack into final else so that we won't show anything if there are no attachments?????
    var body: some View {
        VStack(alignment: .leading) {
            PopupElementHeader(
                title: popupElement.title,
                description: popupElement.description
            )
            Spacer()
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
                    AttachmentList(attachmentImages: viewModel.attachmentImages)
                case.preview:
                    AttachmentList(attachmentImages: viewModel.attachmentImages)
//                        AttachmentPreview(attachmentImages: viewModel.attachmentImages)
                case .auto:
                    if isRegularWidth {
                        AttachmentList(attachmentImages: viewModel.attachmentImages)
//                        AttachmentPreview(attachmentImages: viewModel.attachmentImages)
                    } else {
                        AttachmentList(attachmentImages: viewModel.attachmentImages)
                    }
                }
            }
        }
        .task {
            try? await popupElement.fetchAttachments()
            let attachmentImages = popupElement.attachments.map { attachment in
                AttachmentImage(attachment: attachment)
            }
            viewModel.attachmentImages.append(contentsOf: attachmentImages)
            loadingAttachments = false
        }
    }
    
    struct AttachmentList: View {
        var attachmentImages: [AttachmentImage]
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(attachmentImages) { attachmentImage in
                    AttachmentRow(attachmentImage: attachmentImage)
                    if attachmentImage != attachmentImages.last {
                        Divider()
                    }
                }
            }
        }
        
        struct ImageView: View  {
            @ObservedObject var attachmentImage: AttachmentImage
            
            // TODO: instead of this big block, pre-load attachmentImage.image with correct placeholder image
            //       which will get overwritten when the preview image loads.
            var body: some View {
                if let image = attachmentImage.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .padding(2)
                        .frame(width: 40, height: 40, alignment: .center)
                }
                else {
                    switch attachmentImage.attachment.kind {
                    case .image:
                        if let image = attachmentImage.image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                                .frame(width: 40, height: 40, alignment: .center)
                        }
                        else {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                                .frame(width: 40, height: 40, alignment: .center)
                        }
                    case .video:
                        Image(systemName: "video")
                            .resizable()
                            .foregroundColor(.accentColor)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                            .frame(width: 40, height: 40, alignment: .center)
                    case .document, .other:
                        Image(systemName: "doc")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                            .frame(width: 40, height: 30, alignment: .center)
                    }
                }
            }
        }
        
        struct AttachmentRow: View  {
            @ObservedObject var attachmentImage: AttachmentImage
            @State var url: URL?
            @Environment(\.displayScale) var displayScale

            var body: some View {
                HStack {
                    HStack {
                        ImageView(attachmentImage: attachmentImage)
                        VStack(alignment: .leading) {
                            Text(attachmentImage.attachment.name)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Text("\(attachmentImage.attachment.size.formatted(.byteCount(style: .file)))")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .onTapGesture {
                        if attachmentImage.attachment.loadStatus == .loaded {
                            url = attachmentImage.attachment.fileURL
                        }
                    }
                    .quickLookPreview($url)
                    if attachmentImage.loadStatus != .loaded {
                        Button {
                            Task {
                                // TODO: Move this into a separate function
                                try await attachmentImage.load()
                                
                                let request = QLThumbnailGenerator.Request(
                                    fileAt: attachmentImage.attachment.fileURL,
                                    size: CGSize(width: 40, height: 40),
                                    scale: displayScale,
                                    representationTypes: .thumbnail)
                                
                                // 2
                                let generator = QLThumbnailGenerator.shared
                                generator.generateRepresentations(for: request) { thumbnail, _, error in
                                    // 3
                                    Task {
                                        await MainActor.run {
                                            if let thumbnail = thumbnail {
                                                attachmentImage.image = thumbnail.uiImage
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            // TODO: Move this into a separate view
                            Group {
                                switch attachmentImage.loadStatus {
                                case .notLoaded:
                                    Image(systemName: "square.and.arrow.down")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                case .loading:
                                    ProgressView()
                                case .loaded:
                                    EmptyView()
                                case .failed:
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.red)
                                        .background(Color.clear)
                                        .frame(width: 24, height: 24)
                                }
                            }
                            .padding(.leading)
                        }
                    }
                }
            }
        }
    }
    
    struct AttachmentPreview: View {
        var attachmentImages: [AttachmentImage]
        
        var body: some View {
            VStack(alignment: .center) {
                //                ForEach(0..<attachments.count) { i in
                ////                ForEach(attachments) { attachment in
                //                    HStack {
                //                        Spacer()
                //                        VStack {
                //                            if i < images.count {
                //                                Image(uiImage: images[i])
                //                                    .resizable()
                //                                    .aspectRatio(contentMode: .fit)
                //                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                ////                                    .frame(width: 75, height: 75, alignment: .center)
                //                            }
                //                            Text(attachments[i].name)
                //                        }
                //                        Spacer()
                //                    }
                //                }
            }
        }
    }
}
