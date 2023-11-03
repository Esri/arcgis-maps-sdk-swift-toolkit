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
***REMOVED***
import XCTest
@testable ***REMOVED***Toolkit

@MainActor final class ARTests: XCTestCase {
***REMOVED***func testFlyoverLocationInitWithDefaults() throws {
***REMOVED******REMOVED***let sceneView = SceneView(scene: Scene())
***REMOVED******REMOVED***
***REMOVED******REMOVED***let view = FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLocation: .init(
***REMOVED******REMOVED******REMOVED******REMOVED***latitude: 0,
***REMOVED******REMOVED******REMOVED******REMOVED***longitude: 0
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***sceneView
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let initialCamera = view.getInitialCamera()
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.x, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.y, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.heading, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.pitch, 90)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.roll, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let translationFactor = view.getTranslationFactor()
***REMOVED******REMOVED***XCTAssertEqual(translationFactor, 1_000)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let cameraController = view.getCameraController()
***REMOVED******REMOVED***XCTAssertTrue(cameraController is TransformationMatrixCameraController)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let shouldOrientToCompass = view.getShouldOrientToCompass()
***REMOVED******REMOVED***XCTAssertTrue(shouldOrientToCompass)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let interfaceOrientation = view.getInterfaceOrientation()
***REMOVED******REMOVED***XCTAssertEqual(interfaceOrientation, .none)
***REMOVED***
***REMOVED***
***REMOVED***func testFlyoverLocationInit() throws {
***REMOVED******REMOVED***let sceneView = SceneView(scene: Scene())
***REMOVED******REMOVED***
***REMOVED******REMOVED***let view = FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLocation: .init(
***REMOVED******REMOVED******REMOVED******REMOVED***latitude: 0,
***REMOVED******REMOVED******REMOVED******REMOVED***longitude: 0
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000,
***REMOVED******REMOVED******REMOVED***initialHeading: 90
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***sceneView
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let initialCamera = view.getInitialCamera()
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.x, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.y, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.heading, 90)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.pitch, 90)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.roll, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let translationFactor = view.getTranslationFactor()
***REMOVED******REMOVED***XCTAssertEqual(translationFactor, 1_000)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let cameraController = view.getCameraController()
***REMOVED******REMOVED***XCTAssertTrue(cameraController is TransformationMatrixCameraController)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let shouldOrientToCompass = view.getShouldOrientToCompass()
***REMOVED******REMOVED***XCTAssertFalse(shouldOrientToCompass)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let interfaceOrientation = view.getInterfaceOrientation()
***REMOVED******REMOVED***XCTAssertEqual(interfaceOrientation, .none)
***REMOVED***
***REMOVED***
***REMOVED***func testFlyoverLatLongInitWithDefaults() throws {
***REMOVED******REMOVED***let sceneView = SceneView(scene: Scene())
***REMOVED******REMOVED***
***REMOVED******REMOVED***let view = FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLatitude: 0,
***REMOVED******REMOVED******REMOVED***initialLongitude: 0,
***REMOVED******REMOVED******REMOVED***initialAltitude: 1_000,
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***sceneView
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let initialCamera = view.getInitialCamera()
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.x, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.y, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.heading, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.pitch, 90)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.roll, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let translationFactor = view.getTranslationFactor()
***REMOVED******REMOVED***XCTAssertEqual(translationFactor, 1_000)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let cameraController = view.getCameraController()
***REMOVED******REMOVED***XCTAssertTrue(cameraController is TransformationMatrixCameraController)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let shouldOrientToCompass = view.getShouldOrientToCompass()
***REMOVED******REMOVED***XCTAssertTrue(shouldOrientToCompass)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let interfaceOrientation = view.getInterfaceOrientation()
***REMOVED******REMOVED***XCTAssertEqual(interfaceOrientation, .none)
***REMOVED***
***REMOVED***
***REMOVED***func testFlyoverLatLongInit() throws {
***REMOVED******REMOVED***let sceneView = SceneView(scene: Scene())
***REMOVED******REMOVED***
***REMOVED******REMOVED***let view = FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLatitude: 0,
***REMOVED******REMOVED******REMOVED***initialLongitude: 0,
***REMOVED******REMOVED******REMOVED***initialAltitude: 1_000,
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000,
***REMOVED******REMOVED******REMOVED***initialHeading: 180
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***sceneView
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let initialCamera = view.getInitialCamera()
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.x, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.y, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.heading, 180)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.pitch, 90)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.roll, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let translationFactor = view.getTranslationFactor()
***REMOVED******REMOVED***XCTAssertEqual(translationFactor, 1_000)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let cameraController = view.getCameraController()
***REMOVED******REMOVED***XCTAssertTrue(cameraController is TransformationMatrixCameraController)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let shouldOrientToCompass = view.getShouldOrientToCompass()
***REMOVED******REMOVED***XCTAssertFalse(shouldOrientToCompass)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let interfaceOrientation = view.getInterfaceOrientation()
***REMOVED******REMOVED***XCTAssertEqual(interfaceOrientation, .none)
***REMOVED***
***REMOVED***
***REMOVED***func testTableTopInit() throws {
***REMOVED******REMOVED***let sceneView = SceneView(scene: Scene())
***REMOVED******REMOVED***
***REMOVED******REMOVED***let view = TableTopSceneView(
***REMOVED******REMOVED******REMOVED***anchorPoint: .init(latitude: 0, longitude: 0),
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000,
***REMOVED******REMOVED******REMOVED***clippingDistance: 1_000
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***sceneView
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let cameraController = view.getCameraController()
***REMOVED******REMOVED***let initialCamera = cameraController.originCamera
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.x, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.location.y, 0)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.heading, 0, accuracy: 0.001)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.pitch, 90, accuracy: 0.001)
***REMOVED******REMOVED***XCTAssertEqual(initialCamera.roll, 0, accuracy: 0.001)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let translationFactor = view.getTranslationFactor()
***REMOVED******REMOVED***XCTAssertEqual(translationFactor, 1_000)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let clippingDistance = try XCTUnwrap(view.getClippingDistance())
***REMOVED******REMOVED***XCTAssertEqual(clippingDistance, 1_000)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let initialTransformationIsSet = view.getInitialTransformationIsSet()
***REMOVED******REMOVED***XCTAssertFalse(initialTransformationIsSet)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let coachingOverlayIsHidden = view.getCoachingOverlayIsHidden()
***REMOVED******REMOVED***XCTAssertFalse(coachingOverlayIsHidden)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let interfaceOrientation = view.getInterfaceOrientation()
***REMOVED******REMOVED***XCTAssertEqual(interfaceOrientation, .none)
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
***REMOVED******REMOVED***let coachingOverlayIsHidden = view.getCoachingOverlayIsHidden()
***REMOVED******REMOVED***XCTAssertTrue(coachingOverlayIsHidden)
***REMOVED***
***REMOVED***
