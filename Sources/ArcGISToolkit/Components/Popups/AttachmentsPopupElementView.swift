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

// TODO: taking info from Ryan and come up with API for fetching attachment file urls
// TODO: update Visual Code tooling from README and generate stuff for all but attachments(?)
// TODO: look at notes and follow up
// TODO: look at prototype implementations and update if necessary
// TODO: Goal is to have all done on Monday (or at least all but attachments).

class AttachmentImage: ObservableObject, Identifiable {
    @Published var attachment: PopupAttachment
    @Published var image: UIImage?
    @Published var isLoaded = false
    var id = UUID()
    
    init(attachment: PopupAttachment, image: UIImage? = nil) {
        self.attachment = attachment
        self.image = image
    }
}

@MainActor
class AttachmentModel: ObservableObject {
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
    
    var body: some View {
        VStack(alignment: .leading) {
            PopupElementHeader(
                title: popupElement.title,
                description: popupElement.description
            )
            Spacer()
            if loadingAttachments {
                ProgressView()
            } else if popupElement.attachments.count == 0 {
                Text("No attachments.")
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
//            await withTaskGroup(of: AttachmentImage.self) { group in
//                for attachment in popupElement.attachments {
//                    group.addTask {
//                        if attachment.kind == .image {
//                            do {
//                                let image = try await attachment.makeFullImage()
//                                return (attachment, image)
//                            } catch {
//                                return (attachment, UIImage(systemName: "photo")!)
//                            }
//                        }
//                        else {
//                            return(attachment, UIImage(systemName: "doc")!)
//                        }
//                    }
//                }
//                for await pair in group {
//                    attachmentImages.append(pair)
//                }
//            }
            
            loadingAttachments = false
        }
    }
    
    struct AttachmentList: View {
        var attachmentImages: [AttachmentImage]
        @State var url: URL?
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(attachmentImages) { attachmentImage in
                    makeAttachmentView(for: attachmentImage)
                    .onTapGesture {
                        //QuickLook
                    }
                }
            }
        }
        
        func makeImage(for attachmentImage: AttachmentImage) -> Image  {
            switch attachmentImage.attachment.kind {
            case .image:
                if let image = attachmentImage.image {
                    return Image(uiImage: image)
                }
                else {
                    return Image(systemName: "photo")
                }
            case .video:
                return Image(systemName: "video")
            case .document, .other:
                return Image(systemName: "doc")
            }
        }
        
        @ViewBuilder func makeAttachmentView(for attachmentImage: AttachmentImage) -> some View  {
            HStack {
                HStack {
                    makeImage(for: attachmentImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                        .frame(width: 60, height: 40, alignment: .center)
                    VStack(alignment: .leading) {
                        Text(attachmentImage.attachment.name)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Text("\(attachmentImage.attachment.size.formatted(.byteCount(style: .file)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .onTapGesture {
                    if attachmentImage.attachment.loadStatus == .loaded {
                        url = attachmentImage.attachment.fileURL
                    }
                }
                .quickLookPreview($url)
                Button {
                    Task {
                        try await attachmentImage.attachment.load()
                        let image = try await attachmentImage.attachment.makeThumbnail(width: 60, height: 60)
                        attachmentImage.image = image
                    }
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .padding(.leading)
                }
                .opacity(showDownloadButton(attachmentImage) ? 1 : 0)
            }
        }

        func showDownloadButton(_ attachmentImage: AttachmentImage) -> Bool {
            print("loadStatus = \(attachmentImage.attachment.loadStatus)")
            if attachmentImage.attachment.kind == .image {
                return attachmentImage.image == nil
            } else {
                return attachmentImage.attachment.loadStatus != .loaded
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
                //                                    .clipShape(RoundedRectangle(cornerRadius: 8))
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

extension Attachment: Identifiable {}
