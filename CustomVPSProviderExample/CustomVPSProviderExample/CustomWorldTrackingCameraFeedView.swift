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
import RealityKit
import SwiftUI

/// Displays the AR camera feed and updates world-scale camera state using
/// Google geospatial tracking.
struct CustomWorldTrackingCameraFeedView: View {
    /// Shared world-scale context used to read provider state and update the
    /// scene.
    let context: WorldScaleSceneView<CustomWorldTracking>.Context
    
    /// Creates an instance using the provided world-scale scene context.
    /// - Parameter context: The world-scale scene context backing this view.
    init(context: WorldScaleSceneView<CustomWorldTracking>.Context) {
        self.context = context
    }
    
    /// The closure to perform when the camera tracking state changes.
    private var onCameraTrackingStateChangedAction: ((ARCamera.TrackingState) -> Void)?
    
    /// The current interface orientation.
    @State private var interfaceOrientation: InterfaceOrientation?
    
    /// A Boolean value indicating whether streetscape geometry is enabled.
    private var streetscapeGeometryEnabled = false
    
    var body: some View {
        SwiftUIARView(sessionProvider: context.provider.arSessionProvider)
            .onDidUpdateFrame { _, frame in
                guard let interfaceOrientation,
                      let garFrame = try? context.provider.garSession.update(frame),
                      let earth = garFrame.earth else {
                    return
                }
                
                if context.isLocalized {
                    updateCameraController(
                        camera: frame.camera,
                        geospatialTransform: earth.cameraGeospatialTransform
                    )
                    
                    context.sceneView.setFieldOfView(
                        for: frame,
                        orientation: interfaceOrientation
                    )
                    
                    if streetscapeGeometryEnabled {
                        updateStreetscapeGeometry(using: garFrame.streetscapeGeometries ?? [])
                    }
                } else {
                    updateLocalizationState(for: earth.trackingState)
                }
            }
            .onCameraDidChangeTrackingState { _, trackingState in
                onCameraTrackingStateChangedAction?(trackingState)
            }
            .observingInterfaceOrientation($interfaceOrientation)
            .onChange(of: streetscapeGeometryEnabled) { _, newEnabled in
                guard !newEnabled else { return }
                context.provider.removeStreetscapeGeometry()
            }
    }
    
    /// Updates the localization based on the given tracking state.
    /// - Parameter trackingState: The ARCore frame tracking state.
    func updateLocalizationState(for trackingState: GARTrackingState?) {
        guard trackingState == .tracking else { return }
        context.isLocalized = true
    }
}

extension CustomWorldTrackingCameraFeedView {
    /// Sets a closure to perform when the camera tracking state changes.
    /// - Parameter action: The closure to perform when the camera tracking
    /// state has changed.
    func onCameraTrackingStateChanged(
        perform action: @escaping (_ cameraTrackingState: ARCamera.TrackingState) -> Void
    ) -> Self {
        var copy = self
        copy.onCameraTrackingStateChangedAction = action
        return copy
    }
    
    /// Sets a closure to perform when the streetscape geometry enabled value
    /// changes.
    /// - Parameter enabled: A Boolean value that indicates whether the
    /// streetscape geometry is enabled.
    func streetscapeGeometryEnabled(_ enabled: Bool) -> Self {
        var copy = self
        copy.streetscapeGeometryEnabled = enabled
        return copy
    }
}

private extension CustomWorldTrackingCameraFeedView {
    /// Updates the scene's camera controller based on the given AR camera and
    /// ARCore frame geospatial transform.
    /// - Parameters:
    ///   - camera: The current ARKit camera.
    ///   - geospatialTransform: The ARCore frame geospatial transform data.
    func updateCameraController(camera: ARCamera, geospatialTransform: GARGeospatialTransform?) {
        guard let interfaceOrientation,
              let geospatialTransform else {
            return
        }
        
        let orientation = geospatialTransform.eastUpSouthQTarget
        let transform = camera.transform(for: interfaceOrientation)
        let (pitch, roll) = transform.pitchAndRoll
        let heading = CLLocation.headingFromEastUpSouthQTarget(orientation)

        let fromSpatialReference = SpatialReference(wkid: WKID(4326)!, verticalWKID: WKID(115700)!)!
        let toSpatialReference = SpatialReference(wkid: WKID(4326)!, verticalWKID: WKID(5773)!)!
        
        let pointToProject = Point(
            x: geospatialTransform.coordinate.longitude,
            y: geospatialTransform.coordinate.latitude,
            z: geospatialTransform.altitude,
            spatialReference: fromSpatialReference
        )
        
        guard let projectedLocation = GeometryEngine.project(
            pointToProject,
            into: toSpatialReference
        ) else {
            return
        }
        
        let correctedAltitude = (projectedLocation.z ?? 0) + context.calibration.totalElevationCorrection
        let correctedHeading = heading + context.calibration.totalHeadingCorrection
        
        context.cameraController.originCamera = Camera(
            latitude: projectedLocation.y,
            longitude: projectedLocation.x,
            altitude: correctedAltitude,
            heading: correctedHeading,
            pitch: 90 + pitch,
            roll: 90 + roll
        )
        
        // We have to do this or the error gets bigger and bigger.
        context.cameraController.transformationMatrix = .identity
    }
    
