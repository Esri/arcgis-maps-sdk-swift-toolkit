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
                latitude: 0,
                longitude: 0
            ),
            translationFactor: 1_000
        ) { _ in
            sceneView
        }
        
        let initialCamera = view.initialCamera
        XCTAssertEqual(initialCamera.location.x, 0)
        XCTAssertEqual(initialCamera.location.y, 0)
        XCTAssertEqual(initialCamera.heading, 0)
        XCTAssertEqual(initialCamera.pitch, 90)
        XCTAssertEqual(initialCamera.roll, 0)
        
        XCTAssertEqual(view.translationFactor, 1_000)
        
        let cameraController = view.getCameraController()
        XCTAssertTrue(cameraController is TransformationMatrixCameraController)
        
        XCTAssertTrue(view.shouldOrientToCompass)
        
        let interfaceOrientation = view.getInterfaceOrientation()
        XCTAssertEqual(interfaceOrientation, .none)
    }
    
    func testFlyoverLocationInit() throws {
        let sceneView = SceneView(scene: Scene())
        
        let view = FlyoverSceneView(
            initialLocation: .init(
                latitude: 0,
                longitude: 0
            ),
            translationFactor: 1_000,
            initialHeading: 90
        ) { _ in
            sceneView
        }
        
        let initialCamera = view.initialCamera
        XCTAssertEqual(initialCamera.location.x, 0)
        XCTAssertEqual(initialCamera.location.y, 0)
        XCTAssertEqual(initialCamera.heading, 90)
        XCTAssertEqual(initialCamera.pitch, 90)
        XCTAssertEqual(initialCamera.roll, 0)
        
        XCTAssertEqual(view.translationFactor, 1_000)
        
        let cameraController = view.getCameraController()
        XCTAssertTrue(cameraController is TransformationMatrixCameraController)
        
        XCTAssertFalse(view.shouldOrientToCompass)
        
        let interfaceOrientation = view.getInterfaceOrientation()
        XCTAssertEqual(interfaceOrientation, .none)
    }
    
    func testFlyoverLatLongInitWithDefaults() throws {
        let sceneView = SceneView(scene: Scene())
        
        let view = FlyoverSceneView(
            initialLatitude: 0,
            initialLongitude: 0,
            initialAltitude: 1_000,
            translationFactor: 1_000
        ) { _ in
            sceneView
        }
        
        let initialCamera = view.initialCamera
        XCTAssertEqual(initialCamera.location.x, 0)
        XCTAssertEqual(initialCamera.location.y, 0)
        XCTAssertEqual(initialCamera.heading, 0)
        XCTAssertEqual(initialCamera.pitch, 90)
        XCTAssertEqual(initialCamera.roll, 0)
        
        XCTAssertEqual(view.translationFactor, 1_000)
        
        let cameraController = view.getCameraController()
        XCTAssertTrue(cameraController is TransformationMatrixCameraController)
        
        XCTAssertTrue(view.shouldOrientToCompass)
        
        let interfaceOrientation = view.getInterfaceOrientation()
        XCTAssertEqual(interfaceOrientation, .none)
    }
    
    func testFlyoverLatLongInit() throws {
        let sceneView = SceneView(scene: Scene())
        
        let view = FlyoverSceneView(
            initialLatitude: 0,
            initialLongitude: 0,
            initialAltitude: 1_000,
            translationFactor: 1_000,
            initialHeading: 180
        ) { _ in
            sceneView
        }
        
        let initialCamera = view.initialCamera
        XCTAssertEqual(initialCamera.location.x, 0)
        XCTAssertEqual(initialCamera.location.y, 0)
        XCTAssertEqual(initialCamera.heading, 180)
        XCTAssertEqual(initialCamera.pitch, 90)
        XCTAssertEqual(initialCamera.roll, 0)
        
        XCTAssertEqual(view.translationFactor, 1_000)
        
        let cameraController = view.getCameraController()
        XCTAssertTrue(cameraController is TransformationMatrixCameraController)
        
        XCTAssertFalse(view.shouldOrientToCompass)
        
        let interfaceOrientation = view.getInterfaceOrientation()
        XCTAssertEqual(interfaceOrientation, .none)
    }
    
    func testTableTopInit() throws {
        let sceneView = SceneView(scene: Scene())
        
        let view = TableTopSceneView(
            anchorPoint: .init(latitude: 0, longitude: 0),
            translationFactor: 1_000,
            clippingDistance: 1_000
        ) { _ in
            sceneView
        }
        
        let initialCamera = view.getCameraController().originCamera
        XCTAssertEqual(initialCamera.location.x, 0)
        XCTAssertEqual(initialCamera.location.y, 0)
        XCTAssertEqual(initialCamera.heading, 0, accuracy: 0.001)
        XCTAssertEqual(initialCamera.pitch, 90, accuracy: 0.001)
        XCTAssertEqual(initialCamera.roll, 0, accuracy: 0.001)
        
        XCTAssertEqual(view.anchorPoint.x, 0)
        XCTAssertEqual(view.anchorPoint.y, 0)
        
        XCTAssertEqual(view.translationFactor, 1_000)
        XCTAssertEqual(view.clippingDistance, 1_000)
        XCTAssertFalse(view.initialTransformationIsSet)
        XCTAssertFalse(view.coachingOverlayIsHidden)
        
        let interfaceOrientation = view.getInterfaceOrientation()
        XCTAssertEqual(interfaceOrientation, .none)
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
