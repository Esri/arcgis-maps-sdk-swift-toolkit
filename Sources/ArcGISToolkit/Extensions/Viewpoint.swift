***REMOVED*** Copyright 2023 Esri.

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

public extension Viewpoint {
***REMOVED******REMOVED***/ Creates a new viewpoint with the same target geometry and scale but with a new rotation.
***REMOVED******REMOVED***/ - Parameter rotation: The rotation for the new viewpoint.
***REMOVED******REMOVED***/ - Returns: A new viewpoint.
***REMOVED***func withRotation(_ rotation: Double) -> Viewpoint {
***REMOVED******REMOVED***switch self.kind {
***REMOVED******REMOVED***case .centerAndScale:
***REMOVED******REMOVED******REMOVED***return Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***center: self.targetGeometry as! Point,
***REMOVED******REMOVED******REMOVED******REMOVED***scale: self.targetScale,
***REMOVED******REMOVED******REMOVED******REMOVED***rotation: rotation
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .boundingGeometry:
***REMOVED******REMOVED******REMOVED***return Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***boundingGeometry: self.targetGeometry,
***REMOVED******REMOVED******REMOVED******REMOVED***rotation: rotation
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***return self
***REMOVED***
***REMOVED***
***REMOVED***
