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
***REMOVED***var body: some View {
***REMOVED******REMOVED***AsyncImage(url: url) { phase in
***REMOVED******REMOVED******REMOVED***if let image = phase.image {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Displays the loaded image.
***REMOVED******REMOVED******REMOVED******REMOVED***image
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED*** else if phase.error != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Displays an error notification.
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "exclamationmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.red)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("An error occurred loading the image.")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top, .bottom])
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Display the progress view until image loads.
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
