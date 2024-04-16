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

***REMOVED***/ A view displaying chart popup media.
struct ChartMediaView: View {
***REMOVED******REMOVED***/ The popup media to display.
***REMOVED***let popupMedia: PopupMedia
***REMOVED***
***REMOVED******REMOVED***/ The size of the media's frame.
***REMOVED***let mediaSize: CGSize
***REMOVED***
***REMOVED******REMOVED***/ The data to display in the chart.
***REMOVED***let chartData: [ChartData]
***REMOVED***
***REMOVED******REMOVED***/ Creates a `ChartMediaView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - popupMedia: The popup media to display.
***REMOVED******REMOVED***/   - mediaSize: The size of the media's frame.
***REMOVED***init(popupMedia: PopupMedia, mediaSize: CGSize) {
***REMOVED******REMOVED***self.popupMedia = popupMedia
***REMOVED******REMOVED***self.mediaSize = mediaSize
***REMOVED******REMOVED***self.chartData = ChartData.getChartData(from: popupMedia)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The corner radius for the view.
***REMOVED***private let cornerRadius: CGFloat = 8
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether the media should be drawn in a larger format.
***REMOVED***@State private var isShowingDetailView = false
***REMOVED***
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
***REMOVED******REMOVED******REMOVED***isShowingDetailView = true
***REMOVED***
***REMOVED******REMOVED***.sheet(isPresented: $isShowingDetailView) {
***REMOVED******REMOVED******REMOVED***MediaDetailView(
***REMOVED******REMOVED******REMOVED******REMOVED***popupMedia: popupMedia,
***REMOVED******REMOVED******REMOVED******REMOVED***isShowingDetailView: $isShowingDetailView
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view describing a chart.
struct ChartView: View {
***REMOVED******REMOVED***/ The popup media to display.
***REMOVED***let popupMedia: PopupMedia
***REMOVED***
***REMOVED******REMOVED***/ The data to display in the chart.
***REMOVED***let data: [ChartData]
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether the chart is being drawn in a larger format.
***REMOVED***let isShowingDetailView: Bool
***REMOVED***
***REMOVED******REMOVED***/ Creates a `ChartView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - popupMedia: The popup media to display.
***REMOVED******REMOVED***/   - data: The data to display in the chart.
***REMOVED******REMOVED***/   - isShowingDetailView: Specifies whether the chart is being drawn in a larger format.
***REMOVED***init(popupMedia: PopupMedia, data: [ChartData], isShowingDetailView: Bool = false) {
***REMOVED******REMOVED***self.popupMedia = popupMedia
***REMOVED******REMOVED***self.data = data
***REMOVED******REMOVED***self.isShowingDetailView = isShowingDetailView
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***switch popupMedia.kind {
***REMOVED******REMOVED***case .barChart, .columnChart:
***REMOVED******REMOVED******REMOVED***BarChart(
***REMOVED******REMOVED******REMOVED******REMOVED***chartData: data,
***REMOVED******REMOVED******REMOVED******REMOVED***isColumnChart: (popupMedia.kind == .columnChart),
***REMOVED******REMOVED******REMOVED******REMOVED***isShowingDetailView: isShowingDetailView
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .pieChart:
***REMOVED******REMOVED******REMOVED***PieChart(
***REMOVED******REMOVED******REMOVED******REMOVED***chartData: data,
***REMOVED******REMOVED******REMOVED******REMOVED***isShowingDetailView: isShowingDetailView
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .lineChart:
***REMOVED******REMOVED******REMOVED***LineChart(
***REMOVED******REMOVED******REMOVED******REMOVED***chartData: data,
***REMOVED******REMOVED******REMOVED******REMOVED***isShowingDetailView: isShowingDetailView
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED***
***REMOVED***
***REMOVED***
