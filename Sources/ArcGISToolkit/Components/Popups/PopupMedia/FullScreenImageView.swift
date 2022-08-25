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

/// A view displaying a popup media image in full screen.
struct FullScreenImageView: View {
    /// The popup media to display.
    let popupMedia: PopupMedia
    
    /// The sourceURL of the image media.
    let sourceURL: URL
    
    /// A Boolean value specifying whether the media should be shown full screen.
    @Binding var showingFullScreen: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showingFullScreen = false
                } label: {
                    Text("Done")
                        .fontWeight(.semibold)
                }
                .padding([.bottom], 4)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(popupMedia.title)
                        .font(.title2)
                    Text(popupMedia.caption)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            AsyncImageView(url: sourceURL)
                .onTapGesture {
                    if let url = popupMedia.value?.linkURL {
                        UIApplication.shared.open(url)
                    }
                }
            if popupMedia.value?.linkURL != nil {
                HStack {
                    Text("Tap on the image for more information.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            Spacer()
        }
    }
}
