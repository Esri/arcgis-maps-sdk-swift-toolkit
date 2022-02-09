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

@MainActor
class CompassViewModelTests: XCTestCase {
***REMOVED******REMOVED***/ Asserts that accessibility labels are properly generated.
***REMOVED***func testCardinalAndIntercardinals() {
***REMOVED******REMOVED***var viewpoint = getViewpoint(0.0)
***REMOVED******REMOVED***let _viewpoint = Binding(get: { viewpoint ***REMOVED***, set: { viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = CompassViewModel(viewpoint: _viewpoint)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 0 degrees north"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***viewpoint = getViewpoint(23)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 337 degrees northwest"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***viewpoint = getViewpoint(68)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 292 degrees west"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***viewpoint = getViewpoint(113)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 247 degrees southwest"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***viewpoint = getViewpoint(158)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 202 degrees south"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***viewpoint = getViewpoint(203)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 157 degrees southeast"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***viewpoint = getViewpoint(248)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 112 degrees east"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***viewpoint = getViewpoint(293)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 67 degrees northeast"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***viewpoint = getViewpoint(293)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.viewpoint.heading,
***REMOVED******REMOVED******REMOVED***"Compass, heading 67 degrees northeast"
***REMOVED******REMOVED***)
***REMOVED***

***REMOVED******REMOVED***/ Asserts that the model accurately indicates when the compass should be hidden when autoHide is
***REMOVED******REMOVED***/ disabled.
***REMOVED***func testHiddenWithAutoHideOff() {
***REMOVED******REMOVED***let initialValue = 0.0
***REMOVED******REMOVED***let finalValue = 90.0
***REMOVED******REMOVED***var viewpoint = getViewpoint(initialValue)
***REMOVED******REMOVED***let binding = Binding(get: { viewpoint ***REMOVED***, set: { viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = CompassViewModel(viewpoint: binding, autoHide: false)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.hidden)
***REMOVED******REMOVED***viewpoint = getViewpoint(finalValue)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.hidden)
***REMOVED***

***REMOVED******REMOVED***/ Asserts that the model accurately indicates when the compass should be hidden when autoHide is
***REMOVED******REMOVED***/ enabled.
***REMOVED***func testHiddenWithAutoHideOn() {
***REMOVED******REMOVED***let initialValue = 0.0
***REMOVED******REMOVED***let finalValue = 90.0
***REMOVED******REMOVED***var viewpoint = getViewpoint(initialValue)
***REMOVED******REMOVED***let binding = Binding(get: { viewpoint ***REMOVED***, set: { viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = CompassViewModel(viewpoint: binding)
***REMOVED******REMOVED***XCTAssertTrue(viewModel.hidden)
***REMOVED******REMOVED***viewpoint = getViewpoint(finalValue)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.hidden)
***REMOVED***

***REMOVED******REMOVED***/ Asserts that the model correctly initializes when given only a viewpoint.
***REMOVED***func testInitWithViewpoint() {
***REMOVED******REMOVED***var viewpoint = getViewpoint(0.0)
***REMOVED******REMOVED***let _viewpoint = Binding(get: { viewpoint ***REMOVED***, set: { viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = CompassViewModel(viewpoint: _viewpoint)
***REMOVED******REMOVED***XCTAssertTrue(viewModel.viewpoint.rotation.isZero)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.height, 30.0)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.width, 30.0)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.autoHide, true)
***REMOVED***

***REMOVED******REMOVED***/ Asserts that the model correctly initializes when given a viewpoint and size.
***REMOVED***func testInitWithViewpointAndSize() {
***REMOVED******REMOVED***let initialRotationValue = 0.0
***REMOVED******REMOVED***let initialSizeValue = 90.0
***REMOVED******REMOVED***var viewpoint = getViewpoint(initialRotationValue)
***REMOVED******REMOVED***let _viewpoint = Binding(get: { viewpoint ***REMOVED***, set: { viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = CompassViewModel(
***REMOVED******REMOVED******REMOVED***viewpoint: _viewpoint,
***REMOVED******REMOVED******REMOVED***size: initialSizeValue
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertTrue(viewModel.viewpoint.rotation.isZero)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.width, initialSizeValue)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.height, initialSizeValue)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.autoHide, true)
***REMOVED***

***REMOVED******REMOVED***/ Asserts that the model correctly initializes when given only a viewpoint.
***REMOVED***func testInitWithViewpointAndSizeAndAutoHide() {
***REMOVED******REMOVED***let rotationValue = 0.0
***REMOVED******REMOVED***let sizeValue = 90.0
***REMOVED******REMOVED***let autoHide = false
***REMOVED******REMOVED***var viewpoint = getViewpoint(rotationValue)
***REMOVED******REMOVED***let _viewpoint = Binding(get: { viewpoint ***REMOVED***, set: { viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = CompassViewModel(
***REMOVED******REMOVED******REMOVED***viewpoint: _viewpoint,
***REMOVED******REMOVED******REMOVED***size: sizeValue,
***REMOVED******REMOVED******REMOVED***autoHide: autoHide
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertTrue(viewModel.viewpoint.rotation.isZero)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.width, sizeValue)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.height, sizeValue)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.autoHide, autoHide)
***REMOVED***

***REMOVED***func testResetHeading() {
***REMOVED******REMOVED***let initialValue = 0.5
***REMOVED******REMOVED***let finalValue = 0.0
***REMOVED******REMOVED***var viewpoint = getViewpoint(initialValue)
***REMOVED******REMOVED***let binding = Binding(get: { viewpoint ***REMOVED***, set: { viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = CompassViewModel(viewpoint: binding)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.viewpoint.rotation, initialValue)
***REMOVED******REMOVED***viewModel.resetHeading()
***REMOVED******REMOVED***XCTAssertEqual(viewModel.viewpoint.rotation, finalValue)
***REMOVED***
***REMOVED***

extension CompassViewModelTests {
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
