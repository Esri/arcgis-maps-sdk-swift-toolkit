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
import XCTest
@testable ***REMOVED***Toolkit

final class CompassTests: XCTestCase {
***REMOVED******REMOVED***/ Verifies that the compass accurately indicates when the compass should be hidden when
***REMOVED******REMOVED***/ `autoHide` is `false`.
***REMOVED***func testHiddenWithAutoHideOff() {
***REMOVED******REMOVED***let initialValue = 0.0
***REMOVED******REMOVED***let finalValue = 90.0
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = makeViewpoint(rotation: initialValue)
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let compass = Compass(viewpoint: viewpoint)
***REMOVED******REMOVED******REMOVED***.automaticallyHides(false) as! Compass
***REMOVED******REMOVED***XCTAssertFalse(compass.shouldHide)
***REMOVED******REMOVED***_viewpoint = makeViewpoint(rotation: finalValue)
***REMOVED******REMOVED***XCTAssertFalse(compass.shouldHide)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Verifies that the compass accurately indicates when the compass should be hidden when
***REMOVED******REMOVED***/ `autoHide` is `true` (which is the default).
***REMOVED***func testHiddenWithAutoHideOn() {
***REMOVED******REMOVED***let initialValue = 0.0
***REMOVED******REMOVED***let finalValue = 90.0
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = makeViewpoint(rotation: initialValue)
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let compass = Compass(viewpoint: viewpoint)
***REMOVED******REMOVED***XCTAssertTrue(compass.shouldHide)
***REMOVED******REMOVED***_viewpoint = makeViewpoint(rotation: finalValue)
***REMOVED******REMOVED***XCTAssertFalse(compass.shouldHide)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Verifies that the compass correctly initializes when given a `nil` viewpoint.
***REMOVED***func testInit() {
***REMOVED******REMOVED***let compass = Compass(viewpoint: .constant(nil))
***REMOVED******REMOVED***XCTAssertTrue(compass.shouldHide)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Verifies that the compass correctly initializes when given a `nil` viewpoint, and `autoHide` is
***REMOVED******REMOVED***/ `false`.
***REMOVED***func testAutomaticallyHidesNoAutoHide() {
***REMOVED******REMOVED***let compass = Compass(viewpoint: .constant(nil))
***REMOVED******REMOVED******REMOVED***.automaticallyHides(false) as! Compass
***REMOVED******REMOVED***XCTAssertFalse(compass.shouldHide)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Verifies that the compass correctly initializes when given only a viewpoint.
***REMOVED***func testInitWithViewpoint() {
***REMOVED******REMOVED***let compass = Compass(viewpoint: .constant(makeViewpoint(rotation: .zero)))
***REMOVED******REMOVED***XCTAssertTrue(compass.shouldHide)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Verifies that the compass correctly initializes when given only a viewpoint.
***REMOVED***func testInitWithViewpointAndAutoHide() {
***REMOVED******REMOVED***let compass = Compass(viewpoint: .constant(makeViewpoint(rotation: .zero)))
***REMOVED******REMOVED******REMOVED***.automaticallyHides(false) as! Compass
***REMOVED******REMOVED***XCTAssertFalse(compass.shouldHide)
***REMOVED***
***REMOVED***

extension CompassTests {
***REMOVED******REMOVED***/ An arbitrary point to use for testing.
***REMOVED***var point: Point {
***REMOVED******REMOVED***Point(x: -117.19494, y: 34.05723, spatialReference: .wgs84)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ An arbitrary scale to use for testing.
***REMOVED***var scale: Double {
***REMOVED******REMOVED***10_000.00
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Builds viewpoints to use for tests.
***REMOVED******REMOVED***/ - Parameter rotation: The rotation to use for the resulting viewpoint.
***REMOVED******REMOVED***/ - Returns: A viewpoint object for tests.
***REMOVED***func makeViewpoint(rotation: Double) -> Viewpoint {
***REMOVED******REMOVED***return Viewpoint(center: point, scale: scale, rotation: rotation)
***REMOVED***
***REMOVED***