    /// Synchronizes the provider's streetscape geometry models with the latest
    /// ARCore streetscape geometry collection.
    ///
    /// Existing models are updated in place, new models are created and
    /// attached to the world origin when possible, and models that have
    /// stopped tracking are removed. When a geometry is present but not
    /// actively tracking, its model remains in the scene graph but is hidden.
    /// If ARCore reports no streetscape geometries, all existing streetscape
    /// geometry is removed from the provider.
    /// - Parameter geometries: The latest streetscape geometries reported by
    ///   the current ARCore frame.
    func updateStreetscapeGeometry(using geometries: [GARStreetscapeGeometry]) {
        if !geometries.isEmpty {
            for geometry in geometries {
                var model: ModelEntity
                if let existingModel = context.provider.streetscapeGeometryModels[geometry.identifier] {
                    model = existingModel
                } else if let newModel = CustomWorldTracking.makeStreetscapeGeometryModel(geometry: geometry) {
                    context.provider.streetscapeGeometryModels[geometry.identifier] = newModel
                    newModel.setParent(context.provider.worldOrigin)
                    model = newModel
                } else {
                    continue
                }
                
                model.transform = Transform(matrix: geometry.meshTransform)
                
                if geometry.trackingState == .stopped {
                    // Remove geometries that permanently stopped tracking.
                    context.provider.streetscapeGeometryModels.removeValue(forKey: geometry.identifier)
                    model.removeFromParent()
                } else {
                    // Hide geometries if not actively tracking.
                    model.isEnabled = (geometry.trackingState == .tracking)
                }
            }
        } else {
            context.provider.removeStreetscapeGeometry()
        }
    }
}

private extension ARCamera {
    /// Returns the transform rotated for the given interface orientation.
    /// - Parameter orientation: The current interface orientation.
    func transform(for orientation: InterfaceOrientation) -> simd_float4x4 {
        let rotation: SCNMatrix4? = switch orientation {
        case .landscapeLeft:
            // Rotate -90° around Z axis
            SCNMatrix4MakeRotation(-.pi / 2, 0, 0, 1)
        case .landscapeRight:
            // Rotate +90° around Z axis
            SCNMatrix4MakeRotation(.pi / 2, 0, 0, 1)
        case .portraitUpsideDown:
            // Rotate 180° around Z axis
            SCNMatrix4MakeRotation(.pi, 0, 0, 1)
        default:
            nil
        }
        return if let rotation {
            simd_mul(transform, simd_float4x4(rotation))
        } else {
            transform
        }
    }
}

private extension simd_float4x4 {
    /// The pitch and roll (degrees) derived from this transform matrix.
    var pitchAndRoll: (pitch: Double, roll: Double) {
        // Forward vector in camera space is -z axis.
        let forward = SIMD3<Double>(
            x: -Double(columns.2.x),
            y: -Double(columns.2.y),
            z: -Double(columns.2.z)
        )
        
        // Pitch: angle between forward vector and horizontal plane (x-z).
        let pitch = atan2(forward.y, hypot(forward.x, forward.z)) * 180.0 / .pi
        // Roll: angle between up vector and vertical plane (y-z).
        let roll = atan2(Double(columns.0.y), Double(columns.1.y)) * 180.0 / .pi
        return (pitch, roll)
    }
}

private extension CLLocation {
    /// Converts an East-Up-South orientation quaternion into a compass heading
    /// in degrees.
    /// - Parameter q: The orientation quaternion in the EUS coordinate frame.
    /// - Returns: A heading normalized to the range `0..<360`.
    static func headingFromEastUpSouthQTarget(_ q: simd_quatf) -> Double {
        let forwardTarget = SIMD3<Float>(0, 0, -1)
        let forwardEUS = q.act(forwardTarget)
        let headingRad = atan2(
            Double(forwardEUS.x),
            Double(-forwardEUS.z)
        )
        let degrees = headingRad * 180.0 / .pi
        let normalized = degrees.truncatingRemainder(dividingBy: 360)
        return normalized < 0 ? normalized + 360 : normalized
    }
}
