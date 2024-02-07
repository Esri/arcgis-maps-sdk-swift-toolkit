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
public struct WorldScaleGeoTrackingSceneView: View {
    /// The proxy for the ARSwiftUIView.
    @State private var arViewProxy = ARSwiftUIViewProxy()
    /// The camera controller that will be set on the scene view.
    @State private var cameraController: TransformationMatrixCameraController
    /// The camera controller heading.
    @State var heading: Double = 0
    /// The camera controller elevation.
    @State var elevation: Double = 0
    /// A Boolean value that indicates if the user is calibrating.
    @State var isCalibrating = false
    /// The current interface orientation.
    @State private var interfaceOrientation: InterfaceOrientation?
    /// The location datasource that is used to access the device location.
    @State private var locationDataSource: LocationDataSource
    /// A Boolean value indicating if the camera was initially set.
    @State private var initialCameraIsSet = false
    /// A Boolean value that indicates whether the coaching overlay view is active.
    @State private var coachingOverlayIsActive = false
    /// The current camera of the scene view.
    @State private var currentCamera: Camera?
    /// A Boolean value that indicates whether the calibration view is hidden.
    private var calibrationViewIsHidden = false
    /// The closure that builds the scene view.
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
    /// The configuration for the AR session.
    private let configuration: ARConfiguration
    /// The timestamp of the last received location.
    @State private var lastLocationTimestamp: Date?
    /// The current device location.
    @State private var currentLocation: Location?
    /// The current device heading.
    @State private var currentHeading: Double?
    /// The valid accuracy threshold for a location in meters.
    private let validAccuracyThreshold = 0.0
    /// The distance threshold in meters between camera and device location to reset
    /// world-tracking session.
    private let distanceThreshold = 2.0
    /// Projected point from the spatial reference of the location data source's to the scene view's.
    private var currentPosition: Point? {
        guard let currentLocation,
              let currentCamera,
              let spatialReference = currentCamera.location.spatialReference,
              let position = GeometryEngine.project(currentLocation.position, into: spatialReference)
        else { return nil }
        return position
    }
    /// Determines the alignment of the calibration view.
    private var calibrationViewAlignment: Alignment = .bottom
    /// The initial camera controller elevation.
    @State private var initialElevation = 0.0
    
