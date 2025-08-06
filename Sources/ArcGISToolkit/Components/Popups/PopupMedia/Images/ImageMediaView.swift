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
    
    var body: some View {
        if let sourceURL = popupMedia.value?.sourceURL {
            NavigationLink {
                ImageMediaDetailView(popupMedia: popupMedia)
            } label: {
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
                .hoverEffect()
            }
            .buttonStyle(.plain)
        }
    }
}

/// A view displaying an image media in a large format.
private struct ImageMediaDetailView: View {
    /// The popup media to display.
    let popupMedia: PopupMedia
    
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                if let linkURL = popupMedia.value?.linkURL {
                    UIApplication.shared.open(linkURL)
                }
            } label: {
                AsyncImageView(
                    url: popupMedia.value!.sourceURL!,
                    refreshInterval: popupMedia.imageRefreshInterval
                )
                .hoverEffect()
            }
            .buttonStyle(.plain)
            if popupMedia.value?.linkURL != nil {
                Text.tapInstruction
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .popupViewToolbar()
        .navigationTitle(popupMedia.title, subtitle: popupMedia.caption)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension Text {
    /// Localized text for the phrase "Tap on the image for more information.".
    static var tapInstruction: Self {
        .init(
            "Tap on the image for more information.",
            bundle: .toolkitModule,
            comment: "A label indicating that tapping an image will reveal additional information."
        )
    }
}
