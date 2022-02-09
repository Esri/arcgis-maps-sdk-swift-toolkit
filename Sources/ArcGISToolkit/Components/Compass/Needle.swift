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

***REMOVED***/ Represents the spinning needle at the center of the compass.
struct Needle: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***VStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NeedleQuadrant(color: Color.redLight)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NeedleQuadrant(color: Color.redDark)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotation3DEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Angle(degrees: 180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 0, y: 1, z: 0))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NeedleQuadrant(color: Color.grayLight)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotation3DEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Angle(degrees: 180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 1, y: 0, z: 0))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NeedleQuadrant(color: Color.grayDark)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotation3DEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Angle(degrees: 180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 0, y: 1, z: 0))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotation3DEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Angle(degrees: 180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 1, y: 0, z: 0))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***NeedleCenter()
***REMOVED***
***REMOVED******REMOVED***.aspectRatio(1.0/3.0, contentMode: .fit)
***REMOVED******REMOVED***.scaleEffect(0.6)
***REMOVED***
***REMOVED***

***REMOVED***/ Represents the center of the spinning needle at the center of the compass.
struct NeedleCenter: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED***.scale(0.25)
***REMOVED******REMOVED******REMOVED***.foregroundColor(Color.bronze)
***REMOVED***
***REMOVED***

***REMOVED***/ Represents 1/4 (one triangle) of the spinning needle at the center of the compass.
struct NeedleQuadrant: View {
***REMOVED******REMOVED***/ The color of this needle quadrant.
***REMOVED***let color: Color

***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED***Path { path in
***REMOVED******REMOVED******REMOVED******REMOVED***let width = geometry.size.width
***REMOVED******REMOVED******REMOVED******REMOVED***let height = geometry.size.height
***REMOVED******REMOVED******REMOVED******REMOVED***path.move(to: CGPoint(x: 0, y: height))
***REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: width, y: 0))
***REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: CGPoint(x: width, y: height))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.fill(color)
***REMOVED***
***REMOVED***
***REMOVED***

private extension Color {
***REMOVED******REMOVED***/ The bronze color of the center of the compass needle.
***REMOVED***static let bronze = Color(red: 241, green: 169, blue: 59)

***REMOVED******REMOVED***/ The dark gray color of the compass needle.
***REMOVED***static let grayDark = Color(red: 128, green: 128, blue: 128)

***REMOVED******REMOVED***/ The light gray color of the compass needle.
***REMOVED***static let grayLight = Color(red: 169, green: 168, blue: 168)

***REMOVED******REMOVED***/ The dark red color of the compass needle.
***REMOVED***static let redDark = Color(red: 124, green: 22, blue: 13)

***REMOVED******REMOVED***/ The light red color of the compass needle.
***REMOVED***static let redLight = Color(red: 233, green: 51, blue: 35)
***REMOVED***
