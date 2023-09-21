// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ARKit
import SwiftUI
import ArcGIS

/// A scene view that provides an augmented reality fly over experience.
public struct TableTopSceneView: View {
    /// The last portrait or landscape orientation value.
    @State private var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
    @State private var arViewProxy = ARSwiftUIViewProxy()
    @State private var sceneViewProxy: SceneViewProxy?
    @State private var initialTransformation: TransformationMatrix? = nil
    
    private let cameraController: TransformationMatrixCameraController
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
    private let configuration: ARWorldTrackingConfiguration
    private var didSetTransforamtion: Bool {
        initialTransformation != nil
    }
    
    /// Creates a fly over scene view.
    /// - Parameters:
    ///   - anchorPoint: The anchor point of the ArcGIS Scene.
    ///   - translationFactor: The translation factor that defines how much the scene view translates
    ///   as the device moves.
    ///   - clippingDistance: Determines the clipping distance in meters around the camera. A value
    ///   of `nil` means that no data will be clipped.
    ///   - sceneView: A closure that builds the scene view to be overlayed on top of the
    ///   augmented reality video feed.
    /// - Remark: The provided scene view will have certain properties overridden in order to
    /// be effectively viewed in augmented reality. Properties such as the camera controller,
    /// and view drawing mode.
    public init(
        anchorPoint: Point,
        translationFactor: Double,
        clippingDistance: Double?,
        @ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
    ) {
        self.sceneViewBuilder = sceneView
        
        let initialCamera = Camera(location: anchorPoint, heading: 0, pitch: 90, roll: 0)
        cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
        cameraController.translationFactor = translationFactor
        cameraController.clippingDistance = clippingDistance
        
        configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = [.horizontal]
    }
    
    public var body: some View {
        if #available(iOS 16.0, *) {
            ZStack {
                ARSwiftUIView(proxy: arViewProxy)
                    .onRender { _, _, _ in
                        guard let sceneViewProxy else { return }
                        updateLastGoodDeviceOrientation()
                        sceneViewProxy.draw(
                            for: arViewProxy,
                            cameraController: cameraController,
                            orientation: lastGoodDeviceOrientation,
                            initialTransformation: initialTransformation ?? .identity
                        )
                    }
                    .onAddNode { renderer, node, anchor in
                        visualizePlane(renderer, didAdd: node, for: anchor)
                    }
                    .onUpdateNode { renderer, node, anchor in
                        updatePlane(renderer, didUpdate: node, for: anchor)
                    }
                    .onAppear {
                        arViewProxy.session?.run(configuration)
                    }
                    .onDisappear {
                        arViewProxy.session?.pause()
                    }
                    .onTapGesture { screenPoint in
                        guard let sceneViewProxy,
                              !didSetTransforamtion else { return }
                        
                        if let transformation = sceneViewProxy.setInitialTransformation(
                            for: arViewProxy,
                            using: screenPoint,
                            cameraController: cameraController
                        ) {
                            initialTransformation = transformation
                        }
                    }
                
                    SceneViewReader { proxy in
                        sceneViewBuilder(proxy)
                            .cameraController(cameraController)
                            .attributionBarHidden(true)
                            .spaceEffect(.transparent)
                            .viewDrawingMode(.manual)
                            .atmosphereEffect(.off)
                            .onAppear {
                                self.sceneViewProxy = proxy
                            }
                            .opacity(didSetTransforamtion ? 1 : 0)
                    }
                }
            }
    }
    
    /// Updates the last good device orientation.
    func updateLastGoodDeviceOrientation() {
        // Get the device orientation, but don't allow non-landscape/portrait values.
        let deviceOrientation = UIDevice.current.orientation
        if deviceOrientation.isValidInterfaceOrientation {
            lastGoodDeviceOrientation = deviceOrientation
        }
    }
    
    func visualizePlane(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a custom object to visualize the plane geometry and extent.
        let plane = Plane(anchor: planeAnchor)
        
        // Add the visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(plane)
    }
    
    func updatePlane(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if didSetTransforamtion {
           node.removeFromParentNode()
        }
    
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              let plane = node.childNodes.first as? Plane
        else { return }
        
        // Update extent visualization to the anchor's new bounding rectangle.
        if let extentGeometry = plane.node.geometry as? SCNPlane {
            extentGeometry.width = CGFloat(planeAnchor.extent.x)
            extentGeometry.height = CGFloat(planeAnchor.extent.z)
            plane.node.simdPosition = planeAnchor.center
        }
    }
}

