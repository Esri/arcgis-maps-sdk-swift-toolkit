// Copyright 2026 Esri
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

#if os(iOS)
public import ArcGIS
public import Observation
public import RealityKit

import ARKit

/// A world-tracking provider that supports system-provided geo tracking and
/// world tracking.
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
@Observable public final class AppleWorldTracking {
    /// The type of tracking configuration used by the view.
    public enum Mode: CaseIterable, Equatable, Sendable {
        /// If geo-tracking is unavailable, fall back to world-tracking.
        case preferGeoTracking
        /// Geo-tracking.
        case geoTracking
        /// World-tracking.
        case worldTracking
    }
    
    /// The current tracking mode of this provider.
    public var mode: Mode
    
    @MainActor public let arSessionProvider = ARSessionProvider()
    
    /// The location data source that supplies the device position.
    public let dataSource = SystemLocationDataSource()
    
    /// A Boolean value indicating whether geo-tracking is currently available
    /// on this device and location.
    private var geoTrackingIsAvailable = false
    
    /// Creates an instance with the given tracking mode.
    /// - Parameter mode: The preferred tracking mode.
    @MainActor public init(mode: Mode) {
        self.mode = mode
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
extension AppleWorldTracking: WorldTrackingProvider {
    public typealias CameraFeedView = AppleWorldTrackingCameraFeedView
    
    public var arConfiguration: ARConfiguration {
        var geoTrackingConfiguration: ARConfiguration {
            ARGeoTrackingConfiguration()
        }
        var worldTrackingConfiguration: ARConfiguration {
            let configuration = ARWorldTrackingConfiguration()
            // Set world alignment to 'gravityAndHeading' so the world-tracking
            // configuration uses geographic location from the device. Geo-
            // tracking uses it by default.
            configuration.worldAlignment = .gravityAndHeading
            return configuration
        }
        return switch mode {
        case .preferGeoTracking:
            if geoTrackingIsAvailable {
                geoTrackingConfiguration
            } else {
                worldTrackingConfiguration
            }
        case .geoTracking:
            geoTrackingConfiguration
        case .worldTracking:
            worldTrackingConfiguration
        }
    }
    
    public func start() async {
        runARSession()
        if let geoTrackingIsAvailable = try? await ARGeoTrackingConfiguration.isGeoTrackingAvailable {
            self.geoTrackingIsAvailable = geoTrackingIsAvailable
        }
        
        let locationManager = CLLocationManager()
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        guard locationManager.authorizationStatus == .authorizedWhenInUse else {
            return
        }
        
        do {
            try await dataSource.start()
        } catch {
            // Do nothing.
        }
    }
    
    public func stop() {
        pauseARSession()
        Task { await dataSource.stop() }
    }
}

private extension ARGeoTrackingConfiguration {
    /// A Boolean value that indicates whether geo-tracking is available.
    static var isGeoTrackingAvailable: Bool {
        get async throws {
            guard ARGeoTrackingConfiguration.isSupported else {
                // Return false if the device doesn't satisfy the hardware
                // requirements.
                return false
            }
            return try await withCheckedThrowingContinuation { continuation in
                ARGeoTrackingConfiguration.checkAvailability { isAvailable, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: isAvailable)
                    }
                }
            }
        }
    }
}
#endif
