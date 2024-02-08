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

/// A scene view that provides an augmented reality world scale experience.
public struct WorldScaleSceneView: View {
    /// Determines the alignment of the calibration view.
    var calibrationViewAlignment: Alignment = .bottom
    /// A Boolean value that indicates whether the calibration view is hidden.
    var calibrationViewIsHidden = false
    
    /// The closure that builds the scene view.
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
    
    private let trackingMode: TrackingMode
    
    private let clippingDistance: Double?
    
    /// The view model for the calibration view.
    @StateObject private var calibrationViewModel = CalibrationViewModel()
    /// A Boolean value that indicates if the user is calibrating.
    @State private var isCalibrating = false
    /// The location datasource that is used to access the device location.
    @State private var locationDataSource = SystemLocationDataSource()
    
    /// The current device location.
    @State private var currentLocation: Location?
    
    @State private var geoTrackingIsAvailable = true
    
    @State private var initialCameraIsSet = false
    
    @State private var error: Error?
    
    public init(
        clippingDistance: Double? = nil,
        trackingMode: TrackingMode,
        sceneViewBuilder: @escaping (SceneViewProxy) -> SceneView
    ) {
        self.clippingDistance = clippingDistance
        self.trackingMode = trackingMode
        self.sceneViewBuilder = sceneViewBuilder
    }
    
    public var body: some View {
        Group {
            switch trackingMode {
            case .automatic:
                if geoTrackingIsAvailable {
                    GeoTrackingSceneView(
                        initialCameraIsSet: $initialCameraIsSet,
                        isCalibrating: isCalibrating,
                        locationDataSource: locationDataSource,
                        calibrationViewModel: calibrationViewModel,
                        clippingDistance: clippingDistance,
                        sceneView: sceneViewBuilder
                    )
                } else {
                    WorldTrackingSceneView(
                        initialCameraIsSet: $initialCameraIsSet,
                        isCalibrating: isCalibrating,
                        locationDataSource: locationDataSource,
                        calibrationViewModel: calibrationViewModel,
                        clippingDistance: clippingDistance,
                        sceneView: sceneViewBuilder
                    )
                }
            case .geoTracking:
                GeoTrackingSceneView(
                    initialCameraIsSet: $initialCameraIsSet,
                    isCalibrating: isCalibrating,
                    locationDataSource: locationDataSource,
                    calibrationViewModel: calibrationViewModel,
                    clippingDistance: clippingDistance,
                    sceneView: sceneViewBuilder
                )
            case .worldTracking:
                WorldTrackingSceneView(
                    initialCameraIsSet: $initialCameraIsSet,
                    isCalibrating: isCalibrating,
                    locationDataSource: locationDataSource,
                    calibrationViewModel: calibrationViewModel,
                    clippingDistance: clippingDistance,
                    sceneView: sceneViewBuilder
                )
            }
        }
        .onAppear {
        }
        .onDisappear {
            Task { await locationDataSource.stop() }
        }
        .task {
            // Start the location data source when the view appears.
            
            // Request when-in-use location authorization.
            // The view utilizes a location datasource and it will not start until authorized.
            let locationManager = CLLocationManager()
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            if !checkDeviceCapabilities(locationManager) {
                print("Device doesn't support full accuracy location.")
            }
            
            do {
                try await locationDataSource.start()
            } catch {
                self.error = error
            }
            for await location in locationDataSource.locations {
                currentLocation = location
            }
        }
        .task {
            do {
                let isAvailable = try await checkGeoTrackingAvailability()
                geoTrackingIsAvailable = isAvailable
            } catch {
                self.error = error
            }
        }
        .overlay(alignment: calibrationViewAlignment) {
            if !calibrationViewIsHidden {
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
                CalibrationView(viewModel: calibrationViewModel, isPresented: $isCalibrating)
                    .padding(.bottom)
            }
        }
        .overlay(alignment: .top) {
            accuracyView
        }
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
    
    private func checkDeviceCapabilities(_ locationManager: CLLocationManager) -> Bool {
        let headingAvailable = CLLocationManager.headingAvailable()
        let fullAccuracy: Bool
        switch locationManager.accuracyAuthorization {
        case .fullAccuracy:
            // World scale AR experience must use full accuracy of device location.
            fullAccuracy = true
        default:
            fullAccuracy = false
        }
        return headingAvailable && fullAccuracy
    }
    
    private func checkGeoTrackingAvailability() async throws -> Bool {
        if !ARGeoTrackingConfiguration.isSupported {
            return false
        }
        return try await ARGeoTrackingConfiguration.checkAvailability()
    }
}

public extension WorldScaleSceneView {
    /// The type of tracking configuration used by the view.
    enum TrackingMode {
        /// If geo-tracking is unavailable, fall back to world-tracking.
        case automatic
        /// Geo-tracking.
        case geoTracking
        /// World-tracking.
        case worldTracking
    }
}

private extension ARGeoTrackingConfiguration {
    /// Determines the availability of geo tracking at the current location.
    /// - Returns: A Boolean that indicates whether geo-tracking is available at the current
    /// location or not. If not, an error will be thrown that indicates why geo tracking is
    /// not available at the current location.
    static func checkAvailability() async throws -> Bool {
        return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Bool, Error>) in
            self.checkAvailability { isAvailable, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: isAvailable)
                }
            }
        }
    }
}
