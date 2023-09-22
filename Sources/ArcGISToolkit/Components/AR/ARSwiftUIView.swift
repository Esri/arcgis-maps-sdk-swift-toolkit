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
        arView.session.delegate = context.coordinator
        proxy?.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARViewType, context: Context) {
        context.coordinator.onDidUpdateFrameAction = onDidUpdateFrameAction
        uiView.isHidden = videoFeedIsHidden
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

extension ARSwiftUIView {
    class Coordinator: NSObject, ARSessionDelegate {
        var onDidUpdateFrameAction: ((ARSession, ARFrame) -> Void)?
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            onDidUpdateFrameAction?(session, frame)
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
}
