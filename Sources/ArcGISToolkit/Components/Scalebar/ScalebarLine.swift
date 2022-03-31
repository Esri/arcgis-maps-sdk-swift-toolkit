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

extension Scalebar {
***REMOVED******REMOVED***/ Provides simple and predictable line creation.
***REMOVED***struct Line {
***REMOVED******REMOVED******REMOVED***/ The stroke width used to produce a line.
***REMOVED******REMOVED***private static let strokeWidth = 4.0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A basic line.
***REMOVED******REMOVED***private struct basic: View {
***REMOVED******REMOVED******REMOVED******REMOVED***/ The width of the line.
***REMOVED******REMOVED******REMOVED***var width: Double
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***/ The color used to fill the line.
***REMOVED******REMOVED******REMOVED***let color: Color = .white
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED******REMOVED***Path { path in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: Double.zero, y: .zero))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: width, y: .zero))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: width, y: strokeWidth))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: .zero, y: strokeWidth))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: Double.zero, y: .zero))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.fill(color)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A horizontally oriented line
***REMOVED******REMOVED***struct basicHorizontal: View {
***REMOVED******REMOVED******REMOVED******REMOVED***/ The width of the line.
***REMOVED******REMOVED******REMOVED***var width: CGFloat
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED******REMOVED***basic(width: width)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: width, height: strokeWidth)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.cornerRadius(strokeWidth/2)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A vertically oriented line
***REMOVED******REMOVED***struct basicVertical: View {
***REMOVED******REMOVED******REMOVED******REMOVED***/ The height of the line.
***REMOVED******REMOVED******REMOVED***var height: CGFloat
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED******REMOVED***basic(width: height)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotationEffect(Angle(degrees: 90), anchor: .topLeading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.offset(x: strokeWidth)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: strokeWidth, height: height)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.cornerRadius(strokeWidth/2)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
