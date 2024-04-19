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
***REMOVED***

***REMOVED***/ A view displaying an async image, with error display and progress view.
public struct AsyncImageView: View {
***REMOVED******REMOVED***/ The `URL` of the image.
***REMOVED***private var url: URL?
***REMOVED***
***REMOVED******REMOVED***/ The `LoadableImage` representing the view.
***REMOVED***private var loadableImage: LoadableImage?
***REMOVED***
***REMOVED******REMOVED***/ The `ContentMode` defining how the image fills the available space.
***REMOVED***private let contentMode: ContentMode
***REMOVED***
***REMOVED******REMOVED***/ The refresh interval, in milliseconds. A refresh interval of 0 means never refresh.
***REMOVED***private let refreshInterval: TimeInterval?
***REMOVED***
***REMOVED******REMOVED***/ The size of the media's frame.
***REMOVED***private let mediaSize: CGSize?
***REMOVED***
***REMOVED******REMOVED***/ The data model for an `AsyncImageView`.
***REMOVED***@StateObject var viewModel: AsyncImageViewModel
***REMOVED***
***REMOVED******REMOVED***/ Creates an `AsyncImageView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - url: The `URL` of the image.
***REMOVED******REMOVED***/   - contentMode: The `ContentMode` defining how the image fills the available space.
***REMOVED******REMOVED***/   - refreshInterval: The refresh interval, in seconds. A `nil` interval means never refresh.
***REMOVED******REMOVED***/   - mediaSize: The size of the media's frame.
***REMOVED***public init(
***REMOVED******REMOVED***url: URL,
***REMOVED******REMOVED***contentMode: ContentMode = .fit,
***REMOVED******REMOVED***refreshInterval: TimeInterval? = nil,
***REMOVED******REMOVED***mediaSize: CGSize? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.contentMode = contentMode
***REMOVED******REMOVED***self.mediaSize = mediaSize
***REMOVED******REMOVED***self.url = url
***REMOVED******REMOVED***self.refreshInterval = refreshInterval
***REMOVED******REMOVED***loadableImage = nil
***REMOVED******REMOVED***
***REMOVED******REMOVED***_viewModel = StateObject(wrappedValue: AsyncImageViewModel())
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates an `AsyncImageView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - loadableImage: The `LoadableImage` representing the image.
***REMOVED******REMOVED***/   - contentMode: The `ContentMode` defining how the image fills the available space.
***REMOVED******REMOVED***/   - mediaSize: The size of the media's frame.
***REMOVED***public init(
***REMOVED******REMOVED***loadableImage: LoadableImage,
***REMOVED******REMOVED***contentMode: ContentMode = .fit,
***REMOVED******REMOVED***mediaSize: CGSize? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.contentMode = contentMode
***REMOVED******REMOVED***self.mediaSize = mediaSize
***REMOVED******REMOVED***self.loadableImage = loadableImage
***REMOVED******REMOVED***refreshInterval = nil
***REMOVED******REMOVED***url = nil
***REMOVED******REMOVED***
***REMOVED******REMOVED***_viewModel = StateObject(wrappedValue: AsyncImageViewModel())
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***switch viewModel.result {
***REMOVED******REMOVED******REMOVED***case .success(let image):
***REMOVED******REMOVED******REMOVED******REMOVED***if let image {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: image)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: contentMode)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .failure(_):
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.red)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top, .bottom])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let progressInterval = viewModel.progressInterval {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***timerInterval: progressInterval,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***countsDown: true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.tint(.white)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.opacity(0.5)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top], 4)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: mediaSize?.width)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onAppear() {
***REMOVED******REMOVED******REMOVED***viewModel.url = url
***REMOVED******REMOVED******REMOVED***viewModel.loadableImage = loadableImage
***REMOVED******REMOVED******REMOVED***viewModel.refreshInterval = refreshInterval
***REMOVED***
***REMOVED***
***REMOVED***
