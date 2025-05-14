***REMOVED*** Copyright 2024 Esri
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

***REMOVED***/ A view that loads a `LoadableImage` and displays it.
***REMOVED***/ While the image is loading a progress view is displayed.
***REMOVED***/ If there is an error loading the image then user defined failure content is shown.
***REMOVED***/ Once the image loads, a user-defined closure is used to display the image.
struct LoadableImageView<FailureContent: View, LoadedContent: View>: View {
***REMOVED******REMOVED***/ The loadable image to display.
***REMOVED***let loadableImage: LoadableImage
***REMOVED******REMOVED***/ The content to display in the case of load failure.
***REMOVED***var failureContent: (() -> FailureContent)?
***REMOVED******REMOVED***/ The content to display once the image loads.
***REMOVED***var loadedContent: (Image) -> LoadedContent
***REMOVED******REMOVED***/ The result of loading the image.
***REMOVED***@State private var result: Result<UIImage, Error>?
***REMOVED***
***REMOVED******REMOVED***/ Creates a `LoadableImageView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - loadableImage: The loadable image.
***REMOVED******REMOVED***/   - failureContent: The content to display if the loadable image fails to load.
***REMOVED******REMOVED***/   - loadedContent: The content to display once the loadable image loads.
***REMOVED***init(
***REMOVED******REMOVED***loadableImage: LoadableImage,
***REMOVED******REMOVED***failureContent: @escaping () -> FailureContent,
***REMOVED******REMOVED***loadedContent: @escaping (Image) -> LoadedContent
***REMOVED***) {
***REMOVED******REMOVED***self.loadableImage = loadableImage
***REMOVED******REMOVED***self.failureContent = failureContent
***REMOVED******REMOVED***self.loadedContent = loadedContent
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `LoadableImageView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - loadableImage: The loadable image.
***REMOVED******REMOVED***/   - loadedContent: The content to display once the loadable image loads.
***REMOVED***init(
***REMOVED******REMOVED***loadableImage: LoadableImage,
***REMOVED******REMOVED***loadedContent: @escaping (Image) -> LoadedContent
***REMOVED***) where FailureContent == EmptyView {
***REMOVED******REMOVED***self.loadableImage = loadableImage
***REMOVED******REMOVED***self.failureContent = nil
***REMOVED******REMOVED***self.loadedContent = loadedContent
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ An error to signify that the loadable image had a null image once it loaded.
***REMOVED******REMOVED***/ This shouldn't ever happen, but in the case that it does, the failure content
***REMOVED******REMOVED***/ will be displayed.
***REMOVED***private struct NoImageError: Error {***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch result {
***REMOVED******REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED***case .failure:
***REMOVED******REMOVED******REMOVED******REMOVED***if let failureContent {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***failureContent()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .success(let image):
***REMOVED******REMOVED******REMOVED******REMOVED***loadedContent(Image(uiImage: image))
***REMOVED******REMOVED***
***REMOVED***.task {
***REMOVED******REMOVED******REMOVED***result = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***try await loadableImage.load()
***REMOVED******REMOVED******REMOVED******REMOVED***guard let image = loadableImage.image else { throw NoImageError() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***return image
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
