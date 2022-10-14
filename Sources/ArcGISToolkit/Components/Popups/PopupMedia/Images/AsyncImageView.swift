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
***REMOVED******REMOVED***/ The `URL` of the image.
***REMOVED***let url: URL
***REMOVED***
***REMOVED***var imageURL: URL
***REMOVED***
***REMOVED******REMOVED***/ The `ContentMode` defining how the image fills the available space.
***REMOVED***let contentMode: ContentMode
***REMOVED***
***REMOVED******REMOVED***/ The `ContentMode` defining how the image fills the available space.
***REMOVED***let refreshInterval: UInt64
***REMOVED***
***REMOVED***@State var timer: Timer?
***REMOVED***
***REMOVED***@State var refreshing: Bool = false

***REMOVED******REMOVED***/ Creates an `AsyncImageView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - url: The `URL` of the image.
***REMOVED******REMOVED***/   - contentMode: The `ContentMode` defining how the image fills the available space.
***REMOVED***public init(url: URL, contentMode: ContentMode = .fit, refreshInterval: UInt64 = 0) {
***REMOVED******REMOVED***self.url = url
***REMOVED******REMOVED***self.imageURL = url
***REMOVED******REMOVED***self.contentMode = contentMode
***REMOVED******REMOVED***self.refreshInterval = refreshInterval
***REMOVED******REMOVED***print("self.refreshInterval = \(self.refreshInterval)")
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED***TODO: Maybe put in another Image as a background while this is refreshing
***REMOVED******REMOVED***TODO: maybe have an `oldImage` that gets displayed behind this.
***REMOVED******REMOVED******REMOVED***AsyncImage(url: refreshing ? nil : imageURL) { phase in
***REMOVED******REMOVED******REMOVED******REMOVED***if let image = phase.image {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Displays the loaded image.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***image
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: contentMode)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.task(id: refreshing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print(".task(id: refreshing) = \(refreshing)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if refreshing {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***refreshing = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("refreshing = \(refreshing)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** else if phase.error != nil, !refreshing {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Displays an error notification.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.red)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("An error occurred loading the image.")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top, .bottom])
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display the progress view until image loads.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onAppear() {
***REMOVED******REMOVED******REMOVED******REMOVED***put refresh interval here???
***REMOVED******REMOVED******REMOVED******REMOVED***put refresh interval here???
***REMOVED******REMOVED******REMOVED***print("refreshInterval = \(refreshInterval)")
***REMOVED******REMOVED******REMOVED***if refreshInterval > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED***timer = Timer.scheduledTimer(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withTimeInterval: Double(refreshInterval) / 1000,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***repeats: true,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***block: { timer in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !refreshing {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***refreshing = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("refreshing: \(refreshing) url: \(url.absoluteString)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***imageURL = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***imageURL = url
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***imageURL = URL(string: "https:***REMOVED***upload.wikimedia.org/wikipedia/commons/thumb/4/45/Nationale_oldtimerdag_Zandvoort_2010%2C_1978_FIAT_X1-9%2C_51-VV-18_pic2.JPG/1280px-Nationale_oldtimerdag_Zandvoort_2010%2C_1978_FIAT_X1-9%2C_51-VV-18_pic2.JPG")!
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***timer?.fire()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onDisappear() {
***REMOVED******REMOVED******REMOVED***timer?.invalidate()
***REMOVED***
***REMOVED***
***REMOVED***
