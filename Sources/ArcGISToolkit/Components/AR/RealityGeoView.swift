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

import ArcGIS
import ARKit
import SwiftUI

public enum RealityTrackingMode {
    case ignore
    case initial
    case continuous
}

public struct RealityGeoView: UIViewControllerRepresentable {
    private let scene: ArcGIS.Scene
    private let renderVideoFeed: Bool
    private let cameraController: TransformationMatrixCameraController
    private let trackingMode: RealityTrackingMode
    
    public func makeUIViewController(context: Context) -> RealityGeoViewController {
        let viewController = RealityGeoViewController(
            scene: scene,
            cameraController: cameraController,
            renderVideoFeed: renderVideoFeed
        )
        viewController.arSCNView.delegate = context.coordinator
        setProperties(for: viewController, with: context)
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: RealityGeoViewController, context: Context) {
        setProperties(for: uiViewController, with: context)
    }
    
    public init(
        scene: ArcGIS.Scene = ArcGIS.Scene(),
        cameraController: TransformationMatrixCameraController = TransformationMatrixCameraController(),
        trackingMode: RealityTrackingMode = .ignore,
        renderVideoFeed: Bool
    ) {
        self.scene = scene
        self.cameraController = cameraController
        self.trackingMode = trackingMode
        self.renderVideoFeed = renderVideoFeed
    }
    
    private func setProperties(for viewController: RealityGeoViewController, with context: Context) {
        context.coordinator.arSCNView = viewController.arSCNView
        context.coordinator.isTracking = viewController.isTracking
        context.coordinator.lastGoodDeviceOrientation = viewController.lastGoodDeviceOrientation
        context.coordinator.initialTransformation = viewController.initialTransformation
        context.coordinator.sceneViewController = viewController.sceneViewController
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

extension RealityGeoView {
    public class Coordinator: NSObject, ARSCNViewDelegate, SCNSceneRendererDelegate, ARSessionObserver {
        /// We implement `ARSCNViewDelegate` methods, but will use `arSCNViewDelegate` to forward them to clients.
        /// - Since: 200.3
        public weak var arSCNViewDelegate: ARSCNViewDelegate?
        
        var arSCNView: ARSCNView?
        var isTracking: Bool = false
        var sceneViewController: ArcGISSceneViewController?
        var lastGoodDeviceOrientation: UIDeviceOrientation?
        var initialTransformation: TransformationMatrix?
        
        // ARSCNViewDelegate methods
        
        public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            arSCNViewDelegate?.renderer?(renderer, didAdd: node, for: anchor)
        }
        
        public func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
            arSCNViewDelegate?.renderer?(renderer, willUpdate: node, for: anchor)
        }
        
        public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            arSCNViewDelegate?.renderer?(renderer, didUpdate: node, for: anchor)
        }
        
