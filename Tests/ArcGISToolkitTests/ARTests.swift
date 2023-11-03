// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import SwiftUI
import XCTest
@testable import ArcGISToolkit

@MainActor final class ARTests: XCTestCase {
    func testFlyoverLocationInitWithDefaults() throws {
        let sceneView = SceneView(scene: Scene())
        
        let view = FlyoverSceneView(
            initialLocation: .init(
                latitude: 34.056397,
                longitude: -117.195646
            ),
            translationFactor: 1_000
        ) { _ in
            sceneView
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
    
    func testFlyoverLocationInit() throws {
        let sceneView = SceneView(scene: Scene())
        
        let view = FlyoverSceneView(
            initialLocation: .init(
                latitude: 34.056397,
                longitude: -117.195646
            ),
            translationFactor: 1_000,
            initialHeading: 90
        ) { _ in
            sceneView
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
    
    func testFlyoverLatLongInitWithDefaults() throws {
        let sceneView = SceneView(scene: Scene())
        
        let view = FlyoverSceneView(
            initialLatitude: 34.056397,
            initialLongitude: -117.195646,
            initialAltitude: 1_000,
            translationFactor: 1_000
        ) { _ in
            sceneView
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
    
    func testFlyoverLatLongInit() throws {
        let sceneView = SceneView(scene: Scene())
        
        let view = FlyoverSceneView(
            initialLatitude: 34.056397,
            initialLongitude: -117.195646,
            initialAltitude: 1_000,
            translationFactor: 1_000,
            initialHeading: 180
        ) { _ in
            sceneView
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
    
    func testTableTopInit() throws {
        let sceneView = SceneView(scene: Scene())
        
        let view = TableTopSceneView(
            anchorPoint: .init(latitude: 34.056397, longitude: -117.195646),
            translationFactor: 1_000,
            clippingDistance: 1_000
        ) { _ in
            sceneView
        }
        
        XCTAssertEqual(view.anchorPoint.x, -117.195646)
        XCTAssertEqual(view.anchorPoint.y, 34.056397)
        
        XCTAssertEqual(view.translationFactor, 1_000)
        XCTAssertEqual(view.clippingDistance, 1_000)
        XCTAssertFalse(view.initialTransformationIsSet)
        XCTAssertFalse(view.coachingOverlayIsHidden)
    }
    
    func testTableTopARCoachingOverlayViewModifier() throws {
        let sceneView = SceneView(scene: Scene())
        
        let view = TableTopSceneView(
            anchorPoint: .init(latitude: 0, longitude: 0),
            translationFactor: 1_000,
            clippingDistance: 1_000
        ) { _ in
            sceneView
        }
        .coachingOverlayHidden(true)
        
        XCTAssertTrue(view.coachingOverlayIsHidden)
    }
}
