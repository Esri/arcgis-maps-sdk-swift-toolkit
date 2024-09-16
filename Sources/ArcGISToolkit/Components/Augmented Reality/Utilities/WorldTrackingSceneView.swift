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
import ARKit
import SwiftUI
import ArcGIS

/// A scene view that provides an augmented reality world scale experience using world-tracking.
@MainActor
struct WorldTrackingSceneView: View {
    /// A Boolean value indicating if the camera was initially set.
    @Binding var initialCameraIsSet: Bool
    /// The view model for the calibration view.
    @ObservedObject private var calibrationViewModel: WorldScaleCalibrationViewModel
    /// The configuration for the AR session.
    private let configuration: ARConfiguration
    /// The distance threshold in meters between camera and device location to reset the
    /// world-tracking session.
    private let distanceThreshold: Double
    /// A Boolean value that indicates if the user is calibrating.
    private let calibrationViewIsPresented: Bool
    /// The location datasource that is used to access the device location.
    private let locationDataSource: LocationDataSource
    /// The closure that builds the scene view.
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
    /// The time threshold in seconds between location updates to reset the world-tracking session.
    private let timeThreshold: Double
    /// The proxy for the ARSwiftUIView.
    private let arViewProxy: ARSwiftUIViewProxy
    /// The camera controller that will be set on the scene view.
    private let cameraController: TransformationMatrixCameraController
    /// A Boolean value that indicates whether the coaching overlay view is active.
    @State private var coachingOverlayIsActive = false
    /// The current camera of the scene view.
    @State private var currentCamera: Camera?
    /// The current device location.
    @State private var currentLocation: Location?
    /// The current interface orientation.
    @State private var interfaceOrientation: InterfaceOrientation?
    /// The timestamp of the last received location.
    @State private var lastLocationTimestamp: Date?
    /// The closure to perform when the camera tracking state changes.
    private var onCameraTrackingStateChangedAction: ((ARCamera.TrackingState) -> Void)?
    
    /// Creates a world scale world-tracking scene view.
    /// - Parameters:
    ///   - arViewProxy: The proxy for the ARSwiftUIView.
    ///   - cameraController: The camera controller that will be set on the scene view.
    ///   - calibrationViewModel: The view model for accessing the calibration values.
    ///   - clippingDistance: Determines the clipping distance in meters around the camera. A value
    ///   of `nil` means that no data will be clipped.
    ///   - distanceThreshold: The distance threshold for the camera to be re-aligned with the GPS.
    ///   - initialCameraIsSet: A Boolean value that indicates whether the initial camera is set for the scene view.
    ///   - calibrationViewIsPresented: A Boolean value that indicates whether the calibration view is present.
    ///   - locationDataSource: The location datasource used to acquire the device's location.
    ///   - timeThreshold: The time threshold for the camera to be re-aligned with the GPS.
    ///   - sceneView: A closure that builds the scene view to be overlayed on top of the
    ///   augmented reality video feed.
    init(
        arViewProxy: ARSwiftUIViewProxy,
        cameraController: TransformationMatrixCameraController,
        calibrationViewModel: WorldScaleCalibrationViewModel,
        clippingDistance: Double?,
        distanceThreshold: Double = 2.0,
        initialCameraIsSet: Binding<Bool>,
        calibrationViewIsPresented: Bool,
        locationDataSource: LocationDataSource,
        timeThreshold: Double = 10.0,
        @ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
    ) {
        self.arViewProxy = arViewProxy
        self.cameraController = cameraController
        self.calibrationViewModel = calibrationViewModel
        self.cameraController.clippingDistance = clippingDistance
        self.distanceThreshold = distanceThreshold
        _initialCameraIsSet = initialCameraIsSet
        self.calibrationViewIsPresented = calibrationViewIsPresented
        self.locationDataSource = locationDataSource
        self.timeThreshold = timeThreshold
        
        sceneViewBuilder = sceneView
        
        let worldTrackingConfiguration = ARWorldTrackingConfiguration()
        // Set world alignment to `gravityAndHeading` so the world-tracking configuration uses
        // geographic location from the device. Geo-tracking uses it by default.
        worldTrackingConfiguration.worldAlignment = .gravityAndHeading
        configuration = worldTrackingConfiguration
    }
    