        public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
            arSCNViewDelegate?.renderer?(renderer, didRemove: node, for: anchor)
        }
        
        // ARSessionObserver methods
        
        public func session(_ session: ARSession, didFailWithError error: Error) {
            arSCNViewDelegate?.session?(session, didFailWithError: error)
        }
        
        public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            arSCNViewDelegate?.session?(session, cameraDidChangeTrackingState: camera)
        }
        
        public func sessionWasInterrupted(_ session: ARSession) {
            arSCNViewDelegate?.sessionWasInterrupted?(session)
        }
        
        public func sessionInterruptionEnded(_ session: ARSession) {
            arSCNViewDelegate?.sessionWasInterrupted?(session)
        }
        
        public func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
            return arSCNViewDelegate?.sessionShouldAttemptRelocalization?(session) ?? false
        }
        
        public func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
            arSCNViewDelegate?.session?(session, didOutputAudioSampleBuffer: audioSampleBuffer)
        }
        
        // SCNSceneRendererDelegate methods
        
        public  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            arSCNViewDelegate?.renderer?(renderer, updateAtTime: time)
        }
        
        public func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
            arSCNViewDelegate?.renderer?(renderer, didApplyConstraintsAtTime: time)
        }
        
        public func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
            arSCNViewDelegate?.renderer?(renderer, didSimulatePhysicsAtTime: time)
        }
        
        public func renderer(_ renderer: SCNSceneRenderer, didApplyConstraintsAtTime time: TimeInterval) {
            arSCNViewDelegate?.renderer?(renderer, didApplyConstraintsAtTime: time)
        }
        
        public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
            // If we aren't tracking yet, return.
            //  guard isTracking else { return }
            
            guard
                let arSCNView,
                let initialTransformation,
                let sceneViewController
            else { return }
            
            guard lastGoodDeviceOrientation != nil else { return }
            
            // Get transform from SCNView.pointOfView.
            guard let transform = arSCNView.pointOfView?.transform else { return }
            let cameraTransform = simd_double4x4(transform)
            
            let cameraQuat = simd_quatd(cameraTransform)
            let transformationMatrix = TransformationMatrix.normalized(
                quaternionX: cameraQuat.vector.x,
                quaternionY: cameraQuat.vector.y,
                quaternionZ: cameraQuat.vector.z,
                quaternionW: cameraQuat.vector.w,
                translationX: cameraTransform.columns.3.x,
                translationY: cameraTransform.columns.3.y,
                translationZ: cameraTransform.columns.3.z
            )
            
            // Set the matrix on the camera controller.
            let cameraController = sceneViewController.cameraController as! TransformationMatrixCameraController
            cameraController.transformationMatrix = initialTransformation.adding(transformationMatrix)
            
            // Set FOV on camera.
            if let camera = arSCNView.session.currentFrame?.camera {
                let intrinsics = camera.intrinsics
                let imageResolution = camera.imageResolution
                
                // Get the device orientation, but don't allow non-landscape/portrait values.
                let deviceOrientation = UIDevice.current.orientation
                if deviceOrientation.isValidInterfaceOrientation {
                    lastGoodDeviceOrientation = deviceOrientation
                }
                
                sceneViewController.setFieldOfViewFromLensIntrinsics(
                    xFocalLength: intrinsics[0][0],
                    yFocalLength: intrinsics[1][1],
                    xPrincipal: intrinsics[2][0],
                    yPrincipal: intrinsics[2][1],
                    xImageSize: Float(imageResolution.width),
                    yImageSize: Float(imageResolution.height),
                    deviceOrientation: lastGoodDeviceOrientation!
                )
            }
            
            // Render the Scene with the new transformation.
            sceneViewController.draw()
            
            // Call our arSCNViewDelegate method.
            arSCNViewDelegate?.renderer?(renderer, willRenderScene: scene, atTime: time)
        }
        
        public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
            arSCNViewDelegate?.renderer?(renderer, didRenderScene: scene, atTime: time)
        }
    }
}

public class RealityGeoViewController: UIViewController {
    /// The view used to display the `ARKit` camera image and 3D `SceneKit` content.
    /// - Since: 200.3
    let arSCNView = ARSCNView(frame: .zero)
    
    /// Denotes whether tracking location and angles has started.
    /// - Since: 200.3
    public private(set) var isTracking: Bool = false
    
    /// Whether `ARKit` is supported on this device.
    private let deviceSupportsARKit: Bool = ARWorldTrackingConfiguration.isSupported
    
    /// The world tracking information used by `ARKit`.
    /// - Since: 200.3
    public var arConfiguration: ARConfiguration {
        didSet {
            // If we're already tracking, reset tracking to use the new configuration.
            if isTracking, deviceSupportsARKit {
                arSCNView.session.run(arConfiguration, options: .resetTracking)
            }
        }
    }
    
    /// The last portrait or landscape orientation value.
    var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
    
    /// The tracking mode controlling how the locations generated from the location data source are used during AR tracking.
    private var trackingMode: RealityTrackingMode = .ignore
    
    /// The initial transformation used for a table top experience.  Defaults to the Identity Matrix.
    /// - Since: 200.3
    public var initialTransformation: TransformationMatrix = .identity
    
    /// The data source used to get device location.  Used either in conjuction with ARKit data or when ARKit is not present or not being used.
    /// - Since: 200.3
    public var locationDataSource: LocationDataSource? {
        didSet {
            // locationDataSource?.locationChangeHandlerDelegate = self
        }
    }
    
