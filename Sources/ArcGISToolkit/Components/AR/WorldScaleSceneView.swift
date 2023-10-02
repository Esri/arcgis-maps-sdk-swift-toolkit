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

enum GeotrackingLocationAvailability {
***REMOVED***case checking
***REMOVED***case available
***REMOVED***case unavailable(Error?)
***REMOVED***

***REMOVED***/ A scene view that provides an augmented reality world scale experience.
public struct WorldScaleSceneView: View {
***REMOVED******REMOVED***/ The proxy for the ARSwiftUIView.
***REMOVED***@State private var arViewProxy = ARSwiftUIViewProxy()
***REMOVED******REMOVED***/ The proxy for the scene view.
***REMOVED***@State private var sceneViewProxy: SceneViewProxy?
***REMOVED******REMOVED***/ The camera controller that will be set on the scene view.
***REMOVED***@State private var cameraController: TransformationMatrixCameraController
***REMOVED******REMOVED***/ The current interface orientation.
***REMOVED***@State private var interfaceOrientation: InterfaceOrientation?
***REMOVED******REMOVED***/ The closure that builds the scene view.
***REMOVED***private let sceneViewBuilder: (SceneViewProxy) -> SceneView
***REMOVED******REMOVED***/ The configuration for the AR session.
***REMOVED***private let configuration: ARConfiguration
***REMOVED***
***REMOVED***@State private var availability: GeotrackingLocationAvailability = .checking
***REMOVED***@State private var trackingStatus: ARGeoTrackingStatus?
***REMOVED***
***REMOVED******REMOVED***/ Creates a world scale scene view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - sceneView: A closure that builds the scene view to be overlayed on top of the
***REMOVED******REMOVED***/   augmented reality video feed.
***REMOVED******REMOVED***/ - Remark: The provided scene view will have certain properties overridden in order to
***REMOVED******REMOVED***/ be effectively viewed in augmented reality. Properties such as the camera controller,
***REMOVED******REMOVED***/ and view drawing mode.
***REMOVED***public init(
***REMOVED******REMOVED***@ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
***REMOVED***) {
***REMOVED******REMOVED***self.sceneViewBuilder = sceneView
***REMOVED******REMOVED***
***REMOVED******REMOVED***let initial = Point(latitude: 0, longitude: 0)
***REMOVED******REMOVED***let initialCamera = Camera(location: initial, heading: 0, pitch: 90, roll: 0)
***REMOVED******REMOVED***let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
***REMOVED******REMOVED******REMOVED***cameraController.translationFactor = translationFactor
***REMOVED******REMOVED***_cameraController = .init(initialValue: cameraController)
***REMOVED******REMOVED***
***REMOVED******REMOVED***configuration = ARGeoTrackingConfiguration()
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***if !ARGeoTrackingConfiguration.isSupported {
***REMOVED******REMOVED******REMOVED***unsupportedDeviceView
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***switch availability {
***REMOVED******REMOVED******REMOVED******REMOVED***case .checking:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***checkingGeotrackingAvailability
***REMOVED******REMOVED******REMOVED******REMOVED***case .available:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arView
***REMOVED******REMOVED******REMOVED******REMOVED***case .unavailable:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geotrackingIsNotAvailable
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***ARGeoTrackingConfiguration.checkAvailability { available, error in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if available {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.availability = .available
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.availability = .unavailable(error)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***@ViewBuilder
***REMOVED***var checkingGeotrackingAvailability: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***Text("Checking Geotracking availability at current location")
***REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***@ViewBuilder
***REMOVED***var geotrackingIsNotAvailable: some View {
***REMOVED******REMOVED***Text("Geotracking is not available at your current location.")
***REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***@ViewBuilder
***REMOVED***var unsupportedDeviceView: some View {
***REMOVED******REMOVED***Text("Geotracking is not supported by this device.")
***REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***@ViewBuilder
***REMOVED***var trackingStatusView: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***switch trackingStatus?.state {
***REMOVED******REMOVED******REMOVED***case .notAvailable:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Not available.")
***REMOVED******REMOVED******REMOVED***case .initializing:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Initializing.")
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED***case .localizing:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Localizing.")
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED***case .localized:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Localized.")
***REMOVED******REMOVED******REMOVED***case nil:
***REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***.background(Color.white.opacity(0.5))
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***@ViewBuilder
***REMOVED***var arView: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***ARSwiftUIView(proxy: arViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED***.onDidUpdateFrame { _, frame in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***trackingStatus = frame.geoTrackingStatus
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let sceneViewProxy, let interfaceOrientation else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.updateCamera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***frame: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.setFieldOfView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if trackingStatus?.state == .localized {
***REMOVED******REMOVED******REMOVED******REMOVED***SceneViewReader { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewBuilder(proxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.cameraController(cameraController)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.attributionBarHidden(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.spaceEffect(.transparent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.atmosphereEffect(.off)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Capture scene view proxy as a workaround for a bug where
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** preferences set for `ARSwiftUIView` are not honored. The
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** issue has been logged with a bug report with ID FB13188508.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.sceneViewProxy = proxy
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***trackingStatusView
***REMOVED***
***REMOVED******REMOVED***.observingInterfaceOrientation($interfaceOrientation)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***arViewProxy.session?.run(configuration)
***REMOVED***
***REMOVED***
***REMOVED***