/// Helper class to visualize a plane found by ARKit
class Plane: SCNNode {
    let node: SCNNode
    
    init(anchor: ARPlaneAnchor) {
        // Create a node to visualize the plane's bounding rectangle.
        let extent = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        node = SCNNode(geometry: extent)
        node.simdPosition = anchor.center
        
        // `SCNPlane` is vertically oriented in its local coordinate space, so
        // rotate it to match the orientation of `ARPlaneAnchor`.
        node.eulerAngles.x = -.pi / 2

        super.init()

        node.opacity = 0.25
        guard let material = node.geometry?.firstMaterial
            else { fatalError("SCNPlane always has one material") }
        
        material.diffuse.contents = UIColor.white

        // Add the plane node as child node so they appear in the scene.
        addChildNode(node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SceneViewProxy {
    /// Sets the initial transformation used to offset the originCamera.  The initial transformation is based on an AR point determined via existing plane hit detection from `screenPoint`.  If an AR point cannot be determined, this method will return `false`.
    ///
    /// - Parameter screenPoint: The screen point to determine the `initialTransformation` from.
    /// - Returns: The `initialTransformation`.
    /// - Since: 200.3
    func setInitialTransformation(
        for arViewProxy: ARSwiftUIViewProxy,
        using screenPoint: CGPoint,
        cameraController: TransformationMatrixCameraController
    ) -> TransformationMatrix? {
        // Use the `internalHitTest` method to get the matrix of `screenPoint`.
        guard let matrix = internalHitTest(using: screenPoint, for: arViewProxy) else { return nil }

        // Set the `initialTransformation` as the TransformationMatrix.identity - hit test matrix.
        let initialTransformation = TransformationMatrix.identity.subtracting(matrix)

        return initialTransformation
    }
    
    /// Internal method to perform a hit test operation to get the transformation matrix representing the corresponding real-world point for `screenPoint`.
    ///
    /// - Parameter screenPoint: The screen point to determine the real world transformation matrix from.
    /// - Returns: An `TransformationMatrix` representing the real-world point corresponding to `screenPoint`.
    func internalHitTest(using screenPoint: CGPoint, for arViewProxy: ARSwiftUIViewProxy) -> TransformationMatrix? {
        // Use the `raycastQuery` method on ARSCNView to get the location of `screenPoint`.
        guard let query = arViewProxy.raycastQuery(
            from: screenPoint,
            allowing: .existingPlaneGeometry,
            alignment: .any
        ) else { return nil }

        let results = arViewProxy.session?.raycast(query)

        // Get the worldTransform from the first result; if there's no worldTransform, return nil.
        guard let worldTransform = results?.first?.worldTransform else { return nil }

        // Create our hit test matrix based on the worldTransform location.
        // right now we ignore the orientation of the plane that was hit to find the point
        // since we only use horizontal planes, when we will start using vertical planes
        // we should stop suppressing the quaternion rotation to a null rotation (0,0,0,1)
        let hitTestMatrix = TransformationMatrix.normalized(
            quaternionX: 0,
            quaternionY: 0,
            quaternionZ: 0,
            quaternionW: 1,
            translationX: Double(worldTransform.columns.3.x),
            translationY: Double(worldTransform.columns.3.y),
            translationZ: Double(worldTransform.columns.3.z)
        )

        return hitTestMatrix
    }
}
