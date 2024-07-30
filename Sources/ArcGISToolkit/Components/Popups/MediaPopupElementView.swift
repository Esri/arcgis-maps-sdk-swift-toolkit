***REMOVED*** Copyright 2022 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
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
***REMOVED***@State var isExpanded: Bool = true
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if displayableMediaCount > 0 {
***REMOVED******REMOVED******REMOVED***DisclosureGroup(isExpanded: $isExpanded) {
***REMOVED******REMOVED******REMOVED******REMOVED***PopupMediaView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***popupMedia: popupElement.media,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***displayableMediaCount: displayableMediaCount
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***PopupElementHeader(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: popupElement.displayTitle,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***description: popupElement.description
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.catalystPadding(4)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The number of popup media that can be displayed. The count includes
***REMOVED******REMOVED***/ all image media and chart media.
***REMOVED***var displayableMediaCount: Int {
***REMOVED******REMOVED***popupElement.media.count
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view displaying an array of `PopupMedia`.
***REMOVED***struct PopupMediaView: View {
***REMOVED******REMOVED******REMOVED***/ The popup media to display.
***REMOVED******REMOVED***let popupMedia: [PopupMedia]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The number of popup media that can be displayed.
***REMOVED******REMOVED***let displayableMediaCount: Int
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
***REMOVED******REMOVED******REMOVED******REMOVED***displayableMediaCount > 1 ? 0.75 : 1
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The size of the image or chart media.
***REMOVED******REMOVED***var mediaSize: CGSize {
***REMOVED******REMOVED******REMOVED***CGSize(width: width, height: 200)
***REMOVED***
***REMOVED***
***REMOVED***

extension PopupMedia: @retroactive Identifiable {***REMOVED***

private extension MediaPopupElement {
***REMOVED******REMOVED***/ Provides a default title to display if `title` is empty.
***REMOVED***var displayTitle: String {
***REMOVED******REMOVED***title.isEmpty ? String(
***REMOVED******REMOVED******REMOVED***localized: "Media",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label in reference to media elements contained within a popup."
***REMOVED******REMOVED***) : title
***REMOVED***
***REMOVED***
