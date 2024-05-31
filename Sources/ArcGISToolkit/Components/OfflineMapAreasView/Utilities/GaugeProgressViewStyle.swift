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

***REMOVED***/ A circular gauge progress view style.
struct GaugeProgressViewStyle: ProgressViewStyle {
***REMOVED***private var strokeStyle: StrokeStyle { .init(lineWidth: 3, lineCap: .round) ***REMOVED***
***REMOVED***
***REMOVED***func makeBody(configuration: Configuration) -> some View {
***REMOVED******REMOVED***if let fractionCompleted = configuration.fractionCompleted {
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(Color(.systemGray5), style: strokeStyle)
***REMOVED******REMOVED******REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.trim(from: 0, to: fractionCompleted)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(.gray, style: strokeStyle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotationEffect(.degrees(-90))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.fixedSize()
***REMOVED***
***REMOVED***
***REMOVED***
