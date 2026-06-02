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
import RealityKit

/// A scene view that provides an augmented reality table top experience.
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
public struct TableTopSceneView: View {
#if os(iOS)
    /// The AR session provider for the ARSwiftUIView.
    @State private var arSessionProvider = ARSessionProvider<ARView>()
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
    /// The entities for the identified planes.
    @State private var planeEntities = [UUID: ModelEntity]()
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
                ARSwiftUIView(sessionProvider: arSessionProvider)
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
                    .onAddAnchor { planeAnchor in
                        addPlane(for: planeAnchor)
                    }
                    .onUpdateAnchor { planeAnchor in
                        updatePlane(for: planeAnchor)
                    }
                    .onTapGesture { screenPoint in
                        guard !initialTransformationIsSet else { return }
                        
                        if let transformation = sceneViewProxy.initialTransformation(
                            for: arSessionProvider,
                            using: screenPoint
                        ) {
                            initialTransformation = transformation
                            withAnimation {
                                helpText = ""
                            }
                        }
                    }
                    .onAppear {
                        arSessionProvider.session.run(configuration, options: .removeExistingAnchors)
                    }
                    .onDisappear {
                        arSessionProvider.session.pause()
                    }
                
                if !coachingOverlayIsHidden {
                    ARCoachingOverlay(goal: .horizontalPlane)
                        .sessionProvider(arSessionProvider)
                        .active(coachingOverlayIsActive)
                        .allowsHitTesting(false)
                        .ignoresSafeArea()
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
        .onChange(of: anchorPoint) {
            cameraController.originCamera = Camera(location: anchorPoint, heading: 0, pitch: 90, roll: 0)
        }
        .onChange(of: translationFactor) {
            cameraController.translationFactor = translationFactor
        }
        .onChange(of: clippingDistance) {
            cameraController.clippingDistance = clippingDistance
        }
        .observingInterfaceOrientation($interfaceOrientation)
    }
    
#if os(iOS)
    /// Visualizes a new AR Plane being added to the scene.
    /// - Parameter planeAnchor: The plane anchor.
    private func addPlane(for planeAnchor: ARPlaneAnchor) {
        guard !initialTransformationIsSet else { return }
        
        // Disable coaching overlay when a plane is found.
        coachingOverlayIsActive = false
        
        let anchorEntity = AnchorEntity()
        anchorEntity.transform = Transform(matrix: planeAnchor.transform)
        
        let mesh = makeMesh(from: planeAnchor)
        let material = SimpleMaterial(
            color: .white.withAlphaComponent(0.6),
            roughness: 1,
            isMetallic: true
        )
        
        let planeEntity = ModelEntity(mesh: mesh, materials: [material])
        
        anchorEntity.addChild(planeEntity)
        arSessionProvider.scene.addAnchor(anchorEntity)
        
        planeEntities[planeAnchor.identifier] = planeEntity
        
        // Set help text when plane is visualized.
        withAnimation {
            helpText = .planeFound
        }
    }
    
    /// Visualizes an AR Plane update in the scene.
    /// - Parameter planeAnchor: The plane anchor.
    private func updatePlane(for planeAnchor: ARPlaneAnchor) {
        if initialTransformationIsSet {
            planeEntities.values.forEach { $0.removeFromParent() }
            planeEntities.removeAll()
            return
        }
        
        guard let planeEntity = planeEntities[planeAnchor.identifier] else { return }
        
        planeEntity.model?.mesh = makeMesh(from: planeAnchor)
        
        // Set help text when plane visualization is updated.
        withAnimation {
            helpText = .planeFound
        }
    }
    
    /// Creates a mesh resource for a plane anchor.
    /// - Parameter anchor: The plane anchor.
    private func makeMesh(from anchor: ARPlaneAnchor) -> MeshResource {
        // Convert plane anchor vertices to SIMD3<Float> for use in the mesh descriptor.
        let positions = anchor.geometry.vertices.map { SIMD3<Float>($0.x, $0.y, $0.z) }
        // Convert plane anchor triangle indices to UInt32 for use in the mesh descriptor.
        let triangles = anchor.geometry.triangleIndices.map(UInt32.init)
        
        // Create a mesh descriptor for the plane anchor geometry using
        // the positions and triangle indices.
        var descriptor = MeshDescriptor()
        descriptor.positions = MeshBuffers.Positions(positions)
        descriptor.primitives = .triangles(triangles)
        
        // Generate and return a mesh resource from the mesh descriptor.
        return try! MeshResource.generate(from: [descriptor])
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
    ///   - sessionProvider: The AR session provider.
    ///   - screenPoint: The screen point to determine the `initialTransformation` from.
    /// - Returns: The `initialTransformation`.
    @MainActor
    func initialTransformation(
        for sessionProvider: ARSessionProvider<ARView>,
        using screenPoint: CGPoint
    ) -> TransformationMatrix? {
        // Use the `raycast` method to get the matrix of `screenPoint`.
        guard let matrix = sessionProvider.arView.raycast(from: screenPoint, allowing: .existingPlaneGeometry) else { return nil }
        
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