    /// Creates a world scale scene view.
    /// - Parameters:
    ///   - locationDataSource: The location datasource used to acquire the device's location.
    ///   - clippingDistance: Determines the clipping distance in meters around the camera. A value
    ///   of `nil` means that no data will be clipped.
    ///   - sceneView: A closure that builds the scene view to be overlayed on top of the
    ///   augmented reality video feed.
    /// - Remark: The provided scene view will have certain properties overridden in order to
    /// be effectively viewed in augmented reality. Properties such as the camera controller,
    /// and view drawing mode.
    public init(
        trackingType: TrackingType = .worldTracking,
        locationDataSource: LocationDataSource = SystemLocationDataSource(),
        clippingDistance: Double? = nil,
        @ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
    ) {
        sceneViewBuilder = sceneView
        
        let cameraController = TransformationMatrixCameraController()
        cameraController.translationFactor = 1
        cameraController.clippingDistance = clippingDistance
        _cameraController = .init(initialValue: cameraController)
        
        configuration = trackingType.trackingConfiguration
        _locationDataSource = .init(initialValue: locationDataSource)
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
                        // This modifier will only be called when using geo-tracking.
                        switch status.state {
                        case .notAvailable, .initializing, .localizing:
                            initialCameraIsSet = false
                        case .localized:
                            if !initialCameraIsSet, let currentLocation, let currentHeading {
                                // Set the initial heading of scene view camera based on location
                                // and heading. Geo-tracking requires 90 degrees adjustment.
                                updateCameraController(
                                    location: currentLocation,
                                    heading: currentHeading + 90,
                                    altitude: currentPosition?.z ?? 0
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
            .overlay(alignment: calibrationViewAlignment) {
                if configuration is ARWorldTrackingConfiguration,
                   !calibrationViewIsHidden {
                    if !isCalibrating {
                        Button {
                            withAnimation {
                                isCalibrating = true
                            }
                        } label: {
                            Text("Calibrate")
                                .padding()
                        }
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .disabled(!initialCameraIsSet)
                        .padding()
                        .padding(.vertical)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if isCalibrating {
                    CalibrationView(
                        heading: $heading,
                        elevation: $elevation,
                        isCalibrating: $isCalibrating,
                        initialElevation: $initialElevation
                    )
                    .padding(.bottom)
                }
            }
            .overlay(alignment: .top) {
                accuracyView
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
            Task { await locationDataSource.stop() }
        }
        .task {
            // Start the location data source when the view appears.
            do {
                try await locationDataSource.start()
            } catch {}
        }
        .task {
            for await location in locationDataSource.locations {
                lastLocationTimestamp = location.timestamp
                currentLocation = location
                // Call the method to check if world tracking session needs to be updated.
                updateWorldTrackingSceneView(for: location)
            }
        }
        .task {
            for await heading in locationDataSource.headings {
                currentHeading = heading
            }
        }
        .onChange(of: heading) { heading in
            if let currentLocation {
                updateCameraController(location: currentLocation, heading: heading, altitude: elevation)
            }
        }
        .onChange(of: elevation) { elevation in
            if let currentLocation {
                updateCameraController(location: currentLocation, heading: heading, altitude: elevation)
            }
        }
    }
    
    /// Updates the scene view's camera controller with location and heading.
    /// - Parameters:
    ///   - location: The location for the camera.
    ///   - heading: The heading for the camera.
    private func updateCameraController(location: Location, heading: Double, altitude: Double) {
        // Ignore location updates when calibrating heading and elevation.
        guard !isCalibrating else { return }
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
    
    /// Updates the scene view's camera controller with a new location coming from the
    /// location data source and resets the AR session when using world-tracking configuration.
    /// - Parameter location: The location data source location.
    private func updateWorldTrackingSceneView(for location: Location) {
        // Do not update the scene view when the coaching overlay is in place.
        guard !coachingOverlayIsActive else { return }
        
        // Update if the location is more than 10 seconds old.
        guard abs(lastLocationTimestamp?.timeIntervalSinceNow ?? 0) < 10 else { return }
        
        // Make sure that horizontal and vertical accuracy are valid.
        guard location.horizontalAccuracy > validAccuracyThreshold,
              location.verticalAccuracy > validAccuracyThreshold else { return }
        
        // Make sure we need to update the camera based on distance deviation.
        guard !initialCameraIsSet || shouldUpdateCamera(for: location) else { return }
        
        updateCameraController(location: location, heading: heading, altitude: elevation)
        
        // Reset the AR session to provide the best tracking performance.
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
        guard let currentCamera, let currentPosition else { return false }
        
        // Measure the distance between the location datasource's reported location
        // and the camera's current location.
        guard let result = GeometryEngine.geodeticDistance(
            from: currentCamera.location,
            to: currentPosition,
            distanceUnit: .meters,
            azimuthUnit: nil,
            curveType: .geodesic
        ) else {
            return false
        }
        
        // If the location becomes off by over a certain threshold, then update the camera location.
        return result.distance.value > distanceThreshold ? true : false
    }
    
    /// Sets the visibility of the calibration view for the AR experience.
    /// - Parameter hidden: A Boolean value that indicates whether to hide the
    ///  calibration view.
    public func calibrationViewHidden(_ hidden: Bool) -> Self {
        var view = self
        view.calibrationViewIsHidden = hidden
        return view
    }
    
    /// Sets the alignment of the calibration view.
    /// - Parameter alignment: The alignment for the calibration view.
    public func calibrationViewAlignment(_ alignment: Alignment) -> Self {
        var view = self
        view.calibrationViewAlignment = alignment
        return view
    }
    
    /// A view that displays the horizontal and vertical accuracy of the current location datasource location.
    @ViewBuilder
    var accuracyView: some View {
        if let currentLocation {
            VStack {
                Text("H. Accuracy: \(currentLocation.horizontalAccuracy.formatted(.number.precision(.fractionLength(2))))")
                Text("V. Accuracy: \(currentLocation.verticalAccuracy.formatted(.number.precision(.fractionLength(2))))")
            }
            .multilineTextAlignment(.center)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding([.horizontal, .top])
        }
    }
    
    /// The type of tracking configuration used by the view.
    public enum TrackingType {
        /// Geo-tracking.
        case geoTracking
        /// World-tracking.
        case worldTracking
        
        /// The `ARConfiguration` object for the tracking type.
        var trackingConfiguration: ARConfiguration {
            let geoTrackingConfiguration = ARGeoTrackingConfiguration()
            let worldTrackingConfiguration = ARWorldTrackingConfiguration()
            // Set world alignment to `gravityAndHeading` so the world-tracking configuration
            // uses geographic location from the device. Geo-tracking uses it by default.
            worldTrackingConfiguration.worldAlignment = .gravityAndHeading
            
            switch self {
            case .geoTracking:
                return geoTrackingConfiguration
            case .worldTracking:
                return worldTrackingConfiguration
            }
        }
    }
}
