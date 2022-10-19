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

***REMOVED***/ A view displaying a popup media in a large format.
struct MediaDetailView : View {
***REMOVED******REMOVED***/ The popup media to display.
***REMOVED***let popupMedia: PopupMedia
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether the media should be drawn in a larger format.
***REMOVED***var isShowingDetailView: Binding<Bool>
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isShowingDetailView.wrappedValue = false
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Done")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.semibold)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom], 4)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(popupMedia.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(popupMedia.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title3)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***switch popupMedia.kind {
***REMOVED******REMOVED******REMOVED***case .image:
***REMOVED******REMOVED******REMOVED******REMOVED***if let sourceURL = popupMedia.value?.sourceURL {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AsyncImageView(url: sourceURL, refreshInterval: popupMedia.imageRefreshInterval)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let linkURL = popupMedia.value?.linkURL {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UIApplication.shared.open(linkURL)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if popupMedia.value?.linkURL != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Tap on the image for more information.")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .barChart, .columnChart, .pieChart, .lineChart:
***REMOVED******REMOVED******REMOVED******REMOVED***if #available(iOS 16, *) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ChartView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***popupMedia: popupMedia,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***data: ChartData.getChartData(from: popupMedia),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isShowingDetailView: true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CoreChartView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***popupMedia: popupMedia,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***data: ChartData.getChartData(from: popupMedia),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isShowingDetalView: true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 512, height: 512)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED***
***REMOVED***

struct CoreChartView: View {
***REMOVED***let popupMedia: PopupMedia
***REMOVED***let data: [ChartData]
***REMOVED***let isShowingDetalView: Bool
***REMOVED***@State var chartImage: ChartImage? = nil
***REMOVED******REMOVED***let parameters = ChartImageParameters(width: 2048, height: 2048)
***REMOVED***let parameters = ChartImageParameters(width: 1024, height: 1024)
***REMOVED******REMOVED***let parameters = ChartImageParameters(width: 256, height: 256)
***REMOVED******REMOVED***let parameters = ChartImageParameters(width: 512, height: 512)
***REMOVED******REMOVED***let parameters = ChartImageParameters(width: 261, height: 200)
***REMOVED******REMOVED***let parameters = ChartImageParameters(width: 128, height: 128)

***REMOVED***init(popupMedia: PopupMedia, data: [ChartData], isShowingDetalView: Bool = false) {
***REMOVED******REMOVED***self.popupMedia = popupMedia
***REMOVED******REMOVED***self.data = data
***REMOVED******REMOVED***self.isShowingDetalView = isShowingDetalView
***REMOVED******REMOVED***
***REMOVED******REMOVED***parameters.generateLegend = true
***REMOVED******REMOVED***parameters.screenScale = Float(UIScreen.main.scale)  ***REMOVED*** 2.0 in the simulator.
***REMOVED******REMOVED***parameters.style = .neutral
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if let image = chartImage?.image {
***REMOVED******REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: image)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: isShowingDetalView ? .fit : .fill)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***chartImage = try? await popupMedia.generateChart(parameters: parameters)
***REMOVED***
***REMOVED***
***REMOVED***
