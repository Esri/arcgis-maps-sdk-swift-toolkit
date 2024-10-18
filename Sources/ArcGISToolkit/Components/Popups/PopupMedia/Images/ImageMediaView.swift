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
@available(visionOS, unavailable)
struct ImageMediaView: View {
***REMOVED******REMOVED***/ The popup media to display.
***REMOVED***let popupMedia: PopupMedia
***REMOVED***
***REMOVED******REMOVED***/ The size of the media's frame.
***REMOVED***let mediaSize: CGSize
***REMOVED***
***REMOVED******REMOVED***/ The corner radius for the view.
***REMOVED***private let cornerRadius: CGFloat = 8
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether the media should be drawn in a larger format.
***REMOVED***@State private var isShowingDetailView = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if let sourceURL = popupMedia.value?.sourceURL {
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***AsyncImageView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: sourceURL,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***contentMode: .fill,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***refreshInterval: popupMedia.imageRefreshInterval,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mediaSize: mediaSize
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: mediaSize.width, height: mediaSize.height)
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PopupMediaFooter(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***popupMedia: popupMedia,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mediaSize: mediaSize
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: cornerRadius)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.gray, lineWidth: 1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: mediaSize.width, height: mediaSize.height)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(width: mediaSize.width, height: mediaSize.height)
***REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
***REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED***isShowingDetailView = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isShowingDetailView) {
***REMOVED******REMOVED******REMOVED******REMOVED***MediaDetailView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***popupMedia: popupMedia,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isShowingDetailView: $isShowingDetailView
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
