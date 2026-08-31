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

import ArcGIS
import ArcGISToolkit
import ARCore
import ARCoreGeospatial
import ARKit
import CoreLocation
import Observation
import os
import RealityKit

/// A world-tracking provider backed by the Google ARCore SDK.
@MainActor
@Observable
final class CustomWorldTracking: NSObject {
    let arSessionProvider = ARSessionProvider<ARView>()
    /// The ARCore session that produces geospatial and streetscape updates.
    let garSession: GARSession
    /// The root world origin anchor for all generated streetscape content.
    let worldOrigin = AnchorEntity(world: matrix_identity_float4x4)
    /// A cache of generated streetscape models keyed by ARCore geometry
    /// identifier.
    @ObservationIgnored var streetscapeGeometryModels: [UUID: ModelEntity] = [:]
    /// Guidance or failure information for the current localization state.
    private(set) var statusMessage = "Starting Google VPS…"
    /// A Boolean value indicating whether an unrecoverable issue prevents
    /// localization.
    private(set) var hasBlockingError = false
    
    /// The location manager retained for the asynchronous authorization and
    /// VPS availability flow.
    private let locationManager = CLLocationManager()
    /// A Boolean value indicating whether the ARCore session is ready for
    /// frame updates.
    @ObservationIgnored private(set) var isGARSessionConfigured = false
    
    /// Creates an instance with the given API key and bundle identifier.
    /// - Parameters:
    ///   - apiKey: An API key for Google Cloud Services.
    ///   - bundleIdentifier: The bundle identifier associated to the API key.
    ///   If `nil`, defaults to `Bundle.main.bundleIdentifier`.
    init(apiKey: String, bundleIdentifier: String? = nil) throws {
        garSession = try GARSession(apiKey: apiKey, bundleIdentifier: bundleIdentifier)
        super.init()
        locationManager.delegate = self
    }
}

extension CustomWorldTracking: @MainActor WorldTrackingProvider {
    typealias CameraFeedView = CustomWorldTrackingCameraFeedView
    
    var arConfiguration: ARConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        configuration.planeDetection = [.horizontal, .vertical]
        return configuration
    }
    
    func start() async {
        if TransformationCatalog.projectionEngineDirectoryURL == nil {
            // Set projection data for ellipsoidal projection.
            setProjectionEngineDirectoryURL()
        }
        
        runARSession()
        arSessionProvider.scene.addAnchor(worldOrigin)
        updateLocationAuthorization()
    }
    
    func stop() {
        pauseARSession()
        locationManager.stopUpdatingLocation()
    }
    
    func reset() {
        updateStatus("Localizing with Google VPS…")
        runARSession(options: .resetTracking)
    }
}

extension CustomWorldTracking: @MainActor CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateLocationAuthorization()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let coordinate = locations.last?.coordinate else { return }
        manager.stopUpdatingLocation()
        garSession.checkVPSAvailability(coordinate: coordinate) { availability in
            Task { @MainActor in
                if availability != .available {
                    self.updateStatus(
                        "Google VPS is unavailable at the current location.",
                        isBlocking: true
                    )
                }
            }
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: any Error
    ) {
        Logger.customVPSProviderExample.error(
            "Location request failed: \(error.localizedDescription)"
        )
        updateStatus(
            "Google VPS could not determine the current location.",
            isBlocking: true
        )
    }
}

extension CustomWorldTracking {
    /// Updates the user-facing localization status.
    /// - Parameters:
    ///   - message: The guidance or error to display.
    ///   - isBlocking: A Boolean value indicating whether localization cannot
    ///   continue without user action.
    func updateStatus(_ message: String, isBlocking: Bool = false) {
        statusMessage = message
        hasBlockingError = isBlocking
    }
    
    /// Updates ARCore setup in response to location authorization.
    private func updateLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            guard locationManager.accuracyAuthorization == .fullAccuracy else {
                updateStatus(
                    "Google VPS requires Precise Location.",
                    isBlocking: true
                )
                return
            }
            setupGARSession()
            guard isGARSessionConfigured else { return }
            updateStatus("Point the camera at nearby buildings and signs.")
            locationManager.requestLocation()
        case .notDetermined:
            updateStatus("Allow location access to use Google VPS.")
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            updateStatus(
                "Google VPS requires location permission.",
                isBlocking: true
            )
        @unknown default:
            updateStatus(
                "Google VPS could not determine location authorization.",
                isBlocking: true
            )
        }
    }
    
    /// Configures the ARCore session.
    private func setupGARSession() {
        guard !isGARSessionConfigured else { return }
        guard garSession.isGeospatialModeSupported(.enabled) else {
            updateStatus(
                "Google geospatial tracking is unsupported on this device.",
                isBlocking: true
            )
            return
        }
        
        let configuration = GARSessionConfiguration()
        configuration.geospatialMode = .enabled
        configuration.streetscapeGeometryMode = .enabled
        var error: NSError?
        garSession.setConfiguration(configuration, error: &error)
        if let error {
            Logger.customVPSProviderExample.error(
                "ARCore configuration failed: \(error.localizedDescription)"
            )
            updateStatus(
                "Google VPS could not be configured.",
                isBlocking: true
            )
        } else {
            isGARSessionConfigured = true
        }
    }
}

