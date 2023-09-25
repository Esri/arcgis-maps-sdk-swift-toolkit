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

/// A scene view that provides an augmented reality table top experience.
public struct TableTopSceneView: View {
    /// The last portrait or landscape orientation value.
    @State private var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
    @State private var arViewProxy = ARSwiftUIViewProxy()
    @State private var sceneViewProxy: SceneViewProxy?
    @State private var initialTransformation: TransformationMatrix? = nil
    @State private var cameraController: TransformationMatrixCameraController
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
    private let configuration: ARWorldTrackingConfiguration
    private var initialTransformationIsSet: Bool { initialTransformation != nil }
    
    /// Creates a table top scene view.
    /// - Parameters:
    ///   - anchorPoint: The location point of the ArcGIS Scene that is anchored on a physical surface.
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
        let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
        cameraController.translationFactor = translationFactor
        cameraController.clippingDistance = clippingDistance
        _cameraController = .init(initialValue: cameraController)
        
        configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = [.horizontal]
    }
    
    public var body: some View {
        ZStack {
            ARSwiftUIView(proxy: arViewProxy)
                .onDidUpdateFrame { _, frame in
                    guard let sceneViewProxy else { return }
                    updateLastGoodDeviceOrientation()
                    sceneViewProxy.updateCamera(
                        frame: frame,
                        cameraController: cameraController,
                        orientation: lastGoodDeviceOrientation,
                        initialTransformation: initialTransformation ?? .identity
                    )
                    sceneViewProxy.setFieldOfView(
                        for: frame,
                        orientation: lastGoodDeviceOrientation
                    )
                }
                .onAddNode { _, node, anchor in
                    addPlane(with: node, for: anchor)
                }
                .onUpdateNode { _, node, anchor in
                    updatePlane(with: node, for: anchor)
                }
                .onSingleTapGesture { screenPoint in
                    guard let sceneViewProxy,
                          !initialTransformationIsSet else { return }
                    
                    if let transformation = sceneViewProxy.initialTransformation(
                        for: arViewProxy,
                        using: screenPoint
                    ) {
                        initialTransformation = transformation
                    }
                }
                .onAppear {
                    arViewProxy.session?.run(configuration)
                }
                .onDisappear {
                    arViewProxy.session?.pause()
                }
            
            SceneViewReader { proxy in
                sceneViewBuilder(proxy)
                    .cameraController(cameraController)
                    .attributionBarHidden(true)
                    .spaceEffect(.transparent)
                    .atmosphereEffect(.off)
                    .onAppear {
                        self.sceneViewProxy = proxy
                    }
                    .opacity(initialTransformationIsSet ? 1 : 0)
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
    
    /// Visualizes a new node added to the scene as an AR Plane.
    /// - Parameters:
    ///   - node: The node to be added to the scene.
    ///   - anchor: The anchor position of the node.
    func addPlane(with node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              // Create a custom object to visualize the plane geometry and extent.
              let plane = Plane(anchor: planeAnchor) else { return }
        
        // Add the visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(plane)
    }
    
    /// Visualizes a node updated in scene as an AR Plane.
    /// - Parameters:
    ///   - node: The node to be updated in the scene.
    ///   - anchor: The anchor position of the node.
    func updatePlane(with node: SCNNode, for anchor: ARAnchor) {
        if initialTransformationIsSet {
            node.removeFromParentNode()
        }
        
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              let plane = node.childNodes.first as? Plane else { return }
        
        // Update extent visualization to the anchor's new bounding rectangle.
        if let extentGeometry = plane.node.geometry as? SCNPlane {
            extentGeometry.width = CGFloat(planeAnchor.extent.x)
            extentGeometry.height = CGFloat(planeAnchor.extent.z)
            plane.node.simdPosition = planeAnchor.center
        }
    }
}

/// A helper class to visualize a plane found by ARKit.
class Plane: SCNNode {
    let node: SCNNode
    
    init?(anchor: ARPlaneAnchor) {
        // Create a node to visualize the plane's bounding rectangle.
        let extent = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        node = SCNNode(geometry: extent)
        node.simdPosition = anchor.center
        
        // `SCNPlane` is vertically oriented in its local coordinate space, so
        // rotate it to match the orientation of `ARPlaneAnchor`.
        node.eulerAngles.x = -.pi / 2
        
        super.init()
        
        node.opacity = 0.25
        guard let material = node.geometry?.firstMaterial else { return nil }
        
        material.diffuse.contents = UIColor.white
        
        // Add the plane node as child node so they appear in the scene.
        addChildNode(node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ARSwiftUIViewProxy {
    /// Performs a hit test operation to get the transformation matrix representing the corresponding real-world point for `screenPoint`.
    /// - Parameter screenPoint: The screen point to determine the real world transformation matrix from.
    /// - Returns: A `TransformationMatrix` representing the real-world point corresponding to `screenPoint`.
    func hitTest(using screenPoint: CGPoint) -> TransformationMatrix? {
        // Use the `raycastQuery` method on ARSCNView to get the location of `screenPoint`.
        guard let query = raycastQuery(
            from: screenPoint,
            allowing: .existingPlaneGeometry,
            alignment: .any
        ) else { return nil }
        
        let results = session?.raycast(query)
        
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

private extension SceneViewProxy {
    /// Sets the initial transformation used to offset the originCamera.  The initial transformation is based on an AR point determined
    /// via existing plane hit detection from `screenPoint`.  If an AR point cannot be determined, this method will return `false`.
    /// - Parameters:
    ///   - arViewProxy: The AR view proxy.
    ///   - screenPoint: The screen point to determine the `initialTransformation` from.
    /// - Returns: The `initialTransformation`.
    func initialTransformation(
        for arViewProxy: ARSwiftUIViewProxy,
        using screenPoint: CGPoint
    ) -> TransformationMatrix? {
        // Use the `hitTest` method to get the matrix of `screenPoint`.
        guard let matrix = arViewProxy.hitTest(using: screenPoint) else { return nil }
        
        // Set the `initialTransformation` as the TransformationMatrix.identity - hit test matrix.
        let initialTransformation = TransformationMatrix.identity.subtracting(matrix)
        
        return initialTransformation
    }
    
    /// Sets the field of view for the scene view's camera for a given augmented reality frame.
    /// - Parameters:
    ///   - frame: The current AR frame.
    ///   - orientation: The device orientation.
    func setFieldOfView(for frame: ARFrame, orientation: UIDeviceOrientation) {
        let camera = frame.camera
        let intrinsics = camera.intrinsics
        let imageResolution = camera.imageResolution
        
        setFieldOfViewFromLensIntrinsics(
            xFocalLength: intrinsics[0][0],
            yFocalLength: intrinsics[1][1],
            xPrincipal: intrinsics[2][0],
            yPrincipal: intrinsics[2][1],
            xImageSize: Float(imageResolution.width),
            yImageSize: Float(imageResolution.height),
            deviceOrientation: orientation
        )
    }
}
