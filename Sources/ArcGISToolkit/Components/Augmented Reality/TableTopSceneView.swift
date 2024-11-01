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

/// A scene view that provides an augmented reality table top experience.
@available(visionOS, unavailable)
public struct TableTopSceneView: View {
#if os(iOS)
    /// The proxy for the ARSwiftUIView.
    @State private var arViewProxy = ARSwiftUIViewProxy()
#endif
    /// The initial transformation for the scene's camera controller.
    @State private var initialTransformation: TransformationMatrix? = nil
    /// The camera controller that will be set on the scene view.
    @State private var cameraController: TransformationMatrixCameraController
    /// The current interface orientation.
    @State private var interfaceOrientation: InterfaceOrientation?
    /// The help text to guide the user through an AR experience.
    @State private var helpText: String = ""
    /// A Boolean value that indicates whether the coaching overlay view is active.
    @State private var coachingOverlayIsActive: Bool = true
    /// A Boolean value that indicates whether to hide the coaching overlay view.
    var coachingOverlayIsHidden: Bool = false
    /// The closure that builds the scene view.
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
#if os(iOS)
    /// The configuration for the AR session.
    private let configuration: ARWorldTrackingConfiguration
#endif
    /// A Boolean value indicating that the scene's initial transformation has been set.
    var initialTransformationIsSet: Bool { initialTransformation != nil }
    /// The anchor point for the scene view.
    let anchorPoint: Point
    /// The translation factor for the scene's camera controller.
    let translationFactor: Double
    /// The clipping distance for the scene's camera controller.
    let clippingDistance: Double?
    
    /// Creates a table top scene view.
    /// - Parameters:
    ///   - anchorPoint: The location point of the ArcGIS Scene that is anchored on a physical surface.
    ///   - translationFactor: The translation factor that defines how much the scene view
    ///   translates as the device moves. This value can be determined by dividing the virtual
    ///   content width by the desired physical content width (translation factor = virtual content
    ///   width / desired physical content width). The virtual content width is the real-world size
    ///   of the scene content, and the desired physical content width is the physical tabletop
    ///   width; both measurements should be in meters. The virtual content width is determined 
    ///   by the clipping distance in meters around the camera.
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
        self.anchorPoint = anchorPoint
        self.translationFactor = translationFactor
        self.clippingDistance = clippingDistance
        
