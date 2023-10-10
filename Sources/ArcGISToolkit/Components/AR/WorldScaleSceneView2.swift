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

***REMOVED***/ A scene view that provides an augmented reality world scale experience.
public struct WorldScaleSceneView2: View {
***REMOVED******REMOVED***/ The proxy for the ARSwiftUIView.
***REMOVED***@State private var arViewProxy = ARSwiftUIViewProxy()
***REMOVED******REMOVED***/ The proxy for the scene view.
***REMOVED***@State private var sceneViewProxy: SceneViewProxy?
***REMOVED******REMOVED***/ The camera controller that will be set on the scene view.
***REMOVED***@State private var cameraController: TransformationMatrixCameraController
***REMOVED******REMOVED***/ The current interface orientation.
***REMOVED***@State private var interfaceOrientation: InterfaceOrientation?
***REMOVED******REMOVED***/ Status text displayed.
***REMOVED***@State private var statusText: String = ""
***REMOVED******REMOVED***/ The location datasource that is used to access the device location.
***REMOVED***@State private var locationDatasSource = SystemLocationDataSource()
***REMOVED******REMOVED***/ The current location.
***REMOVED***@State private var currentLocation: Location?
***REMOVED******REMOVED***/ A Boolean value indicating if the camera was initially set.
***REMOVED***@State private var initialCameraIsSet = false
***REMOVED******REMOVED***/ The current camera of the scene view.
***REMOVED***@State private var currentCamera: Camera?
***REMOVED******REMOVED***/ The closure that builds the scene view.
***REMOVED***private let sceneViewBuilder: (SceneViewProxy) -> SceneView
***REMOVED******REMOVED***/ The configuration for the AR session.
***REMOVED***private let configuration: ARConfiguration
***REMOVED***
***REMOVED******REMOVED***/ Creates a world scale scene view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - clippingDistance: Determines the clipping distance in meters around the camera. A value
***REMOVED******REMOVED***/   of `nil` means that no data will be clipped.
***REMOVED******REMOVED***/   - sceneView: A closure that builds the scene view to be overlayed on top of the
***REMOVED******REMOVED***/   augmented reality video feed.
***REMOVED******REMOVED***/ - Remark: The provided scene view will have certain properties overridden in order to
***REMOVED******REMOVED***/ be effectively viewed in augmented reality. Properties such as the camera controller,
***REMOVED******REMOVED***/ and view drawing mode.
***REMOVED***public init(
***REMOVED******REMOVED***clippingDistance: Double? = nil,
***REMOVED******REMOVED***@ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
***REMOVED***) {
***REMOVED******REMOVED***self.sceneViewBuilder = sceneView
***REMOVED******REMOVED***
***REMOVED******REMOVED***let cameraController = TransformationMatrixCameraController()
***REMOVED******REMOVED***cameraController.translationFactor = 1
***REMOVED******REMOVED***cameraController.clippingDistance = clippingDistance
***REMOVED******REMOVED***_cameraController = .init(initialValue: cameraController)
***REMOVED******REMOVED***
***REMOVED******REMOVED***configuration = ARWorldTrackingConfiguration()
***REMOVED******REMOVED***configuration.worldAlignment = .gravityAndHeading
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***ARSwiftUIView(proxy: arViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED***.onDidUpdateFrame { _, frame in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let sceneViewProxy, let interfaceOrientation, initialCameraIsSet else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.updateCamera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***frame: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***initialTransformation: .identity
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.setFieldOfView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.draw()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if initialCameraIsSet {
***REMOVED******REMOVED******REMOVED******REMOVED***SceneViewReader { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewBuilder(proxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.cameraController(cameraController)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.attributionBarHidden(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.spaceEffect(.transparent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.atmosphereEffect(.off)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.viewDrawingMode(.manual)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onCameraChanged { camera in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.currentCamera = camera
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Capture scene view proxy as a workaround for a bug where
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** preferences set for `ARSwiftUIView` are not honored. The
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** issue has been logged with a bug report with ID FB13188508.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.sceneViewProxy = proxy
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.overlay(alignment: .top) {
***REMOVED******REMOVED******REMOVED***if !statusText.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***statusView(for: statusText)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(8)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(.regularMaterial, ignoresSafeAreaEdges: .horizontal)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.observingInterfaceOrientation($interfaceOrientation)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***arViewProxy.session.run(configuration)
***REMOVED***
***REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED***arViewProxy.session.pause()
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try await locationDatasSource.start()
***REMOVED******REMOVED******REMOVED******REMOVED***await withTaskGroup(of: Void.self) { group in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***group.addTask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await location in locationDatasSource.locations {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.currentLocation = location
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await updateSceneView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***statusText = "Failed to access current location."
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***private func updateSceneView() {
***REMOVED******REMOVED***guard let currentLocation else { return ***REMOVED***
***REMOVED******REMOVED***guard (!initialCameraIsSet || shouldUpdateCamera()) else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***updateOriginCamera(with: currentLocation)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** We have to do this or the error gets bigger and bigger.
***REMOVED******REMOVED***cameraController.transformationMatrix = .identity
***REMOVED******REMOVED***arViewProxy.session.run(configuration, options: .resetTracking)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set flag
***REMOVED******REMOVED***initialCameraIsSet = true
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***private func updateOriginCamera(with location: Location) {
***REMOVED******REMOVED***cameraController.originCamera = Camera(
***REMOVED******REMOVED******REMOVED***latitude: location.position.y,
***REMOVED******REMOVED******REMOVED***longitude: location.position.x,
***REMOVED******REMOVED******REMOVED***altitude: 5,
***REMOVED******REMOVED******REMOVED***heading: 0,
***REMOVED******REMOVED******REMOVED***pitch: 90,
***REMOVED******REMOVED******REMOVED***roll: 0
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func shouldUpdateCamera() -> Bool {
***REMOVED******REMOVED***guard let currentLocation, let currentCamera, currentLocation.horizontalAccuracy < 5 else { return false ***REMOVED***
***REMOVED******REMOVED***guard let sr = currentCamera.location.spatialReference else { return false ***REMOVED***
***REMOVED******REMOVED***guard let currentLocationPosition = GeometryEngine.project(currentLocation.position, into: sr) else { return false ***REMOVED***
***REMOVED******REMOVED***guard let result = GeometryEngine.geodeticDistance(
***REMOVED******REMOVED******REMOVED***from: currentCamera.location,
***REMOVED******REMOVED******REMOVED***to: currentLocationPosition,
***REMOVED******REMOVED******REMOVED***distanceUnit: .meters,
***REMOVED******REMOVED******REMOVED***azimuthUnit: nil,
***REMOVED******REMOVED******REMOVED***curveType: .geodesic
***REMOVED******REMOVED***) else {
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** If the location becomes off by over a certain threshold, then update the camera location.
***REMOVED******REMOVED***let threshold = 2.0
***REMOVED******REMOVED***if result.distance.value > threshold {
***REMOVED******REMOVED******REMOVED***return true
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder func statusView(for status: String) -> some View {
***REMOVED******REMOVED***Text(status)
***REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED***
***REMOVED***