private extension CustomWorldTracking {
    /// Sets the ArcGIS projection engine directory from bundled projection data
    /// when available.
    func setProjectionEngineDirectoryURL() {
        if let pedataURL = Bundle.main.url(forResource: "pedata", withExtension: nil) {
            do {
                Logger.customVPSProviderExample.info("Setting Projection Engine Directory: \(pedataURL)")
                try TransformationCatalog.setProjectionEngineDirectoryURL(pedataURL)
            } catch {
                Logger.customVPSProviderExample.error("Error setting Projection Engine Directory: \(error)")
            }
        } else if let egm96URL = Bundle.main.url(forResource: "egm96", withExtension: "grd") {
            let pedataURL = egm96URL.deletingLastPathComponent()
            do {
                try TransformationCatalog.setProjectionEngineDirectoryURL(pedataURL)
            } catch {
                Logger.customVPSProviderExample.error("Error setting Projection Engine Directory: \(error)")
            }
        } else {
            Logger.customVPSProviderExample.warning("Note: PE data not found - using built-in transformations")
        }
    }
}

extension CustomWorldTracking {
    /// Builds a `ModelEntity` representation of ARCore streetscape geometry.
    /// - Parameter geometry: The ARCore streetscape geometry mesh and type
    /// data.
    /// - Returns: A model with filled and wireframe rendering, or `nil` if mesh
    /// creation fails.
    @MainActor
    static func makeStreetscapeGeometryModel(geometry: GARStreetscapeGeometry) -> ModelEntity? {
        var descriptor = MeshDescriptor()
        
        let garMesh = geometry.mesh
        let vertices = UnsafeBufferPointer(start: garMesh.vertices, count: Int(garMesh.vertexCount))
            .map { vertex in
                simd_float3(x: vertex.x, y: vertex.y, z: vertex.z)
            }
        descriptor.positions = MeshBuffers.Positions(vertices)
        
        let triangleIndices = UnsafeBufferPointer(start: garMesh.triangles, count: Int(garMesh.triangleCount))
            .flatMap { triangle in
                [triangle.indices.0, triangle.indices.1, triangle.indices.2]
            }
        descriptor.primitives = .triangles(triangleIndices)
        
        guard let mesh = try? MeshResource.generate(from: [descriptor]) else { return nil }
        let material = if geometry.type == .terrain {
            terrainMaterial()
        } else {
            randomBuildingMaterial()
        }
        let model = ModelEntity(mesh: mesh, materials: [material])
        
        var linesMaterial = UnlitMaterial(color: .black)
        linesMaterial.triangleFillMode = .lines
        model.addChild(ModelEntity(mesh: mesh, materials: [linesMaterial]))
        
        return model
    }
    
    /// Creates a semi-transparent material for non-terrain streetscape
    /// geometry.
    /// - Returns: A randomly selected unlit building material.
    static func randomBuildingMaterial() -> UnlitMaterial {
        let colors = [
            UIColor(red: 0.7, green: 0, blue: 0.7, alpha: 0.8),
            UIColor(red: 0.7, green: 0.7, blue: 0, alpha: 0.8),
            UIColor(red: 0, green: 0.7, blue: 0.7, alpha: 0.8)
        ]
        var material = UnlitMaterial(color: colors.randomElement()!)
        material.blending = .transparent(opacity: 0.8)
        return material
    }
    
    /// Creates a semi-transparent material for terrain geometry.
    /// - Returns: An unlit green terrain material.
    static func terrainMaterial() -> UnlitMaterial {
        var material = UnlitMaterial(color: UIColor(red: 0, green: 0.5, blue: 0, alpha: 0.7))
        material.blending = .transparent(opacity: 0.9)
        return material
    }
    
    /// Removes all currently rendered streetscape models from the scene and
    /// cache.
    @MainActor
    func removeStreetscapeGeometry() {
        for model in streetscapeGeometryModels.values {
            model.removeFromParent()
        }
        streetscapeGeometryModels.removeAll()
    }
}

extension Logger {
    /// A logger for the custom VPS provider example.
    static let customVPSProviderExample: Self = {
        Logger(subsystem: "com.esri.ArcGISToolkit.Examples", category: "CustomVPSProvider")
    }()
}
