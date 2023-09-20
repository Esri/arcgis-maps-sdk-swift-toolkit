***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import ARKit
import RealityKit
***REMOVED***

***REMOVED***/ A SwiftUI version of ARSCNView.
struct ARSwiftUIView {
***REMOVED******REMOVED***/ The closure to call when the ARSCNView renders.
***REMOVED***private(set) var onAnchorsDidUpdateAction: ((ARSession, [ARAnchor]) -> Void)?
***REMOVED***private(set) var videoFeedIsHidden: Bool = false
***REMOVED******REMOVED***/ The proxy.
***REMOVED***private let proxy: ARSwiftUIViewProxy?
***REMOVED***
***REMOVED******REMOVED***/ Creates an ARSwiftUIView.
***REMOVED******REMOVED***/ - Parameter proxy: The provided proxy which will have it's state filled out
***REMOVED******REMOVED***/ when available by the underlying view.
***REMOVED***init(proxy: ARSwiftUIViewProxy? = nil) {
***REMOVED******REMOVED***self.proxy = proxy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the closure to call when underlying scene renders.
***REMOVED***func onAnchorsDidUpdate(
***REMOVED******REMOVED***perform action: @escaping (ARSession, [ARAnchor]) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onAnchorsDidUpdateAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Hides the video feed for the AR view.
***REMOVED***func videoFeedHidden() -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.videoFeedIsHidden = true
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***

extension ARSwiftUIView: UIViewRepresentable {
***REMOVED***func makeUIView(context: Context) -> ARView {
***REMOVED******REMOVED***let arView = ARView()
***REMOVED******REMOVED***arView.session.delegate = context.coordinator
***REMOVED******REMOVED***proxy?.arView = arView
***REMOVED******REMOVED***return arView
***REMOVED***

***REMOVED***func updateUIView(_ uiView: ARView, context: Context) {
***REMOVED******REMOVED***context.coordinator.onAnchorsDidUpdateAction = onAnchorsDidUpdateAction
***REMOVED******REMOVED***uiView.isHidden = videoFeedIsHidden
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator()
***REMOVED***
***REMOVED***

extension ARSwiftUIView {
***REMOVED***class Coordinator: NSObject, ARSessionDelegate {
***REMOVED******REMOVED***var onAnchorsDidUpdateAction: ((ARSession, [ARAnchor]) -> Void)?
***REMOVED******REMOVED***
***REMOVED******REMOVED***func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
***REMOVED******REMOVED******REMOVED***onAnchorsDidUpdateAction?(session, anchors)
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A proxy for the ARSwiftUIView.
class ARSwiftUIViewProxy {
***REMOVED******REMOVED***/ The underlying ARSCNView.
***REMOVED******REMOVED***/ This is set by the ARSwiftUIView when it is available.
***REMOVED***fileprivate var arView: ARView?
***REMOVED***
***REMOVED******REMOVED***/ The AR session.
***REMOVED***var session: ARSession? {
***REMOVED******REMOVED***arView?.session
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current camera transform of the AR view.
***REMOVED***var cameraTransform: Transform? {
***REMOVED******REMOVED***arView?.cameraTransform
***REMOVED***
***REMOVED***