    var body: some View {
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
                    .onCameraDidChangeTrackingState { _, trackingState in
                        onCameraTrackingStateChangedAction?(trackingState)
                    }
                sceneViewBuilder(sceneViewProxy)
                    .worldScaleSetup(cameraController: cameraController)
                    .onCameraChanged { camera in
                        currentCamera = camera
                    }
                    .opacity(initialCameraIsSet ? 1 : 0)
            }
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
                        if let currentLocation {
                            updateWorldTrackingSceneView(for: currentLocation)
                        }
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
                lastLocationTimestamp = location.timestamp
                currentLocation = location
                // Call the method to check if world tracking session needs to be updated.
                updateWorldTrackingSceneView(for: location)
            }
        }
    }
    
    /// Updates the scene view's camera controller with a new location coming from the
    /// location data source and resets the AR session when using world-tracking configuration.
    /// - Parameter location: The location data source location.
    private func updateWorldTrackingSceneView(for location: Location) {
        // Do not update the scene view when the coaching overlay is in place.
        guard !coachingOverlayIsActive else { return }
        
        // Do not use cached location more than 10 seconds old.
        guard abs(lastLocationTimestamp?.timeIntervalSinceNow ?? 0) < timeThreshold else { return }
        
        // Make sure that horizontal and vertical accuracy are valid.
        guard location.horizontalAccuracy >= .zero,
              location.verticalAccuracy >= .zero else { return }
        
        // Make sure we need to update the camera based on distance deviation.
        guard !initialCameraIsSet || shouldUpdateCamera(for: location) else { return }
        
        let altitude = location.position.z ?? 0
        
        if !initialCameraIsSet {
            cameraController.originCamera = Camera(
                latitude: location.position.y,
                longitude: location.position.x,
                altitude: altitude,
                heading: 0,
                pitch: 90,
                roll: 0
            )
        } else {
            // Ignore location updates when calibrating heading and elevation.
            guard !calibrationViewIsPresented else { return }
            cameraController.originCamera = Camera(
                latitude: location.position.y,
                longitude: location.position.x,
                altitude: altitude + calibrationViewModel.totalElevationCorrection,
                heading: calibrationViewModel.totalHeadingCorrection,
                pitch: 90,
                roll: 0
            )
        }
        
        // We have to do this or the error gets bigger and bigger.
        cameraController.transformationMatrix = .identity
        
        arViewProxy.session.run(configuration, options: .resetTracking)
        
        // If initial camera is not set, then we set it the flag here to true
        // and set the status text to empty.
        if !initialCameraIsSet {
            initialCameraIsSet = true
        }
    }
    
    /// Returns a Boolean value indicating if the camera should be updated for a location
    /// coming in from the location data source based on current camera deviation.
    /// - Parameter location: The location data source location.
    /// - Returns: A Boolean value indicating if the camera should be updated.
    func shouldUpdateCamera(for location: Location) -> Bool {
        guard let currentCamera, let currentLocation else { return false }
        
        // Measure the distance between the location datasource's reported location
        // and the camera's current location.
        guard let result = GeometryEngine.geodeticDistance(
            from: currentCamera.location,
            to: currentLocation.position,
            distanceUnit: .meters,
            azimuthUnit: nil,
            curveType: .geodesic
        ) else {
            return false
        }
        
        // If the location becomes off by over a certain threshold, then update the camera location.
        return result.distance.value > distanceThreshold ? true : false
    }
    
    /// Sets a closure to perform when the camera tracking state changes.
    /// - Parameter action: The closure to perform when the camera tracking state has changed.
    public func onCameraTrackingStateChanged(
        perform action: @escaping (
            _ cameraTrackingState: ARCamera.TrackingState
        ) -> Void
    ) -> Self {
        var view = self
        view.onCameraTrackingStateChangedAction = action
        return view
    }
}
#endif
