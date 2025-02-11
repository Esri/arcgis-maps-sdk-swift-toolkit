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

/// A view displaying details for popup media.
struct PopupMediaFooter: View {
    /// The popup media to display.
    let popupMedia: PopupMedia
    
    /// The size of the media's frame.
    let mediaSize: CGSize
    
    var body: some View {
        ZStack {
            let gradient = Gradient(colors: [.black, .black.opacity(0.15)])
            Rectangle()
                .fill(.linearGradient(gradient, startPoint: .bottom, endPoint: .top))
                .frame(height: mediaSize.height * 0.25)
            HStack {
                VStack(alignment: .leading) {
                    if !popupMedia.title.isEmpty {
                        Text(popupMedia.title)
                            .foregroundStyle(.white)
                            .font(.body)
                    }
                    
                    if !popupMedia.caption.isEmpty {
                        Text(popupMedia.caption)
                            .font(.subheadline)
                            .foregroundStyle(Color(white: 0.75))
                    }
                }
                .lineLimit(1)
                Spacer()
            }
            .padding([.leading, .trailing], 12)
        }
    }
}
