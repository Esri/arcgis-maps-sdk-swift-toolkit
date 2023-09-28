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
***REMOVED***

***REMOVED***/ A scene view that provides an augmented reality fly over experience.
public struct FlyoverSceneView: View {
***REMOVED******REMOVED***/ The AR session.
***REMOVED***@StateObject private var session = ObservableARSession()
***REMOVED******REMOVED***/ The closure that builds the scene view.
***REMOVED***private let sceneViewBuilder: (SceneViewProxy) -> SceneView
***REMOVED******REMOVED***/ The camera controller that we will set on the scene view.
***REMOVED***@State private var cameraController: TransformationMatrixCameraController
***REMOVED******REMOVED***/ The last portrait or landscape orientation value.
***REMOVED***@State private var interfaceOrientation: InterfaceOrientation?
***REMOVED***
***REMOVED******REMOVED***/ Creates a fly over scene view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - initialCamera: The initial camera.
***REMOVED******REMOVED***/   - translationFactor: The translation factor that defines how much the scene view translates
***REMOVED******REMOVED***/   as the device moves.
***REMOVED******REMOVED***/   - sceneView: A closure that builds the scene view to be overlayed on top of the
***REMOVED******REMOVED***/   augmented reality video feed.
***REMOVED******REMOVED***/ - Remark: The provided scene view will have certain properties overridden in order to
***REMOVED******REMOVED***/ be effectively viewed in augmented reality. One such property is the camera controller.
***REMOVED***public init(
***REMOVED******REMOVED***initialCamera: Camera,
***REMOVED******REMOVED***translationFactor: Double,
***REMOVED******REMOVED***@ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
***REMOVED***) {
***REMOVED******REMOVED***self.sceneViewBuilder = sceneView
***REMOVED******REMOVED***
***REMOVED******REMOVED***let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
***REMOVED******REMOVED***cameraController.translationFactor = translationFactor
***REMOVED******REMOVED***_cameraController = .init(initialValue: cameraController)
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***SceneViewReader { sceneViewProxy in
***REMOVED******REMOVED******REMOVED***sceneViewBuilder(sceneViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED***.cameraController(cameraController)
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear { session.start() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onDisappear { session.pause() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: session.currentFrame) { frame in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let frame else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.updateCamera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***frame: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***InterfaceOrientationDetector(interfaceOrientation: $interfaceOrientation)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ An observable object that wraps an `ARSession` and provides the current frame.
private class ObservableARSession: NSObject, ObservableObject, ARSessionDelegate {
***REMOVED******REMOVED***/ The configuration used for the AR session.
***REMOVED***private let configuration: ARWorldTrackingConfiguration
***REMOVED***
***REMOVED******REMOVED***/ The backing AR session.
***REMOVED***private let session = ARSession()
***REMOVED***
***REMOVED***override init() {
***REMOVED******REMOVED***configuration = ARWorldTrackingConfiguration()
***REMOVED******REMOVED***configuration.worldAlignment = .gravityAndHeading
***REMOVED******REMOVED***super.init()
***REMOVED******REMOVED***session.delegate = self
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Starts the AR session.
***REMOVED***func start() {
***REMOVED******REMOVED***session.run(configuration)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Pauses the AR session.
***REMOVED***func pause() {
***REMOVED******REMOVED***session.pause()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The latest AR frame.
***REMOVED***@Published
***REMOVED***var currentFrame: ARFrame?
***REMOVED***
***REMOVED***func session(_ session: ARSession, didUpdate frame: ARFrame) {
***REMOVED******REMOVED***currentFrame = frame
***REMOVED***
***REMOVED***

***REMOVED***/ A view that is able to update a binding to an interface orientation.
struct InterfaceOrientationDetector: UIViewControllerRepresentable {
***REMOVED******REMOVED***/ The binding to update when an interface orientation change is detected.
***REMOVED***let binding: Binding<UIInterfaceOrientation?>
***REMOVED***
***REMOVED******REMOVED***/ Creates an interface orientation detector view.
***REMOVED***init(interfaceOrientation: Binding<UIInterfaceOrientation?>) {
***REMOVED******REMOVED***binding = interfaceOrientation
***REMOVED***
***REMOVED***
***REMOVED***func makeUIViewController(context: Context) -> InterfaceOrientationViewController {
***REMOVED******REMOVED***InterfaceOrientationViewController(interfaceOrientation: binding)
***REMOVED***
***REMOVED***
***REMOVED***func updateUIViewController(_ uiView: InterfaceOrientationViewController, context: Context) {***REMOVED***
***REMOVED***
***REMOVED***final class InterfaceOrientationViewController: UIViewController {
***REMOVED******REMOVED***let binding: Binding<UIInterfaceOrientation?>
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(interfaceOrientation: Binding<UIInterfaceOrientation?>) {
***REMOVED******REMOVED******REMOVED***binding = interfaceOrientation
***REMOVED******REMOVED******REMOVED***super.init(nibName: nil, bundle: nil)
***REMOVED******REMOVED******REMOVED***view.isUserInteractionEnabled = false
***REMOVED******REMOVED******REMOVED***view.isHidden = true
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***required init?(coder: NSCoder) {
***REMOVED******REMOVED******REMOVED***fatalError("init(coder:) has not been implemented")
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***override func viewDidAppear(_ animated: Bool) {
***REMOVED******REMOVED******REMOVED***super.viewDidAppear(animated)
***REMOVED******REMOVED******REMOVED***self.binding.wrappedValue = self.windowInterfaceOrientation
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
***REMOVED******REMOVED******REMOVED******REMOVED*** According to the Apple documentation, this is the new way to be notified when the
***REMOVED******REMOVED******REMOVED******REMOVED*** interface orientation changes.
***REMOVED******REMOVED******REMOVED******REMOVED*** Also, a similar solution is on SO here: https:***REMOVED***stackoverflow.com/a/60577486/1687195
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***super.viewWillTransition(to: size, with: coordinator)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***coordinator.animate { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***self.binding.wrappedValue = self.windowInterfaceOrientation
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The interface orientation of the window that this view is contained in.
***REMOVED******REMOVED***var windowInterfaceOrientation: UIInterfaceOrientation? {
***REMOVED******REMOVED******REMOVED***view.window?.windowScene?.interfaceOrientation
***REMOVED***
***REMOVED***
***REMOVED***
