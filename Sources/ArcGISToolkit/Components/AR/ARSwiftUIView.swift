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

public struct ARSwiftUIView {
***REMOVED***private(set) var onRenderAction: ((SCNSceneRenderer, SCNScene, TimeInterval) -> Void)?
***REMOVED***
***REMOVED***init() {
***REMOVED***
***REMOVED***
***REMOVED***public func onRender(
***REMOVED******REMOVED***perform action: @escaping (SCNSceneRenderer, SCNScene, TimeInterval) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onRenderAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***

extension ARSwiftUIView: UIViewRepresentable {
***REMOVED***public func makeUIView(context: Context) -> ARSCNView {
***REMOVED******REMOVED***let arView = ARSCNView()
***REMOVED******REMOVED***arView.delegate = context.coordinator
***REMOVED******REMOVED***return arView
***REMOVED***
***REMOVED***
***REMOVED***public func updateUIView(_ uiView: ARSCNView, context: Context) {
***REMOVED***
***REMOVED***
***REMOVED***public func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator(arSwiftUIView: self)
***REMOVED***
***REMOVED***

extension ARSwiftUIView {
***REMOVED***public class Coordinator: NSObject, ARSCNViewDelegate {
***REMOVED******REMOVED***private let view: ARSwiftUIView
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(arSwiftUIView: ARSwiftUIView) {
***REMOVED******REMOVED******REMOVED***self.view = arSwiftUIView
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
***REMOVED******REMOVED******REMOVED***view.onRenderAction?(renderer, scene, time)
***REMOVED***
***REMOVED***
***REMOVED***

extension ARSwiftUIView {
***REMOVED***public class Model: ObservableObject {
***REMOVED***
***REMOVED***
