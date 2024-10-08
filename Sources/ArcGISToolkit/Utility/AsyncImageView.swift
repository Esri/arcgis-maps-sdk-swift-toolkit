// Copyright 2022 Esri
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

/// A view displaying an async image, with error display and progress view.
@available(visionOS, unavailable)
public struct AsyncImageView: View {
    /// The `URL` of the image.
    private var url: URL?
    
    /// The `LoadableImage` representing the view.
    private var loadableImage: LoadableImage?
    
    /// The `ContentMode` defining how the image fills the available space.
    private let contentMode: ContentMode
    
    /// The refresh interval, in milliseconds. A refresh interval of 0 means never refresh.
    private let refreshInterval: TimeInterval?
    
    /// The size of the media's frame.
    private let mediaSize: CGSize?
    
    /// The data model for an `AsyncImageView`.
    @StateObject private var viewModel = AsyncImageViewModel()
    
    /// Creates an `AsyncImageView`.
    /// - Parameters:
    ///   - url: The `URL` of the image.
    ///   - contentMode: The `ContentMode` defining how the image fills the available space.
    ///   - refreshInterval: The refresh interval, in seconds. A `nil` interval means never refresh.
    ///   - mediaSize: The size of the media's frame.
    public init(
        url: URL,
        contentMode: ContentMode = .fit,
        refreshInterval: TimeInterval? = nil,
        mediaSize: CGSize? = nil
    ) {
        self.contentMode = contentMode
        self.mediaSize = mediaSize
        self.url = url
        self.refreshInterval = refreshInterval
        loadableImage = nil
    }
    
    /// Creates an `AsyncImageView`.
    /// - Parameters:
    ///   - loadableImage: The `LoadableImage` representing the image.
    ///   - contentMode: The `ContentMode` defining how the image fills the available space.
    ///   - mediaSize: The size of the media's frame.
    public init(
        loadableImage: LoadableImage,
        contentMode: ContentMode = .fit,
        mediaSize: CGSize? = nil
    ) {
        self.contentMode = contentMode
        self.mediaSize = mediaSize
        self.loadableImage = loadableImage
        refreshInterval = nil
        url = nil
        
        _viewModel = StateObject(wrappedValue: AsyncImageViewModel())
    }
    
    public var body: some View {
        ZStack {
            switch viewModel.result {
            case .success(let image):
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                } else {
                    ProgressView()
                }
            case .failure(_):
                HStack(alignment: .center) {
                    Image(systemName: "exclamationmark.circle")
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                }
                .padding([.top, .bottom])
            }
            if let progressInterval = viewModel.progressInterval {
                VStack {
                    ProgressView(
                        timerInterval: progressInterval,
                        countsDown: true
                    )
                    .tint(.white)
                    .opacity(0.5)
                    .padding([.top], 4)
                    .frame(width: mediaSize?.width)
                    Spacer()
                }
            }
        }
        .onAppear() {
            viewModel.url = url
            viewModel.loadableImage = loadableImage
            viewModel.refreshInterval = refreshInterval
        }
    }
}
