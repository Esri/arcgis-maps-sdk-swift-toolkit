// Copyright 2024 Esri
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

/// A view the displays a single attachment contained within an attachment form element.
struct AttachmentCarouselItem: View {
    /// The form element containing the attachment.
    var element: AttachmentFormElement
    
    /// The attachment represented by the item.
    var attachment: FormAttachment
    
    var body: some View {
        VStack {
            AttachmentCarouselItemThumbnail(element: element, formAttachment: attachment)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(Rectangle())
            Text(attachment.name)
                .lineLimit(1)
                .truncationMode(.middle)
                .font(.footnote)
            Text(attachment.size, format: .byteCount(style: .file))
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}
