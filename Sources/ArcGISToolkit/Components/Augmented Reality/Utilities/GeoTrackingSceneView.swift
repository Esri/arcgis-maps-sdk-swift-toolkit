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

import ARKit
import SwiftUI
import ArcGIS

/// A scene view that provides an augmented reality world scale experience using geo-tracking.
public struct GeoTrackingSceneView: View {
    /// A Boolean value indicating if the camera was initially set.
    @Binding var initialCameraIsSet: Bool
    /// The view model for the calibration view.
    @ObservedObject private var calibrationViewModel: WorldScaleSceneView.CalibrationViewModel
    /// The geo-tracking configuration for the AR session.
    private let configuration = ARGeoTrackingConfiguration()
    /// A Boolean value that indicates if the user is calibrating.
    private let isCalibrating: Bool
    /// The location datasource that is used to access the device location.
    private let locationDataSource: LocationDataSource
    /// The closure that builds the scene view.
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
    /// The proxy for the ARSwiftUIView.
    @State private var arViewProxy = ARSwiftUIViewProxy()
    /// The camera controller that will be set on the scene view.
    @State private var cameraController: TransformationMatrixCameraController
    /// A Boolean value that indicates whether the coaching overlay view is active.
    @State private var coachingOverlayIsActive = false
    /// The current camera of the scene view.
    @State private var currentCamera: Camera?
    /// The current device heading.
    @State private var currentHeading: Double?
    /// The current device location.
    @State private var currentLocation: Location?
    /// The current interface orientation.
    @State private var interfaceOrientation: InterfaceOrientation?
    
    /// Creates a world scale geo-tracking scene view.
    /// - Parameters:
    ///   - calibrationViewModel: The view model for accessing the calibration values.
    ///   - clippingDistance: Determines the clipping distance in meters around the camera. A value
    ///   of `nil` means that no data will be clipped.
    ///   - initialCameraIsSet: A Boolean value that indicates whether the initial camera is set for the scene view.
    ///   - isCalibrating: A Boolean value that indicates whether the calibration view is present.
    ///   - locationDataSource: The location datasource used to acquire the device's location.
    ///   - sceneView: A closure that builds the scene view to be overlayed on top of the
    ///   augmented reality video feed.
    public init(
        calibrationViewModel: WorldScaleSceneView.CalibrationViewModel,
        clippingDistance: Double?,
        initialCameraIsSet: Binding<Bool>,
        isCalibrating: Bool,
        locationDataSource: LocationDataSource,
        @ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
    ) {
        self.calibrationViewModel = calibrationViewModel
        _initialCameraIsSet = initialCameraIsSet
        self.isCalibrating = isCalibrating
        self.locationDataSource = locationDataSource
        
        sceneViewBuilder = sceneView
        
        let cameraController = TransformationMatrixCameraController()
        cameraController.translationFactor = 1
        cameraController.clippingDistance = clippingDistance
        _cameraController = .init(initialValue: cameraController)
    }
    
    public var body: some View {
        SceneViewReader { sceneViewProxy in
            ZStack {
                ARSwiftUIView(proxy: arViewProxy)
                    .onDidUpdateFrame { _, frame in
                        guard let interfaceOrientation, initialCameraIsSet else { return }
                        
                        sceneViewProxy.updateCamera(
                            frame: frame,
                            cameraController: cameraController,
                            orientation: interfaceOrientation,
                            initialTransformation: .identity
                        )
                        sceneViewProxy.setFieldOfView(
                            for: frame,
                            orientation: interfaceOrientation
                        )
                    }
                    .onDidChangeGeoTrackingStatus { session, status in
                        switch status.state {
                        case .notAvailable, .initializing, .localizing:
                            initialCameraIsSet = false
                        case .localized:
                            // Update the camera controller every time geo-tracking is localized,
                            // to ensure the best experience.
                            if !initialCameraIsSet, let currentLocation, let currentHeading {
                                // Set the initial heading of scene view camera based on location
                                // and heading. Geo-tracking requires 90 degrees rotation.
                                updateCameraController(
                                    location: currentLocation,
                                    heading: currentHeading + 90,
                                    altitude: currentLocation.position.z ?? 0
                                )
                                initialCameraIsSet = true
                            }
                        @unknown default:
                            fatalError("Unknown ARGeoTrackingStatus.State")
                        }
                    }
                
                if initialCameraIsSet {
                    sceneViewBuilder(sceneViewProxy)
                        .cameraController(cameraController)
                        .attributionBarHidden(true)
                        .spaceEffect(.transparent)
                        .atmosphereEffect(.off)
                        .interactiveNavigationDisabled(true)
                        .onCameraChanged { camera in
                            currentCamera = camera
                        }
                }
            }
            .ignoresSafeArea(.all)
            .overlay {
                ARCoachingOverlay(goal: .geoTracking)
                    .sessionProvider(arViewProxy)
                    .onCoachingOverlayActivate { _ in
                        coachingOverlayIsActive = true
                    }
                    .onCoachingOverlayDeactivate { _ in
                        coachingOverlayIsActive = false
                    }
                    .onCoachingOverlayRequestSessionReset { _ in
                        // Reset the AR session to provide the best tracking performance.
                        arViewProxy.session.run(configuration, options: .resetTracking)
                    }
                    .allowsHitTesting(false)
            }
        }
        .observingInterfaceOrientation($interfaceOrientation)
        .onAppear {
            arViewProxy.session.run(configuration)
        }
        .onDisappear {
            arViewProxy.session.pause()
        }
        .task {
            for await location in locationDataSource.locations {
                currentLocation = location
            }
        }
        .task {
            for await heading in locationDataSource.headings {
                currentHeading = heading
            }
        }
        .onReceive(calibrationViewModel.headingCorrections) { correction in
            let originCamera = cameraController.originCamera
            cameraController.originCamera = originCamera.rotatedTo(
                heading: originCamera.heading + correction,
                pitch: originCamera.pitch,
                roll: originCamera.roll
            )
        }
        .onReceive(calibrationViewModel.elevationCorrections) { correction in
            cameraController.originCamera = cameraController.originCamera.elevated(by: correction)
        }
    }
    
    /// Updates the scene view's camera controller with location and heading.
    /// - Parameters:
    ///   - location: The location for the camera.
    ///   - heading: The heading for the camera.
    ///   - altitude: The altitude for the camera.
    private func updateCameraController(location: Location, heading: Double, altitude: Double) {
        // Add some of the vertical accuracy to the z value of the position, that way if the
        // GPS location is not accurate, it won't end up below the earth's surface.
        let adjustedAltitude = altitude + location.verticalAccuracy
        
        cameraController.originCamera = Camera(
            latitude: location.position.y,
            longitude: location.position.x,
            altitude: adjustedAltitude,
            heading: heading,
            pitch: 90,
            roll: 0
        )
        
        // We have to do this or the error gets bigger and bigger.
        cameraController.transformationMatrix = .identity
    }
}
