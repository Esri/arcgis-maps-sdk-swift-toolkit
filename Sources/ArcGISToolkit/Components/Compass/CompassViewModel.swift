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

***REMOVED***/ Manages the state for a `Compass`.
@MainActor
final internal class CompassViewModel: ObservableObject {
***REMOVED******REMOVED***/ Acts as link between the compass and the parent map or scene view.
***REMOVED***@Binding
***REMOVED***var viewpoint: Viewpoint

***REMOVED******REMOVED***/ Determines if the compass should automatically hide/show itself when the parent view is oriented
***REMOVED******REMOVED***/ north.
***REMOVED***@Published
***REMOVED***public var autoHide: Bool

***REMOVED******REMOVED***/ Indicates if the compass should be hidden or visible based on the current viewpoint rotation and
***REMOVED******REMOVED***/ autoHide preference.
***REMOVED***public var hidden: Bool {
***REMOVED******REMOVED***viewpoint.rotation.isZero && autoHide
***REMOVED***

***REMOVED******REMOVED***/ Creates a `CompassViewModel`
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - viewpoint: Acts a communication link between the MapView or SceneView and the compass.
***REMOVED******REMOVED***/   - size: Enables a custom size configuuration for the compass. Default is 30.
***REMOVED******REMOVED***/   - autoHide: Determines if the compass automatically hides itself when the MapView or
***REMOVED******REMOVED***/   SceneView is oriented north.
***REMOVED***public init(
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint>,
***REMOVED******REMOVED***autoHide: Bool = true
***REMOVED***) {
***REMOVED******REMOVED***self._viewpoint = viewpoint
***REMOVED******REMOVED***self.autoHide = autoHide
***REMOVED***

***REMOVED******REMOVED***/ Resets the viewpoints `rotation` to zero.
***REMOVED***public func resetHeading() {
***REMOVED******REMOVED***self.viewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: viewpoint.targetGeometry.extent.center,
***REMOVED******REMOVED******REMOVED***scale: viewpoint.targetScale,
***REMOVED******REMOVED******REMOVED***rotation: .zero
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

internal extension Viewpoint {
***REMOVED******REMOVED***/ The viewpoint's `rotation` adjusted to offset any rotation applied to the parent view.
***REMOVED***var adjustedRotation: Double {
***REMOVED******REMOVED***rotation.isZero ? .zero : 360 - rotation
***REMOVED***

***REMOVED******REMOVED***/ A text description of the current heading, sutiable for accessibility voiceover.
***REMOVED***var heading: String {
***REMOVED******REMOVED***"Compass, heading "
***REMOVED******REMOVED***+ Int(self.adjustedRotation.rounded()).description
***REMOVED******REMOVED***+ " degrees "
***REMOVED******REMOVED***+ CompassDirection(self.adjustedRotation).rawValue
***REMOVED***
***REMOVED***
