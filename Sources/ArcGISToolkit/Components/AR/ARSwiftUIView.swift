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

typealias ARViewType = ARSCNView

/// A SwiftUI version of an AR view.
struct ARSwiftUIView {
    /// The closure to call when the AR view renders.
    private(set) var onDidUpdateFrameAction: ((ARSession, ARFrame) -> Void)?
    private(set) var onAddNodeAction: ((SCNSceneRenderer, SCNNode, ARAnchor) -> Void)?
    private(set) var onUpdateNodeAction: ((SCNSceneRenderer, SCNNode, ARAnchor) -> Void)?
    private(set) var onSingleTapGesture: ((CGPoint) -> Void)?
    private(set) var videoFeedIsHidden: Bool = false
    /// The proxy.
    private let proxy: ARSwiftUIViewProxy?
    
    /// Creates an ARSwiftUIView.
    /// - Parameter proxy: The provided proxy which will have it's state filled out
    /// when available by the underlying view.
    init(proxy: ARSwiftUIViewProxy? = nil) {
        self.proxy = proxy
    }
    
    /// Sets the closure to call when underlying scene renders.
    func onDidUpdateFrame(
        perform action: @escaping (ARSession, ARFrame) -> Void
    ) -> Self {
        var view = self
        view.onDidUpdateFrameAction = action
        return view
    }
    
    /// Sets the closure to call when a new node has been added to the scene.
    func onAddNode(
        perform action: @escaping (SCNSceneRenderer, SCNNode, ARAnchor) -> Void
    ) -> Self {
        var view = self
        view.onAddNodeAction = action
        return view
    }
    
    /// Sets the closure to call when the scene's nodes are update.
    func onUpdateNode(
        perform action: @escaping (SCNSceneRenderer, SCNNode, ARAnchor) -> Void
    ) -> Self {
        var view = self
        view.onUpdateNodeAction = action
        return view
    }
    
    /// Sets a closure to perform when a single tap occurs on the AR view.
    func onSingleTapGesture(
        perform action: @escaping (CGPoint) -> Void
    ) -> Self {
        var view = self
        view.onSingleTapGesture = action
        return view
    }
    
    /// Hides the video feed for the AR view.
    func videoFeedHidden() -> Self {
        var view = self
        view.videoFeedIsHidden = true
        return view
    }
}

extension ARSwiftUIView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARViewType {
        let arView = ARViewType()
        arView.delegate = context.coordinator
        arView.session.delegate = context.coordinator
        arView.addGestureRecognizer(context.coordinator.makeGestureRecognizer())
        proxy?.arView = arView
        return arView
    }
    
    func updateUIView(_ uiView: ARViewType, context: Context) {
        context.coordinator.onDidUpdateFrameAction = onDidUpdateFrameAction
        context.coordinator.onAddNodeAction = onAddNodeAction
        context.coordinator.onUpdateNodeAction = onUpdateNodeAction
        context.coordinator.onSingleTapGesture = onSingleTapGesture
        uiView.isHidden = videoFeedIsHidden
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

extension ARSwiftUIView {
    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var onDidUpdateFrameAction: ((ARSession, ARFrame) -> Void)?
        var onAddNodeAction: ((SCNSceneRenderer, SCNNode, ARAnchor) -> Void)?
        var onUpdateNodeAction: ((SCNSceneRenderer, SCNNode, ARAnchor) -> Void)?
        var onSingleTapGesture: ((CGPoint) -> Void)?
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            onDidUpdateFrameAction?(session, frame)
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            onAddNodeAction?(renderer, node, anchor)
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            onUpdateNodeAction?(renderer, node, anchor)
        }
        
        func makeGestureRecognizer() -> UITapGestureRecognizer {
            let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
            return tapGestureRecognizer
        }
        
        @objc private func handleTap(_ sender: UIGestureRecognizer) {
            guard let view = sender.view else { return }
            onSingleTapGesture?(sender.location(in: view))
        }
    }
}

/// A proxy for the ARSwiftUIView.
class ARSwiftUIViewProxy {
    /// The underlying AR view.
    /// This is set by the ARSwiftUIView when it is available.
    fileprivate var arView: ARViewType?
    
    /// The AR session.
    var session: ARSession? {
        arView?.session
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
