***REMOVED*** Copyright 2024 Esri
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

import ARKit
***REMOVED***
***REMOVED***

***REMOVED***/ A scene view that provides an augmented reality world scale experience.
@preconcurrency
public struct WorldScaleSceneView: View {
***REMOVED******REMOVED***/ The clipping distance of the scene view.
***REMOVED***let clippingDistance: Double?
***REMOVED******REMOVED***/ The tracking mode for world scale AR.
***REMOVED***let trackingMode: TrackingMode
***REMOVED******REMOVED***/ The closure that builds the scene view.
***REMOVED***private let sceneViewBuilder: (SceneViewProxy) -> SceneView
***REMOVED******REMOVED***/ Determines the alignment of the calibration button.
***REMOVED***var calibrationButtonAlignment: Alignment = .bottom
***REMOVED******REMOVED***/ A Boolean value that indicates whether the calibration view is hidden.
***REMOVED***var calibrationViewIsHidden = false
***REMOVED******REMOVED***/ The proxy for the ARSwiftUIView.
***REMOVED***@State private var arViewProxy = ARSwiftUIViewProxy()
***REMOVED******REMOVED***/ The view model for the calibration view.
***REMOVED***@StateObject private var calibrationViewModel = WorldScaleCalibrationViewModel()
***REMOVED******REMOVED***/ A Boolean value that indicates whether the geo-tracking configuration is available.
***REMOVED***@State private var geoTrackingIsAvailable = true
***REMOVED******REMOVED***/ A Boolean value that indicates whether the initial camera is set for the scene view.
***REMOVED***@State private var initialCameraIsSet = false
***REMOVED******REMOVED***/ A Boolean value that indicates if the user is calibrating.
***REMOVED***@State private var isCalibrating = false
***REMOVED******REMOVED***/ The location datasource that is used to access the device location.
***REMOVED***@State private var locationDataSource = SystemLocationDataSource()
***REMOVED******REMOVED***/ The error from the view.
***REMOVED***@State private var error: Error?
***REMOVED******REMOVED***/ The closure to call upon a single tap.
***REMOVED***private var onSingleTapGestureAction: ((CGPoint, Point?) -> Void)? = nil
***REMOVED******REMOVED***/ The closure to perform when the `isCalibrating` property has changed.
***REMOVED***private var onCalibratingChangedAction: ((Bool) -> Void)?
***REMOVED******REMOVED***/ The closure to perform when the camera tracking state changes.
***REMOVED***private var onCameraTrackingStateChangedAction: ((ARCamera.TrackingState) -> Void)?
***REMOVED******REMOVED***/ The closure to perform when the geo tracking status changes.
***REMOVED***private var onGeoTrackingStatusChangedAction: ((ARGeoTrackingStatus) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ Creates a world scale scene view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - clippingDistance: Determines the clipping distance in meters around the camera. A value
***REMOVED******REMOVED***/   of `nil` means that no data will be clipped.
***REMOVED******REMOVED***/   - trackingMode: The type of tracking configuration used by the AR view.
***REMOVED******REMOVED***/   - sceneViewBuilder: A closure that builds the scene view to be overlayed on top of the
***REMOVED******REMOVED***/   augmented reality video feed.
***REMOVED******REMOVED***/ - Remark: The provided scene view will have certain properties overridden in order to
***REMOVED******REMOVED***/ be effectively viewed in augmented reality. Properties such as the camera controller,
***REMOVED******REMOVED***/ and view drawing mode.
***REMOVED***public init(
***REMOVED******REMOVED***clippingDistance: Double? = nil,
***REMOVED******REMOVED***trackingMode: TrackingMode = .worldTracking,
***REMOVED******REMOVED***sceneViewBuilder: @escaping (SceneViewProxy) -> SceneView
***REMOVED***) {
***REMOVED******REMOVED***self.clippingDistance = clippingDistance
***REMOVED******REMOVED***self.trackingMode = trackingMode
***REMOVED******REMOVED***self.sceneViewBuilder = sceneViewBuilder
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch trackingMode {
***REMOVED******REMOVED******REMOVED***case .preferGeoTracking:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** By default we try the geo-tracking configuration. If it is not available at
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** the current location, fall back to world-tracking.
***REMOVED******REMOVED******REMOVED******REMOVED***if geoTrackingIsAvailable {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoTrackingSceneView
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***worldTrackingSceneView
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .geoTracking:
***REMOVED******REMOVED******REMOVED******REMOVED***geoTrackingSceneView
***REMOVED******REMOVED******REMOVED***case .worldTracking:
***REMOVED******REMOVED******REMOVED******REMOVED***worldTrackingSceneView
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***calibrationViewModel.cameraController.clippingDistance = clippingDistance
***REMOVED***
***REMOVED******REMOVED***.onChange(of: clippingDistance) { newClippingDistance in
***REMOVED******REMOVED******REMOVED***calibrationViewModel.cameraController.clippingDistance = newClippingDistance
***REMOVED***
***REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED***Task { await locationDataSource.stop() ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED*** Start the location data source when the view appears.
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Request when-in-use location authorization.
***REMOVED******REMOVED******REMOVED******REMOVED*** The view utilizes a location datasource and it will not start until authorized.
***REMOVED******REMOVED******REMOVED***let locationManager = CLLocationManager()
***REMOVED******REMOVED******REMOVED***if locationManager.authorizationStatus == .notDetermined {
***REMOVED******REMOVED******REMOVED******REMOVED***locationManager.requestWhenInUseAuthorization()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if !checkTrackingCapabilities(locationManager) {
***REMOVED******REMOVED******REMOVED******REMOVED***print("Device doesn't support full accuracy location.")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try await locationDataSource.start()
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***self.error = error
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***geoTrackingIsAvailable = try await checkGeoTrackingAvailability()
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***self.error = error
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.ignoresSafeArea(.container, edges: [.horizontal, .bottom])
***REMOVED******REMOVED***.overlay(alignment: calibrationButtonAlignment) {
***REMOVED******REMOVED******REMOVED***if !calibrationViewIsHidden && !isCalibrating {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isCalibrating = true
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(calibrateLabel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.background(.regularMaterial)
***REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 10))
***REMOVED******REMOVED******REMOVED******REMOVED***.disabled(!initialCameraIsSet)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.vertical)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.overlay(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED***if isCalibrating {
***REMOVED******REMOVED******REMOVED******REMOVED***CalibrationView(viewModel: calibrationViewModel, isPresented: $isCalibrating)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.bottom)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.animation(.default.speed(0.25), value: initialCameraIsSet)
***REMOVED******REMOVED***.onChange(of: isCalibrating) { value in
***REMOVED******REMOVED******REMOVED***onCalibratingChangedAction?(value)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A world scale geo-tracking scene view.
***REMOVED***@ViewBuilder private var geoTrackingSceneView: some View {
***REMOVED******REMOVED***GeoTrackingSceneView(
***REMOVED******REMOVED******REMOVED***arViewProxy: arViewProxy,
***REMOVED******REMOVED******REMOVED***cameraController: calibrationViewModel.cameraController,
***REMOVED******REMOVED******REMOVED***calibrationViewModel: calibrationViewModel,
***REMOVED******REMOVED******REMOVED***clippingDistance: clippingDistance,
***REMOVED******REMOVED******REMOVED***initialCameraIsSet: $initialCameraIsSet,
***REMOVED******REMOVED******REMOVED***calibrationViewIsPresented: isCalibrating,
***REMOVED******REMOVED******REMOVED***locationDataSource: locationDataSource,
***REMOVED******REMOVED******REMOVED***sceneView: sceneViewBuilder
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.onGeoTrackingStatusChanged { geoTrackingStatus in
***REMOVED******REMOVED******REMOVED***onGeoTrackingStatusChangedAction?(geoTrackingStatus)
***REMOVED***
***REMOVED******REMOVED***.onCameraTrackingStateChanged { trackingState in
***REMOVED******REMOVED******REMOVED***onCameraTrackingStateChangedAction?(trackingState)
***REMOVED***
***REMOVED******REMOVED***.onTapGesture { tapPoint in
***REMOVED******REMOVED******REMOVED***handleSingleTap(tapPoint)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A world scale world-tracking scene view.
***REMOVED***@ViewBuilder private var worldTrackingSceneView : some View {
***REMOVED******REMOVED***WorldTrackingSceneView(
***REMOVED******REMOVED******REMOVED***arViewProxy: arViewProxy,
***REMOVED******REMOVED******REMOVED***cameraController: calibrationViewModel.cameraController,
***REMOVED******REMOVED******REMOVED***calibrationViewModel: calibrationViewModel,
***REMOVED******REMOVED******REMOVED***clippingDistance: clippingDistance,
***REMOVED******REMOVED******REMOVED***initialCameraIsSet: $initialCameraIsSet,
***REMOVED******REMOVED******REMOVED***calibrationViewIsPresented: isCalibrating,
***REMOVED******REMOVED******REMOVED***locationDataSource: locationDataSource,
***REMOVED******REMOVED******REMOVED***sceneView: sceneViewBuilder
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.onCameraTrackingStateChanged { trackingState in
***REMOVED******REMOVED******REMOVED***onCameraTrackingStateChangedAction?(trackingState)
***REMOVED***
***REMOVED******REMOVED***.onTapGesture { tapPoint in
***REMOVED******REMOVED******REMOVED***handleSingleTap(tapPoint)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Handles a single tap on the view.
***REMOVED******REMOVED***/ - Parameter tapPoint: The tapped screen point.
***REMOVED***private func handleSingleTap(_ tapPoint: CGPoint) {
***REMOVED******REMOVED***let scenePoint = arScreenToLocation(screenPoint: tapPoint)
***REMOVED******REMOVED***onSingleTapGestureAction?(tapPoint, scenePoint)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the visibility of the calibration view for the AR experience.
***REMOVED******REMOVED***/ - Parameter hidden: A Boolean value that indicates whether to hide the
***REMOVED******REMOVED***/  calibration view.
***REMOVED***public func calibrationViewHidden(_ hidden: Bool) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.calibrationViewIsHidden = hidden
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the alignment of the calibration button.
***REMOVED******REMOVED***/ - Parameter alignment: The alignment for the calibration button.
***REMOVED***public func calibrationButtonAlignment(_ alignment: Alignment) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.calibrationButtonAlignment = alignment
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets a closure to perform when calibration begins or ends.
***REMOVED******REMOVED***/ - Parameter action: The closure to perform when calibration begins or ends.
***REMOVED***public func onCalibratingChanged(
***REMOVED******REMOVED***perform action: @escaping (
***REMOVED******REMOVED******REMOVED***_ newCalibrating: Bool
***REMOVED******REMOVED***) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onCalibratingChangedAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets a closure to perform when the camera tracking state changes.
***REMOVED******REMOVED***/ - Parameter action: The closure to perform when the camera tracking state has changed.
***REMOVED***public func onCameraTrackingStateChanged(
***REMOVED******REMOVED***perform action: @escaping (
***REMOVED******REMOVED******REMOVED***_ cameraTrackingState: ARCamera.TrackingState
***REMOVED******REMOVED***) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onCameraTrackingStateChangedAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets a closure to perform when the geo tracking status changes.
***REMOVED******REMOVED***/ - Parameter action: The closure to perform when the geo tracking status has changed.
***REMOVED***public func onGeoTrackingStatusChanged(
***REMOVED******REMOVED***perform action: @escaping (
***REMOVED******REMOVED******REMOVED***_ geoTrackingStatus: ARGeoTrackingStatus
***REMOVED******REMOVED***) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onGeoTrackingStatusChangedAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Checks if GPS is providing the most accurate location and heading.
***REMOVED******REMOVED***/ - Parameter locationManager: The location manager to determine the accuracy authorization.
***REMOVED******REMOVED***/ - Returns: A Boolean value that indicates whether tracking is accurate.
***REMOVED***private func checkTrackingCapabilities(_ locationManager: CLLocationManager) -> Bool {
***REMOVED******REMOVED***let headingAvailable = CLLocationManager.headingAvailable()
***REMOVED******REMOVED***let fullAccuracy: Bool
***REMOVED******REMOVED***switch locationManager.accuracyAuthorization {
***REMOVED******REMOVED***case .fullAccuracy:
***REMOVED******REMOVED******REMOVED******REMOVED*** World scale AR experience must use full accuracy of device location.
***REMOVED******REMOVED******REMOVED***fullAccuracy = true
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***fullAccuracy = false
***REMOVED***
***REMOVED******REMOVED***return headingAvailable && fullAccuracy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Checks if the hardware and the current location supports geo-tracking.
***REMOVED******REMOVED***/ - Returns: A Boolean value that indicates whether geo-tracking is available.
***REMOVED***private func checkGeoTrackingAvailability() async throws -> Bool {
***REMOVED******REMOVED***if !ARGeoTrackingConfiguration.isSupported {
***REMOVED******REMOVED******REMOVED******REMOVED*** Return false if the device doesn't satisfy the hardware requirements.
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***return try await ARGeoTrackingConfiguration.checkAvailability()
***REMOVED***
***REMOVED***

public extension WorldScaleSceneView {
***REMOVED******REMOVED***/ The type of tracking configuration used by the view.
***REMOVED***enum TrackingMode {
***REMOVED******REMOVED******REMOVED***/ If geo-tracking is unavailable, fall back to world-tracking.
***REMOVED******REMOVED***case preferGeoTracking
***REMOVED******REMOVED******REMOVED***/ Geo-tracking.
***REMOVED******REMOVED***case geoTracking
***REMOVED******REMOVED******REMOVED***/ World-tracking.
***REMOVED******REMOVED***case worldTracking
***REMOVED***
***REMOVED***

private extension ARGeoTrackingConfiguration {
***REMOVED******REMOVED***/ Determines the availability of geo tracking at the current location.
***REMOVED******REMOVED***/ - Returns: A Boolean that indicates whether geo-tracking is available at the current
***REMOVED******REMOVED***/ location or not. If not, an error will be thrown that indicates why geo tracking is
***REMOVED******REMOVED***/ not available at the current location.
***REMOVED***static func checkAvailability() async throws -> Bool {
***REMOVED******REMOVED***return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Bool, Error>) in
***REMOVED******REMOVED******REMOVED***self.checkAvailability { isAvailable, error in
***REMOVED******REMOVED******REMOVED******REMOVED***if let error = error {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continuation.resume(throwing: error)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continuation.resume(returning: isAvailable)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension WorldScaleSceneView {
***REMOVED***var calibrateLabel: String {
***REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED***localized: "Calibrate",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED*** A label for a button to show the calibration view.
***REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

public extension WorldScaleSceneView {
***REMOVED******REMOVED***/ Determines the scene point for the given screen point.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ If the raycast fails due to certain reasons, this method returns `nil`.
***REMOVED******REMOVED***/ - Parameter screenPoint: The point in screen's coordinate space.
***REMOVED******REMOVED***/ - Returns: The scene point corresponding to screen point.
***REMOVED***private func arScreenToLocation(screenPoint: CGPoint) -> Point? {
***REMOVED******REMOVED******REMOVED*** Use the `raycast` method to get the matrix of `screenPoint`.
***REMOVED******REMOVED***guard let localOffsetMatrix = arViewProxy.raycast(from: screenPoint, allowing: .estimatedPlane) else { return nil ***REMOVED***
***REMOVED******REMOVED***let originTransformationMatrix = calibrationViewModel.cameraController.originCamera.transformationMatrix
***REMOVED******REMOVED***let scenePointMatrix = originTransformationMatrix.adding(localOffsetMatrix)
***REMOVED******REMOVED******REMOVED*** Create a camera from transformationMatrix and return its location.
***REMOVED******REMOVED***return Camera(transformationMatrix: scenePointMatrix).location
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets a closure to perform when a single tap occurs on the view.
***REMOVED***func onSingleTapGesture(
***REMOVED******REMOVED***perform action: @escaping (_ screenPoint: CGPoint, _ scenePoint: Point?) -> Void
***REMOVED***) -> some View {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.onSingleTapGestureAction = action
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

extension SceneView {
***REMOVED******REMOVED***/ A modifier to combine various modifiers that apply to both world and geo tracking scene view.
***REMOVED***func worldScaleSetup(cameraController: TransformationMatrixCameraController) -> SceneView {
***REMOVED******REMOVED***self
***REMOVED******REMOVED******REMOVED***.cameraController(cameraController)
***REMOVED******REMOVED******REMOVED***.attributionBarHidden(true)
***REMOVED******REMOVED******REMOVED***.spaceEffect(.transparent)
***REMOVED******REMOVED******REMOVED***.atmosphereEffect(.off)
***REMOVED******REMOVED******REMOVED***.interactiveNavigationDisabled(true)
***REMOVED***
***REMOVED***
