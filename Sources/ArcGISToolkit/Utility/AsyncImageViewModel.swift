***REMOVED*** Copyright 2022 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import Combine
import Foundation
import UIKit

***REMOVED***/ A view model which performs the work necessary to asynchronously download an image
***REMOVED***/ from a URL and handles refreshing that image at a given time interval.
@MainActor final class AsyncImageViewModel: ObservableObject {
***REMOVED******REMOVED***/ The `URL` of the image.
***REMOVED***var url: URL? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***refresh()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `LoadableImage` representing the view.
***REMOVED***var loadableImage: LoadableImage? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***refresh()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The refresh interval, in milliseconds. A refresh interval of 0 means never refresh.
***REMOVED***var refreshInterval: TimeInterval? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***timer?.invalidate()
***REMOVED******REMOVED******REMOVED***progressInterval = nil
***REMOVED******REMOVED******REMOVED***if let refreshInterval {
***REMOVED******REMOVED******REMOVED******REMOVED***timer = Timer.scheduledTimer(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withTimeInterval: refreshInterval,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***repeats: true,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***block: { [weak self] timer in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let self = self else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.refresh()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***refresh()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The timer used refresh the image when `refreshInterval` is not zero.
***REMOVED***private var timer: Timer?
***REMOVED***
***REMOVED******REMOVED***/ An interval to be used by an indeterminate ProgressView to display progress
***REMOVED******REMOVED***/ until next refresh. Will be `nil` if `refreshInterval` is less than 1.
***REMOVED***@Published var progressInterval: ClosedRange<Date>? = nil
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether data from the image url is currently being refreshed.
***REMOVED***private var isRefreshing: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ The result of the operation to load the image from `url`.
***REMOVED***@Published var result: Result<UIImage?, Error> = .success(nil)
***REMOVED***
***REMOVED******REMOVED***/ The image download task.
***REMOVED***private var task: URLSessionDataTask?
***REMOVED***
***REMOVED******REMOVED***/ Creates an `AsyncImageViewModel`.
***REMOVED***init() {
***REMOVED******REMOVED***refresh()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Refreshes the image data from `url` or `loadableImage` and creates the image.
***REMOVED***private func refresh() {
***REMOVED******REMOVED***guard !isRefreshing, (url != nil || loadableImage != nil) else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Only refresh if we're not already refreshing.  Sometimes the
***REMOVED******REMOVED******REMOVED*** `refreshInterval` will be shorter than the time it takes to
***REMOVED******REMOVED******REMOVED*** download the image.  In this case, we want to finish downloading
***REMOVED******REMOVED******REMOVED*** the current image before starting a new download, otherwise
***REMOVED******REMOVED******REMOVED*** we may never get an image to display.
***REMOVED******REMOVED***isRefreshing = true
***REMOVED******REMOVED***Task { [weak self] in
***REMOVED******REMOVED******REMOVED***guard let self else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***if let url {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await loadFromURL(url: url)
***REMOVED******REMOVED******REMOVED*** else if let loadableImage {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await loadFromLoadableImage(loadableImage: loadableImage)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***result = .failure(error)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func loadFromURL(url: URL) async throws {
***REMOVED******REMOVED***let (data, _) = try await ArcGISEnvironment.urlSession.data(from: url)
***REMOVED******REMOVED***DispatchQueue.main.async { [weak self] in
***REMOVED******REMOVED******REMOVED***if let image = UIImage(data: data) {
***REMOVED******REMOVED******REMOVED******REMOVED***self?.result = .success(image)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** We have data, but couldn't create an image.
***REMOVED******REMOVED******REMOVED******REMOVED***self?.result = .failure(LoadImageError())
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***isRefreshing = false
***REMOVED******REMOVED***if let refreshInterval,
***REMOVED******REMOVED***   refreshInterval >= 1 {
***REMOVED******REMOVED******REMOVED***progressInterval = Date()...Date().addingTimeInterval(refreshInterval)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED***private func loadFromLoadableImage(loadableImage: LoadableImage) async throws {
***REMOVED******REMOVED***try await loadableImage.load()
***REMOVED******REMOVED***result = .success(loadableImage.image)
***REMOVED***
***REMOVED***

***REMOVED***/ An error returned when an image can't be created from data downloaded via a URL.
struct LoadImageError: Error {
***REMOVED***

extension LoadImageError: LocalizedError {
***REMOVED***public var errorDescription: String? {
***REMOVED******REMOVED***return String(
***REMOVED******REMOVED******REMOVED***localized: "The URL could not be reached or did not contain image data.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "Description of error thrown when a remote image could not be loaded."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
