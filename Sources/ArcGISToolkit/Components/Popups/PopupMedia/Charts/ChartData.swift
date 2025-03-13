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

***REMOVED***/ Data for a chart, representing a label and value pair.
struct ChartData: Identifiable {
***REMOVED******REMOVED***/ A label for the data.
***REMOVED***let label: String
***REMOVED******REMOVED***/ The value of the data.
***REMOVED***let value: Double
***REMOVED******REMOVED***/ A chart color to be used for the data.
***REMOVED***let color: UIColor
***REMOVED***let id = UUID()
***REMOVED***
***REMOVED******REMOVED***/ Creates a `ChartData`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - label: The label for the data.
***REMOVED******REMOVED***/   - value: The value of the data.
***REMOVED***init(label: String, value: Any, color: UIColor) {
***REMOVED******REMOVED***self.label = label
***REMOVED******REMOVED***if let int = value as? Int {
***REMOVED******REMOVED******REMOVED***self.value = Double(int)
***REMOVED*** else if let float = value as? Float {
***REMOVED******REMOVED******REMOVED***self.value = Double(float)
***REMOVED*** else if let double = value as? Double {
***REMOVED******REMOVED******REMOVED***self.value = double
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self.value = 0
***REMOVED***
***REMOVED******REMOVED***self.color = color
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Gets the chart data for a `PopupMedia`.
***REMOVED******REMOVED***/ - Parameter popupMedia: The popup media to get the data for.
***REMOVED******REMOVED***/ - Returns: The array of chart data for the popup media.
***REMOVED***static func getChartData(from popupMedia: PopupMedia) -> [ChartData] {
***REMOVED******REMOVED***guard let labels = popupMedia.value?.labels,
***REMOVED******REMOVED******REMOVED***  let data = popupMedia.value?.data,
***REMOVED******REMOVED******REMOVED***  let colors = popupMedia.value?.chartColors else { return [] ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let chartData: [ChartData]
***REMOVED******REMOVED***let chartRawData = zip(labels, data).map { ($0, $1) ***REMOVED***
***REMOVED******REMOVED***if popupMedia.kind == .lineChart, let color = colors.first {
***REMOVED******REMOVED******REMOVED******REMOVED*** When the popup media type is line chart, the first color
***REMOVED******REMOVED******REMOVED******REMOVED*** will be the line color and other colors are ignored.
***REMOVED******REMOVED******REMOVED***chartData = chartRawData.map {
***REMOVED******REMOVED******REMOVED******REMOVED***ChartData(label: $0.0, value: $0.1, color: color)
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***var paddedColors = colors
***REMOVED******REMOVED******REMOVED***if paddedColors.count > labels.count {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Ignores the additional colors when the color array is
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** longer than field labels.
***REMOVED******REMOVED******REMOVED******REMOVED***paddedColors.removeLast(colors.count - labels.count)
***REMOVED******REMOVED*** else if colors.count < labels.count {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Uses a fallback color ramp when the color array is
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** shorter than field labels.
***REMOVED******REMOVED******REMOVED******REMOVED***for i in 0 ..< labels.count - colors.count {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***paddedColors += [color(for: i)]
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***chartData = zip(chartRawData, paddedColors).map {
***REMOVED******REMOVED******REMOVED******REMOVED***ChartData(label: $0.0, value: $0.1, color: $1)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***return chartData
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The pre-defined colors for a color ramp.
***REMOVED***private static let rampColors: [UIColor] = [
***REMOVED******REMOVED***.systemMint,
***REMOVED******REMOVED***.systemTeal,
***REMOVED******REMOVED***.systemGreen,
***REMOVED******REMOVED***.systemCyan,
***REMOVED******REMOVED***.systemYellow,
***REMOVED******REMOVED***.systemBlue,
***REMOVED******REMOVED***.systemOrange,
***REMOVED******REMOVED***.systemIndigo,
***REMOVED******REMOVED***.systemRed,
***REMOVED******REMOVED***.systemPurple,
***REMOVED******REMOVED***.systemPink,
***REMOVED******REMOVED***.systemBrown
***REMOVED***]
***REMOVED***
***REMOVED******REMOVED***/ Calculates a color for the given index.
***REMOVED******REMOVED***/ - Parameter index: The index of an element in color ramp array.
***REMOVED******REMOVED***/ - Returns: The color for the element at `index`.
***REMOVED***private static func color(for index: Int) -> UIColor {
***REMOVED******REMOVED******REMOVED*** We don't want to just wrap color indices because we don't want
***REMOVED******REMOVED******REMOVED*** two adjacent slices to have the same color. "extra" will skip the
***REMOVED******REMOVED******REMOVED*** the 1st color for the second time through the list, skip the 2nd
***REMOVED******REMOVED******REMOVED*** color the third time through the list, etc., ensuring that we
***REMOVED******REMOVED******REMOVED*** don't get adjacent colors.
***REMOVED******REMOVED***let extra = index / rampColors.count
***REMOVED******REMOVED***return rampColors[(index + extra) % rampColors.count]
***REMOVED***
***REMOVED***
