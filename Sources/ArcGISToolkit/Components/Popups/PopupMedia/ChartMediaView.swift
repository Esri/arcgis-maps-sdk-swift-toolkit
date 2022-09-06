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
***REMOVED******REMOVED***/ The size of the media's frame.
***REMOVED***let mediaSize: CGSize
***REMOVED***
***REMOVED***let chartData: [ChartData]
***REMOVED***
***REMOVED***init(popupMedia: PopupMedia, mediaSize: CGSize) {
***REMOVED******REMOVED***self.popupMedia = popupMedia
***REMOVED******REMOVED***self.mediaSize = mediaSize
***REMOVED******REMOVED***self.chartData = ChartData.getChartData(popupMedia: popupMedia)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether the media should be shown full screen.
***REMOVED***@State private var showingFullScreen = false
***REMOVED***
***REMOVED***private let cornerRadius: CGFloat = 8

***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***ChartView(popupMedia: popupMedia, data: chartData)
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***PopupMediaFooter(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***popupMedia: popupMedia,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mediaSize: mediaSize
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: cornerRadius)
***REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.gray, lineWidth: 1)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: mediaSize.width, height: mediaSize.height)
***REMOVED***
***REMOVED******REMOVED***.frame(width: mediaSize.width, height: mediaSize.height)
***REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
***REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED***showingFullScreen = true
***REMOVED***
***REMOVED******REMOVED***.sheet(isPresented: $showingFullScreen) {
***REMOVED******REMOVED******REMOVED***MediaDetailView(
***REMOVED******REMOVED******REMOVED******REMOVED***popupMedia: popupMedia,
***REMOVED******REMOVED******REMOVED******REMOVED***showingFullScreen: $showingFullScreen
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED***

struct ChartView: View {
***REMOVED***let popupMedia: PopupMedia
***REMOVED***let data: [ChartData]
***REMOVED***let isFullScreen: Bool

***REMOVED***init(popupMedia: PopupMedia, data: [ChartData], isFullScreen: Bool = false) {
***REMOVED******REMOVED***self.popupMedia = popupMedia
***REMOVED******REMOVED***self.data = data
***REMOVED******REMOVED***self.isFullScreen = isFullScreen
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***switch popupMedia.kind {
***REMOVED******REMOVED***case .barChart, .columnChart:
***REMOVED******REMOVED******REMOVED***BarChart(chartData: data, isColumnChart: (popupMedia.kind == .columnChart))
***REMOVED******REMOVED***case .pieChart:
***REMOVED******REMOVED******REMOVED***PieChart(chartData: data, showLegend: isFullScreen)
***REMOVED******REMOVED***case .lineChart:
***REMOVED******REMOVED******REMOVED***LineChart(chartData: data)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED***
***REMOVED***
