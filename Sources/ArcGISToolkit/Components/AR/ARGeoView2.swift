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

//public enum ARGeoViewTrackingMode {
//    case ignore
//    case initial
//    case continuous
//}

public struct ARGeoView2: UIViewControllerRepresentable {
    private let scene: ArcGIS.Scene
    private let cameraController: TransformationMatrixCameraController
    private let trackingMode: ARGeoViewTrackingMode
    private let renderVideoFeed: Bool
    
    public func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController(
            scene: scene,
            cameraController: cameraController,
            trackingMode: trackingMode,
            renderVideoFeed: renderVideoFeed
        )
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
    
    public init(
        scene: ArcGIS.Scene = ArcGIS.Scene(),
        cameraController: TransformationMatrixCameraController = TransformationMatrixCameraController(),
        trackingMode: ARGeoViewTrackingMode = .initial,
        renderVideoFeed: Bool = true
    ) {
        self.scene = scene
        self.cameraController = cameraController
        self.trackingMode = trackingMode
        self.renderVideoFeed = renderVideoFeed
    }
}

extension ARGeoView2 {
    public class ViewController: UIViewController {
        public init(
            scene: ArcGIS.Scene,
            cameraController: TransformationMatrixCameraController,
            trackingMode: ARGeoViewTrackingMode,
            renderVideoFeed: Bool
        ) {
            sceneViewController = ArcGISSceneViewController(
                scene: scene,
                cameraController: cameraController,
                graphicsOverlays: [],
                analysisOverlays: [],
                spaceEffect: .transparent,
                atmosphereEffect: .off,
                isAttributionBarHidden: true,
                viewDrawingMode: .manual
            )
            
            let config = ARWorldTrackingConfiguration()
            config.worldAlignment = .gravityAndHeading
            config.planeDetection = [.horizontal]
            arConfiguration = config
            
            self.trackingMode = trackingMode
            
            super.init(nibName: nil, bundle: nil)
            
            if !deviceSupportsARKit || !renderVideoFeed {
                // User is not using ARKit, or they don't want to see video,
                // set the arSCNView.alpha to 0.0 so it doesn't display.
                arView.alpha = 0
            }
            
            arView.delegate = self
        }
        
        public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            fatalError("init(nibName:bundle:) has not been implemented")
        }
        
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        /// The view used to display the `ARKit` camera image and 3D `SceneKit` content.
        private let arView = ARSCNView(frame: .zero)
        
        /// Denotes whether tracking location and angles has started.
        private var isTracking: Bool = false
        
        /// Whether `ARKit` is supported on this device.
        private let deviceSupportsARKit: Bool = ARWorldTrackingConfiguration.isSupported
        
        /// The world tracking information used by `ARKit`.
        private let arConfiguration: ARConfiguration
        
        /// The last portrait or landscape orientation value.
        private var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
        
        /// The tracking mode controlling how the locations generated from the location data source are used during AR tracking.
        private var trackingMode: ARGeoViewTrackingMode = .ignore
        
        /// The initial transformation used for a table top experience.  Defaults to the Identity Matrix.
        private var initialTransformation: TransformationMatrix = .identity
        
        let sceneViewController: ArcGISSceneViewController
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            
            if deviceSupportsARKit {
                view.addSubview(arView)
                arView.frame = view.bounds
                arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
            
            // Add scene view controller
            addChild(sceneViewController)
            sceneViewController.view.frame = self.view.bounds
            view.addSubview(sceneViewController.view)
            sceneViewController.view.backgroundColor = .clear
            sceneViewController.view.frame = view.bounds
            sceneViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            sceneViewController.didMove(toParent: self)
        }
        
        override public func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.startTracking()
        }
        
        public override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            self.stopTracking()
        }
        
        /// Starts device tracking.
        private func startTracking() {
            if deviceSupportsARKit {
                arView.session.run(arConfiguration, options: .resetTracking)
            }
            isTracking = true
        }
        
        /// Suspends device tracking.
        private func stopTracking() {
            self.arView.session.pause()
            self.isTracking = false
        }
    }
}

extension ARGeoView2.ViewController: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        // If we aren't tracking yet, return.
        guard isTracking else { return }
        
        // Get transform from SCNView.pointOfView.
        guard let transform = arView.pointOfView?.transform else { return }
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
        if let camera = arView.session.currentFrame?.camera {
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
                deviceOrientation: lastGoodDeviceOrientation
            )
        }
        
        // Render the Scene with the new transformation.
        sceneViewController.draw()
    }
}
