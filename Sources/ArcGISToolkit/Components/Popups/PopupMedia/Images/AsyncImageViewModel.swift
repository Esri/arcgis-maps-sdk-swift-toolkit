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

/// A view model which performs the work necessary to asynchronously download an image
/// from a URL and handles refreshing that image at a given time interval.
@MainActor final class AsyncImageViewModel: ObservableObject {
    /// The `URL` of the image.
    private var imageURL: URL
    
    /// The timer used refresh the image when `refreshInterval` is not zero.
    private var timer: Timer?
    
    /// A Boolean value specifying whether data from the image url is currently being refreshed.
    private var isRefreshing: Bool = false
    
    /// The result of the operation to load the image from `imageURL`.
    @Published var result: Result<UIImage?, Error> = .success(nil)
    
    /// The image download task.
    var task: URLSessionDataTask?
    
    /// Creates an `AsyncImageViewModel`.
    /// - Parameters:
    ///   - imageURL: The URL of the image to download.
    ///   - refreshInterval: The refresh interval, in milliseconds. A refresh interval of 0 means never refresh.
    init(imageURL: URL, refreshInterval: UInt64 = 0) {
        self.imageURL = imageURL
        
        if refreshInterval > 0 {
            timer = Timer.scheduledTimer(
                withTimeInterval: Double(refreshInterval) / 1000,
                repeats: true,
                block: { [weak self] timer in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.refresh()
                    }
                })
        }
        // First refresh.
        refresh()
    }
    
    /// Refreshes the image data from `imageURL` and creates the image.
    private func refresh() {
        guard !isRefreshing else { return }
        
        // Only refresh if we're not already refreshing.  Sometimes the
        // `refreshInterval` will be shorter than the time it takes to
        // download the image.  In this case, we want to finish downloading
        // the current image before starting a new download, otherwise
        // we may never get an image to display.
        isRefreshing = true
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let (data, _) = try await ArcGISRuntimeEnvironment.urlSession.data(from: imageURL)
                DispatchQueue.main.async { [weak self] in
                    if let image = UIImage(data: data) {
                        self?.result = .success(image)
                    } else {
                        // We have data, but couldn't create an image.
                        self?.result = .failure(LoadImageError())
                    }
                }
            } catch {
                result = .failure(error)
            }
            
            isRefreshing = false
        }
    }
}

/// An error returned when an image can't be created from data downloaded via a URL.
struct LoadImageError: Error {
}

extension LoadImageError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString(
            "The URL could not be reached or did not contain image data",
            comment: "No Data"
        )
    }
}
