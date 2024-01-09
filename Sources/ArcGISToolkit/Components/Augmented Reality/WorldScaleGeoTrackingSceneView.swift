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

/// The types of tracking states that determine how locations generated from the
/// location data source are used during AR tracking.
public enum TrackingState {
    /// Use only the initial location from the location data source
    /// and ignore all subsequent locations.
    case initial
    /// Use all locations from the location data source.
    case continious
}

/// A scene view that provides an augmented reality world scale experience using geotracking.
public struct WorldScaleGeoTrackingSceneView: View {
    /// The proxy for the ARSwiftUIView.
    @State private var arViewProxy = ARSwiftUIViewProxy()
    /// The camera controller that will be set on the scene view.
    @State private var cameraController: TransformationMatrixCameraController
    /// The current interface orientation.
    @State private var interfaceOrientation: InterfaceOrientation?
    /// The location datasource that is used to access the device location.
    @State private var locationDataSource: LocationDataSource
    /// A Boolean value indicating if the camera was initially set.
    @State private var initialCameraIsSet = false
    /// A Boolean value that indicates whether to hide the coaching overlay view.
    private var coachingOverlayIsHidden = false
    /// A Boolean value that indicates whether the coaching overlay view is active.
    @State private var coachingOverlayIsActive = true
    /// The current camera of the scene view.
    @State private var currentCamera: Camera?
    /// A Boolean value that indicates whether the calibration view is hidden.
    private var calibrationViewIsHidden = false
    /// The calibrated camera heading.
    @State private var calibrationHeading: Double?
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
    private var validAccuracyThreshold = 0.0
    /// The tracking state for the AR experience.
    private var trackingState: TrackingState = .initial
    
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
        locationDataSource: LocationDataSource = SystemLocationDataSource(),
        clippingDistance: Double? = nil,
        @ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
    ) {
        sceneViewBuilder = sceneView
        
        let cameraController = TransformationMatrixCameraController()
        cameraController.translationFactor = 1
        cameraController.clippingDistance = clippingDistance
        _cameraController = .init(initialValue: cameraController)
        
        if ARGeoTrackingConfiguration.isSupported {
            configuration = ARGeoTrackingConfiguration()
        } else {
            configuration = ARWorldTrackingConfiguration()
            configuration.worldAlignment = .gravityAndHeading
        }
        
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
                
                if !coachingOverlayIsHidden {
                    ARCoachingOverlay(goal: .geoTracking)
                        .sessionProvider(arViewProxy)
                        .active(coachingOverlayIsActive)
                        .allowsHitTesting(false)
                }
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
        .onChange(of: trackingState) { trackingState in
            Task {
                do {
                    try await setLocation(using: trackingState)
                } catch {}
            }
        }
        .task {
            do {
                try await setLocation(using: trackingState)
            } catch {}
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                if !calibrationViewIsHidden {
                    calibrationView
                }
            }
        }
        .overlay(alignment: .top) {
            accuracyView
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(8)
                .background(.regularMaterial, ignoresSafeAreaEdges: .horizontal)
        }
    }
    
    /// Sets camera controller camera values based on location data source location
    /// and heading values.
    /// - Parameter trackingState: The tracking state.
    private func setLocation(using trackingState: TrackingState) async throws {
        try await manageLocationDataSource(using: trackingState)
        
        switch trackingState {
        case .initial:
            try await setInitialLocation()
            await locationDataSource.stop()
        case .continious:
            try await observeLocationDataSourceUpdates()
        }
    }
    
    /// Sets the camera controller camera with initial location data source values.
    private func setInitialLocation() async throws {
        if let currentLocation {
            await updateSceneView(for: currentLocation)
        } else {
            guard let location = await locationDataSource.locations.first(where: { _ in true }),
                  let heading = await locationDataSource.headings.first(where: { _ in true }) else { return }
            
            self.currentLocation = location
            self.currentHeading = heading
            await updateSceneView(for: location)
            updateHeading(heading)
        }
    }
    
    /// Sets the camera controller camera with location data source location
    /// and heading values as they update.
    private func observeLocationDataSourceUpdates() async throws {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                for await location in locationDataSource.locations {
                    self.lastLocationTimestamp = location.timestamp
                    self.currentLocation = location
                    await updateSceneView(for: location)
                }
            }
            group.addTask {
                for await heading in locationDataSource.headings {
                    self.currentHeading = heading
                    updateHeading(heading)
                }
            }
        }
    }
    
    /// If necessary, updates the scene view's camera controller for a new location coming
    /// from the location datasource.
    /// - Parameter location: The location data source location.
    @MainActor
    private func updateSceneView(for location: Location) {
        // Do not use cached location more than 10 seconds old.
        guard abs(lastLocationTimestamp?.timeIntervalSinceNow ?? 0) < 10 else { return }
        
        // Make sure that horizontal and vertical accuracy are valid.
        guard location.horizontalAccuracy > validAccuracyThreshold,
              location.verticalAccuracy > validAccuracyThreshold else { return }
        
        // Make sure either the initial camera is not set, or we need to update the camera.
        guard !initialCameraIsSet || shouldUpdateCamera(for: location) else { return }
        
        // Add some of the vertical accuracy to the z value of the position, that way if the
        // GPS location is not accurate, we won't end up below the earth's surface.
        let altitude = (location.position.z ?? 0) + location.verticalAccuracy
        
        cameraController.originCamera = Camera(
            latitude: location.position.y,
            longitude: location.position.x,
            altitude: altitude,
            heading: calibrationHeading ?? currentHeading ?? 0,
            pitch: 90,
            roll: 0
        )
        
        // We have to do this or the error gets bigger and bigger.
        cameraController.transformationMatrix = .identity
        arViewProxy.session.run(configuration, options: .resetTracking)
        
        // If initial camera is not set, then we set it the flag here to true
        // and set the status text to empty.
        if !initialCameraIsSet {
            coachingOverlayIsActive = false
            initialCameraIsSet = true
        }
    }
    
    /// Returns a Boolean value indicating if the camera should be updated for a location
    /// coming in from the location datasource.
    /// - Parameter location: The location datasource location.
    /// - Returns: A Boolean value indicating if the camera should be updated.
    func shouldUpdateCamera(for location: Location) -> Bool {
        // Do not update unless the horizontal accuracy is less than a threshold.
        guard let currentCamera,
              let spatialReference = currentCamera.location.spatialReference,
              // Project point from the location datasource spatial reference
              // to the scene view spatial reference.
                let currentPosition = GeometryEngine.project(location.position, into: spatialReference)
        else { return false }
        
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
        let threshold = 2.0
        return result.distance.value > threshold ? true : false
    }
    
    /// Sets the visibility of the coaching overlay view for the AR experience.
    /// - Parameter hidden: A Boolean value that indicates whether to hide the
    ///  coaching overlay view.
    public func coachingOverlayHidden(_ hidden: Bool) -> Self {
        var view = self
        view.coachingOverlayIsHidden = hidden
        return view
    }
    
    /// Sets the visibility of the calibration view for the AR experience.
    /// - Parameter hidden: A Boolean value that indicates whether to hide the
    ///  calibration view.
    public func calibrationViewHidden(_ hidden: Bool) -> Self {
        var view = self
        view.calibrationViewIsHidden = hidden
        return view
    }
    
    /// Sets the tracking state for the AR experience.
    /// - Parameter trackingState: The tracking state.
    public func trackingState(_ trackingState: TrackingState) -> Self {
        var view = self
        view.trackingState = trackingState
        return view
    }
    
    /// Updates the heading of the scene view camera controller.
    /// - Parameter heading: The camera heading.
    func updateHeading(_ heading: Double) {
        cameraController.originCamera = cameraController.originCamera.rotatedTo(
            heading: calibrationHeading ?? heading,
            pitch: cameraController.originCamera.pitch,
            roll: cameraController.originCamera.roll
        )
    }
    
    /// Starts or stops the location data source based on the location data source
    /// status and the tracking state.
    /// - Parameter trackingState: The tracking state.
    func manageLocationDataSource(using trackingState: TrackingState) async throws {
        switch(locationDataSource.status) {
        case .stopped, .stopping, .failedToStart:
            try await locationDataSource.start()
        case .starting, .started:
            // Stop location data source once initial camera is set.
            if trackingState == .initial,
               initialCameraIsSet {
                await locationDataSource.stop()
            }
        }
    }
    
    /// A view that allows the user to calibrate the heading of the scene view camera controller.
    var calibrationView: some View {
        HStack {
            Button {
                let heading = cameraController.originCamera.heading + 1
                updateHeading(heading)
                calibrationHeading = heading
            } label: {
                Image(systemName: "plus")
            }
            
            Text("heading: \(calibrationHeading?.rounded() ?? cameraController.originCamera.heading.rounded(.towardZero), format: .number)")
            
            Button {
                let heading = cameraController.originCamera.heading - 1
                updateHeading(heading)
                calibrationHeading = heading
            } label: {
                Image(systemName: "minus")
            }
        }
    }
    
    /// A view that displays the horizontal and vertical accuracy of the current location datasource location.
    var accuracyView: some View {
        VStack {
            if let currentLocation {
                Text("horizontalAccuracy: \(currentLocation.horizontalAccuracy, format: .number)")
                Text("verticalAccuracy: \(currentLocation.verticalAccuracy, format: .number)")
            }
        }
    }
}

extension TrackingState: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
