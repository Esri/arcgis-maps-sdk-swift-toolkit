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

/// A view displaying image popup media.
struct ImageMediaView: View {
    /// The popup media to display.
    let popupMedia: PopupMedia
    
    /// The size of the media's frame.
    let mediaSize: CGSize
    
    /// A Boolean value specifying whether the media should be drawn in a larger format.
    @State private var isShowingDetalView = false
    private let cornerRadius: CGFloat = 8

    var body: some View {
        ZStack {
            if let sourceURL = popupMedia.value?.sourceURL {
                AsyncImageView(url: sourceURL, contentMode: .fill)
                    .onTapGesture {
                        isShowingDetalView = true
                    }
                    .frame(width: mediaSize.width, height: mediaSize.height)
            }
            VStack {
                Spacer()
                PopupMediaFooter(
                    popupMedia: popupMedia,
                    mediaSize: mediaSize
                )
            }
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(.gray, lineWidth: 1)
                .frame(width: mediaSize.width, height: mediaSize.height)
        }
        .frame(width: mediaSize.width, height: mediaSize.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .sheet(isPresented: $isShowingDetalView) {
            if popupMedia.value?.sourceURL != nil {
                MediaDetailView(
                    popupMedia: popupMedia,
                    isShowingDetalView: $isShowingDetalView
                )
                .padding()
            }
        }
    }
}
