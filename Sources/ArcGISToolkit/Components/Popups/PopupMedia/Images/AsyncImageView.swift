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

***REMOVED***/ A view displaying an async image, with error display and progress view.
struct AsyncImageView: View {
***REMOVED******REMOVED***/ The `ContentMode` defining how the image fills the available space.
***REMOVED***let contentMode: ContentMode
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
***REMOVED***init(
***REMOVED******REMOVED***url: URL,
***REMOVED******REMOVED***contentMode: ContentMode = .fit,
***REMOVED******REMOVED***refreshInterval: TimeInterval? = nil,
***REMOVED******REMOVED***mediaSize: CGSize? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.contentMode = contentMode
***REMOVED******REMOVED***self.mediaSize = mediaSize
***REMOVED******REMOVED***
***REMOVED******REMOVED***_viewModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: AsyncImageViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED***imageURL: url,
***REMOVED******REMOVED******REMOVED******REMOVED***refreshInterval: refreshInterval
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
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
***REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.red)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("An error occurred loading the image: \(error.localizedDescription).")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top, .bottom])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if #available(iOS 16.0, *),
***REMOVED******REMOVED******REMOVED***   let progressInterval = viewModel.progressInterval {
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
***REMOVED***
***REMOVED***
