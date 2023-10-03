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
    /// The proxy for the ARSwiftUIView.
    @State private var arViewProxy = ARSwiftUIViewProxy()
    /// The proxy for the scene view.
    @State private var sceneViewProxy: SceneViewProxy?
    /// The initial transformation for the scene's camera controller.
    @State private var initialTransformation: TransformationMatrix? = nil
    /// The camera controller that will be set on the scene view.
    @State private var cameraController: TransformationMatrixCameraController
    /// The current interface orientation.
    @State private var interfaceOrientation: InterfaceOrientation?
    /// The closure that builds the scene view.
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
    /// The configuration for the AR session.
    private let configuration: ARWorldTrackingConfiguration
    /// A Boolean value indicating that the scene's initial transformation has been set.
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
                    guard let sceneViewProxy, let interfaceOrientation, let initialTransformation else { return }
                    sceneViewProxy.updateCamera(
                        frame: frame,
                        cameraController: cameraController,
                        orientation: interfaceOrientation,
                        initialTransformation: initialTransformation
                    )
                    sceneViewProxy.setFieldOfView(
                        for: frame,
                        orientation: interfaceOrientation
                    )
                }
                .onAddNode { renderer, node, anchor in
                    addPlane(renderer: renderer, node: node, anchor: anchor)
                }
                .onUpdateNode { _, node, anchor in
                    updatePlane(with: node, for: anchor)
                }
                .onSingleTapGesture { screenPoint in
                    guard let sceneViewProxy,
                          !initialTransformationIsSet
                    else { return }
                    
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
                        // Capture scene view proxy as a workaround for a bug where
                        // preferences set for `ARSwiftUIView` are not honored. The
                        // issue has been logged with a bug report with ID FB13188508.
                        self.sceneViewProxy = proxy
                    }
                    .opacity(initialTransformationIsSet ? 1 : 0)
            }
        }
        .observingInterfaceOrientation($interfaceOrientation)
    }
    
    /// Visualizes a new node added to the scene as an AR Plane.
    /// - Parameters:
    ///   - renderer: The renderer for the scene.
    ///   - node: The node to be added to the scene.
    ///   - anchor: The anchor position of the node.
    private func addPlane(renderer: SCNSceneRenderer, node: SCNNode, anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              let device = renderer.device,
              let planeGeometry = ARSCNPlaneGeometry(device: device)
        else { return }
        
        planeGeometry.update(from: planeAnchor.geometry)
        
        // Add SCNMaterial to plane geometry.
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        planeGeometry.materials = [material]
        
        // Create a SCNNode from plane geometry.
        let planeNode = SCNNode(geometry: planeGeometry)
        
        // Add the visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(planeNode)
    }
    
    /// Visualizes a node updated in the scene as an AR Plane.
    /// - Parameters:
    ///   - node: The node to be updated in the scene.
    ///   - anchor: The anchor position of the node.
    private func updatePlane(with node: SCNNode, for anchor: ARAnchor) {
        if initialTransformationIsSet {
            node.removeFromParentNode()
            return
        }
        
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              let planeNode = node.childNodes.first,
              let planeGeometry = planeNode.geometry as? ARSCNPlaneGeometry
        else { return }
        
        // Update extent visualization to the anchor's new geometry.
        planeGeometry.update(from: planeAnchor.geometry)
    }
}

private extension View {
    /// Sets a closure to perform when a single tap occurs on the view.
    /// - Parameters:
    ///   - action: The closure to perform upon single tap.
    ///   - screenPoint: The location of the tap in the view's coordinate space.
    func onSingleTapGesture(perform action: @escaping (_ screenPoint: CGPoint) -> Void) -> some View {
        if #available(iOS 16.0, *) {
            return self.onTapGesture { screenPoint in
                action(screenPoint)
            }
        } else {
            return self.gesture(
                DragGesture()
                    .onEnded { dragAttributes in
                        action(dragAttributes.location)
                    }
            )
        }
    }
}

private extension ARSwiftUIViewProxy {
    /// Performs a hit test operation to get the transformation matrix representing the corresponding real-world point for `screenPoint`.
    /// - Parameter screenPoint: The screen point to determine the real world transformation matrix from.
    /// - Returns: A `TransformationMatrix` representing the real-world point corresponding to `screenPoint`.
    func hitTest(at screenPoint: CGPoint) -> TransformationMatrix? {
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
        // Right now we ignore the orientation of the plane that was hit to find the point
        // since we only use horizontal planes.
        // If we start supporting vertical planes we will have to stop suppressing the
        // quaternion rotation to a null rotation (0,0,0,1).
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
        guard let matrix = arViewProxy.hitTest(at: screenPoint) else { return nil }
        
        // Set the `initialTransformation` as the TransformationMatrix.identity - hit test matrix.
        let initialTransformation = TransformationMatrix.identity.subtracting(matrix)
        
        return initialTransformation
    }
}
