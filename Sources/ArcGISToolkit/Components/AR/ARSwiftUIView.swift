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

/// A SwiftUI version of ARSCNView.
struct ARSwiftUIView {
    /// The closure to call when the ARSCNView renders.
    private(set) var onRenderAction: ((SCNSceneRenderer, SCNScene, TimeInterval) -> Void)?
    private(set) var videoFeedIsHidden: Bool = false
    private(set) var onAddNodeAction: ((SCNSceneRenderer, SCNNode, ARAnchor) -> Void)?
    private(set) var onUpdateNodeAction: ((SCNSceneRenderer, SCNNode, ARAnchor) -> Void)?
    /// The proxy.
    private let proxy: ARSwiftUIViewProxy?
    
    /// Creates an ARSwiftUIView.
    /// - Parameter proxy: The provided proxy which will have it's state filled out
    /// when available by the underlying view.
    init(proxy: ARSwiftUIViewProxy? = nil) {
        self.proxy = proxy
    }
    
    /// Sets the closure to call when underlying scene renders.
    func onRender(
        perform action: @escaping (SCNSceneRenderer, SCNScene, TimeInterval) -> Void
    ) -> Self {
        var view = self
        view.onRenderAction = action
        return view
    }
    
    /// Hides the video feed for the AR view.
    func videoFeedHidden() -> Self {
        var view = self
        view.videoFeedIsHidden = true
        return view
    }
    
    func onAddNode(
        perform action: @escaping (SCNSceneRenderer, SCNNode, ARAnchor) -> Void
    ) -> Self {
        var view = self
        view.onAddNodeAction = action
        return view
    }
    
    func onUpdateNode(
        perform action: @escaping (SCNSceneRenderer, SCNNode, ARAnchor) -> Void
    ) -> Self {
        var view = self
        view.onUpdateNodeAction = action
        return view
    }
}

extension ARSwiftUIView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        proxy?.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        uiView.isHidden = videoFeedIsHidden
        context.coordinator.onRenderAction = onRenderAction
        context.coordinator.onAddNodeAction = onAddNodeAction
        context.coordinator.onUpdateNodeAction = onUpdateNodeAction
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

extension ARSwiftUIView {
    class Coordinator: NSObject, ARSCNViewDelegate {
        var onRenderAction: ((SCNSceneRenderer, SCNScene, TimeInterval) -> Void)?
        var onAddNodeAction: ((SCNSceneRenderer, SCNNode, ARAnchor) -> Void)?
        var onUpdateNodeAction: ((SCNSceneRenderer, SCNNode, ARAnchor) -> Void)?
        
        func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
            onRenderAction?(renderer, scene, time)
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            onAddNodeAction?(renderer, node, anchor)
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            onUpdateNodeAction?(renderer, node, anchor)
        }
        
    }
}

/// A proxy for the ARSwiftUIView.
class ARSwiftUIViewProxy {
    /// The underlying ARSCNView.
    /// This is set by the ARSwiftUIView when it is available.
    fileprivate var arView: ARSCNView?
    
    /// The AR session.
    var session: ARSession? {
        arView?.session
    }
    
    /// The current point of view of the AR view.
    var pointOfView: SCNNode? {
        arView?.pointOfView
    }
    
    /// Creates a raycast query that originates from a point on the view, aligned with the center of the camera's field of view.
    /// - Parameters:
    ///   - point: The point on the view to extend the raycast from.
    ///   - target: The type of surface the raycast can interact with.
    ///   - alignment: The target's alignment with respect to gravity.
    /// - Returns: An `ARRaycastQuery`.
    func raycastQuery(
        from point: CGPoint,
        allowing target: ARRaycastQuery.Target,
        alignment: ARRaycastQuery.TargetAlignment
    ) -> ARRaycastQuery? {
        return arView?.raycastQuery(
            from: point,
            allowing: target,
            alignment: alignment
        )
    }
}
