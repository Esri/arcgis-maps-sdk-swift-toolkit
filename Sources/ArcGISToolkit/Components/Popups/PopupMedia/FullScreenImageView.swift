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
        VStack() {
            HStack {
                Spacer()
                Button("Done") {
                    showingFullScreen = false
                }
            }
            Text("\(popupMedia.title)")
                .font(.title2)
            AsyncImage(url: sourceURL) { phase in
                if let image = phase.image {
                    // Displays the loaded image.
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if phase.error != nil {
                    // Displays an error image.
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.red)
                        Text("An error occurred loading the image.")
                    }
                    .padding([.top])
                } else {
                    // Display the progress view until image loads.
                    ProgressView()
                }
            }
            .onTapGesture {
                if let url = popupMedia.value?.linkURL {
                    UIApplication.shared.open(url)
                }
            }
            if popupMedia.value?.linkURL != nil {
                HStack {
                    Text("Tap on the image for more information.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            Spacer()
        }
    }
}
