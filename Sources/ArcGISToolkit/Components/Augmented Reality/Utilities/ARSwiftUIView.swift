***REMOVED*** Copyright 2023 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import ARKit
***REMOVED***

internal import os

typealias ARViewType = ARSCNView

***REMOVED***/ A SwiftUI version of an AR view.
struct ARSwiftUIView {
***REMOVED******REMOVED***/ The closure to call when the session's geo-tracking state changes.
***REMOVED***private(set) var onDidChangeGeoTrackingStatusAction: ((ARSession, ARGeoTrackingStatus) -> Void)?
***REMOVED******REMOVED***/ The closure to call when the session's camera tracking state changes.
***REMOVED***private(set) var onCameraDidChangeTrackingStateAction: ((ARSession, ARCamera.TrackingState) -> Void)?
***REMOVED******REMOVED***/ The closure to call when the session's frame updates.
***REMOVED***private(set) var onDidUpdateFrameAction: ((ARSession, ARFrame) -> Void)?
***REMOVED******REMOVED***/ The closure to call when a node corresponding to a new anchor has been added to the view.
***REMOVED***private(set) var onAddNodeAction: (@MainActor (SceneParameters) -> Void)?
***REMOVED******REMOVED***/ The closure to call when a node has been updated to match it's corresponding anchor.
***REMOVED***private(set) var onUpdateNodeAction: (@MainActor (SceneParameters) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The proxy.
***REMOVED***private let proxy: ARSwiftUIViewProxy
***REMOVED***
***REMOVED******REMOVED***/ Creates an ARSwiftUIView.
***REMOVED******REMOVED***/ - Parameter proxy: The provided proxy which will have it's state filled out
***REMOVED******REMOVED***/ when available by the underlying view.
***REMOVED***init(proxy: ARSwiftUIViewProxy) {
***REMOVED******REMOVED***self.proxy = proxy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the closure to call when the session's geo-tracking state changes.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ ARKit invokes the callback only for `ARGeoTrackingConfiguration` sessions.
***REMOVED***func onDidChangeGeoTrackingStatus(
***REMOVED******REMOVED***perform action: @escaping (ARSession, ARGeoTrackingStatus) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onDidChangeGeoTrackingStatusAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the closure to call when session's camera tracking state changes.
***REMOVED***func onCameraDidChangeTrackingState(
***REMOVED******REMOVED***perform action: @escaping (ARSession, ARCamera.TrackingState) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onCameraDidChangeTrackingStateAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the closure to call when underlying scene renders.
***REMOVED***func onDidUpdateFrame(
***REMOVED******REMOVED***perform action: @escaping (ARSession, ARFrame) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onDidUpdateFrameAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the closure to call when a new node has been added to the scene.
***REMOVED***func onAddNode(
***REMOVED******REMOVED***perform action: @escaping @MainActor (SceneParameters) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onAddNodeAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the closure to call when the scene's nodes are updated.
***REMOVED***func onUpdateNode(
***REMOVED******REMOVED***perform action: @escaping @MainActor (SceneParameters) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onUpdateNodeAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***

extension ARSwiftUIView: UIViewRepresentable {
***REMOVED***func makeUIView(context: Context) -> ARViewType {
***REMOVED******REMOVED***let arView = ARViewType()
***REMOVED******REMOVED***arView.delegate = context.coordinator
***REMOVED******REMOVED***arView.session.delegate = context.coordinator
***REMOVED******REMOVED******REMOVED*** Set the AR view on the proxy.
***REMOVED******REMOVED***proxy.arView = arView
***REMOVED******REMOVED***return arView
***REMOVED***
***REMOVED***
***REMOVED***func updateUIView(_ uiView: ARViewType, context: Context) {
***REMOVED******REMOVED***context.coordinator.onDidChangeGeoTrackingStatusAction = onDidChangeGeoTrackingStatusAction
***REMOVED******REMOVED***context.coordinator.onCameraDidChangeTrackingStateAction = onCameraDidChangeTrackingStateAction
***REMOVED******REMOVED***context.coordinator.onDidUpdateFrameAction = onDidUpdateFrameAction
***REMOVED******REMOVED***context.coordinator.onAddNodeAction = onAddNodeAction
***REMOVED******REMOVED***context.coordinator.onUpdateNodeAction = onUpdateNodeAction
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator()
***REMOVED***
***REMOVED***

extension ARSwiftUIView {
***REMOVED***class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
***REMOVED******REMOVED***struct State: Sendable {
***REMOVED******REMOVED******REMOVED***var onAddNodeAction: (@MainActor (SceneParameters) -> Void)?
***REMOVED******REMOVED******REMOVED***var onUpdateNodeAction: (@MainActor (SceneParameters) -> Void)?
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let state = OSAllocatedUnfairLock(initialState: State())
***REMOVED******REMOVED***
***REMOVED******REMOVED***var onDidChangeGeoTrackingStatusAction: ((ARSession, ARGeoTrackingStatus) -> Void)?
***REMOVED******REMOVED***var onCameraDidChangeTrackingStateAction: ((ARSession, ARCamera.TrackingState) -> Void)?
***REMOVED******REMOVED***var onDidUpdateFrameAction: ((ARSession, ARFrame) -> Void)?
***REMOVED******REMOVED***var onAddNodeAction: (@MainActor (SceneParameters) -> Void)? {
***REMOVED******REMOVED******REMOVED***get { state.withLock { $0.onAddNodeAction ***REMOVED*** ***REMOVED***
***REMOVED******REMOVED******REMOVED***set { state.withLock { $0.onAddNodeAction = newValue ***REMOVED*** ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***var onUpdateNodeAction: (@MainActor (SceneParameters) -> Void)? {
***REMOVED******REMOVED******REMOVED***get { state.withLock { $0.onUpdateNodeAction ***REMOVED*** ***REMOVED***
***REMOVED******REMOVED******REMOVED***set { state.withLock { $0.onUpdateNodeAction = newValue ***REMOVED*** ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
***REMOVED******REMOVED******REMOVED***onDidChangeGeoTrackingStatusAction?(session, geoTrackingStatus)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
***REMOVED******REMOVED******REMOVED***onCameraDidChangeTrackingStateAction?(session, camera.trackingState)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func session(_ session: ARSession, didUpdate frame: ARFrame) {
***REMOVED******REMOVED******REMOVED***onDidUpdateFrameAction?(session, frame)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED******REMOVED***let sceneParameters = SceneParameters(renderer: renderer, node: node, anchor: anchor)
***REMOVED******REMOVED******REMOVED***Task { [onAddNodeAction] in
***REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onAddNodeAction?(sceneParameters)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
***REMOVED******REMOVED******REMOVED***let sceneParameters = SceneParameters(renderer: renderer, node: node, anchor: anchor)
***REMOVED******REMOVED******REMOVED***Task { [onUpdateNodeAction] in
***REMOVED******REMOVED******REMOVED******REMOVED***await MainActor.run {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onUpdateNodeAction?(sceneParameters)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A temporary type to workaround this issue:
***REMOVED***/ https:***REMOVED***forums.developer.apple.com/forums/thread/765644
struct SceneParameters: @unchecked Sendable {
***REMOVED***let renderer: SCNSceneRenderer
***REMOVED***let node: SCNNode
***REMOVED***let anchor: ARAnchor
***REMOVED***

***REMOVED***/ A proxy for the ARSwiftUIView.
@MainActor
class ARSwiftUIViewProxy: NSObject, @preconcurrency ARSessionProviding {
***REMOVED******REMOVED***/ The underlying AR view.
***REMOVED******REMOVED***/ This is set by the ARSwiftUIView when it is available.
***REMOVED***fileprivate var arView: ARViewType!
***REMOVED***
***REMOVED******REMOVED***/ The AR session.
***REMOVED***@objc dynamic var session: ARSession {
***REMOVED******REMOVED***arView.session
***REMOVED***
***REMOVED***

extension ARSwiftUIViewProxy {
***REMOVED******REMOVED***/ Performs a raycast to get the transformation matrix representing the corresponding
***REMOVED******REMOVED***/ real-world point for `screenPoint`.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ The method returns `nil` when the raycast query or the raycast fails. They can fail due to
***REMOVED******REMOVED***/ certain limitations, such as reflective or irregular surfaces, poorly lit environment that
***REMOVED******REMOVED***/ reduces the amount of visible objects, distance between the camera and the object being
***REMOVED******REMOVED***/ too far, camera occlusion that blocks the rays, etc.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - screenPoint: The screen point to determine the real world transformation matrix from.
***REMOVED******REMOVED***/   - target: The type of surface the raycast can interact with.
***REMOVED******REMOVED***/ - Returns: A `TransformationMatrix` representing the real-world point corresponding to `screenPoint`.
***REMOVED***@MainActor func raycast(from screenPoint: CGPoint, allowing target: ARRaycastQuery.Target) -> TransformationMatrix? {
***REMOVED******REMOVED******REMOVED*** Use the `raycastQuery` method on ARSCNView to get the location of `screenPoint`.
***REMOVED******REMOVED***guard let query = arView.raycastQuery(
***REMOVED******REMOVED******REMOVED***from: screenPoint,
***REMOVED******REMOVED******REMOVED***allowing: target,
***REMOVED******REMOVED******REMOVED***alignment: .any
***REMOVED******REMOVED***) else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let results = session.raycast(query)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Get the worldTransform from the first result; if there's no worldTransform, return nil.
***REMOVED******REMOVED***guard let worldTransform = results.first?.worldTransform else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Create our raycast matrix based on the worldTransform location.
***REMOVED******REMOVED******REMOVED*** Right now we ignore the orientation of the plane that was hit to find the point
***REMOVED******REMOVED******REMOVED*** since we only use horizontal planes.
***REMOVED******REMOVED******REMOVED*** If we start supporting vertical planes we will have to stop suppressing the
***REMOVED******REMOVED******REMOVED*** quaternion rotation to a null rotation (0,0,0,1).
***REMOVED******REMOVED***let raycastMatrix = TransformationMatrix.normalized(
***REMOVED******REMOVED******REMOVED***quaternionX: 0,
***REMOVED******REMOVED******REMOVED***quaternionY: 0,
***REMOVED******REMOVED******REMOVED***quaternionZ: 0,
***REMOVED******REMOVED******REMOVED***quaternionW: 1,
***REMOVED******REMOVED******REMOVED***translationX: Double(worldTransform.columns.3.x),
***REMOVED******REMOVED******REMOVED***translationY: Double(worldTransform.columns.3.y),
***REMOVED******REMOVED******REMOVED***translationZ: Double(worldTransform.columns.3.z)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***return raycastMatrix
***REMOVED***
***REMOVED***
