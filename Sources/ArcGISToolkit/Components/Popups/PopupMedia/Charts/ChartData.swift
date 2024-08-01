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
***REMOVED***let id = UUID()
***REMOVED***
***REMOVED******REMOVED***/ Creates a `ChartData`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - label: The label for the data.
***REMOVED******REMOVED***/   - value: The value of the data.
***REMOVED***init(label: String, value: Any) {
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
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Gets the chart data for a `PopupMedia`.
***REMOVED******REMOVED***/ - Parameter popupMedia: The popup media to get the data for.
***REMOVED******REMOVED***/ - Returns: The array of chart data for the popup media.
***REMOVED***static func getChartData(from popupMedia: PopupMedia) -> [ChartData] {
***REMOVED******REMOVED***guard let labels = popupMedia.value?.labels,
***REMOVED******REMOVED******REMOVED***  let data = popupMedia.value?.data else { return [] ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let chartRawData = zip(labels, data).map { ($0, $1) ***REMOVED***
***REMOVED******REMOVED***let chartData = chartRawData.map {
***REMOVED******REMOVED******REMOVED***ChartData(label: $0.0, value: $0.1)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return chartData
***REMOVED***
***REMOVED***
