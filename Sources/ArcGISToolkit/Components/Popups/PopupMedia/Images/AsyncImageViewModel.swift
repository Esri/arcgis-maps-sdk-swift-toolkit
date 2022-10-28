***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

***REMOVED***/ A view model which performs the work necessary to asynchronously download an image
***REMOVED***/ from a URL and handles refreshing that image at a given time interval.
@MainActor final class AsyncImageViewModel: ObservableObject {
***REMOVED******REMOVED***/ The `URL` of the image.
***REMOVED***private var imageURL: URL
***REMOVED***
***REMOVED******REMOVED***/ The timer used refresh the image when `refreshInterval` is not zero.
***REMOVED***private var timer: Timer?
***REMOVED***
***REMOVED******REMOVED***/ The refresh interval, in milliseconds. A refresh interval of 0 means never refresh.
***REMOVED***let refreshInterval: TimeInterval?
***REMOVED***
***REMOVED******REMOVED***/ An interval to be used by an indeterminate ProgressView to display progress
***REMOVED******REMOVED***/ until next refresh.  Will be `nil` if `refreshInterval` is less than 1.
***REMOVED***@Published var progressInterval: ClosedRange<Date>? = nil
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether data from the image url is currently being refreshed.
***REMOVED***private var isRefreshing: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ The result of the operation to load the image from `imageURL`.
***REMOVED***@Published var result: Result<UIImage?, Error> = .success(nil)
***REMOVED***
***REMOVED******REMOVED***/ The image download task.
***REMOVED***var task: URLSessionDataTask?
***REMOVED***
***REMOVED******REMOVED***/ Creates an `AsyncImageViewModel`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - imageURL: The URL of the image to download.
***REMOVED******REMOVED***/   - refreshInterval: The refresh interval, in seconds. A `nil` interval means never refresh.
***REMOVED***init(imageURL: URL, refreshInterval: TimeInterval? = nil) {
***REMOVED******REMOVED***self.imageURL = imageURL
***REMOVED******REMOVED***self.refreshInterval = refreshInterval
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let refreshInterval {
***REMOVED******REMOVED******REMOVED***timer = Timer.scheduledTimer(
***REMOVED******REMOVED******REMOVED******REMOVED***withTimeInterval: refreshInterval,
***REMOVED******REMOVED******REMOVED******REMOVED***repeats: true,
***REMOVED******REMOVED******REMOVED******REMOVED***block: { [weak self] timer in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let self = self else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.refresh()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED******REMOVED*** First refresh.
***REMOVED******REMOVED***refresh()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Refreshes the image data from `imageURL` and creates the image.
***REMOVED***private func refresh() {
***REMOVED******REMOVED***guard !isRefreshing else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Only refresh if we're not already refreshing.  Sometimes the
***REMOVED******REMOVED******REMOVED*** `refreshInterval` will be shorter than the time it takes to
***REMOVED******REMOVED******REMOVED*** download the image.  In this case, we want to finish downloading
***REMOVED******REMOVED******REMOVED*** the current image before starting a new download, otherwise
***REMOVED******REMOVED******REMOVED*** we may never get an image to display.
***REMOVED******REMOVED***isRefreshing = true
***REMOVED******REMOVED***Task { [weak self] in
***REMOVED******REMOVED******REMOVED***guard let self = self else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***let (data, _) = try await ArcGISRuntimeEnvironment.urlSession.data(from: imageURL)
***REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async { [weak self] in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let image = UIImage(data: data) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self?.result = .success(image)
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** We have data, but couldn't create an image.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self?.result = .failure(LoadImageError())
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***result = .failure(error)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***isRefreshing = false
***REMOVED******REMOVED******REMOVED***if let refreshInterval,
***REMOVED******REMOVED******REMOVED***   refreshInterval >= 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***progressInterval = Date()...Date().addingTimeInterval(refreshInterval)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ An error returned when an image can't be created from data downloaded via a URL.
struct LoadImageError: Error {
***REMOVED***

extension LoadImageError: LocalizedError {
***REMOVED***public var errorDescription: String? {
***REMOVED******REMOVED***return NSLocalizedString(
***REMOVED******REMOVED******REMOVED***"The URL could not be reached or did not contain image data",
***REMOVED******REMOVED******REMOVED***comment: "No Data"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
