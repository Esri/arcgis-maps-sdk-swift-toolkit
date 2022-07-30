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
import Charts

***REMOVED***/ A view displaying a `MediaPopupElement`.
struct MediaPopupElementView: View {
***REMOVED******REMOVED***/ The `PopupElement` to display.
***REMOVED***var popupElement: MediaPopupElement
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***PopupElementHeader(
***REMOVED******REMOVED******REMOVED***title: popupElement.title,
***REMOVED******REMOVED******REMOVED***description: popupElement.description
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.padding([.bottom], 4)
***REMOVED******REMOVED***PopupMediaView(popupMedia: popupElement.media)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view displaying an array of `PopupMedia`.
***REMOVED***struct PopupMediaView: View {
***REMOVED******REMOVED******REMOVED***/ The popup media to display.
***REMOVED******REMOVED***let popupMedia: [PopupMedia]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The width of the view content.
***REMOVED******REMOVED***@State private var viewWidth: CGFloat = .zero
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***TabView {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(popupMedia) { media in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch media.kind {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .image:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ImageMediaView(popupMedia: media)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .barChart, .columnChart, .lineChart, .pieChart:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ChartMediaView(popupMedia: media)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom], popupMedia.count > 1 ? 48: 8)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.tabItem {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(media.title)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.tabViewStyle(PageTabViewStyle())
***REMOVED******REMOVED******REMOVED***.indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
***REMOVED******REMOVED******REMOVED***.frame(height: viewWidth * 0.75)
***REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED***viewWidth = $0.width
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension PopupMedia: Identifiable {***REMOVED***
