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

import Foundation
import ARKit
***REMOVED***
***REMOVED***

struct ARSwiftUIView {
***REMOVED***private(set) var onRenderAction: ((SCNSceneRenderer, SCNScene, TimeInterval) -> Void)?
***REMOVED***private(set) var onCameraTrackingStateChangeAction: ((ARSession, ARCamera) -> Void)?
***REMOVED***private(set) var onGeoTrackingStatusChangeAction: ((ARSession, ARGeoTrackingStatus) -> Void)?
***REMOVED***private let proxy: ARSwiftUIViewProxy?
***REMOVED***
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
***REMOVED***func onCameraTrackingStateChange(
***REMOVED******REMOVED***perform action: @escaping (ARSession, ARCamera) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onCameraTrackingStateChangeAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED***func onGeoTrackingStatusChange(
***REMOVED******REMOVED***perform action: @escaping (ARSession, ARGeoTrackingStatus) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onGeoTrackingStatusChangeAction = action
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
***REMOVED******REMOVED***context.coordinator.onCameraTrackingStateChangeAction = onCameraTrackingStateChangeAction
***REMOVED******REMOVED***context.coordinator.onGeoTrackingStatusChangeAction = onGeoTrackingStatusChangeAction
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator()
***REMOVED***
***REMOVED***

extension ARSwiftUIView {
***REMOVED***class Coordinator: NSObject, ARSCNViewDelegate {
***REMOVED******REMOVED***var onRenderAction: ((SCNSceneRenderer, SCNScene, TimeInterval) -> Void)?
***REMOVED******REMOVED***var onCameraTrackingStateChangeAction: ((ARSession, ARCamera) -> Void)?
***REMOVED******REMOVED***var onGeoTrackingStatusChangeAction: ((ARSession, ARGeoTrackingStatus) -> Void)?
***REMOVED******REMOVED***
***REMOVED******REMOVED***func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***onRenderAction?(renderer, scene, time)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
***REMOVED******REMOVED******REMOVED***onCameraTrackingStateChangeAction?(session, camera)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
***REMOVED******REMOVED******REMOVED***onGeoTrackingStatusChangeAction?(session, geoTrackingStatus)
***REMOVED***
***REMOVED***
***REMOVED***

class ARSwiftUIViewProxy {
***REMOVED***var arView: ARSCNView?
***REMOVED***
***REMOVED***var session: ARSession? {
***REMOVED******REMOVED***arView?.session
***REMOVED***
***REMOVED***
***REMOVED***var pointOfView: SCNNode? {
***REMOVED******REMOVED***arView?.pointOfView
***REMOVED***
***REMOVED***

class ValueWrapper<Value> {
***REMOVED***var value: Value
***REMOVED***
***REMOVED***init(value: Value) {
***REMOVED******REMOVED***self.value = value
***REMOVED***
***REMOVED***
