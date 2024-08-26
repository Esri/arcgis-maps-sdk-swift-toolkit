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

import SwiftUI
import ArcGIS

/// A view that loads a `LoadableImage` and displays it.
/// While the image is loading a progress view is displayed.
/// If there is an error displaying the image a red exclamation circle is displayed.
@MainActor
struct LoadableImageView: View {
    /// The loadable image to display.
    let loadableImage: LoadableImage
    
    /// The result of loading the image.
    @State private var result: Result<UIImage, Error>?
    
    var body: some View {
        Group {
            switch result {
            case .none:
                ProgressView()
            case .failure:
                Image(systemName: "exclamationmark.circle")
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.red)
            case .success(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
        .task {
            result = await Result {
                try await loadableImage.load()
                return loadableImage.image ?? UIImage()
            }
        }
    }
}
