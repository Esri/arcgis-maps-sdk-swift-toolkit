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

***REMOVED***/ A scene view that provides an augmented reality world scale experience using geo-tracking.
@preconcurrency
@available(visionOS, unavailable)
public struct GeoTrackingSceneView: View {
***REMOVED******REMOVED***/ A Boolean value indicating if the camera was initially set.
***REMOVED***@Binding var initialCameraIsSet: Bool
***REMOVED******REMOVED***/ The view model for the calibration view.
***REMOVED***@ObservedObject private var calibrationViewModel: WorldScaleCalibrationViewModel
#if os(iOS)
***REMOVED******REMOVED***/ The geo-tracking configuration for the AR session.
***REMOVED***private let configuration = ARGeoTrackingConfiguration()
#endif
***REMOVED******REMOVED***/ A Boolean value that indicates if the user is calibrating.
***REMOVED***private let calibrationViewIsPresented: Bool
***REMOVED******REMOVED***/ The location datasource that is used to access the device location.
***REMOVED***private let locationDataSource: LocationDataSource
***REMOVED******REMOVED***/ The closure that builds the scene view.
***REMOVED***private let sceneViewBuilder: (SceneViewProxy) -> SceneView
#if os(iOS)
***REMOVED******REMOVED***/ The proxy for the ARSwiftUIView.
***REMOVED***private let arViewProxy: ARSwiftUIViewProxy
#endif
***REMOVED******REMOVED***/ The camera controller that will be set on the scene view.
***REMOVED***private let cameraController: TransformationMatrixCameraController
***REMOVED******REMOVED***/ A Boolean value that indicates whether the coaching overlay view is active.
***REMOVED***@State private var coachingOverlayIsActive = false
***REMOVED******REMOVED***/ The current device heading.
***REMOVED***@State private var currentHeading: Double?
***REMOVED******REMOVED***/ The current device location.
***REMOVED***@State private var currentLocation: Location?
***REMOVED******REMOVED***/ The current interface orientation.
***REMOVED***@State private var interfaceOrientation: InterfaceOrientation?
#if os(iOS)
***REMOVED******REMOVED***/ The closure to perform when the camera tracking state changes.
***REMOVED***private var onCameraTrackingStateChangedAction: ((ARCamera.TrackingState) -> Void)?
***REMOVED******REMOVED***/ The closure to perform when the geo tracking status changes.
***REMOVED***private var onGeoTrackingStatusChangedAction: ((ARGeoTrackingStatus) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ Creates a world scale geo-tracking scene view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - arViewProxy: The proxy for the ARSwiftUIView.
***REMOVED******REMOVED***/   - cameraController: The camera controller that will be set on the scene view.
***REMOVED******REMOVED***/   - calibrationViewModel: The view model for accessing the calibration values.
***REMOVED******REMOVED***/   - clippingDistance: Determines the clipping distance in meters around the camera. A value
***REMOVED******REMOVED***/   of `nil` means that no data will be clipped.
***REMOVED******REMOVED***/   - initialCameraIsSet: A Boolean value that indicates whether the initial camera is set for the scene view.
***REMOVED******REMOVED***/   - calibrationViewIsPresented: A Boolean value that indicates whether the calibration view is present.
***REMOVED******REMOVED***/   - locationDataSource: The location datasource used to acquire the device's location.
***REMOVED******REMOVED***/   - sceneView: A closure that builds the scene view to be overlayed on top of the
***REMOVED******REMOVED***/   augmented reality video feed.
***REMOVED***init(
***REMOVED******REMOVED***arViewProxy: ARSwiftUIViewProxy,
***REMOVED******REMOVED***cameraController: TransformationMatrixCameraController,
***REMOVED******REMOVED***calibrationViewModel: WorldScaleCalibrationViewModel,
***REMOVED******REMOVED***clippingDistance: Double?,
***REMOVED******REMOVED***initialCameraIsSet: Binding<Bool>,
***REMOVED******REMOVED***calibrationViewIsPresented: Bool,
***REMOVED******REMOVED***locationDataSource: LocationDataSource,
***REMOVED******REMOVED***@ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
***REMOVED***) {
***REMOVED******REMOVED***self.arViewProxy = arViewProxy
***REMOVED******REMOVED***self.cameraController = cameraController
***REMOVED******REMOVED***self.calibrationViewModel = calibrationViewModel
***REMOVED******REMOVED***self.cameraController.clippingDistance = clippingDistance
***REMOVED******REMOVED***_initialCameraIsSet = initialCameraIsSet
***REMOVED******REMOVED***self.calibrationViewIsPresented = calibrationViewIsPresented
***REMOVED******REMOVED***self.locationDataSource = locationDataSource
***REMOVED******REMOVED***
***REMOVED******REMOVED***sceneViewBuilder = sceneView
***REMOVED***
#endif
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***SceneViewReader { sceneViewProxy in
***REMOVED******REMOVED******REMOVED***ZStack {
#if os(iOS)
***REMOVED******REMOVED******REMOVED******REMOVED***ARSwiftUIView(proxy: arViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onDidUpdateFrame { _, frame in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let interfaceOrientation, initialCameraIsSet else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.updateCamera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***frame: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***initialTransformation: .identity
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewProxy.setFieldOfView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: frame,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***orientation: interfaceOrientation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onDidChangeGeoTrackingStatus { _, status in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***handleGeoTrackingStatusChange(status)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onGeoTrackingStatusChangedAction?(status)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onCameraDidChangeTrackingState { _, trackingState in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onCameraTrackingStateChangedAction?(trackingState)
***REMOVED******REMOVED******REMOVED******REMOVED***
#endif
***REMOVED******REMOVED******REMOVED******REMOVED***sceneViewBuilder(sceneViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.worldScaleSetup(cameraController: cameraController)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.opacity(initialCameraIsSet ? 1 : 0)
***REMOVED******REMOVED***
#if os(iOS)
***REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED***ARCoachingOverlay(goal: .geoTracking)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.sessionProvider(arViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onCoachingOverlayActivate { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***coachingOverlayIsActive = true
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onCoachingOverlayDeactivate { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***coachingOverlayIsActive = false
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onCoachingOverlayRequestSessionReset { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Reset the AR session to provide the best tracking performance.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***arViewProxy.session.run(configuration, options: .resetTracking)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.allowsHitTesting(false)
***REMOVED******REMOVED***
#endif
***REMOVED***
***REMOVED******REMOVED***.observingInterfaceOrientation($interfaceOrientation)
#if os(iOS)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***arViewProxy.session.run(configuration)
***REMOVED***
***REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED***arViewProxy.session.pause()
***REMOVED***
#endif
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***for await location in locationDataSource.locations {
***REMOVED******REMOVED******REMOVED******REMOVED***currentLocation = location
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***for await heading in locationDataSource.headings {
***REMOVED******REMOVED******REMOVED******REMOVED***currentHeading = heading
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the scene view's camera controller with location and heading.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - location: The location for the camera.
***REMOVED******REMOVED***/   - heading: The heading for the camera.
***REMOVED******REMOVED***/   - altitude: The altitude for the camera.
***REMOVED***private func updateCameraController(location: Location, heading: Double, altitude: Double) {
***REMOVED******REMOVED***cameraController.originCamera = Camera(
***REMOVED******REMOVED******REMOVED***latitude: location.position.y,
***REMOVED******REMOVED******REMOVED***longitude: location.position.x,
***REMOVED******REMOVED******REMOVED***altitude: altitude,
***REMOVED******REMOVED******REMOVED***heading: heading,
***REMOVED******REMOVED******REMOVED***pitch: 90,
***REMOVED******REMOVED******REMOVED***roll: 0
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** We have to do this or the error gets bigger and bigger.
***REMOVED******REMOVED***cameraController.transformationMatrix = .identity
***REMOVED***
***REMOVED***
#if os(iOS)
***REMOVED***private func handleGeoTrackingStatusChange(_ status: ARGeoTrackingStatus) {
***REMOVED******REMOVED***switch status.state {
***REMOVED******REMOVED***case .notAvailable, .initializing, .localizing:
***REMOVED******REMOVED******REMOVED***initialCameraIsSet = false
***REMOVED******REMOVED***case .localized:
***REMOVED******REMOVED******REMOVED******REMOVED*** Update the camera controller every time geo-tracking is localized,
***REMOVED******REMOVED******REMOVED******REMOVED*** to ensure the best experience.
***REMOVED******REMOVED******REMOVED***if !initialCameraIsSet, let currentLocation, let currentHeading {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Set the initial heading of scene view camera based on location
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** and heading. Geo-tracking requires 90 degrees rotation.
***REMOVED******REMOVED******REMOVED******REMOVED***updateCameraController(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***location: currentLocation,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***heading: currentHeading + 90,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***altitude: currentLocation.position.z ?? 0
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***initialCameraIsSet = true
***REMOVED******REMOVED***
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***fatalError("Unknown ARGeoTrackingStatus.State")
***REMOVED***
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
#endif
***REMOVED***
