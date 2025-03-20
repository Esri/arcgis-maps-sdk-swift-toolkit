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

***REMOVED***/ The view model for pie charts.
@MainActor
final class PieChartModel: ObservableObject {
***REMOVED******REMOVED***/ The slices that make up the pie chart.
***REMOVED***let pieSlices: [PieSlice]
***REMOVED***
***REMOVED******REMOVED***/ Creates a `PieChartModel`
***REMOVED******REMOVED***/ - Parameter chartData: The data used for the pie chart.
***REMOVED***init(chartData: [ChartData]) {
***REMOVED******REMOVED***var slices = [PieSlice]()
***REMOVED******REMOVED***let dataTotal = chartData.reduce(0) { $0 + $1.value ***REMOVED***
***REMOVED******REMOVED***for i in 0..<chartData.count {
***REMOVED******REMOVED******REMOVED***let data = chartData[i]
***REMOVED******REMOVED******REMOVED***slices.append(
***REMOVED******REMOVED******REMOVED******REMOVED***PieSlice(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fraction: data.value / dataTotal,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: Color(data.color),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***name: data.label
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***pieSlices = slices
***REMOVED***
***REMOVED***

***REMOVED***/ A single slice of a pie chart.
final class PieSlice: Identifiable {
***REMOVED******REMOVED***/ The fraction of the whole the slice represents.
***REMOVED***let fraction: Double
***REMOVED***
***REMOVED******REMOVED***/ The color of the slice.
***REMOVED***let color: Color
***REMOVED***
***REMOVED******REMOVED***/ The name of the slice.
***REMOVED***let name: String
***REMOVED***
***REMOVED******REMOVED***/ Creates a `PieSlice`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - fraction: The fraction of the whole the slice represents.
***REMOVED******REMOVED***/   - color: The color of the slice.
***REMOVED******REMOVED***/   - name: The name of the slice.
***REMOVED***init(fraction: Double, color: Color, name: String) {
***REMOVED******REMOVED***self.fraction = fraction
***REMOVED******REMOVED***self.color = color
***REMOVED******REMOVED***self.name = name
***REMOVED***
***REMOVED***

extension PieSlice: Equatable {
***REMOVED***static func == (lhs: PieSlice, rhs: PieSlice) -> Bool {
***REMOVED******REMOVED***lhs.fraction == rhs.fraction &&
***REMOVED******REMOVED***lhs.color == rhs.color &&
***REMOVED******REMOVED***lhs.name == rhs.name
***REMOVED***
***REMOVED***

extension PieSlice: Hashable {
***REMOVED***func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(self.fraction)
***REMOVED******REMOVED***hasher.combine(self.color)
***REMOVED******REMOVED***hasher.combine(self.name)
***REMOVED***
***REMOVED***
