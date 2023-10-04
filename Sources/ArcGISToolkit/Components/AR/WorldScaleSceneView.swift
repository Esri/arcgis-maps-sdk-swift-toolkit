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
***REMOVED******REMOVED***@State private var localizedPoint: CLLocationCoordinate2D?
***REMOVED***
***REMOVED***@State private var statusText: String = ""
***REMOVED***@State private var geoAnchor: ARGeoAnchor?
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let initial = Point(latitude: 44.541829415061166, longitude: -117.5794293050851)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let initialCamera = Camera(location: initial, heading: 0, pitch: 90, roll: 0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let cameraController = TransformationMatrixCameraController(originCamera: initialCamera)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let cameraController = TransformationMatrixCameraController()
***REMOVED******REMOVED***cameraController.translationFactor = 1
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
***REMOVED***var arView: some View {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***GeometryReader { proxy in
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***ARSwiftUIView(proxy: arViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED***.onDidUpdateFrame { _, frame in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***trackingStatus = frame.geoTrackingStatus
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let sceneViewProxy, let interfaceOrientation, let initialTransformation else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.updateCamera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***frame: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***initialTransformation: initialTransformation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.setFieldOfView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onAddNode { renderer, node, anchor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if anchor == geoAnchor {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***statusText = "adding box"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let box = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let box = SCNSphere(radius: 1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let material = SCNMaterial()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***material.isDoubleSided = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***material.diffuse.contents = UIColor.red.withAlphaComponent(0.85)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***box.materials = [material]
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let boxNode = SCNNode()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***boxNode.geometry = box
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***boxNode.worldPosition = node.worldPosition
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***node.addChildNode(boxNode)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onUpdateNode { renderer, node, anchor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if anchor == geoAnchor, initialTransformation == nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***statusText = "\(anchor.transform)"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***initialTransformation = .normalized(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***quaternionX: 0,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***quaternionY: 0,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***quaternionZ: 0,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***quaternionW: 1,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***translationX: Double(anchor.transform.columns.3.x),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***translationY: Double(anchor.transform.columns.3.y),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***translationZ: Double(anchor.transform.columns.3.z)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED***arViewProxy.session?.run(configuration)
***REMOVED***
***REMOVED******REMOVED***.onChange(of: trackingStatus) { status in
***REMOVED******REMOVED******REMOVED***handleTrackingStatusChange(status: status)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func handleTrackingStatusChange(status: ARGeoTrackingStatus?) {
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let state = status?.state, let trackingStateText = statusText(for: state) {
***REMOVED******REMOVED******REMOVED***statusText = trackingStateText
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let session = arViewProxy.session, let status, status.state == .localized else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let query = session.currentFrame?.raycastQuery(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***from: CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***allowing: .estimatedPlane,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .any
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***statusText = "cannot create query"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let result = session.raycast(query).first else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***statusText = "raycast failed"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***statusText = "Getting geo location..."
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let point = result.worldTransform.translation
***REMOVED******REMOVED******REMOVED***var point = simd_float3()
***REMOVED******REMOVED******REMOVED***point.x = 1
***REMOVED******REMOVED******REMOVED***point.y = 1
***REMOVED******REMOVED******REMOVED***point.z = 1
***REMOVED******REMOVED******REMOVED***let (location, altitude) = try await session.geoLocation(forPoint: point)
***REMOVED******REMOVED******REMOVED***cameraController.originCamera = Camera(
***REMOVED******REMOVED******REMOVED******REMOVED***latitude: location.latitude,
***REMOVED******REMOVED******REMOVED******REMOVED***longitude: location.longitude,
***REMOVED******REMOVED******REMOVED******REMOVED***altitude: altitude + 3,
***REMOVED******REMOVED******REMOVED******REMOVED***heading: 0,
***REMOVED******REMOVED******REMOVED******REMOVED***pitch: 90,
***REMOVED******REMOVED******REMOVED******REMOVED***roll: 0
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***statusText = "\(location.latitude), \(location.longitude)\n+/-\(status.accuracy.rawValue)m"
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let geoAnchor {
***REMOVED******REMOVED******REMOVED******REMOVED***session.remove(anchor: geoAnchor)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let anchor = ARGeoAnchor(coordinate: location)
***REMOVED******REMOVED******REMOVED***session.add(anchor: anchor)
***REMOVED******REMOVED******REMOVED***geoAnchor = anchor
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@State private var initialTransformation: TransformationMatrix?
***REMOVED***
***REMOVED***@MainActor
***REMOVED***@ViewBuilder
***REMOVED***var checkingGeotrackingAvailability: some View {
***REMOVED******REMOVED***statusView(for: "Checking Geotracking availability at current location.")
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***@ViewBuilder
***REMOVED***var geotrackingIsNotAvailable: some View {
***REMOVED******REMOVED***statusView(for: "Geotracking is not available at your current location.")
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***@ViewBuilder
***REMOVED***var unsupportedDeviceView: some View {
***REMOVED******REMOVED***statusView(for: "Geotracking is not supported by this device.")
***REMOVED***
***REMOVED***
***REMOVED***func statusText(for: ARGeoTrackingStatus.State) -> String? {
***REMOVED******REMOVED***switch trackingStatus?.state {
***REMOVED******REMOVED***case .notAvailable:
***REMOVED******REMOVED******REMOVED***return "GeoTracking is not available."
***REMOVED******REMOVED***case .initializing:
***REMOVED******REMOVED******REMOVED***return "Make sure you are outdoors.\nUse the camera to scan static structures or buildings."
***REMOVED******REMOVED***case .localizing:
***REMOVED******REMOVED******REMOVED***return "Attempting to identify device location.\nContinue to scan outdoor structures or buildings."
***REMOVED******REMOVED***case .localized:
***REMOVED******REMOVED******REMOVED***return "Location has been identified."
***REMOVED******REMOVED***case nil:
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder func statusView(for status: String) -> some View {
***REMOVED******REMOVED***Text(status)
***REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED***
***REMOVED***

extension simd_float4x4 {
***REMOVED***var translation: simd_float3 {
***REMOVED******REMOVED***return [columns.3.x, columns.3.y, columns.3.z]
***REMOVED***
***REMOVED***
