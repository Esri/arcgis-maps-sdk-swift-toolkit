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
    
    /// The corner radius for the view.
    private let cornerRadius: CGFloat = 8
    
    /// A Boolean value specifying whether the media should be drawn in a larger format.
    @State private var isShowingDetailView = false
    
    var body: some View {
        if let sourceURL = popupMedia.value?.sourceURL {
            ZStack {
                AsyncImageView(
                    url: sourceURL,
                    contentMode: .fill,
                    refreshInterval: popupMedia.imageRefreshInterval,
                    mediaSize: mediaSize
                )
                    .frame(width: mediaSize.width, height: mediaSize.height)
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
            .clipShape(.rect(cornerRadius: cornerRadius))
            .onTapGesture {
                isShowingDetailView = true
            }
            .hoverEffect()
            .sheet(isPresented: $isShowingDetailView) {
                MediaDetailView(
                    popupMedia: popupMedia,
                    isShowingDetailView: $isShowingDetailView
                )
                .padding()
            }
        }
    }
}
