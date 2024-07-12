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
***REMOVED******REMOVED***var dataTotal: Double = 0
***REMOVED******REMOVED***_ = chartData.map { dataTotal += $0.value ***REMOVED***
***REMOVED******REMOVED***for i in 0..<chartData.count {
***REMOVED******REMOVED******REMOVED***slices.append(
***REMOVED******REMOVED******REMOVED******REMOVED***PieSlice(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fraction: chartData[i].value / dataTotal,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: PieChartModel.color(for: i),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***name: chartData[i].label
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***pieSlices = slices
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The pre-defined colors for the pie slices.
***REMOVED***static let sliceColors: [Color] = [
***REMOVED******REMOVED***.mint,
***REMOVED******REMOVED***.teal,
***REMOVED******REMOVED***.green,
***REMOVED******REMOVED***.cyan,
***REMOVED******REMOVED***.yellow,
***REMOVED******REMOVED***.blue,
***REMOVED******REMOVED***.orange,
***REMOVED******REMOVED***.indigo,
***REMOVED******REMOVED***.red,
***REMOVED******REMOVED***.purple,
***REMOVED******REMOVED***.pink,
***REMOVED******REMOVED***.brown
***REMOVED***]
***REMOVED***
***REMOVED******REMOVED***/ Calculates a slice color for the given slice index.
***REMOVED******REMOVED***/ - Parameter index: The index of the slice.
***REMOVED******REMOVED***/ - Returns: The color for the slice at `index`.
***REMOVED***static func color(for index: Int) -> Color {
***REMOVED******REMOVED******REMOVED*** We don't want to just wrap color indices because we don't want
***REMOVED******REMOVED******REMOVED*** two adjacent slices to have the same color. "extra" will skip the
***REMOVED******REMOVED******REMOVED*** the 1st color for the second time through the list, skip the 2nd
***REMOVED******REMOVED******REMOVED*** color the third time through the list, etc., ensuring that we
***REMOVED******REMOVED******REMOVED*** don't get adjacent colors.
***REMOVED******REMOVED***let extra = index / sliceColors.count
***REMOVED******REMOVED***return sliceColors[(index + extra) % sliceColors.count].opacity(0.75)
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
