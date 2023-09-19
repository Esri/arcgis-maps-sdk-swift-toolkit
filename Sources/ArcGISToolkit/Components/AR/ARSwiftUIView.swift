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
***REMOVED***

***REMOVED***/ A SwiftUI version of ARSCNView.
struct ARSwiftUIView {
***REMOVED******REMOVED***/ The closure to call when the ARSCNView renders.
***REMOVED***private(set) var onRenderAction: ((SCNSceneRenderer, SCNScene, TimeInterval) -> Void)?
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
***REMOVED***func onRender(
***REMOVED******REMOVED***perform action: @escaping (SCNSceneRenderer, SCNScene, TimeInterval) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onRenderAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***

extension ARSwiftUIView: UIViewRepresentable {
***REMOVED***func makeUIView(context: Context) -> ARSCNView {
***REMOVED******REMOVED***let arView = ARSCNView()
***REMOVED******REMOVED***arView.delegate = context.coordinator
***REMOVED******REMOVED***proxy?.arView = arView
***REMOVED******REMOVED***return arView
***REMOVED***

***REMOVED***func updateUIView(_ uiView: ARSCNView, context: Context) {
***REMOVED******REMOVED***context.coordinator.onRenderAction = onRenderAction
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator()
***REMOVED***
***REMOVED***

extension ARSwiftUIView {
***REMOVED***class Coordinator: NSObject, ARSCNViewDelegate {
***REMOVED******REMOVED***var onRenderAction: ((SCNSceneRenderer, SCNScene, TimeInterval) -> Void)?
***REMOVED******REMOVED***
***REMOVED******REMOVED***func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***onRenderAction?(renderer, scene, time)
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A proxy for the ARSwiftUIView.
class ARSwiftUIViewProxy {
***REMOVED******REMOVED***/ The underlying ARSCNView.
***REMOVED******REMOVED***/ This is set by the ARSwiftUIView when it is available.
***REMOVED***fileprivate var arView: ARSCNView?
***REMOVED***
***REMOVED******REMOVED***/ The AR session.
***REMOVED***var session: ARSession? {
***REMOVED******REMOVED***arView?.session
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current point of view of the AR view.
***REMOVED***var pointOfView: SCNNode? {
***REMOVED******REMOVED***arView?.pointOfView
***REMOVED***
***REMOVED***