        let initialCamera = Camera(location: anchorPoint, heading: 0, pitch: 90, roll: 0)
        let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
        cameraController.translationFactor = translationFactor
        cameraController.clippingDistance = clippingDistance
        _cameraController = .init(initialValue: cameraController)
        
#if os(iOS)
        configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = [.horizontal]
#endif
    }
    
    public var body: some View {
        SceneViewReader { sceneViewProxy in
            ZStack {
#if os(iOS)
                ARSwiftUIView(proxy: arViewProxy)
                    .onDidUpdateFrame { _, frame in
                        guard let interfaceOrientation else { return }
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
                    .onAddNode { parameters in
                        addPlane(renderer: parameters.renderer, node: parameters.node, anchor: parameters.anchor)
                    }
                    .onUpdateNode { parameters in
                        updatePlane(with: parameters.node, for: parameters.anchor)
                    }
                    .onTapGesture { screenPoint in
                        guard !initialTransformationIsSet else { return }
                        
                        if let transformation = sceneViewProxy.initialTransformation(
                            for: arViewProxy,
                            using: screenPoint
                        ) {
                            initialTransformation = transformation
                            withAnimation {
                                helpText = ""
                            }
                        }
                    }
                    .onAppear {
                        arViewProxy.session.run(configuration)
                    }
                    .onDisappear {
                        arViewProxy.session.pause()
                    }
                
                if !coachingOverlayIsHidden {
                    ARCoachingOverlay(goal: .horizontalPlane)
                        .sessionProvider(arViewProxy)
                        .active(coachingOverlayIsActive)
                        .allowsHitTesting(false)
                        .overlay (alignment: .top) {
                            if !helpText.isEmpty {
                                Text(helpText)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(8)
                                    .background(.regularMaterial, ignoresSafeAreaEdges: .horizontal)
                            }
                        }
                }
#endif
                sceneViewBuilder(sceneViewProxy)
                    .cameraController(cameraController)
                    .attributionBarHidden(true)
                    .spaceEffect(.transparent)
                    .atmosphereEffect(.off)
                    .opacity(initialTransformationIsSet ? 1 : 0)
            }
        }
        .onChange(anchorPoint) { anchorPoint in
            cameraController.originCamera = Camera(location: anchorPoint, heading: 0, pitch: 90, roll: 0)
        }
        .onChange(translationFactor) { translationFactor in
            cameraController.translationFactor = translationFactor
        }
        .onChange(clippingDistance) { clippingDistance in
            cameraController.clippingDistance = clippingDistance
        }
        .observingInterfaceOrientation($interfaceOrientation)
    }
    
#if os(iOS)
    /// Visualizes a new node added to the scene as an AR Plane.
    /// - Parameters:
    ///   - renderer: The renderer for the scene.
    ///   - node: The node to be added to the scene.
    ///   - anchor: The anchor position of the node.
    private func addPlane(renderer: SCNSceneRenderer, node: SCNNode, anchor: ARAnchor) {
        guard !initialTransformationIsSet,
              let planeAnchor = anchor as? ARPlaneAnchor,
              let device = renderer.device,
              let planeGeometry = ARSCNPlaneGeometry(device: device)
        else { return }
        
        // Disable coaching overlay when a plane node is found.
        coachingOverlayIsActive = false
        
        planeGeometry.update(from: planeAnchor.geometry)
        
        // Add SCNMaterial to plane geometry.
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.65)
        planeGeometry.materials = [material]
        
        // Create a SCNNode from plane geometry.
        let planeNode = SCNNode(geometry: planeGeometry)
        
        // Add the visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(planeNode)
        
        // Set help text when plane is visualized.
        withAnimation {
            helpText = .planeFound
        }
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
        
        // Set help text when plane visualization is updated.
        withAnimation {
            helpText = .planeFound
        }
    }
#endif
    
    /// Sets the visibility of the coaching overlay view for the AR experience.
    /// - Parameter hidden: A Boolean value that indicates whether to hide the
    ///  coaching overlay view.
    public func coachingOverlayHidden(_ hidden: Bool) -> Self {
        var view = self
        view.coachingOverlayIsHidden = hidden
        return view
    }
}

#if os(iOS)
private extension SceneViewProxy {
    /// Sets the initial transformation used to offset the originCamera.  The initial transformation is based on an AR point determined
    /// via existing plane hit detection from `screenPoint`.  If an AR point cannot be determined, this method will return `false`.
    /// - Parameters:
    ///   - arViewProxy: The AR view proxy.
    ///   - screenPoint: The screen point to determine the `initialTransformation` from.
    /// - Returns: The `initialTransformation`.
    @MainActor
    func initialTransformation(
        for arViewProxy: ARSwiftUIViewProxy,
        using screenPoint: CGPoint
    ) -> TransformationMatrix? {
        // Use the `raycast` method to get the matrix of `screenPoint`.
        guard let matrix = arViewProxy.raycast(from: screenPoint, allowing: .existingPlaneGeometry) else { return nil }
        
        // Set the `initialTransformation` as the TransformationMatrix.identity - raycast matrix.
        let initialTransformation = TransformationMatrix.identity.subtracting(matrix)
        
        return initialTransformation
    }
}
#endif

private extension String {
    static var planeFound: String {
        String(
            localized: "Tap a surface to place the scene",
            bundle: .toolkitModule,
            comment: """
                 An instruction to the user to tap on a horizontal surface to
                 place an ArcGIS Scene.
                 """
        )
    }
}