    /// The translation factor used to support a table top AR experience.
    /// - Since: 200.3
    public dynamic var translationFactor: Double {
        get { cameraController.translationFactor }
        set { cameraController.translationFactor = newValue }
    }
    
    /// Determines the clipping distance around the originCamera. The units are meters; the default is `nil`.
    /// When the value is set to `nil`, there is no enforced clipping distance and therefore no limiting of displayed data.
    /// Setting the value to 10.0 will only render data 10 meters around the origin camera.
    /// - Since: 200.3
    public var clippingDistance: Double? {
        get { cameraController.clippingDistance }
        set { cameraController.clippingDistance = newValue }
    }
    
    /// The viewpoint camera used to set the initial view of the sceneView instead of the device's GPS location via the location data source.  You can use Key-Value Observing to track changes to the origin camera.
    /// - Since: 200.3
    public dynamic var originCamera: Camera {
        get { cameraController.originCamera }
        set { cameraController.originCamera = newValue }
    }
    
    // MARK: Private properties
    
    /// The `TransformationMatrixCameraController` used to control the Scene.
    var cameraController: TransformationMatrixCameraController {
        sceneViewController.cameraController as! TransformationMatrixCameraController
    }
    
    var sceneViewController: ArcGISSceneViewController
    
    public init(
        scene: ArcGIS.Scene,
        cameraController: TransformationMatrixCameraController,
        graphicsOverlays: [GraphicsOverlay] = [],
        analysisOverlays: [AnalysisOverlay] = [],
        renderVideoFeed: Bool = true
    ) {
        sceneViewController = ArcGISSceneViewController(
            scene: scene,
            cameraController: cameraController,
            graphicsOverlays: graphicsOverlays,
            analysisOverlays: analysisOverlays,
            spaceEffect: .transparent,
            atmosphereEffect: .off,
            isAttributionBarHidden: true,
            viewDrawingMode: .manual
        )
        
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading
        config.planeDetection = [.horizontal]
        arConfiguration = config
        
        super.init(nibName: nil, bundle: nil)
        
        if !deviceSupportsARKit || !renderVideoFeed {
            // User is not using ARKit, or they don't want to see video,
            // set the arSCNView.alpha to 0.0 so it doesn't display.
            arSCNView.alpha = 0
        }
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if deviceSupportsARKit {
            view.addSubview(arSCNView)
            arSCNView.frame = view.bounds
            arSCNView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        // Add scene view controller
        addChild(sceneViewController)
        sceneViewController.view.frame = self.view.bounds
        view.addSubview(sceneViewController.view)
        sceneViewController.view.backgroundColor = .clear
        sceneViewController.view.frame = view.bounds
        sceneViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneViewController.didMove(toParent: self)
        
        Task.detached {
            try await self.startTracking(withMode: self.trackingMode)
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Task.detached {
            await self.stopTracking()
        }
    }
    
    /// Operations that happen after device tracking has started.
    @MainActor
    private func finalizeStart() {
        // Run the ARSession.
        if deviceSupportsARKit {
            arSCNView.session.run(arConfiguration, options: .resetTracking)
        }
        isTracking = true
    }
    
    /// Starts device tracking.
    /// - Since: 200.3
    public func startTracking(withMode mode: RealityTrackingMode) async throws {
        // We have a location data source that needs to be started.
        self.trackingMode = mode
        if mode != .ignore,
           let locationDataSource = self.locationDataSource {
            Task.detached { @MainActor in
                do {
                    try await locationDataSource.start()
                    self.finalizeStart()
                } catch {
                    throw error
                }
            }
        } else {
            // We're either ignoring the data source or there is no data source so continue with defaults.
            finalizeStart()
        }
    }
    
    /// Suspends device tracking.
    /// - Since: 200.3
    public func stopTracking() async {
        Task.detached { @MainActor in
            self.arSCNView.session.pause()
            await self.locationDataSource?.stop()
            self.isTracking = false
        }
    }
    
}
