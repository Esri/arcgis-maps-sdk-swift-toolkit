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

***REMOVED***/ Represents the spinning needle at the center of the compass.
struct Needle: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NeedleQuadrant(color: .lightRed)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NeedleQuadrant(color: .darkRed)
#if os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.perspectiveRotationEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.degrees(180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 0, y: 1, z: 0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
#else
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotation3DEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.degrees(180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 0, y: 1, z: 0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
#endif
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NeedleQuadrant(color: .lightGray)
#if os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.perspectiveRotationEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.degrees(180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 1, y: 0, z: 0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
#else
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotation3DEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.degrees(180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 1, y: 0, z: 0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
#endif
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NeedleQuadrant(color: .darkGray)
#if os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.perspectiveRotationEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.degrees(180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 0, y: 1, z: 0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.perspectiveRotationEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.degrees(180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 1, y: 0, z: 0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
#else
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotation3DEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.degrees(180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 0, y: 1, z: 0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotation3DEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.degrees(180),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***axis: (x: 1, y: 0, z: 0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
#endif
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***NeedleCenter()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.aspectRatio(1/3, contentMode: .fit)
***REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED***width: min(geometry.size.width, geometry.size.height),
***REMOVED******REMOVED******REMOVED******REMOVED***height: min(geometry.size.width, geometry.size.height)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.scaleEffect(0.6)
***REMOVED***
***REMOVED******REMOVED***.environment(\.layoutDirection, .leftToRight)
***REMOVED***
***REMOVED***

***REMOVED***/ Represents the center of the spinning needle at the center of the compass.
struct NeedleCenter: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED***.scale(0.25)
***REMOVED******REMOVED******REMOVED***.foregroundColor(.bronze)
***REMOVED***
***REMOVED***

***REMOVED***/ Represents 1/4 (one triangle) of the spinning needle at the center of the compass.
struct NeedleQuadrant: View {
***REMOVED******REMOVED***/ The color of this needle quadrant.
***REMOVED***let color: Color
***REMOVED***
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
***REMOVED***
***REMOVED******REMOVED***/ The dark gray color of the compass needle.
***REMOVED***static let darkGray = Color(red: 128, green: 128, blue: 128)
***REMOVED***
***REMOVED******REMOVED***/ The dark red color of the compass needle.
***REMOVED***static let darkRed = Color(red: 124, green: 22, blue: 13)
***REMOVED***
***REMOVED******REMOVED***/ The light gray color of the compass needle.
***REMOVED***static let lightGray = Color(red: 169, green: 168, blue: 168)
***REMOVED***
***REMOVED******REMOVED***/ The light red color of the compass needle.
***REMOVED***static let lightRed = Color(red: 233, green: 51, blue: 35)
***REMOVED***
