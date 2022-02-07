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

public struct Compass: View {
***REMOVED***var autoHide: Bool

***REMOVED***@Binding var viewpoint: Viewpoint

***REMOVED***@State var opacity: Double

***REMOVED***@State public var height: Double

***REMOVED***@State public var width: Double

***REMOVED***private var heading: String {
***REMOVED******REMOVED***"Compass, heading "
***REMOVED******REMOVED***+ Int(viewpoint.adjustedRotation.rounded()).description
***REMOVED******REMOVED***+ " degrees "
***REMOVED******REMOVED***+ Int(viewpoint.adjustedRotation.rounded()).asCardinalOrIntercardinal
***REMOVED***

***REMOVED***public init(
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint>,
***REMOVED******REMOVED***size: Double = 30.0,
***REMOVED******REMOVED***autoHide: Bool = true
***REMOVED***) {
***REMOVED******REMOVED***self._viewpoint = viewpoint
***REMOVED******REMOVED***self.autoHide = autoHide
***REMOVED******REMOVED***height = size
***REMOVED******REMOVED***width = size
***REMOVED******REMOVED***opacity = viewpoint.wrappedValue.rotation.isZero ? 0 : 1
***REMOVED***

***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***CompassBody()
***REMOVED******REMOVED******REMOVED***Needle()
***REMOVED******REMOVED******REMOVED******REMOVED***.rotationEffect(Angle(degrees: viewpoint.adjustedRotation))
***REMOVED***
***REMOVED******REMOVED***.frame(width: width, height: height)
***REMOVED******REMOVED***.opacity(opacity)
***REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED***viewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***center: viewpoint.targetGeometry.extent.center,
***REMOVED******REMOVED******REMOVED******REMOVED***scale: viewpoint.targetScale,
***REMOVED******REMOVED******REMOVED******REMOVED***rotation: 0.0
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***.onChange(of: viewpoint, perform: { _ in
***REMOVED******REMOVED******REMOVED***let hide = viewpoint.rotation.isZero && autoHide
***REMOVED******REMOVED******REMOVED***withAnimation(.default.delay(hide ? 0.25 : 0)) {
***REMOVED******REMOVED******REMOVED******REMOVED***opacity = hide ? 0 : 1
***REMOVED******REMOVED***
***REMOVED***)
***REMOVED******REMOVED***.accessibilityLabel(heading)
***REMOVED***
***REMOVED***

fileprivate extension Int {
***REMOVED***var asCardinalOrIntercardinal: String {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case 0...22, 338...360: return "north"
***REMOVED******REMOVED***case 23...67: return "northeast"
***REMOVED******REMOVED***case 68...112: return "east"
***REMOVED******REMOVED***case 113...157: return "southeast"
***REMOVED******REMOVED***case 158...202: return "south"
***REMOVED******REMOVED***case 203...247: return "southwest"
***REMOVED******REMOVED***case 248...290: return "west"
***REMOVED******REMOVED***case 291...337: return "northwest"
***REMOVED******REMOVED***default: return ""
***REMOVED***
***REMOVED***
***REMOVED***

fileprivate extension Viewpoint {
***REMOVED***var adjustedRotation: Double {
***REMOVED******REMOVED***self.rotation == 0 ? self.rotation : 360 - self.rotation
***REMOVED***
***REMOVED***
