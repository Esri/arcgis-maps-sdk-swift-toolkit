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
***REMOVED***/ If there is an error displaying the image a red exclamation circle is displayed.
struct LoadableImageView: View {
***REMOVED******REMOVED***/ The loadable image to display.
***REMOVED***let loadableImage: LoadableImage
***REMOVED***
***REMOVED******REMOVED***/ The result of loading the image.
***REMOVED***@State private var result: Result<UIImage, Error>?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch result {
***REMOVED******REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED***case .failure:
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.red)
***REMOVED******REMOVED******REMOVED***case .success(let image):
***REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: image)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***result = await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***try await loadableImage.load()
***REMOVED******REMOVED******REMOVED******REMOVED***return loadableImage.image ?? UIImage()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
