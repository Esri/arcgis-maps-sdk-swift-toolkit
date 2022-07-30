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

***REMOVED***/ A view displaying chart popup media.
struct ChartMediaView: View {
***REMOVED******REMOVED***/ The popup media to display.
***REMOVED***let popupMedia: PopupMedia
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chart.bar")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 100, height: 100)
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Charts coming soon!")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: 8)
***REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.black, lineWidth: 1)
***REMOVED***
***REMOVED***
***REMOVED***
