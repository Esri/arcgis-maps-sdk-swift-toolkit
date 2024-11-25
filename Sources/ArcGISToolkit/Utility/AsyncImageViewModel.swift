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

import ArcGIS
import Combine
import Foundation
import UIKit

/// A view model which performs the work necessary to asynchronously download an image
/// from a URL and handles refreshing that image at a given time interval.
@MainActor final class AsyncImageViewModel: ObservableObject {
    /// The `URL` of the image.
    var url: URL? {
        didSet {
            refresh()
        }
    }
    
    /// The `LoadableImage` representing the view.
    var loadableImage: LoadableImage? {
        didSet {
            refresh()
        }
    }
    
    /// The refresh interval, in milliseconds. A refresh interval of 0 means never refresh.
    var refreshInterval: TimeInterval? {
        didSet {
            timer?.invalidate()
            progressInterval = nil
            if let refreshInterval {
                timer = Timer.scheduledTimer(
                    withTimeInterval: refreshInterval,
                    repeats: true,
                    block: { [weak self] timer in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            self.refresh()
                        }
                    })
                refresh()
            }
        }
    }
    
    /// The timer used refresh the image when `refreshInterval` is not zero.
    private var timer: Timer?
    
    /// An interval to be used by an indeterminate ProgressView to display progress
    /// until next refresh. Will be `nil` if `refreshInterval` is less than 1.
    @Published var progressInterval: ClosedRange<Date>? = nil
    
    /// A Boolean value specifying whether data from the image url is currently being refreshed.
    private var isRefreshing: Bool = false
    
    /// The result of the operation to load the image from `url`.
    @Published var result: Result<UIImage?, Error> = .success(nil)
    
    /// The image download task.
    private var task: URLSessionDataTask?
    
    /// Creates an `AsyncImageViewModel`.
    init() {
        refresh()
    }
    
    /// Refreshes the image data from `url` or `loadableImage` and creates the image.
    private func refresh() {
        guard !isRefreshing, (url != nil || loadableImage != nil) else { return }
        
        // Only refresh if we're not already refreshing.  Sometimes the
        // `refreshInterval` will be shorter than the time it takes to
        // download the image.  In this case, we want to finish downloading
        // the current image before starting a new download, otherwise
        // we may never get an image to display.
        isRefreshing = true
        Task { [weak self] in
            guard let self else { return }
            
            do {
                if let url {
                    try await loadFromURL(url: url)
                } else if let loadableImage {
                    try await loadFromLoadableImage(loadableImage: loadableImage)
                }
            } catch {
                result = .failure(error)
            }
        }
    }
    
    private func loadFromURL(url: URL) async throws {
        let (data, _) = try await ArcGISEnvironment.urlSession.data(from: url)
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                self?.result = .success(image)
            } else {
                // We have data, but couldn't create an image.
                self?.result = .failure(LoadImageError())
            }
        }
        
        isRefreshing = false
        if let refreshInterval,
           refreshInterval >= 1 {
            progressInterval = Date()...Date().addingTimeInterval(refreshInterval)
        }
    }
        
    private func loadFromLoadableImage(loadableImage: LoadableImage) async throws {
        try await loadableImage.load()
        result = .success(loadableImage.image)
    }
}

/// An error returned when an image can't be created from data downloaded via a URL.
struct LoadImageError: Error {
}

extension LoadImageError: LocalizedError {
    public var errorDescription: String? {
        return String(
            localized: "The URL could not be reached or did not contain image data.",
            bundle: .toolkitModule,
            comment: "Description of error thrown when a remote image could not be loaded."
        )
    }
}
