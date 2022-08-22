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
//                    AttachmentList(attachmentModels: viewModel.attachmentModels)
                    AttachmentPreview(attachmentModels: viewModel.attachmentModels)
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
    
    struct AttachmentList: View {
        var attachmentModels: [AttachmentModel]
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(attachmentModels) { attachmentModel in
                    AttachmentRow(attachmentModel: attachmentModel)
                    if attachmentModel != attachmentModels.last {
                        Divider()
                    }
                }
            }
        }
        
        struct AttachmentRow: View  {
            @ObservedObject var attachmentModel: AttachmentModel
            @State var url: URL?
            
            var body: some View {
                HStack {
                    HStack {
                        ThumbnailView(attachmentModel: attachmentModel)
                            .padding(2)
                        VStack(alignment: .leading) {
                            Text(attachmentModel.attachment.name)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Text("\(attachmentModel.attachment.size.formatted(.byteCount(style: .file)))")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .onTapGesture {
                        if attachmentModel.attachment.loadStatus == .loaded {
                            url = attachmentModel.attachment.fileURL
                        }
                    }
                    if attachmentModel.loadStatus != .loaded {
                        AttachmentLoadButton(attachmentModel: attachmentModel)
                    }
                }
                .quickLookPreview($url)
            }
        }
    }
    
    struct ThumbnailView: View  {
        @ObservedObject var attachmentModel: AttachmentModel
        var size: CGSize = CGSize(width: 40, height: 40)
        
        var body: some View {
            if let image = attachmentModel.thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .renderingMode(attachmentModel.usingDefaultImage ? .template : .original)
                    .aspectRatio(contentMode: attachmentModel.usingDefaultImage ? .fit : .fill)
                    .frame(width: size.width, height: size.height, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .foregroundColor(foregroundColor(for: attachmentModel))
            }
        }
        
        func foregroundColor(for attachmentModel: AttachmentModel) -> Color {
            attachmentModel.loadStatus == .failed ? .red :
            (attachmentModel.usingDefaultImage ? .accentColor : .primary)
        }
    }
    
    struct AttachmentLoadButton: View  {
        @ObservedObject var attachmentModel: AttachmentModel
        
        var body: some View {
            Button {
                if attachmentModel.loadStatus == .notLoaded {
                    attachmentModel.load()
                }
                else if attachmentModel.loadStatus == .failed {
                    // TODO:  Show error alert, similar to BasemapGallery.
                }
            } label: {
                Group {
                    switch attachmentModel.loadStatus {
                    case .notLoaded:
                        Image(systemName: "square.and.arrow.down")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
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
                    }
                }
                .frame(width: 24, height: 24)
                .padding(.leading)
            }
        }
    }
    
    struct AttachmentPreview: View {
        var attachmentModels: [AttachmentModel]
        
        var body: some View {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(attachmentModels) { attachmentModel in
                        AttachmentCell(attachmentModel: attachmentModel)
                    }
                }
            }
        }
        
        struct AttachmentCell: View  {
            @ObservedObject var attachmentModel: AttachmentModel
            @State var url: URL?
            
            var body: some View {
                VStack(alignment: .center) {
                    ZStack {
                        if attachmentModel.loadStatus != .loading {
                            ThumbnailView(
                                attachmentModel: attachmentModel,
                                size: attachmentModel.usingDefaultImage ?
                                CGSize(width: 40, height: 40) :
                                    CGSize(width: 120, height: 120)
                            )
                        } else {
                            ProgressView()
                                .padding(8)
                                .background(Color.white.opacity(0.75))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    if attachmentModel.usingDefaultImage {
                        Text(attachmentModel.attachment.name)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Text("\(attachmentModel.attachment.size.formatted(.byteCount(style: .file)))")
                            .foregroundColor(.secondary)
                    }
                }
                .font(.caption)
                .frame(width: 120, height: 120)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture {
                    if attachmentModel.attachment.loadStatus == .loaded {
                        url = attachmentModel.attachment.fileURL
                    }
                    else if attachmentModel.attachment.loadStatus == .notLoaded {
                        attachmentModel.load(thumbnailSize: CGSize(width: 120, height: 120))
                    }
                }
                .quickLookPreview($url)
            }
        }
    }
}
