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
***REMOVED***@State private var isLocalized = false
***REMOVED******REMOVED***@State private var localizedPoint: CLLocationCoordinate2D?
***REMOVED***
***REMOVED***@State private var statusText: String = ""
***REMOVED***@State private var geoAnchor: ARGeoAnchor?
***REMOVED***
***REMOVED***@State private var locationDatasSource = SystemLocationDataSource()
***REMOVED***@State private var currentHeading: Double? = 0
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let sceneViewProxy, let interfaceOrientation, let initialTransformation else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.updateCamera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***frame: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***initialTransformation: initialTransformation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.setFieldOfView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onGeoTrackingStatusChange { session, geoTrackingStatus in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if geoTrackingStatus.state == .localized {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isLocalized = true
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***handleTrackingStatusChange(status: geoTrackingStatus)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onAddNode { renderer, node, anchor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if anchor.identifier == geoAnchor?.identifier {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let box = SCNSphere(radius: 1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let material = SCNMaterial()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***material.isDoubleSided = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***material.diffuse.contents = UIColor.red.withAlphaComponent(0.85)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***box.materials = [material]
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let boxNode = SCNNode()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***boxNode.geometry = box
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***boxNode.worldPosition = node.worldPosition
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***node.addChildNode(boxNode)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screenPoint in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let session = arViewProxy.session else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Perform ARKit raycast on tap location
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let query = arViewProxy.raycastQuery(from: screenPoint, allowing: .estimatedPlane, alignment: .any) else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let result = session.raycast(query).first {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***addGeoAnchor(at: result.worldTransform.translation)
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***statusText = "No raycast result.\nTry pointing at a different area\nor move closer to a surface."
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if initialTransformation != nil {
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
***REMOVED******REMOVED******REMOVED***arViewProxy.session?.run(configuration, options: [.resetTracking])
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***try? await locationDatasSource.start()
***REMOVED******REMOVED******REMOVED***for await heading in locationDatasSource.headings {
***REMOVED******REMOVED******REMOVED******REMOVED***self.currentHeading = heading
***REMOVED******REMOVED******REMOVED******REMOVED***self.statusText = "heading: \(heading)"
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func addGeoAnchor(at worldPosition: SIMD3<Float>) {
***REMOVED******REMOVED***guard let session = arViewProxy.session else { return ***REMOVED***
***REMOVED******REMOVED***session.getGeoLocation(forPoint: worldPosition) { (location, altitude, error) in
***REMOVED******REMOVED******REMOVED***if let error = error {
***REMOVED******REMOVED******REMOVED******REMOVED***statusText = "Cannot add geo anchor: \(error.localizedDescription)"
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***self.addGeoAnchor(at: location, altitude: altitude)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func addGeoAnchor(at location: CLLocationCoordinate2D, altitude: CLLocationDistance? = nil) {
***REMOVED******REMOVED***guard let session = arViewProxy.session else { return ***REMOVED***
***REMOVED******REMOVED***let geoAnchor: ARGeoAnchor
***REMOVED******REMOVED***if let altitude = altitude {
***REMOVED******REMOVED******REMOVED***geoAnchor = ARGeoAnchor(coordinate: location, altitude: altitude)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***geoAnchor = ARGeoAnchor(coordinate: location)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***session.add(anchor: geoAnchor)
***REMOVED******REMOVED***self.geoAnchor = geoAnchor
***REMOVED******REMOVED***
***REMOVED******REMOVED***cameraController.originCamera = Camera(
***REMOVED******REMOVED******REMOVED***latitude: location.latitude,
***REMOVED******REMOVED******REMOVED***longitude: location.longitude,
***REMOVED******REMOVED******REMOVED***altitude: (altitude ?? 0) + 3,
***REMOVED******REMOVED******REMOVED***heading: currentHeading ?? 0,
***REMOVED******REMOVED******REMOVED***pitch: 90,
***REMOVED******REMOVED******REMOVED***roll: 0
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func handleTrackingStatusChange(status: ARGeoTrackingStatus) {
***REMOVED******REMOVED***let state = status.state
***REMOVED******REMOVED***if let trackingStateText = statusText(for: state) {
***REMOVED******REMOVED******REMOVED***statusText = trackingStateText
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
***REMOVED***func statusText(for state: ARGeoTrackingStatus.State) -> String? {
***REMOVED******REMOVED***switch state {
***REMOVED******REMOVED***case .notAvailable:
***REMOVED******REMOVED******REMOVED***return "GeoTracking is not available."
***REMOVED******REMOVED***case .initializing:
***REMOVED******REMOVED******REMOVED***return "Make sure you are outdoors.\nUse the camera to scan static structures or buildings."
***REMOVED******REMOVED***case .localizing:
***REMOVED******REMOVED******REMOVED***return "Attempting to identify device location.\nContinue to scan outdoor structures or buildings."
***REMOVED******REMOVED***case .localized:
***REMOVED******REMOVED******REMOVED***return "Location has been identified."
***REMOVED******REMOVED******REMOVED******REMOVED***return nil
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

extension TransformationMatrix: CustomDebugStringConvertible {
***REMOVED***public var debugDescription: String {
***REMOVED******REMOVED***"\(quaternionX), \(quaternionY), \(quaternionZ), \(quaternionW), \(translationX), \(translationY), \(translationZ)"
***REMOVED***
***REMOVED***
