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
import Combine

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
***REMOVED******REMOVED***@State var timer: Timer?
***REMOVED***var timer: Publishers.Autoconnect<Timer.TimerPublisher>

***REMOVED***@State var refreshing: Bool = false
***REMOVED***
***REMOVED***@State var currentImage: Image?
***REMOVED***
***REMOVED******REMOVED***/ Creates an `AsyncImageView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - url: The `URL` of the image.
***REMOVED******REMOVED***/   - contentMode: The `ContentMode` defining how the image fills the available space.
***REMOVED******REMOVED***/   - refreshInterval: The refresh interval, in milliseconds. A refresh interval of 0 means never refresh.
***REMOVED***public init(url: URL, contentMode: ContentMode = .fit, refreshInterval: UInt64 = 0) {
***REMOVED******REMOVED***self.url = url
***REMOVED******REMOVED***self.imageURL = url
***REMOVED******REMOVED***self.contentMode = contentMode
***REMOVED******REMOVED***self.refreshInterval = refreshInterval
***REMOVED******REMOVED***print("self.refreshInterval = \(self.refreshInterval)")
***REMOVED******REMOVED***let interval = refreshInterval > 0 ? Double(refreshInterval) / 1000 : TimeInterval.greatestFiniteMagnitude
***REMOVED******REMOVED***timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED*** Display the current image behind the AsyncImage so when the
***REMOVED******REMOVED******REMOVED******REMOVED*** AsyncImage is refreshing we don't get a white background with
***REMOVED******REMOVED******REMOVED******REMOVED*** just the progress view.
***REMOVED******REMOVED******REMOVED***if let currentImage {
***REMOVED******REMOVED******REMOVED******REMOVED***currentImage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: contentMode)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***AsyncImage(url: refreshing ? nil : imageURL) { phase in
***REMOVED******REMOVED******REMOVED******REMOVED***if let image = phase.image {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Displays the loaded image.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***image
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: contentMode)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.task(id: refreshing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("ImageDrawing, refreshing = \(refreshing)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***refreshing = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentImage = image
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
***REMOVED******REMOVED***.onReceive(timer) { _ in
***REMOVED******REMOVED******REMOVED***if !refreshing, currentImage != nil {
***REMOVED******REMOVED******REMOVED******REMOVED***print("Timer fired, refreshing = \(refreshing)")
***REMOVED******REMOVED******REMOVED******REMOVED***refreshing = true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onAppear() {
***REMOVED******REMOVED******REMOVED******REMOVED***if refreshInterval > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***timer = Timer.scheduledTimer(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withTimeInterval: Double(refreshInterval) / 1000,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***repeats: true,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***block: { timer in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !refreshing {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("Timer fired, refreshing = \(refreshing)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***refreshing = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onDisappear() {
***REMOVED******REMOVED******REMOVED******REMOVED***timer?.invalidate()
***REMOVED***
***REMOVED***
***REMOVED***
