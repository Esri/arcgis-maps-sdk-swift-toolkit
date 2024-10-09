// Copyright 2023 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#if !os(visionOS)
import ArcGIS
import SwiftUI
import XCTest
@testable import ArcGISToolkit

final class ARTests: XCTestCase {
    @MainActor
    func testFlyoverLocationInitWithDefaults() throws {
        let view = FlyoverSceneView(
            initialLocation: .init(
                latitude: 34.056397,
                longitude: -117.195646
            ),
            translationFactor: 1_000
        ) { _ in
            SceneView(scene: Scene())
        }
        
        let initialCamera = view.initialCamera
        XCTAssertEqual(initialCamera.location.x, -117.195646)
        XCTAssertEqual(initialCamera.location.y, 34.056397)
        XCTAssertEqual(initialCamera.heading, 0)
        XCTAssertEqual(initialCamera.pitch, 90)
        XCTAssertEqual(initialCamera.roll, 0)
        
        XCTAssertEqual(view.translationFactor, 1_000)
        XCTAssertTrue(view.shouldOrientToCompass)
    }
    
    @MainActor
    func testFlyoverLocationInit() throws {
        let view = FlyoverSceneView(
            initialLocation: .init(
                latitude: 34.056397,
                longitude: -117.195646
            ),
            translationFactor: 1_000,
            initialHeading: 90
        ) { _ in
            SceneView(scene: Scene())
        }
        
        let initialCamera = view.initialCamera
        XCTAssertEqual(initialCamera.location.x, -117.195646)
        XCTAssertEqual(initialCamera.location.y, 34.056397)
        XCTAssertEqual(initialCamera.heading, 90)
        XCTAssertEqual(initialCamera.pitch, 90)
        XCTAssertEqual(initialCamera.roll, 0)
        
        XCTAssertEqual(view.translationFactor, 1_000)
        XCTAssertFalse(view.shouldOrientToCompass)
    }
    
    @MainActor
    func testFlyoverLatLongInitWithDefaults() throws {
        let view = FlyoverSceneView(
            initialLatitude: 34.056397,
            initialLongitude: -117.195646,
            initialAltitude: 1_000,
            translationFactor: 1_000
        ) { _ in
            SceneView(scene: Scene())
        }
        
        let initialCamera = view.initialCamera
        XCTAssertEqual(initialCamera.location.x, -117.195646)
        XCTAssertEqual(initialCamera.location.y, 34.056397)
        XCTAssertEqual(initialCamera.heading, 0)
        XCTAssertEqual(initialCamera.pitch, 90)
        XCTAssertEqual(initialCamera.roll, 0)
        
        XCTAssertEqual(view.translationFactor, 1_000)
        XCTAssertTrue(view.shouldOrientToCompass)
    }
    
    @MainActor
    func testFlyoverLatLongInit() throws {
        let view = FlyoverSceneView(
            initialLatitude: 34.056397,
            initialLongitude: -117.195646,
            initialAltitude: 1_000,
            translationFactor: 1_000,
            initialHeading: 180
        ) { _ in
            SceneView(scene: Scene())
        }
        
        let initialCamera = view.initialCamera
        XCTAssertEqual(initialCamera.location.x, -117.195646)
        XCTAssertEqual(initialCamera.location.y, 34.056397)
        XCTAssertEqual(initialCamera.heading, 180)
        XCTAssertEqual(initialCamera.pitch, 90)
        XCTAssertEqual(initialCamera.roll, 0)
        
        XCTAssertEqual(view.translationFactor, 1_000)
        XCTAssertFalse(view.shouldOrientToCompass)
    }
    
    @MainActor
    func testTableTopInit() throws {
        let view = TableTopSceneView(
            anchorPoint: .init(latitude: 34.056397, longitude: -117.195646),
            translationFactor: 1_000,
            clippingDistance: 1_000
        ) { _ in
            SceneView(scene: Scene())
        }
        
        XCTAssertEqual(view.anchorPoint.x, -117.195646)
        XCTAssertEqual(view.anchorPoint.y, 34.056397)
        
        XCTAssertEqual(view.translationFactor, 1_000)
        XCTAssertEqual(view.clippingDistance, 1_000)
        XCTAssertFalse(view.initialTransformationIsSet)
        XCTAssertFalse(view.coachingOverlayIsHidden)
    }
    
    @MainActor
    func testTableTopARCoachingOverlayViewModifier() throws {
        let view = TableTopSceneView(
            anchorPoint: .init(latitude: 0, longitude: 0),
            translationFactor: 1_000,
            clippingDistance: 1_000
        ) { _ in
            SceneView(scene: Scene())
        }
        .coachingOverlayHidden(true)
        
        XCTAssertTrue(view.coachingOverlayIsHidden)
    }
    
    @MainActor
    func testWorldScaleGeoTrackingInitWithDefaults() throws {
        let view = WorldScaleSceneView(
            trackingMode: .geoTracking
        ) { _ in
            SceneView(scene: Scene())
        }
        
        XCTAssertNil(view.clippingDistance)
        XCTAssertEqual(view.trackingMode, .geoTracking)
        XCTAssertEqual(view.calibrationButtonAlignment, .bottom)
        XCTAssertFalse(view.calibrationViewIsHidden)
    }
    
    @MainActor
    func testWorldScaleWorldTrackingInitWithDefaults() throws {
        let view = WorldScaleSceneView { _ in
            SceneView(scene: Scene())
        }
        
        XCTAssertNil(view.clippingDistance)
        XCTAssertEqual(view.trackingMode, .worldTracking)
        XCTAssertEqual(view.calibrationButtonAlignment, .bottom)
        XCTAssertFalse(view.calibrationViewIsHidden)
    }
    
    @MainActor
    func testWorldScalePreferGeoTrackingInitWithDefaults() throws {
        let view = WorldScaleSceneView(
            trackingMode: .preferGeoTracking
        ) { _ in
            SceneView(scene: Scene())
        }
        
        XCTAssertNil(view.clippingDistance)
        XCTAssertEqual(view.trackingMode, .preferGeoTracking)
        XCTAssertEqual(view.calibrationButtonAlignment, .bottom)
        XCTAssertFalse(view.calibrationViewIsHidden)
    }
    
    @MainActor
    func testWorldScaleInitWithClippingDistance() throws {
        let view = WorldScaleSceneView(
            clippingDistance: 1_000,
            trackingMode: .geoTracking
        ) { _ in
            SceneView(scene: Scene())
        }
        
        XCTAssertEqual(view.clippingDistance, 1_000)
        XCTAssertEqual(view.trackingMode, .geoTracking)
        XCTAssertEqual(view.calibrationButtonAlignment, .bottom)
        XCTAssertFalse(view.calibrationViewIsHidden)
    }
    
    @MainActor
    func testWorldScaleCalibrationViewHiddenViewModifier() throws {
        let view = WorldScaleSceneView(
            trackingMode: .geoTracking
        ) { _ in
            SceneView(scene: Scene())
        }
        .calibrationViewHidden(true)
        
        XCTAssertTrue(view.calibrationViewIsHidden)
    }
    
    @MainActor
    func testWorldScaleCalibrationButtonAlignmentViewModifier() throws {
        let view = WorldScaleSceneView(
            trackingMode: .geoTracking
        ) { _ in
            SceneView(scene: Scene())
        }
        .calibrationButtonAlignment(.bottomLeading)
        
        XCTAssertEqual(view.calibrationButtonAlignment, .bottomLeading)
    }
}
#endif
