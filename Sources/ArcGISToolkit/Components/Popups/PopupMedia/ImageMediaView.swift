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

***REMOVED***/ A view displaying image popup media.
struct ImageMediaView: View {
***REMOVED******REMOVED***/ The popup media to display.
***REMOVED***let popupMedia: PopupMedia
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether the media should be shown full screen.
***REMOVED***@State private var showingFullScreen = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if let sourceURL = popupMedia.value?.sourceURL {
***REMOVED******REMOVED******REMOVED******REMOVED***AsyncImage(url: sourceURL) { phase in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let image = phase.image {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display the loaded image.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***image
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED*** else if phase.error != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display an error message.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.red)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("An error occurred loading the image.")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display a placeholder while the image is loading.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showingFullScreen = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***PopupMediaFooter(popupMedia: popupMedia)
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.sheet(isPresented: $showingFullScreen) {
***REMOVED******REMOVED******REMOVED***if let url = popupMedia.value?.sourceURL {
***REMOVED******REMOVED******REMOVED******REMOVED***FullScreenImageView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***popupMedia: popupMedia,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sourceURL: url,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showingFullScreen: $showingFullScreen
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
