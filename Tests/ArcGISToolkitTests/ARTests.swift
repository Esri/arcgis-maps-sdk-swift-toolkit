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

#if !os(visionOS)
***REMOVED***
***REMOVED***
import XCTest
@testable ***REMOVED***Toolkit

final class ARTests: XCTestCase {
***REMOVED***@MainActor
***REMOVED***func testFlyoverLocationInitWithDefaults() throws {
***REMOVED******REMOVED***let view = FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLocation: .init(
***REMOVED******REMOVED******REMOVED******REMOVED***latitude: 34.056397,
***REMOVED******REMOVED******REMOVED******REMOVED***longitude: -117.195646
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: Scene())
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
***REMOVED***@MainActor
***REMOVED***func testFlyoverLocationInit() throws {
***REMOVED******REMOVED***let view = FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLocation: .init(
***REMOVED******REMOVED******REMOVED******REMOVED***latitude: 34.056397,
***REMOVED******REMOVED******REMOVED******REMOVED***longitude: -117.195646
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000,
***REMOVED******REMOVED******REMOVED***initialHeading: 90
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: Scene())
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
***REMOVED***@MainActor
***REMOVED***func testFlyoverLatLongInitWithDefaults() throws {
***REMOVED******REMOVED***let view = FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLatitude: 34.056397,
***REMOVED******REMOVED******REMOVED***initialLongitude: -117.195646,
***REMOVED******REMOVED******REMOVED***initialAltitude: 1_000,
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: Scene())
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
***REMOVED***@MainActor
***REMOVED***func testFlyoverLatLongInit() throws {
***REMOVED******REMOVED***let view = FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLatitude: 34.056397,
***REMOVED******REMOVED******REMOVED***initialLongitude: -117.195646,
***REMOVED******REMOVED******REMOVED***initialAltitude: 1_000,
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000,
***REMOVED******REMOVED******REMOVED***initialHeading: 180
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: Scene())
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
***REMOVED***@MainActor
***REMOVED***func testTableTopInit() throws {
***REMOVED******REMOVED***let view = TableTopSceneView(
***REMOVED******REMOVED******REMOVED***anchorPoint: .init(latitude: 34.056397, longitude: -117.195646),
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000,
***REMOVED******REMOVED******REMOVED***clippingDistance: 1_000
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: Scene())
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
***REMOVED***@MainActor
***REMOVED***func testTableTopARCoachingOverlayViewModifier() throws {
***REMOVED******REMOVED***let view = TableTopSceneView(
***REMOVED******REMOVED******REMOVED***anchorPoint: .init(latitude: 0, longitude: 0),
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000,
***REMOVED******REMOVED******REMOVED***clippingDistance: 1_000
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: Scene())
***REMOVED***
***REMOVED******REMOVED***.coachingOverlayHidden(true)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(view.coachingOverlayIsHidden)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testWorldScaleGeoTrackingInitWithDefaults() throws {
***REMOVED******REMOVED***let view = WorldScaleSceneView(
***REMOVED******REMOVED******REMOVED***trackingMode: .geoTracking
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: Scene())
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(view.clippingDistance)
***REMOVED******REMOVED***XCTAssertEqual(view.trackingMode, .geoTracking)
***REMOVED******REMOVED***XCTAssertEqual(view.calibrationButtonAlignment, .bottom)
***REMOVED******REMOVED***XCTAssertFalse(view.calibrationViewIsHidden)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testWorldScaleWorldTrackingInitWithDefaults() throws {
***REMOVED******REMOVED***let view = WorldScaleSceneView { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: Scene())
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(view.clippingDistance)
***REMOVED******REMOVED***XCTAssertEqual(view.trackingMode, .worldTracking)
***REMOVED******REMOVED***XCTAssertEqual(view.calibrationButtonAlignment, .bottom)
***REMOVED******REMOVED***XCTAssertFalse(view.calibrationViewIsHidden)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testWorldScalePreferGeoTrackingInitWithDefaults() throws {
***REMOVED******REMOVED***let view = WorldScaleSceneView(
***REMOVED******REMOVED******REMOVED***trackingMode: .preferGeoTracking
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: Scene())
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(view.clippingDistance)
***REMOVED******REMOVED***XCTAssertEqual(view.trackingMode, .preferGeoTracking)
***REMOVED******REMOVED***XCTAssertEqual(view.calibrationButtonAlignment, .bottom)
***REMOVED******REMOVED***XCTAssertFalse(view.calibrationViewIsHidden)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testWorldScaleInitWithClippingDistance() throws {
***REMOVED******REMOVED***let view = WorldScaleSceneView(
***REMOVED******REMOVED******REMOVED***clippingDistance: 1_000,
***REMOVED******REMOVED******REMOVED***trackingMode: .geoTracking
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: Scene())
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(view.clippingDistance, 1_000)
***REMOVED******REMOVED***XCTAssertEqual(view.trackingMode, .geoTracking)
***REMOVED******REMOVED***XCTAssertEqual(view.calibrationButtonAlignment, .bottom)
***REMOVED******REMOVED***XCTAssertFalse(view.calibrationViewIsHidden)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testWorldScaleCalibrationViewHiddenViewModifier() throws {
***REMOVED******REMOVED***let view = WorldScaleSceneView(
***REMOVED******REMOVED******REMOVED***trackingMode: .geoTracking
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: Scene())
***REMOVED***
***REMOVED******REMOVED***.calibrationViewHidden(true)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(view.calibrationViewIsHidden)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testWorldScaleCalibrationButtonAlignmentViewModifier() throws {
***REMOVED******REMOVED***let view = WorldScaleSceneView(
***REMOVED******REMOVED******REMOVED***trackingMode: .geoTracking
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***SceneView(scene: Scene())
***REMOVED***
***REMOVED******REMOVED***.calibrationButtonAlignment(.bottomLeading)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(view.calibrationButtonAlignment, .bottomLeading)
***REMOVED***
***REMOVED***
#endif
