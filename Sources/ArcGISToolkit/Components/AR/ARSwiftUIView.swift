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

import Foundation
import ARKit
import SwiftUI

public struct ARSwiftUIView {
    private(set) var alpha: CGFloat = 1.0
    private(set) var onRenderAction: ((SCNSceneRenderer, SCNScene, TimeInterval) -> Void)?
    private(set) var onCameraTrackingStateChangeAction: ((ARSession, ARCamera) -> Void)?
    private(set) var onGeoTrackingStatusChangeAction: ((ARSession, ARGeoTrackingStatus) -> Void)?
    private(set) var onProxyAvailableAction: ((ARSwiftUIView.Proxy) -> Void)?
    
    init() {
    }
    
    public func alpha(_ alpha: CGFloat) -> Self {
        var view = self
        view.alpha = alpha
        return view
    }
    
    public func onRender(
        perform action: @escaping (SCNSceneRenderer, SCNScene, TimeInterval) -> Void
    ) -> Self {
        var view = self
        view.onRenderAction = action
        return view
    }
    
    public func onCameraTrackingStateChange(
        perform action: @escaping (ARSession, ARCamera) -> Void
    ) -> Self {
        var view = self
        view.onCameraTrackingStateChangeAction = action
        return view
    }
    
    public func onGeoTrackingStatusChange(
        perform action: @escaping (ARSession, ARGeoTrackingStatus) -> Void
    ) -> Self {
        var view = self
        view.onGeoTrackingStatusChangeAction = action
        return view
    }
    
    public func onProxyAvailable(
        perform action: @escaping (ARSwiftUIView.Proxy) -> Void
    ) -> Self {
        var view = self
        view.onProxyAvailableAction = action
        return view
    }
}

extension ARSwiftUIView: UIViewRepresentable {
    public func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        onProxyAvailableAction?(Proxy(arView: arView))
        return arView
    }
    
    public func updateUIView(_ uiView: ARSCNView, context: Context) {
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(arSwiftUIView: self)
    }
}

extension ARSwiftUIView {
    public class Coordinator: NSObject, ARSCNViewDelegate {
        private let view: ARSwiftUIView
        
        init(arSwiftUIView: ARSwiftUIView) {
            self.view = arSwiftUIView
        }
        
        public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
            view.onRenderAction?(renderer, scene, time)
        }
        
        public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            view.onCameraTrackingStateChangeAction?(session, camera)
        }
        
        public func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
            view.onGeoTrackingStatusChangeAction?(session, geoTrackingStatus)
        }
    }
}

extension ARSwiftUIView {
    public class Proxy {
        private let arView: ARSCNView
        
        init(arView: ARSCNView) {
            self.arView = arView
        }
        
        var session: ARSession {
            arView.session
        }
        
        var pointOfView: SCNNode? {
            arView.pointOfView
        }
    }
}
