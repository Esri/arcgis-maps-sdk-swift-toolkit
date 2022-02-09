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

***REMOVED***/ Manages the state for a `Compass`
@MainActor
final public class CompassViewModel: ObservableObject {
***REMOVED******REMOVED***/ Acts as link between the compass and the parent map or scene view.
***REMOVED***@Binding var viewpoint: Viewpoint

***REMOVED******REMOVED***/ Determines if the compass should automatically hide/show itself when the parent view is oriented
***REMOVED******REMOVED***/ north.
***REMOVED***@Published public var autoHide: Bool

***REMOVED******REMOVED***/ The height of the compass.
***REMOVED***@Published public var height: Double

***REMOVED******REMOVED***/ The width of the compass.
***REMOVED***@Published public var width: Double

***REMOVED******REMOVED***/ Indicates if the compass should be hidden or visible based on the current viewpoint rotation and
***REMOVED******REMOVED***/ autoHide preference.
***REMOVED***public var hidden: Bool {
***REMOVED******REMOVED***viewpoint.rotation.isZero && autoHide
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
***REMOVED***

***REMOVED******REMOVED***/ Resets the viewpoints `rotation` to zero.
***REMOVED***public func resetHeading() {
***REMOVED******REMOVED***self.viewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: viewpoint.targetGeometry.extent.center,
***REMOVED******REMOVED******REMOVED***scale: viewpoint.targetScale,
***REMOVED******REMOVED******REMOVED***rotation: 0.0
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

internal extension Int {
***REMOVED******REMOVED***/ A representation of an integer's associated cardinal or intercardinal direction.
***REMOVED***var asCardinalOrIntercardinal: String {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case 0...22, 338...360: return "north"
***REMOVED******REMOVED***case 23...67: return "northeast"
***REMOVED******REMOVED***case 68...112: return "east"
***REMOVED******REMOVED***case 113...157: return "southeast"
***REMOVED******REMOVED***case 158...202: return "south"
***REMOVED******REMOVED***case 203...247: return "southwest"
***REMOVED******REMOVED***case 248...292: return "west"
***REMOVED******REMOVED***case 293...337: return "northwest"
***REMOVED******REMOVED***default: return ""
***REMOVED***
***REMOVED***
***REMOVED***

internal extension Viewpoint {
***REMOVED******REMOVED***/ The viewpoint's `rotation` adjusted to offset any rotation applied to the parent view.
***REMOVED***var adjustedRotation: Double {
***REMOVED******REMOVED***self.rotation == 0 ? self.rotation : 360 - self.rotation
***REMOVED***

***REMOVED******REMOVED***/ A text description of the current heading, sutiable for accessibility voiceover.
***REMOVED***var heading: String {
***REMOVED******REMOVED***"Compass, heading "
***REMOVED******REMOVED***+ Int(self.adjustedRotation.rounded()).description
***REMOVED******REMOVED***+ " degrees "
***REMOVED******REMOVED***+ Int(self.adjustedRotation.rounded()).asCardinalOrIntercardinal
***REMOVED***
***REMOVED***
