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

final class PieChartModel: ObservableObject {
***REMOVED***let pieSlices: [PieSlice]
***REMOVED***
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
***REMOVED***static var sliceColors: [Color] = [
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
***REMOVED***static func color(for index: Int) -> Color {
***REMOVED******REMOVED******REMOVED*** We don't want to just wrap color indices because we don't want
***REMOVED******REMOVED******REMOVED*** two adjacent slices to have the same color.  "extra" will skip the
***REMOVED******REMOVED******REMOVED*** the first color for the 2nd time through the list, skip the second
***REMOVED******REMOVED******REMOVED*** color the second time through the list, etc.
***REMOVED******REMOVED***let extra = index / sliceColors.count
***REMOVED******REMOVED***return sliceColors[(index + extra) % sliceColors.count].opacity(0.75)
***REMOVED***
***REMOVED***

class PieSlice: Identifiable {
***REMOVED***let fraction: Double
***REMOVED***let color: Color
***REMOVED***let name: String
***REMOVED***
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
