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

***REMOVED***/ A view displaying details for popup media.
struct PopupMediaFooter: View {
***REMOVED******REMOVED***/ The popup media to display.
***REMOVED***let popupMedia: PopupMedia
***REMOVED***
***REMOVED******REMOVED***/ The size of the media's frame.
***REMOVED***let mediaSize: CGSize
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***let gradient = Gradient(colors: [.black, .black.opacity(0.15)])
***REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED***.fill(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***LinearGradient(gradient: gradient, startPoint: .bottom, endPoint: .top)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: mediaSize.height * 0.25)
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !popupMedia.title.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(popupMedia.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.white)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.body)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !popupMedia.caption.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(popupMedia.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(Color(white: 0.75))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding([.leading, .trailing], 12)
***REMOVED***
***REMOVED***
***REMOVED***
