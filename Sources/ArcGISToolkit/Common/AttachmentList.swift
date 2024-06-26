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
import SwiftUI

/// A view displaying a list of attachments, with a thumbnail, title, and download button.
struct AttachmentList: View {
    /// The attachment models displayed in the list.
    var attachmentModels: [AttachmentModel]
    
    var body: some View {
        ForEach(attachmentModels) { attachmentModel in
            AttachmentRow(attachmentModel: attachmentModel)
        }
    }
}

/// A view representing a single row in an `AttachmentList`.
struct AttachmentRow: View  {
    /// The model representing the attachment to display.
    @ObservedObject var attachmentModel: AttachmentModel
    
    /// The url of the the attachment, used to display the attachment via `QuickLook`.
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
                    Text(attachmentModel.attachment.measuredSize.formatted(.byteCount(style: .file)))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onTapGesture {
                if attachmentModel.attachment.loadStatus == .loaded {
                    // Set the url to trigger `.quickLookPreview`.
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

/// View displaying a button used to load an attachment.
struct AttachmentLoadButton: View  {
    @ObservedObject var attachmentModel: AttachmentModel
    
    var body: some View {
        Button {
            if attachmentModel.loadStatus == .notLoaded {
                attachmentModel.load()
            }
        } label: {
            Group {
                switch attachmentModel.loadStatus {
                case .notLoaded:
                    Image(systemName: "square.and.arrow.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.accentColor)
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
