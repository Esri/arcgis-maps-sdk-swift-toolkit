***REMOVED*** Copyright 2024 Esri
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

extension ProgressViewStyle where Self == GaugeProgressViewStyle {
***REMOVED******REMOVED***/ A progress view that visually indicates its progress with a gauge.
***REMOVED***static var gauge: Self { .init() ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A progress view that visually indicates its progress with a gauge,
***REMOVED******REMOVED***/ and also visually indicates cancel iconography.
***REMOVED***static var cancelGauge: Self { .init(showsCancelIcon: true) ***REMOVED***
***REMOVED***

***REMOVED***/ A circular gauge progress view style.
struct GaugeProgressViewStyle: ProgressViewStyle {
***REMOVED***var strokeColor = Color.accentColor
***REMOVED***var strokeWidth = 3.0
***REMOVED***var showsCancelIcon = false

***REMOVED***@ViewBuilder
***REMOVED***func makeBody(configuration: Configuration) -> some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.quinary, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
***REMOVED******REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED******REMOVED***.trim(from: 0, to: configuration.fractionCompleted ?? 0)
***REMOVED******REMOVED******REMOVED******REMOVED***.stroke(strokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
***REMOVED******REMOVED******REMOVED******REMOVED***.rotationEffect(.degrees(-90))
***REMOVED******REMOVED******REMOVED***if showsCancelIcon {
***REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fill(Color.accentColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 6, height: 6)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.frame(width: 20, height: 20)
***REMOVED******REMOVED***.padding(2)
***REMOVED***
***REMOVED***
