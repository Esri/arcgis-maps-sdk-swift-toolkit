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
***REMOVED******REMOVED***/ The initial camera.
***REMOVED***private let initialCamera: Camera
***REMOVED******REMOVED***/ The translation factor.
***REMOVED***private let translationFactor: Double
***REMOVED******REMOVED***/ The closure that builds the scene view.
***REMOVED***private let sceneViewBuilder: (SceneViewProxy) -> SceneView
***REMOVED******REMOVED***/ The camera controller that we will set on the scene view.
***REMOVED***@State private var cameraController: TransformationMatrixCameraController
***REMOVED******REMOVED***/ The current interface orientation.
***REMOVED***@State private var interfaceOrientation: InterfaceOrientation?
***REMOVED***
***REMOVED******REMOVED***/ Creates a fly over scene view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - initialLatitude: The initial latitude of the scene view's camera.
***REMOVED******REMOVED***/   - initialLongitude: The initial longitude of the scene view's camera.
***REMOVED******REMOVED***/   - initialAltitude: The initial altitude of the scene view's camera.
***REMOVED******REMOVED***/   - initialHeading: The initial heading of the scene view's camera.
***REMOVED******REMOVED***/   - translationFactor: The translation factor that defines how much the scene view translates
***REMOVED******REMOVED***/   as the device moves.
***REMOVED******REMOVED***/   - sceneView: A closure that builds the scene view to be overlayed on top of the
***REMOVED******REMOVED***/   augmented reality video feed.
***REMOVED******REMOVED***/ - Remark: The provided scene view will have certain properties overridden in order to
***REMOVED******REMOVED***/ be effectively viewed in augmented reality. One such property is the camera controller.
***REMOVED***public init(
***REMOVED******REMOVED***initialLatitude: Double,
***REMOVED******REMOVED***initialLongitude: Double,
***REMOVED******REMOVED***initialAltitude: Double,
***REMOVED******REMOVED***initialHeading: Double,
***REMOVED******REMOVED***translationFactor: Double,
***REMOVED******REMOVED***@ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
***REMOVED***) {
***REMOVED******REMOVED***let camera = Camera(
***REMOVED******REMOVED******REMOVED***latitude: initialLatitude,
***REMOVED******REMOVED******REMOVED***longitude: initialLongitude,
***REMOVED******REMOVED******REMOVED***altitude: initialAltitude,
***REMOVED******REMOVED******REMOVED***heading: initialHeading,
***REMOVED******REMOVED******REMOVED***pitch: 90,
***REMOVED******REMOVED******REMOVED***roll: 0
***REMOVED******REMOVED***)
***REMOVED******REMOVED***self.init(initialCamera: camera, translationFactor: translationFactor, sceneView: sceneView)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a fly over scene view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - initialLocation: The initial location of the scene view's camera.
***REMOVED******REMOVED***/   - initialHeading: The initial heading of the scene view's camera.
***REMOVED******REMOVED***/   - translationFactor: The translation factor that defines how much the scene view translates
***REMOVED******REMOVED***/   as the device moves.
***REMOVED******REMOVED***/   - sceneView: A closure that builds the scene view to be overlayed on top of the
***REMOVED******REMOVED***/   augmented reality video feed.
***REMOVED******REMOVED***/ - Remark: The provided scene view will have certain properties overridden in order to
***REMOVED******REMOVED***/ be effectively viewed in augmented reality. One such property is the camera controller.
***REMOVED***public init(
***REMOVED******REMOVED***initialLocation: Point,
***REMOVED******REMOVED***initialHeading: Double,
***REMOVED******REMOVED***translationFactor: Double,
***REMOVED******REMOVED***@ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
***REMOVED***) {
***REMOVED******REMOVED***let camera = Camera(location: initialLocation, heading: initialHeading, pitch: 90, roll: 0)
***REMOVED******REMOVED***self.init(initialCamera: camera, translationFactor: translationFactor, sceneView: sceneView)
***REMOVED***
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
***REMOVED***private init(
***REMOVED******REMOVED***initialCamera: Camera,
***REMOVED******REMOVED***translationFactor: Double,
***REMOVED******REMOVED***@ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
***REMOVED***) {
***REMOVED******REMOVED***self.sceneViewBuilder = sceneView
***REMOVED******REMOVED***self.translationFactor = translationFactor
***REMOVED******REMOVED***self.initialCamera = initialCamera
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let frame, let interfaceOrientation else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.updateCamera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***frame: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: initialCamera) { initialCamera in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController.originCamera = initialCamera
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: translationFactor) { translationFactor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController.translationFactor = translationFactor
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.observingInterfaceOrientation($interfaceOrientation)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func updateCameraController() {
***REMOVED******REMOVED***cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
***REMOVED******REMOVED***cameraController.translationFactor = translationFactor
***REMOVED***
***REMOVED***

***REMOVED***/ An observable object that wraps an `ARSession` and provides the current frame.
private class ObservableARSession: NSObject, ObservableObject, ARSessionDelegate {
***REMOVED******REMOVED***/ The configuration used for the AR session.
***REMOVED***private let configuration: ARConfiguration
***REMOVED***
***REMOVED******REMOVED***/ The backing AR session.
***REMOVED***private let session = ARSession()
***REMOVED***
***REMOVED***override init() {
***REMOVED******REMOVED***configuration = ARPositionalTrackingConfiguration()
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
