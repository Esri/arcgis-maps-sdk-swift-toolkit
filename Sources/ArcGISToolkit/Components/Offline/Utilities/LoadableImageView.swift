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
/// If there is an error loading the image then user defined failure content is shown.
/// Once the image loads, a user-defined closure is used to display the image.
struct LoadableImageView<FailureContent: View, LoadedContent: View>: View {
    /// The loadable image to display.
    let loadableImage: LoadableImage
    /// The content to display in the case of load failure.
    var failureContent: (() -> FailureContent)?
    /// The content to display once the image loads.
    var loadedContent: (Image) -> LoadedContent
    /// The result of loading the image.
    @State var result: Result<UIImage, Error>? = nil
    
    /// Creates a `LoadableImageView`.
    /// - Parameters:
    ///   - loadableImage: The loadable image.
    ///   - failureContent: The content to display if the loadable image fails to load.
    ///   - loadedContent: The content to display once the loadable image loads.
    init(
        loadableImage: LoadableImage,
        failureContent: @escaping () -> FailureContent,
        loadedContent: @escaping (Image) -> LoadedContent
    ) {
        self.loadableImage = loadableImage
        self.failureContent = failureContent
        self.loadedContent = loadedContent
    }
    
    /// Creates a `LoadableImageView`.
    /// - Parameters:
    ///   - loadableImage: The loadable image.
    ///   - loadedContent: The content to display once the loadable image loads.
    init(
        loadableImage: LoadableImage,
        loadedContent: @escaping (Image) -> LoadedContent
    ) where FailureContent == EmptyView {
        self.loadableImage = loadableImage
        self.failureContent = nil
        self.loadedContent = loadedContent
    }
    
    /// An error to signify that the loadable image had a null image once it loaded.
    /// This shouldn't ever happen, but in the case that it does, the failure content
    /// will be displayed.
    private struct NoImageError: Error {}
    
    var body: some View {
        Group {
            switch result {
            case .none:
                ProgressView()
            case .failure:
                if let failureContent {
                    failureContent()
                }
            case .success(let image):
                loadedContent(Image(uiImage: image))
            }
        }.task {
            result = await Result {
                try await loadableImage.load()
                guard let image = loadableImage.image else { throw NoImageError() }
                return image
            }
        }
    }
}
