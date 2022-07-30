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
    
    /// A Boolean value specifying whether the media should be shown full screen.
    @State private var showingFullScreen = false
    
    var body: some View {
        VStack {
            if let sourceURL = popupMedia.value?.sourceURL {
                AsyncImage(url: sourceURL) { phase in
                    if let image = phase.image {
                        // Display the loaded image.
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if phase.error != nil {
                        // Display an error message.
                        HStack {
                            Image(systemName: "exclamationmark.circle")
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.red)
                            Text("An error occurred loading the image.")
                        }
                    } else {
                        // Display a placeholder while the image is loading.
                        ProgressView()
                    }
                }
                .onTapGesture {
                    showingFullScreen = true
                }
                .padding()
            }
            HStack {
                PopupMediaFooter(popupMedia: popupMedia)
                Spacer()
            }
        }
        .sheet(isPresented: $showingFullScreen) {
            if let url = popupMedia.value?.sourceURL {
                FullScreenImageView(
                    popupMedia: popupMedia,
                    sourceURL: url,
                    showingFullScreen: $showingFullScreen
                )
                .padding()
            }
        }
    }
}
