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

class CompassTests: XCTestCase {
***REMOVED******REMOVED***/ Asserts that accessibility labels are properly generated.
***REMOVED***func testCardinalAndIntercardinals() {
***REMOVED******REMOVED***var _viewpoint = getViewpoint(0.0)
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let compass = Compass(viewpoint: viewpoint)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***compass.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 0 degrees north"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***_viewpoint = getViewpoint(23)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***compass.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 337 degrees northwest"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***_viewpoint = getViewpoint(68)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***compass.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 292 degrees west"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***_viewpoint = getViewpoint(113)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***compass.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 247 degrees southwest"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***_viewpoint = getViewpoint(158)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***compass.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 202 degrees south"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***_viewpoint = getViewpoint(203)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***compass.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 157 degrees southeast"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***_viewpoint = getViewpoint(248)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***compass.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 112 degrees east"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***_viewpoint = getViewpoint(293)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***compass.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 67 degrees northeast"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***_viewpoint = getViewpoint(293)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***compass.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 67 degrees northeast"
***REMOVED******REMOVED***)
***REMOVED***

***REMOVED******REMOVED***/ Asserts that the model accurately indicates when the compass should be hidden when autoHide is
***REMOVED******REMOVED***/ disabled.
***REMOVED***func testHiddenWithAutoHideOff() {
***REMOVED******REMOVED***let initialValue = 0.0
***REMOVED******REMOVED***let finalValue = 90.0
***REMOVED******REMOVED***var _viewpoint = getViewpoint(initialValue)
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let compass = Compass(viewpoint: viewpoint, autoHide: false)
***REMOVED******REMOVED***XCTAssertFalse(compass.isHidden)
***REMOVED******REMOVED***_viewpoint = getViewpoint(finalValue)
***REMOVED******REMOVED***XCTAssertFalse(compass.isHidden)
***REMOVED***

***REMOVED******REMOVED***/ Asserts that the model accurately indicates when the compass should be hidden when autoHide is
***REMOVED******REMOVED***/ enabled.
***REMOVED***func testHiddenWithAutoHideOn() {
***REMOVED******REMOVED***let initialValue = 0.0
***REMOVED******REMOVED***let finalValue = 90.0
***REMOVED******REMOVED***var _viewpoint = getViewpoint(initialValue)
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let compass = Compass(viewpoint: viewpoint)
***REMOVED******REMOVED***XCTAssertTrue(compass.isHidden)
***REMOVED******REMOVED***_viewpoint = getViewpoint(finalValue)
***REMOVED******REMOVED***XCTAssertFalse(compass.isHidden)
***REMOVED***

***REMOVED******REMOVED***/ Asserts that the model correctly initializes when given only a viewpoint.
***REMOVED***func testInitWithViewpoint() {
***REMOVED******REMOVED***var _viewpoint = getViewpoint(0.0)
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let compass = Compass(viewpoint: viewpoint)
***REMOVED******REMOVED***XCTAssertTrue(compass.viewpoint.rotation.isZero)
***REMOVED******REMOVED***XCTAssertEqual(compass.isHidden, true)
***REMOVED***

***REMOVED******REMOVED***/ Asserts that the model correctly initializes when given only a viewpoint.
***REMOVED***func testInitWithViewpointAndAutoHide() {
***REMOVED******REMOVED***let autoHide = false
***REMOVED******REMOVED***var _viewpoint = getViewpoint(0)
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let compass = Compass(
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint,
***REMOVED******REMOVED******REMOVED***autoHide: autoHide
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertTrue(compass.viewpoint.rotation.isZero)
***REMOVED******REMOVED***XCTAssertEqual(compass.isHidden, false)
***REMOVED***

***REMOVED***func testResetHeading() {
***REMOVED******REMOVED***let initialValue = 0.5
***REMOVED******REMOVED***let finalValue = 0.0
***REMOVED******REMOVED***var _viewpoint = getViewpoint(initialValue)
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let compass = Compass(viewpoint: viewpoint)
***REMOVED******REMOVED***XCTAssertEqual(compass.viewpoint.rotation, initialValue)
***REMOVED******REMOVED***compass.resetHeading()
***REMOVED******REMOVED***XCTAssertEqual(compass.viewpoint.rotation, finalValue)
***REMOVED***
***REMOVED***

extension CompassTests {
***REMOVED******REMOVED***/ An arbitrary point to use for testing.
***REMOVED***var point: Point {
***REMOVED******REMOVED***Point(x: -117.19494, y: 34.05723, spatialReference: .wgs84)
***REMOVED***

***REMOVED******REMOVED***/ An arbitrary scale to use for testing.
***REMOVED***var scale: Double {
***REMOVED******REMOVED***10_000.00
***REMOVED***

***REMOVED******REMOVED***/ Builds viewpoints to use for tests.
***REMOVED******REMOVED***/ - Parameter rotation: The rotation to use for the resulting viewpoint.
***REMOVED******REMOVED***/ - Returns: A viewpoint object for tests.
***REMOVED***func getViewpoint(_ rotation: Double) -> Viewpoint {
***REMOVED******REMOVED***return Viewpoint(center: point, scale: scale, rotation: rotation)
***REMOVED***
***REMOVED***
