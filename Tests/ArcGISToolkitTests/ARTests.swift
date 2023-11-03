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
    func testFlyOverLocationInitWithDefaults() throws {
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
        
        let initialCamera = view.getInitialCamera()
        XCTAssertEqual(initialCamera.location.x, 0)
        XCTAssertEqual(initialCamera.location.y, 0)
        XCTAssertEqual(initialCamera.heading, 0)
        XCTAssertEqual(initialCamera.pitch, 90)
        XCTAssertEqual(initialCamera.roll, 0)
        
        let translationFactor = view.getTranslationFactor()
        XCTAssertEqual(translationFactor, 1_000)
        
        let cameraController = view.getCameraController()
        XCTAssertTrue(cameraController is TransformationMatrixCameraController)
        
        let shouldOrientToCompass = view.getShouldOrientToCompass()
        XCTAssertTrue(shouldOrientToCompass)
        
        let interfaceOrientation = view.getInterfaceOrientation()
        XCTAssertEqual(interfaceOrientation, .none)
    }
    
    func testFlyOverLocationInit() throws {
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
        
        let initialCamera = view.getInitialCamera()
        XCTAssertEqual(initialCamera.location.x, 0)
        XCTAssertEqual(initialCamera.location.y, 0)
        XCTAssertEqual(initialCamera.heading, 90)
        XCTAssertEqual(initialCamera.pitch, 90)
        XCTAssertEqual(initialCamera.roll, 0)
        
        let translationFactor = view.getTranslationFactor()
        XCTAssertEqual(translationFactor, 1_000)
        
        let cameraController = view.getCameraController()
        XCTAssertTrue(cameraController is TransformationMatrixCameraController)
        
        let shouldOrientToCompass = view.getShouldOrientToCompass()
        XCTAssertFalse(shouldOrientToCompass)
        
        let interfaceOrientation = view.getInterfaceOrientation()
        XCTAssertEqual(interfaceOrientation, .none)
    }
    
    func testFlyOverLatLongInitWithDefaults() throws {
        let sceneView = SceneView(scene: Scene())
        
        let view = FlyoverSceneView(
            initialLatitude: 0,
            initialLongitude: 0,
            initialAltitude: 1_000,
            translationFactor: 1_000
        ) { _ in
            sceneView
        }
        
        let initialCamera = view.getInitialCamera()
        XCTAssertEqual(initialCamera.location.x, 0)
        XCTAssertEqual(initialCamera.location.y, 0)
        XCTAssertEqual(initialCamera.heading, 0)
        XCTAssertEqual(initialCamera.pitch, 90)
        XCTAssertEqual(initialCamera.roll, 0)
        
        let translationFactor = view.getTranslationFactor()
        XCTAssertEqual(translationFactor, 1_000)
        
        let cameraController = view.getCameraController()
        XCTAssertTrue(cameraController is TransformationMatrixCameraController)
        
        let shouldOrientToCompass = view.getShouldOrientToCompass()
        XCTAssertTrue(shouldOrientToCompass)
        
        let interfaceOrientation = view.getInterfaceOrientation()
        XCTAssertEqual(interfaceOrientation, .none)
    }
    
    func testFlyOverLatLongInit() throws {
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
        
        let initialCamera = view.getInitialCamera()
        XCTAssertEqual(initialCamera.location.x, 0)
        XCTAssertEqual(initialCamera.location.y, 0)
        XCTAssertEqual(initialCamera.heading, 180)
        XCTAssertEqual(initialCamera.pitch, 90)
        XCTAssertEqual(initialCamera.roll, 0)
        
        let translationFactor = view.getTranslationFactor()
        XCTAssertEqual(translationFactor, 1_000)
        
        let cameraController = view.getCameraController()
        XCTAssertTrue(cameraController is TransformationMatrixCameraController)
        
        let shouldOrientToCompass = view.getShouldOrientToCompass()
        XCTAssertFalse(shouldOrientToCompass)
        
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
        
        let cameraController = view.getCameraController()
        let initialCamera = cameraController.originCamera
        XCTAssertEqual(initialCamera.location.x, 0)
        XCTAssertEqual(initialCamera.location.y, 0)
        XCTAssertEqual(initialCamera.heading, 0, accuracy: 0.001)
        XCTAssertEqual(initialCamera.pitch, 90, accuracy: 0.001)
        XCTAssertEqual(initialCamera.roll, 0, accuracy: 0.001)
        
        let translationFactor = view.getTranslationFactor()
        XCTAssertEqual(translationFactor, 1_000)
        
        let clippingDistance = try XCTUnwrap(view.getClippingDistance())
        XCTAssertEqual(clippingDistance, 1_000)
        
        let initialTransformationIsSet = view.getInitialTransformationIsSet()
        XCTAssertFalse(initialTransformationIsSet)
        
        let coachingOverlayIsHidden = view.getCoachingOverlayIsHidden()
        XCTAssertFalse(coachingOverlayIsHidden)
        
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
        
        let coachingOverlayIsHidden = view.getCoachingOverlayIsHidden()
        XCTAssertTrue(coachingOverlayIsHidden)
    }
}
