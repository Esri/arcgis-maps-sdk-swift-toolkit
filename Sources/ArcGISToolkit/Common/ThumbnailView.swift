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

/// A view displaying a thumbnail image for an attachment.
@MainActor
@available(visionOS, unavailable)
struct ThumbnailView: View  {
    /// The model represented by the thumbnail.
    @ObservedObject var attachmentModel: AttachmentModel
    
    /// The display size of the thumbnail.
    var size: CGSize = CGSize(width: 36, height: 36)
    
    var body: some View {
        Group {
            if attachmentModel.usingSystemImage,
               let systemName = attachmentModel.systemImageName {
                Image(systemName: systemName)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .fontWeight(.light)
            } else if let image = attachmentModel.thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fill)
            }
        }
        .accessibilityIdentifier("\(attachmentModel.name) Thumbnail")
        .frame(width: size.width, height: size.height, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .contentShape(RoundedRectangle(cornerRadius: 4))
        .foregroundColor(foregroundColor(for: attachmentModel))
    }
    
    /// The foreground color of the thumbnail image.
    /// - Parameter attachmentModel: The model for the associated attachment.
    /// - Returns: A color to be used as the foreground color.
    func foregroundColor(for attachmentModel: AttachmentModel) -> Color {
        attachmentModel.loadStatus == .failed ? .red :
        (attachmentModel.usingSystemImage ? .gray : .primary)
    }
}
