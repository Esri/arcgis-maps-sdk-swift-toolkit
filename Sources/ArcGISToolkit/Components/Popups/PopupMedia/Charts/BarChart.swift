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

import Charts
***REMOVED***

***REMOVED***/ A view displaying details for bar chart popup media.
struct BarChart: View {
***REMOVED******REMOVED***/ The chart data to display.
***REMOVED***let chartData: [ChartData]
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether the chart is a "column" chart, with vertical bars. If it's
***REMOVED******REMOVED***/ not a "column" chart, then the bars are horizontal.
***REMOVED***let isColumnChart: Bool
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value determining whether to show the x axis labels for the chart.
***REMOVED***let showXAxisLabels: Bool
***REMOVED***
***REMOVED******REMOVED***/ Creates a `BarChart`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - chartData: The data to display in the chart.
***REMOVED******REMOVED***/   - isColumnChart: Specifying whether the chart is a "column" chart, with vertical bars.
***REMOVED******REMOVED***/   - isShowingDetailView: Specifies whether the chart is being drawn in a larger format.
***REMOVED***init(chartData: [ChartData], isColumnChart: Bool, isShowingDetailView: Bool = false) {
***REMOVED******REMOVED***self.chartData = chartData
***REMOVED******REMOVED***self.isColumnChart = isColumnChart
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Only show the x axis labels if we're being shown in a detail view.
***REMOVED******REMOVED***showXAxisLabels = isShowingDetailView
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Chart(chartData) {
***REMOVED******REMOVED******REMOVED***if isColumnChart {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Vertical bars.
***REMOVED******REMOVED******REMOVED******REMOVED***BarMark(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: .value(String.field, $0.label),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: .value(String.value, $0.value)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Horizontal bars.
***REMOVED******REMOVED******REMOVED******REMOVED***BarMark(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: .value(String.value, $0.value),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: .value(String.field, $0.label)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.chartXAxis {
***REMOVED******REMOVED******REMOVED***AxisMarks { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***if showXAxisLabels {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AxisValueLabel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***collisionResolution: .greedy,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: .verticalReversed
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
