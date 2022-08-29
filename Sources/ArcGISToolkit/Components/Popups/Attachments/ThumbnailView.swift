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

struct ThumbnailView: View  {
    @ObservedObject var attachmentModel: AttachmentModel
    var size: CGSize = CGSize(width: 36, height: 36)
    
    var body: some View {
        if let image = attachmentModel.thumbnail {
            Image(uiImage: image)
                .resizable()
                .renderingMode(attachmentModel.usingDefaultImage ? .template : .original)
                .aspectRatio(contentMode: attachmentModel.usingDefaultImage ? .fit : .fill)
                .frame(width: size.width, height: size.height, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .contentShape(RoundedRectangle(cornerRadius: 4))
                .foregroundColor(foregroundColor(for: attachmentModel))
        }
    }
    
    func foregroundColor(for attachmentModel: AttachmentModel) -> Color {
        attachmentModel.loadStatus == .failed ? .red :
        (attachmentModel.usingDefaultImage ? .accentColor : .primary)
    }
}
