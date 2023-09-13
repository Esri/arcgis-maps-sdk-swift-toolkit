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

public enum ARLocationTrackingMode {
    case ignore
    case initial
    case continuous
}

public struct ARView: UIViewControllerRepresentable {
    
    private var scene: ArcGIS.Scene = Scene()
    
    private var renderVideoFeed: Bool
    
    private var cameraController = TransformationMatrixCameraController()
    
    private var locationTrackingMode: ARLocationTrackingMode
    
    public func makeUIViewController(context: Context) -> ARViewController {
        let viewController = ARViewController(
            scene: scene,
            cameraController: cameraController,
            renderVideoFeed: renderVideoFeed
        )
        viewController.arSCNView.delegate = context.coordinator
        setProperties(for: viewController, with: context)
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        setProperties(for: uiViewController, with: context)
    }
    
    public init(
        scene: ArcGIS.Scene = ArcGIS.Scene(),
        cameraController: TransformationMatrixCameraController = TransformationMatrixCameraController(),
        locationTrackingMode: ARLocationTrackingMode = .ignore,
        renderVideoFeed: Bool
    ) {
        self.scene = scene
        self.cameraController = cameraController
        self.locationTrackingMode = locationTrackingMode
        self.renderVideoFeed = renderVideoFeed
    }
    
    private func setProperties(for viewController: ARViewController, with context: Context) {
        context.coordinator.arSCNView = viewController.arSCNView
        context.coordinator.isTracking = viewController.isTracking
        context.coordinator.cameraController = viewController.cameraController
        context.coordinator.lastGoodDeviceOrientation = viewController.lastGoodDeviceOrientation
        context.coordinator.initialTransformation = viewController.initialTransformation
        context.coordinator.sceneViewController = viewController.sceneViewController
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    public class Coordinator: NSObject, ARSCNViewDelegate, SCNSceneRendererDelegate, ARSessionObserver {
        /// We implement `ARSCNViewDelegate` methods, but will use `arSCNViewDelegate` to forward them to clients.
        /// - Since: 200.3
        public weak var arSCNViewDelegate: ARSCNViewDelegate?
        
        var arSCNView: ARSCNView?
        
        var isTracking: Bool = false
        
        var sceneViewProxy: SceneViewProxy?
        
        var sceneViewController: ArcGISSceneViewController?
        
        var cameraController: TransformationMatrixCameraController?
        
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
                let cameraController,
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

public class ARViewController: UIViewController {
    /// The view used to display the `ARKit` camera image and 3D `SceneKit` content.
    /// - Since: 200.3
    let arSCNView = ARSCNView(frame: .zero)
    
    /// Denotes whether tracking location and angles has started.
    /// - Since: 200.3
    public private(set) var isTracking: Bool = false
    
    /// Denotes whether ARKit is being used to track location and angles.
    /// - Since: 200.3
    public private(set) var isUsingARKit: Bool = true
    
    /// Whether `ARKit` is supported on this device.
    private let deviceSupportsARKit: Bool = {
        return ARWorldTrackingConfiguration.isSupported
    }()
    
    /// The world tracking information used by `ARKit`.
    /// - Since: 200.3
    public var arConfiguration: ARConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = [.horizontal]
        return configuration
    }() {
        didSet {
            // If we're already tracking, reset tracking to use the new configuration.
            if isTracking, isUsingARKit {
                arSCNView.session.run(arConfiguration, options: .resetTracking)
            }
        }
    }
    
    /// The last portrait or landscape orientation value.
    var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
    
    /// The tracking mode controlling how the locations generated from the location data source are used during AR tracking.
    private var locationTrackingMode: ARLocationTrackingMode = .ignore
    
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
        get {
            return cameraController.translationFactor
        }
        set {
            cameraController.translationFactor = newValue
        }
    }
    
    /// Determines the clipping distance around the originCamera. The units are meters; the default is 0.0. When the value is set to 0.0 there is no enforced clipping distance.
    /// Setting the value to 10.0 will only render data 10 meters around the originCamera.
    /// - Since: 200.3
    public var clippingDistance: Double {
        get {
            return cameraController.clippingDistance ?? 0.0
        }
        set {
            cameraController.clippingDistance = newValue
        }
    }
    
    /// The viewpoint camera used to set the initial view of the sceneView instead of the device's GPS location via the location data source.  You can use Key-Value Observing to track changes to the origin camera.
    /// - Since: 200.3
    public dynamic var originCamera: Camera {
        get {
            return cameraController.originCamera
        }
        set {
            cameraController.originCamera = newValue
        }
    }
    
    // MARK: Private properties
    
    /// The `TransformationMatrixCameraController` used to control the Scene.
    let cameraController: TransformationMatrixCameraController
    
    var sceneViewController: ArcGISSceneViewController
    
    public init(
        scene: ArcGIS.Scene,
        cameraController: TransformationMatrixCameraController,
        graphicsOverlays: [GraphicsOverlay] = [],
        analysisOverlays: [AnalysisOverlay] = [],
        renderVideoFeed: Bool
    ) {
        self.cameraController = cameraController
        
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
        
        super.init(nibName: nil, bundle: nil)
        
        if !isUsingARKit || !renderVideoFeed {
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
        
        // Use ARKit if device supports it.
        isUsingARKit = deviceSupportsARKit
        
        // Add scene view controller
        addChild(sceneViewController)
        sceneViewController.view.frame = self.view.bounds
        view.addSubview(sceneViewController.view)
        sceneViewController.view.backgroundColor = .clear
        sceneViewController.view.frame = view.bounds
        sceneViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneViewController.didMove(toParent: self)
        
        Task {
            try await self.startTracking(self.locationTrackingMode)
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Task {
            await stopTracking()
        }
    }
    
    /// Operations that happen after device tracking has started.
    @MainActor
    private func finalizeStart() {
        // Run the ARSession.
        if self.isUsingARKit {
            self.arSCNView.session.run(self.arConfiguration, options: .resetTracking)
        }
        self.isTracking = true
    }
    
    /// Starts device tracking.
    ///
    /// - Parameter completion: The completion handler called when start tracking completes.  If tracking starts successfully, the `error` property will be nil; if tracking fails to start, the error will be non-nil and contain the reason for failure.
    /// - Since: 200.3
    public func startTracking(_ locationTrackingMode: ARLocationTrackingMode) async throws {
        // We have a location data source that needs to be started.
        self.locationTrackingMode = locationTrackingMode
        if locationTrackingMode != .ignore,
           let locationDataSource = self.locationDataSource {
            Task {
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
        Task {
            arSCNView.session.pause()
            await locationDataSource?.stop()
            isTracking = false
        }
    }
    
}
