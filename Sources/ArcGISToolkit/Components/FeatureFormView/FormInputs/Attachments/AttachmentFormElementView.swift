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

/// The view for an attachment form element.
///
/// A single attachment form element can contain multiple form attachments.
struct AttachmentFormElementView: View {
    /// The attachment form element represented by the view.
    @StateObject var element: AttachmentFormElement
    
    init(element: AttachmentFormElement) {
        _element = StateObject(wrappedValue: element)
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                InputHeader(label: element.label, isRequired: false)
                Text(element.description)
                    .font(.subheadline)
            }
            Spacer()
            AttachmentImportMenu(element: element)
        }
        ScrollView(.horizontal) {
            HStack {
                ForEach(element.attachments) { attachment in
                    AttachmentCarouselItem(element: element, attachment: attachment)
                }
            }
            .task {
                await element.fetchAttachments()
            }
        }
    }
}

extension FormAttachment: Identifiable {}

extension FormAttachment: Equatable {
    public static func == (lhs: FormAttachment, rhs: FormAttachment) -> Bool {
        lhs.attachment === rhs.attachment
    }
}
