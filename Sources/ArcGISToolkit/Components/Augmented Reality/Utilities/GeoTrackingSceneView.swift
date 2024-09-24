// Copyright 2024 Esri
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
@MainActor
@preconcurrency
@available(visionOS, unavailable)
public struct GeoTrackingSceneView: View {
    /// A Boolean value indicating if the camera was initially set.
    @Binding var initialCameraIsSet: Bool
    /// The view model for the calibration view.
    @ObservedObject private var calibrationViewModel: WorldScaleCalibrationViewModel
#if os(iOS)
    /// The geo-tracking configuration for the AR session.
    private let configuration = ARGeoTrackingConfiguration()
#endif
    /// A Boolean value that indicates if the user is calibrating.
    private let calibrationViewIsPresented: Bool
    /// The location datasource that is used to access the device location.
    private let locationDataSource: LocationDataSource
    /// The closure that builds the scene view.
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
#if os(iOS)
    /// The proxy for the ARSwiftUIView.
    private let arViewProxy: ARSwiftUIViewProxy
#endif
    /// The camera controller that will be set on the scene view.
    private let cameraController: TransformationMatrixCameraController
    /// A Boolean value that indicates whether the coaching overlay view is active.
    @State private var coachingOverlayIsActive = false
    /// The current device heading.
    @State private var currentHeading: Double?
    /// The current device location.
    @State private var currentLocation: Location?
    /// The current interface orientation.
    @State private var interfaceOrientation: InterfaceOrientation?
#if os(iOS)
    /// The closure to perform when the camera tracking state changes.
    private var onCameraTrackingStateChangedAction: ((ARCamera.TrackingState) -> Void)?
    /// The closure to perform when the geo tracking status changes.
    private var onGeoTrackingStatusChangedAction: ((ARGeoTrackingStatus) -> Void)?
    
    /// Creates a world scale geo-tracking scene view.
    /// - Parameters:
    ///   - arViewProxy: The proxy for the ARSwiftUIView.
    ///   - cameraController: The camera controller that will be set on the scene view.
    ///   - calibrationViewModel: The view model for accessing the calibration values.
    ///   - clippingDistance: Determines the clipping distance in meters around the camera. A value
    ///   of `nil` means that no data will be clipped.
    ///   - initialCameraIsSet: A Boolean value that indicates whether the initial camera is set for the scene view.
    ///   - calibrationViewIsPresented: A Boolean value that indicates whether the calibration view is present.
    ///   - locationDataSource: The location datasource used to acquire the device's location.
    ///   - sceneView: A closure that builds the scene view to be overlayed on top of the
    ///   augmented reality video feed.
    init(
        arViewProxy: ARSwiftUIViewProxy,
        cameraController: TransformationMatrixCameraController,
        calibrationViewModel: WorldScaleCalibrationViewModel,
        clippingDistance: Double?,
        initialCameraIsSet: Binding<Bool>,
        calibrationViewIsPresented: Bool,
        locationDataSource: LocationDataSource,
        @ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
    ) {
        self.arViewProxy = arViewProxy
        self.cameraController = cameraController
        self.calibrationViewModel = calibrationViewModel
        self.cameraController.clippingDistance = clippingDistance
        _initialCameraIsSet = initialCameraIsSet
        self.calibrationViewIsPresented = calibrationViewIsPresented
        self.locationDataSource = locationDataSource
        
        sceneViewBuilder = sceneView
    }
#endif
    
    public var body: some View {
        SceneViewReader { sceneViewProxy in
            ZStack {
#if os(iOS)
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
                    .onDidChangeGeoTrackingStatus { _, status in
                        handleGeoTrackingStatusChange(status)
                        onGeoTrackingStatusChangedAction?(status)
                    }
                    .onCameraDidChangeTrackingState { _, trackingState in
                        onCameraTrackingStateChangedAction?(trackingState)
                    }
#endif
                sceneViewBuilder(sceneViewProxy)
                    .worldScaleSetup(cameraController: cameraController)
                    .opacity(initialCameraIsSet ? 1 : 0)
            }
#if os(iOS)
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
#endif
        }
        .observingInterfaceOrientation($interfaceOrientation)
#if os(iOS)
        .onAppear {
            arViewProxy.session.run(configuration)
        }
        .onDisappear {
            arViewProxy.session.pause()
        }
#endif
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
    }
    
    /// Updates the scene view's camera controller with location and heading.
    /// - Parameters:
    ///   - location: The location for the camera.
    ///   - heading: The heading for the camera.
    ///   - altitude: The altitude for the camera.
    private func updateCameraController(location: Location, heading: Double, altitude: Double) {
        cameraController.originCamera = Camera(
            latitude: location.position.y,
            longitude: location.position.x,
            altitude: altitude,
            heading: heading,
            pitch: 90,
            roll: 0
        )
        
        // We have to do this or the error gets bigger and bigger.
        cameraController.transformationMatrix = .identity
    }
    
#if os(iOS)
    @MainActor
    private func handleGeoTrackingStatusChange(_ status: ARGeoTrackingStatus) {
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
    
    /// Sets a closure to perform when the geo tracking status changes.
    /// - Parameter action: The closure to perform when the geo tracking status has changed.
    public func onGeoTrackingStatusChanged(
        perform action: @escaping (
            _ geoTrackingStatus: ARGeoTrackingStatus
        ) -> Void
    ) -> Self {
        var view = self
        view.onGeoTrackingStatusChangedAction = action
        return view
    }
#endif
}
