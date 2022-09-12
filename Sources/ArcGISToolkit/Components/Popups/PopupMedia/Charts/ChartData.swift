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

internal struct ChartData: Identifiable {
***REMOVED******REMOVED***/ A label for the data.
***REMOVED***var label: String
***REMOVED******REMOVED***/ The value of the data.
***REMOVED***var value: Double
***REMOVED***var id = UUID()
***REMOVED***
***REMOVED***init(label: String, value: Any) {
***REMOVED******REMOVED***self.label = label
***REMOVED******REMOVED***if let int32 = value as? Int32 {
***REMOVED******REMOVED******REMOVED***self.value = Double(int32)
***REMOVED*** else if let int = value as? Int {
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
