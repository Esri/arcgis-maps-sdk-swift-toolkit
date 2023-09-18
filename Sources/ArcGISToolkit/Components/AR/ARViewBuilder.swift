//
//  File.swift
//
//
//  Created by Ryan Olson on 9/18/23.
//

import Foundation
import ARKit
import SwiftUI
import ArcGIS

public struct ARViewBuilder: View {
    private let configuration: ARWorldTrackingConfiguration
    
    /// The last portrait or landscape orientation value.
    @State private var lastGoodDeviceOrientation = UIDeviceOrientation.portrait
    @State private var arViewProxy = ARSwiftUIViewProxy()
    @State private var sceneViewProxy: SceneViewProxy?
    
    private let sceneViewBuilder: () -> SceneView
    
    public init(
        @ViewBuilder sceneView: @escaping () -> SceneView
    ) {
        self.sceneViewBuilder = sceneView
        
        configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = [.horizontal]
    }
    
    public var body: some View {
        ZStack {
            ARSwiftUIView(proxy: arViewProxy)
                .onRender { _, _, _ in
                    guard let sceneViewProxy else { return }
                    render(arViewProxy: arViewProxy, sceneViewProxy: sceneViewProxy)
                }
                .onAppear {
                    arViewProxy.session?.run(configuration)
                }
                .onDisappear {
                    arViewProxy.session?.pause()
                }
            SceneViewReader { proxy in
                sceneViewBuilder()
                    .attributionBarHidden(true)
                    .spaceEffect(.transparent)
                    .viewDrawingMode(.manual)
                    .atmosphereEffect(.off)
                    .onAppear {
                        self.sceneViewProxy = proxy
                    }
            }
        }
    }
}

private extension ARViewBuilder {
    func render(arViewProxy: ARSwiftUIViewProxy, sceneViewProxy: SceneViewProxy) {
        // Get transform from SCNView.pointOfView.
        guard let transform = arViewProxy.pointOfView?.transform else { return }
        guard let session = arViewProxy.session else { return }
        
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
        //cameraController.transformationMatrix = .identity.adding(transformationMatrix)
        
        // Set FOV on camera.
        if let camera = session.currentFrame?.camera {
            let intrinsics = camera.intrinsics
            let imageResolution = camera.imageResolution
            
            // Get the device orientation, but don't allow non-landscape/portrait values.
            let deviceOrientation = UIDevice.current.orientation
            if deviceOrientation.isValidInterfaceOrientation {
                lastGoodDeviceOrientation = deviceOrientation
            }
            
            sceneViewProxy.setFieldOfViewFromLensIntrinsics(
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
        sceneViewProxy.draw()
    }
}
