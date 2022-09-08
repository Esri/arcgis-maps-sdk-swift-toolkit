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
import Charts

***REMOVED***/ A view displaying details for popup media.
@available(iOS 16, *)
struct LineChart: View {
***REMOVED******REMOVED***/ The chart data to display.
***REMOVED***let chartData: [ChartData]
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***Chart(chartData) {
***REMOVED******REMOVED******REMOVED******REMOVED***LineMark(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: .value("Field", $0.label),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: .value("Value", $0.value)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***PointMark(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: .value("Field", $0.label),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: .value("Value", $0.value)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.chartXAxis {
***REMOVED******REMOVED******REMOVED******REMOVED***AxisMarks { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AxisValueLabel(collisionResolution: .greedy, orientation: .verticalReversed)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AxisGridLine()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
