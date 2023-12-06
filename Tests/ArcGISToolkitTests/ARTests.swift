***REMOVED*** Copyright 2023 Esri
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
***REMOVED***
import XCTest
@testable ***REMOVED***Toolkit

@MainActor final class ARTests: XCTestCase {
***REMOVED***func testFlyoverLocationInitWithDefaults() throws {
***REMOVED******REMOVED***let sceneView = SceneView(scene: Scene())
***REMOVED******REMOVED***
***REMOVED******REMOVED***let view = FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLocation: .init(
***REMOVED******REMOVED******REMOVED******REMOVED***latitude: 34.056397,
***REMOVED******REMOVED******REMOVED******REMOVED***longitude: -117.195646
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***sceneView
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let initialCamera = view.initialCamera
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.x, -117.195646)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.y, 34.056397)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.heading, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.pitch, 90)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.roll, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(view.translationFactor, 1_000)
***REMOVED******REMOVED***XCTAssertTrue(view.shouldOrientToCompass)
***REMOVED***
***REMOVED***
***REMOVED***func testFlyoverLocationInit() throws {
***REMOVED******REMOVED***let sceneView = SceneView(scene: Scene())
***REMOVED******REMOVED***
***REMOVED******REMOVED***let view = FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLocation: .init(
***REMOVED******REMOVED******REMOVED******REMOVED***latitude: 34.056397,
***REMOVED******REMOVED******REMOVED******REMOVED***longitude: -117.195646
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000,
***REMOVED******REMOVED******REMOVED***initialHeading: 90
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***sceneView
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let initialCamera = view.initialCamera
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.x, -117.195646)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.y, 34.056397)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.heading, 90)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.pitch, 90)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.roll, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(view.translationFactor, 1_000)
***REMOVED******REMOVED***XCTAssertFalse(view.shouldOrientToCompass)
***REMOVED***
***REMOVED***
***REMOVED***func testFlyoverLatLongInitWithDefaults() throws {
***REMOVED******REMOVED***let sceneView = SceneView(scene: Scene())
***REMOVED******REMOVED***
***REMOVED******REMOVED***let view = FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLatitude: 34.056397,
***REMOVED******REMOVED******REMOVED***initialLongitude: -117.195646,
***REMOVED******REMOVED******REMOVED***initialAltitude: 1_000,
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***sceneView
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let initialCamera = view.initialCamera
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.x, -117.195646)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.y, 34.056397)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.heading, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.pitch, 90)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.roll, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(view.translationFactor, 1_000)
***REMOVED******REMOVED***XCTAssertTrue(view.shouldOrientToCompass)
***REMOVED***
***REMOVED***
***REMOVED***func testFlyoverLatLongInit() throws {
***REMOVED******REMOVED***let sceneView = SceneView(scene: Scene())
***REMOVED******REMOVED***
***REMOVED******REMOVED***let view = FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLatitude: 34.056397,
***REMOVED******REMOVED******REMOVED***initialLongitude: -117.195646,
***REMOVED******REMOVED******REMOVED***initialAltitude: 1_000,
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000,
***REMOVED******REMOVED******REMOVED***initialHeading: 180
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***sceneView
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let initialCamera = view.initialCamera
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.x, -117.195646)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.y, 34.056397)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.heading, 180)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.pitch, 90)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.roll, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(view.translationFactor, 1_000)
***REMOVED******REMOVED***XCTAssertFalse(view.shouldOrientToCompass)
***REMOVED***
***REMOVED***
***REMOVED***func testTableTopInit() throws {
***REMOVED******REMOVED***let sceneView = SceneView(scene: Scene())
***REMOVED******REMOVED***
***REMOVED******REMOVED***let view = TableTopSceneView(
***REMOVED******REMOVED******REMOVED***anchorPoint: .init(latitude: 34.056397, longitude: -117.195646),
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000,
***REMOVED******REMOVED******REMOVED***clippingDistance: 1_000
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***sceneView
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(view.anchorPoint.x, -117.195646)
***REMOVED******REMOVED***XCTAssertEqual(view.anchorPoint.y, 34.056397)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(view.translationFactor, 1_000)
***REMOVED******REMOVED***XCTAssertEqual(view.clippingDistance, 1_000)
***REMOVED******REMOVED***XCTAssertFalse(view.initialTransformationIsSet)
***REMOVED******REMOVED***XCTAssertFalse(view.coachingOverlayIsHidden)
***REMOVED***
***REMOVED***
***REMOVED***func testTableTopARCoachingOverlayViewModifier() throws {
***REMOVED******REMOVED***let sceneView = SceneView(scene: Scene())
***REMOVED******REMOVED***
***REMOVED******REMOVED***let view = TableTopSceneView(
***REMOVED******REMOVED******REMOVED***anchorPoint: .init(latitude: 0, longitude: 0),
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000,
***REMOVED******REMOVED******REMOVED***clippingDistance: 1_000
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***sceneView
***REMOVED***
***REMOVED******REMOVED***.coachingOverlayHidden(true)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(view.coachingOverlayIsHidden)
***REMOVED***
***REMOVED***
