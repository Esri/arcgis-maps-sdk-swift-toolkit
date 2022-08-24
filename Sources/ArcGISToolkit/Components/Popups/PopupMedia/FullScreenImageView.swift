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

***REMOVED***/ A view displaying a popup media image in full screen.
struct FullScreenImageView: View {
***REMOVED******REMOVED***/ The popup media to display.
***REMOVED***let popupMedia: PopupMedia
***REMOVED***
***REMOVED******REMOVED***/ The sourceURL of the image media.
***REMOVED***let sourceURL: URL
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether the media should be shown full screen.
***REMOVED***@Binding var showingFullScreen: Bool
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack() {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showingFullScreen = false
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Done")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.semibold)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom], 4)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Text(popupMedia.title)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.title3)
***REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.bold)
***REMOVED******REMOVED******REMOVED***AsyncImageView(url: sourceURL)
***REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let url = popupMedia.value?.linkURL {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UIApplication.shared.open(url)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if popupMedia.value?.linkURL != nil {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Tap on the image for more information.")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED***
***REMOVED***
