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
import ArcGIS
import ArcGISToolkit
import ARCore
import ARCoreGeospatial
import ARKit
import RealityKit

/// A world-tracking provider backed by the Google ARCore SDK.
final class CustomWorldTracking {
    @MainActor let arSessionProvider = ARSessionProvider<ARView>()
    /// The ARCore session that produces geospatial and streetscape updates.
    let garSession: GARSession
    /// The root world origin anchor for all generated streetscape content.
    @MainActor let worldOrigin = AnchorEntity(world: matrix_identity_float4x4)
    /// A cache of generated streetscape models keyed by ARCore geometry
    /// identifier.
    var streetscapeGeometryModels: [UUID: ModelEntity] = [:]
    
    /// Creates an instance with the given API key and bundle identifier.
    /// - Parameters:
    ///   - apiKey: An API key for Google Cloud Services.
    ///   - bundleIdentifier: The bundle identifier associated to the API key.
    ///   If `nil`, defaults to `Bundle.main.bundleIdentifier`.
    @MainActor
    init(apiKey: String, bundleIdentifier: String? = nil) throws {
        garSession = try GARSession(apiKey: apiKey, bundleIdentifier: bundleIdentifier)
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
extension CustomWorldTracking: WorldTrackingProvider {
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
        
        do {
            let session = CLServiceSession(authorization: .whenInUse)
            for try await diagnostic in session.diagnostics {
                if !diagnostic.authorizationRequestInProgress {
                    // A denial occurred.
                    break
                }
            }
            
            runARSession()
            arSessionProvider.scene.addAnchor(worldOrigin)
            setupGARSession()
        } catch {
            // Do nothing.
        }
    }
    
    func stop() {
        pauseARSession()
    }
}

extension CustomWorldTracking {
    /// Configures the ARCore session.
    private func setupGARSession() {
        guard garSession.isGeospatialModeSupported(.enabled) else { return }
        
        let configuration = GARSessionConfiguration()
        configuration.geospatialMode = .enabled
        configuration.streetscapeGeometryMode = .enabled
        var error: NSError?
        garSession.setConfiguration(configuration, error: &error)
    }
}

private extension CustomWorldTracking {
    /// Sets the ArcGIS projection engine directory from bundled projection data
    /// when available.
    func setProjectionEngineDirectoryURL() {
        if let pedataURL = Bundle.main.url(forResource: "pedata", withExtension: nil) {
            do {
                print("Setting Projection Engine Directory: \(pedataURL)")
                try TransformationCatalog.setProjectionEngineDirectoryURL(pedataURL)
            } catch {
                print("Error setting Projection Engine Directory: \(error)")
            }
        } else if let egm96URL = Bundle.main.url(forResource: "egm96", withExtension: "grd") {
            let pedataURL = egm96URL.deletingLastPathComponent()
            do {
                try TransformationCatalog.setProjectionEngineDirectoryURL(pedataURL)
            } catch {
                print("Error setting Projection Engine Directory: \(error)")
            }
        } else {
            print("Note: PE data not found - using built-in transformations")
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
#endif
