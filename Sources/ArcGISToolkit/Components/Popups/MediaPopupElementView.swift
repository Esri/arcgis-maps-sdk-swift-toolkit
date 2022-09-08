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

***REMOVED***/ A view displaying a `MediaPopupElement`.
struct MediaPopupElementView: View {
***REMOVED******REMOVED***/ The `PopupElement` to display.
***REMOVED***var popupElement: MediaPopupElement
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if hasDisplayableMedia {
***REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***PopupElementHeader(
***REMOVED******REMOVED******REMOVED******REMOVED***title: popupElement.title,
***REMOVED******REMOVED******REMOVED******REMOVED***description: popupElement.description
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***PopupMediaView(popupMedia: popupElement.media)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying if there is available media to display.  Available media would
***REMOVED******REMOVED***/ be image media or chart media when running on iOS 16 or newer.
***REMOVED***var hasDisplayableMedia: Bool {
***REMOVED******REMOVED***let media = popupElement.media
***REMOVED******REMOVED***let imageMedia = media.filter { $0.kind == .image ***REMOVED***
***REMOVED******REMOVED***if imageMedia.count > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED*** We have image media to display.
***REMOVED******REMOVED******REMOVED***return true
***REMOVED***
***REMOVED******REMOVED***if #available(iOS 16, *) {
***REMOVED******REMOVED******REMOVED******REMOVED*** We're on iOS 16 and we have more media than just images.
***REMOVED******REMOVED******REMOVED***return media.count > imageMedia.count
***REMOVED***
***REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view displaying an array of `PopupMedia`.
***REMOVED***struct PopupMediaView: View {
***REMOVED******REMOVED******REMOVED***/ The popup media to display.
***REMOVED******REMOVED***let popupMedia: [PopupMedia]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The width of the view content.
***REMOVED******REMOVED***@State private var width: CGFloat = .zero
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***ScrollView(.horizontal) {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .top, spacing: 8) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(popupMedia) { media in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch media.kind {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .image:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ImageMediaView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***popupMedia: media,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mediaSize: mediaSize
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .barChart, .columnChart, .lineChart, .pieChart:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ChartMediaView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***popupMedia: media,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mediaSize: mediaSize
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: mediaSize.width, height: mediaSize.height)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(RoundedRectangle(cornerRadius: 8))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED***width = $0.width * widthScaleFactor
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The scale factor for specifying the width of popup media.  If there is only one popup media,
***REMOVED******REMOVED******REMOVED***/ the scale is 1.0 (full width); if there is more than one, the scale is 0.85, which allows for
***REMOVED******REMOVED******REMOVED***/ second and subsequent media to be partially visible, to indicate there is more than one.
***REMOVED******REMOVED***var widthScaleFactor: Double {
***REMOVED******REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED******REMOVED***popupMedia.count > 1 ? 0.75 : 1
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The size of the image or chart media, not counting descriptive text.
***REMOVED******REMOVED***var mediaSize: CGSize {
***REMOVED******REMOVED******REMOVED***CGSize(width: width, height: 200)
***REMOVED***
***REMOVED***
***REMOVED***

extension PopupMedia: Identifiable {***REMOVED***
