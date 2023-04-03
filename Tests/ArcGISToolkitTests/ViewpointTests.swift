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
import XCTest
@testable ***REMOVED***Toolkit

final class ViewpointTests: XCTestCase {
***REMOVED***func testWithRotation() async {
***REMOVED******REMOVED***let viewpoint = Viewpoint(center: .esriRedlands, scale: 15_000)
***REMOVED******REMOVED***let expectedViewpoint = viewpoint.withRotation(45)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(expectedViewpoint.rotation, 45)
***REMOVED******REMOVED***XCTAssertEqual(expectedViewpoint.targetScale, viewpoint.targetScale)
***REMOVED******REMOVED***XCTAssertEqual(expectedViewpoint.targetGeometry, viewpoint.targetGeometry)
***REMOVED***
***REMOVED***
***REMOVED***func testWithRotationWithBoundingGeometry() {
***REMOVED******REMOVED***let rotatedViewpoint = Viewpoint(boundingGeometry: Polyline.simple.extent, rotation: -45)
***REMOVED******REMOVED***XCTAssertEqual(rotatedViewpoint.rotation, -45)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let nonRotatedViewpoint = rotatedViewpoint.withRotation(.zero)
***REMOVED******REMOVED***XCTAssertEqual(nonRotatedViewpoint.rotation, 0)
***REMOVED******REMOVED***XCTAssertEqual(nonRotatedViewpoint.targetGeometry, rotatedViewpoint.targetGeometry)
***REMOVED***
***REMOVED***
***REMOVED***func testWithRotationWithCenterAndScale() {
***REMOVED******REMOVED***let rotatedViewpoint = Viewpoint(center: .esriRedlands, scale: 1_000, rotation: 45)
***REMOVED******REMOVED***XCTAssertEqual(rotatedViewpoint.rotation, 45)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let nonRotatedViewpoint = rotatedViewpoint.withRotation(.zero)
***REMOVED******REMOVED***XCTAssertEqual(nonRotatedViewpoint.rotation, 0)
***REMOVED******REMOVED***XCTAssertEqual(nonRotatedViewpoint.targetScale, rotatedViewpoint.targetScale)
***REMOVED******REMOVED***XCTAssertEqual(nonRotatedViewpoint.targetGeometry, rotatedViewpoint.targetGeometry)
***REMOVED***
***REMOVED***

extension Point {
***REMOVED***static var esriRedlands: Point {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***x: -117.19494,
***REMOVED******REMOVED******REMOVED***y: 34.05723,
***REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private extension Polyline {
***REMOVED***static var simple: Polyline {
***REMOVED******REMOVED***.init(points: [
***REMOVED******REMOVED******REMOVED***Point(x: -117, y: 34, spatialReference: .wgs84),
***REMOVED******REMOVED******REMOVED***Point(x: -116, y: 34, spatialReference: .wgs84),
***REMOVED******REMOVED******REMOVED***Point(x: -116, y: 33, spatialReference: .wgs84)
***REMOVED******REMOVED***])
***REMOVED***
***REMOVED***
