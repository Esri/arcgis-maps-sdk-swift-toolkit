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
struct ImageMediaView: View {
    let popupMedia: PopupMedia
    // TODO: pass in url so we're sure it's available
    
    // TODO: general: clean up main MediaPopupElementView and create sub view files.
    @State private var showingFullScreen = false
    @State private var fullScreenURL: URL!
    
    var body: some View {
        VStack(alignment: .leading) {
            // Use popupMedia.sourceURL for thumbnail
            // Use popupMedia.linkURL for full-screen link
            Group {
                if let sourceURL = popupMedia.value?.sourceURL {
                    AsyncImage(url: sourceURL) { phase in
                        if let image = phase.image {
                            image // Displays the loaded image.
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxHeight: 250)
                                .clipped()  // <- need maxWidth as well for this to work.  Use GeometryReader somewhere above.
                        } else if let error = phase.error {
                            Text("sourceURL: \(sourceURL.absoluteString); An error occurred loading the image: \(error.localizedDescription)") // Indicates an error.
                        } else {
                            ProgressView() // Acts as a placeholder.
                        }
                    }
                    .onTapGesture {
                        showingFullScreen = true
                    }
                }
                else {
                    // TODO:  better error (if any at all)
                    Text("No URL for the image.")
                }
            }
            
            PopupMediaFooter(popupMedia: popupMedia)
        }
        .sheet(isPresented: $showingFullScreen) {
            if let url = popupMedia.value?.sourceURL {
                VStack {
                    HStack {
                        Button("Done") {
                            showingFullScreen = false
                        }
                        Spacer()
                    }
                    .padding()
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            // Displays the loaded image.
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else if phase.error != nil {
                            // Displays an error image.
                            Image(systemName: "exclamationmark.circle")
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.red)
                        } else {
                            // Display the progress view until image loads.
                            ProgressView()
                        }
                    }
                    .padding()
                    .onTapGesture {
                        if let url = popupMedia.value?.linkURL {
                            UIApplication.shared.open(url)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}
