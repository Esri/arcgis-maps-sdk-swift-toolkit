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

/// A view displaying an async image, with error display and progress view.
struct AsyncImageView: View {
    /// The `URL` of the image.
    let url: URL
    
    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                // Displays the loaded image.
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if phase.error != nil {
                // Displays an error image.
                HStack(alignment: .center) {
                    Image(systemName: "exclamationmark.circle")
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                    Text("An error occurred loading the image.")
                }
                .padding([.top, .bottom])
            } else {
                // Display the progress view until image loads.
                ProgressView()
            }
        }
    }
}
