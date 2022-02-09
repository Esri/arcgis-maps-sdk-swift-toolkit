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
***REMOVED***func testInitWithViewpoint() {
***REMOVED******REMOVED***var viewpoint = viewpoint(0.0)
***REMOVED******REMOVED***let _viewpoint = Binding(get: { viewpoint ***REMOVED***, set: { viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = CompassViewModel(viewpoint: _viewpoint)
***REMOVED******REMOVED***XCTAssertTrue(viewModel.viewpoint.rotation.isZero)
***REMOVED***

***REMOVED***func testInitWithViewpointAndSize() {
***REMOVED******REMOVED***let initialRotationValue = 90.0
***REMOVED******REMOVED***let initialSizeValue = 90.0
***REMOVED******REMOVED***var viewpoint = viewpoint(initialRotationValue)
***REMOVED******REMOVED***let _viewpoint = Binding(get: { viewpoint ***REMOVED***, set: { viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = CompassViewModel(
***REMOVED******REMOVED******REMOVED***viewpoint: _viewpoint,
***REMOVED******REMOVED******REMOVED***size: initialSizeValue
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertTrue(viewModel.width.isEqual(to: initialSizeValue))
***REMOVED******REMOVED***XCTAssertTrue(viewModel.height.isEqual(to: initialSizeValue))
***REMOVED***

***REMOVED***func testInitWithViewpointAndAutoHide() {
***REMOVED******REMOVED***let rotationValue = 90.0
***REMOVED******REMOVED***let sizeValue = 90.0
***REMOVED******REMOVED***let autoHide = false
***REMOVED******REMOVED***var viewpoint = viewpoint(rotationValue)
***REMOVED******REMOVED***let _viewpoint = Binding(get: { viewpoint ***REMOVED***, set: { viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = CompassViewModel(
***REMOVED******REMOVED******REMOVED***viewpoint: _viewpoint,
***REMOVED******REMOVED******REMOVED***size: sizeValue,
***REMOVED******REMOVED******REMOVED***autoHide: autoHide
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertTrue(viewModel.autoHide == autoHide)
***REMOVED***

***REMOVED***func testResetHeading() {
***REMOVED******REMOVED***let initialValue = 0.5
***REMOVED******REMOVED***let finalValue = 0.0
***REMOVED******REMOVED***var viewpoint = viewpoint(initialValue)
***REMOVED******REMOVED***let binding = Binding(get: { viewpoint ***REMOVED***, set: { viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = CompassViewModel(viewpoint: binding)
***REMOVED******REMOVED***XCTAssertTrue(viewModel.viewpoint.rotation.isEqual(to: initialValue))
***REMOVED******REMOVED***viewModel.resetHeading()
***REMOVED******REMOVED***XCTAssertTrue(viewModel.viewpoint.rotation.isEqual(to: finalValue))
***REMOVED***
***REMOVED***

extension CompassViewModelTests {
***REMOVED***var point: Point {
***REMOVED******REMOVED***Point(x: -117.19494, y: 34.05723, spatialReference: .wgs84)
***REMOVED***

***REMOVED***var scale: Double {
***REMOVED******REMOVED***10_000.00
***REMOVED***

***REMOVED***func viewpoint(_ rotation: Double) -> Viewpoint {
***REMOVED******REMOVED***return Viewpoint(center: point, scale: scale, rotation: rotation)
***REMOVED***
***REMOVED***
