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
import Foundation

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

    /// Identifies the current provider start, or is nil when stopped.
    private var startID: UUID?
    /// Identifies the latest session configuration request.
    private var configurationID = UUID()

    /// Whether the selected tracking mode uses GeoTracking.
    var isGeoTrackingActive: Bool {
        switch mode {
        case .preferGeoTracking:
            geoTrackingIsAvailable
        case .geoTracking:
            true
        case .worldTracking:
            false
        }
    }
    
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
        if isGeoTrackingActive {
            return ARGeoTrackingConfiguration()
        }

        let configuration = ARWorldTrackingConfiguration()
        // Set world alignment to 'gravityAndHeading' so the world-tracking
        // configuration uses geographic location from the device. Geo-
        // tracking uses it by default.
        configuration.worldAlignment = .gravityAndHeading
        return configuration
    }
    
    /// Updates the AR session for the selected mode if the provider is started.
    @MainActor func handleModeChange() {
        // The next start will configure the session if the provider is stopped.
        guard startID != nil else { return }
        let configurationID = UUID()
        self.configurationID = configurationID
        let mode = mode
        Task {
            await updateARSession(for: mode, configurationID: configurationID)
        }
    }

    public func start() async {
        let startID = UUID()
        self.startID = startID
        let configurationID = UUID()
        self.configurationID = configurationID
        await updateARSession(for: mode, configurationID: configurationID)
        // Do not start the data source for a stopped or superseded lifecycle.
        guard self.startID == startID else { return }

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

    /// Checks geo-tracking availability when needed and runs the AR session
    /// if the configuration request is still current.
    /// - Parameters:
    ///   - mode: The tracking mode for this request.
    ///   - configurationID: The identifier of this configuration request.
    @MainActor private func updateARSession(for mode: Mode, configurationID: UUID) async {
        let isAvailable: Bool?
        if mode == .preferGeoTracking {
            isAvailable = (try? await ARGeoTrackingConfiguration.isGeoTrackingAvailable) ?? false
        } else {
            isAvailable = nil
        }
        // Discard results if stopped, superseded, or the mode changed while awaiting.
        guard startID != nil, self.configurationID == configurationID, self.mode == mode else { return }
        if let isAvailable {
            geoTrackingIsAvailable = isAvailable
        }
        runARSession()
    }
    
    public func stop() {
        startID = nil
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
