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

***REMOVED***/ A view displaying details for pie chart popup media.
@MainActor
struct PieChart: View {
***REMOVED******REMOVED***/ The view model for the pie chart.
***REMOVED***@ObservedObject private var viewModel: PieChartModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value determining whether to show the legend for the chart.
***REMOVED***let showLegend: Bool
***REMOVED***
***REMOVED***@Environment(\.isPortraitOrientation) var isPortraitOrientation
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value denoting if the view should be shown as regular width.
***REMOVED***var isRegularWidth: Bool {
***REMOVED******REMOVED***!isPortraitOrientation
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `PieChart`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - chartData: The data to display in the chart.
***REMOVED******REMOVED***/   - isShowingDetailView: Specifies whether the chart is being drawn in a larger format.
***REMOVED***init(chartData: [ChartData], isShowingDetailView: Bool = false) {
***REMOVED******REMOVED***_viewModel = ObservedObject(wrappedValue: PieChartModel(chartData: chartData))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Only show the legend if we're being shown in a detail view.
***REMOVED******REMOVED***showLegend = isShowingDetailView
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Pie(viewModel: viewModel)
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***if showLegend {
***REMOVED******REMOVED******REMOVED***makeLegend(slices: viewModel.pieSlices)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a legend view for a pie chart.
***REMOVED******REMOVED***/ - Parameter slices: The slices that make up the pie chart.
***REMOVED******REMOVED***/ - Returns: A view representing a pie chart legend.
***REMOVED***@ViewBuilder func makeLegend(slices: [PieSlice]) -> some View {
***REMOVED******REMOVED***LazyVGrid(
***REMOVED******REMOVED******REMOVED***columns: Array(
***REMOVED******REMOVED******REMOVED******REMOVED***repeating: GridItem(.flexible(), alignment: .top),
***REMOVED******REMOVED******REMOVED******REMOVED***count: isRegularWidth ? 3 : 2
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***ForEach(slices) { slice in
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.gray, lineWidth: 1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 20, height: 20)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(slice.color)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(slice.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view representing a pie chart.
@MainActor
struct Pie: View {
***REMOVED******REMOVED***/ The view model for the pie chart.
***REMOVED***@ObservedObject private var viewModel: PieChartModel
***REMOVED***
***REMOVED******REMOVED***/ Creates a Pie view.
***REMOVED******REMOVED***/ - Parameter viewModel: The view model for the pie chart.
***REMOVED***init(viewModel: PieChartModel) {
***REMOVED******REMOVED***self.viewModel = viewModel
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED***let radius = min(geometry.size.width, geometry.size.height) / 2.0
***REMOVED******REMOVED******REMOVED***let center = CGPoint(
***REMOVED******REMOVED******REMOVED******REMOVED***x: geometry.size.width / 2.0,
***REMOVED******REMOVED******REMOVED******REMOVED***y: geometry.size.height / 2.0
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***var startAngle: Double = -90
***REMOVED******REMOVED******REMOVED***ForEach(viewModel.pieSlices, id: \.self) { slice in
***REMOVED******REMOVED******REMOVED******REMOVED***let endAngle = startAngle + slice.fraction * 360.0
***REMOVED******REMOVED******REMOVED******REMOVED***let path = Path { pieChart in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pieChart.move(to: center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pieChart.addArc(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***center: center,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: radius,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***startAngle: .degrees(startAngle),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***endAngle: .degrees(endAngle),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***clockwise: false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pieChart.closeSubpath()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***startAngle = endAngle
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***path.fill(slice.color)
***REMOVED******REMOVED******REMOVED******REMOVED***path.stroke(.gray, lineWidth: 0.5)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
