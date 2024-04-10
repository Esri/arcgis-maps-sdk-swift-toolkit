***REMOVED*** Copyright 2023 Esri
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

***REMOVED***/ A scene view that provides an augmented reality world scale experience using world-tracking.
struct WorldTrackingSceneView: View {
***REMOVED******REMOVED***/ A Boolean value indicating if the camera was initially set.
***REMOVED***@Binding var initialCameraIsSet: Bool
***REMOVED******REMOVED***/ The view model for the calibration view.
***REMOVED***@ObservedObject private var calibrationViewModel: WorldScaleCalibrationViewModel
***REMOVED******REMOVED***/ The configuration for the AR session.
***REMOVED***private let configuration: ARConfiguration
***REMOVED******REMOVED***/ The distance threshold in meters between camera and device location to reset the
***REMOVED******REMOVED***/ world-tracking session.
***REMOVED***private let distanceThreshold: Double
***REMOVED******REMOVED***/ A Boolean value that indicates if the user is calibrating.
***REMOVED***private let calibrationViewIsPresented: Bool
***REMOVED******REMOVED***/ The location datasource that is used to access the device location.
***REMOVED***private let locationDataSource: LocationDataSource
***REMOVED******REMOVED***/ The closure that builds the scene view.
***REMOVED***private let sceneViewBuilder: (SceneViewProxy) -> SceneView
***REMOVED******REMOVED***/ The time threshold in seconds between location updates to reset the world-tracking session.
***REMOVED***private let timeThreshold: Double
***REMOVED******REMOVED***/ The proxy for the ARSwiftUIView.
***REMOVED***private let arViewProxy: ARSwiftUIViewProxy
***REMOVED******REMOVED***/ The camera controller that will be set on the scene view.
***REMOVED***private let cameraController: TransformationMatrixCameraController
***REMOVED******REMOVED***/ A Boolean value that indicates whether the coaching overlay view is active.
***REMOVED***@State private var coachingOverlayIsActive = false
***REMOVED******REMOVED***/ The current camera of the scene view.
***REMOVED***@State private var currentCamera: Camera?
***REMOVED******REMOVED***/ The current device location.
***REMOVED***@State private var currentLocation: Location?
***REMOVED******REMOVED***/ The current interface orientation.
***REMOVED***@State private var interfaceOrientation: InterfaceOrientation?
***REMOVED******REMOVED***/ The timestamp of the last received location.
***REMOVED***@State private var lastLocationTimestamp: Date?
***REMOVED******REMOVED***/ The closure to perform when the camera tracking state changes.
***REMOVED***private var onCameraTrackingStateChangedAction: ((ARCamera.TrackingState) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ Creates a world scale world-tracking scene view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - arViewProxy: The proxy for the ARSwiftUIView.
***REMOVED******REMOVED***/   - cameraController: The camera controller that will be set on the scene view.
***REMOVED******REMOVED***/   - calibrationViewModel: The view model for accessing the calibration values.
***REMOVED******REMOVED***/   - clippingDistance: Determines the clipping distance in meters around the camera. A value
***REMOVED******REMOVED***/   of `nil` means that no data will be clipped.
***REMOVED******REMOVED***/   - distanceThreshold: The distance threshold for the camera to be re-aligned with the GPS.
***REMOVED******REMOVED***/   - initialCameraIsSet: A Boolean value that indicates whether the initial camera is set for the scene view.
***REMOVED******REMOVED***/   - calibrationViewIsPresented: A Boolean value that indicates whether the calibration view is present.
***REMOVED******REMOVED***/   - locationDataSource: The location datasource used to acquire the device's location.
***REMOVED******REMOVED***/   - timeThreshold: The time threshold for the camera to be re-aligned with the GPS.
***REMOVED******REMOVED***/   - sceneView: A closure that builds the scene view to be overlayed on top of the
***REMOVED******REMOVED***/   augmented reality video feed.
***REMOVED***init(
***REMOVED******REMOVED***arViewProxy: ARSwiftUIViewProxy,
***REMOVED******REMOVED***cameraController: TransformationMatrixCameraController,
***REMOVED******REMOVED***calibrationViewModel: WorldScaleCalibrationViewModel,
***REMOVED******REMOVED***clippingDistance: Double?,
***REMOVED******REMOVED***distanceThreshold: Double = 2.0,
***REMOVED******REMOVED***initialCameraIsSet: Binding<Bool>,
***REMOVED******REMOVED***calibrationViewIsPresented: Bool,
***REMOVED******REMOVED***locationDataSource: LocationDataSource,
***REMOVED******REMOVED***timeThreshold: Double = 10.0,
***REMOVED******REMOVED***@ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
***REMOVED***) {
***REMOVED******REMOVED***self.arViewProxy = arViewProxy
***REMOVED******REMOVED***self.cameraController = cameraController
***REMOVED******REMOVED***self.calibrationViewModel = calibrationViewModel
***REMOVED******REMOVED***self.cameraController.clippingDistance = clippingDistance
***REMOVED******REMOVED***self.distanceThreshold = distanceThreshold
***REMOVED******REMOVED***_initialCameraIsSet = initialCameraIsSet
***REMOVED******REMOVED***self.calibrationViewIsPresented = calibrationViewIsPresented
***REMOVED******REMOVED***self.locationDataSource = locationDataSource
***REMOVED******REMOVED***self.timeThreshold = timeThreshold
***REMOVED******REMOVED***
***REMOVED******REMOVED***sceneViewBuilder = sceneView
***REMOVED******REMOVED***
***REMOVED******REMOVED***let worldTrackingConfiguration = ARWorldTrackingConfiguration()
***REMOVED******REMOVED******REMOVED*** Set world alignment to `gravityAndHeading` so the world-tracking configuration uses
***REMOVED******REMOVED******REMOVED*** geographic location from the device. Geo-tracking uses it by default.
***REMOVED******REMOVED***worldTrackingConfiguration.worldAlignment = .gravityAndHeading
***REMOVED******REMOVED***configuration = worldTrackingConfiguration
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***SceneViewReader { sceneViewProxy in
***REMOVED******REMOVED******REMOVED***ZStack {
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onCameraDidChangeTrackingState { _, trackingState in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onCameraTrackingStateChangedAction?(trackingState)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***sceneViewBuilder(sceneViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.worldScaleSetup(cameraController: cameraController)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onCameraChanged { camera in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentCamera = camera
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.opacity(initialCameraIsSet ? 1 : 0)
***REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let currentLocation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateWorldTrackingSceneView(for: currentLocation)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.allowsHitTesting(false)
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
***REMOVED******REMOVED******REMOVED***for await location in locationDataSource.locations {
***REMOVED******REMOVED******REMOVED******REMOVED***lastLocationTimestamp = location.timestamp
***REMOVED******REMOVED******REMOVED******REMOVED***currentLocation = location
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Call the method to check if world tracking session needs to be updated.
***REMOVED******REMOVED******REMOVED******REMOVED***updateWorldTrackingSceneView(for: location)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the scene view's camera controller with a new location coming from the
***REMOVED******REMOVED***/ location data source and resets the AR session when using world-tracking configuration.
***REMOVED******REMOVED***/ - Parameter location: The location data source location.
***REMOVED***private func updateWorldTrackingSceneView(for location: Location) {
***REMOVED******REMOVED******REMOVED*** Do not update the scene view when the coaching overlay is in place.
***REMOVED******REMOVED***guard !coachingOverlayIsActive else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Do not use cached location more than 10 seconds old.
***REMOVED******REMOVED***guard abs(lastLocationTimestamp?.timeIntervalSinceNow ?? 0) < timeThreshold else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Make sure that horizontal and vertical accuracy are valid.
***REMOVED******REMOVED***guard location.horizontalAccuracy >= .zero,
***REMOVED******REMOVED******REMOVED***  location.verticalAccuracy >= .zero else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Make sure we need to update the camera based on distance deviation.
***REMOVED******REMOVED***guard !initialCameraIsSet || shouldUpdateCamera(for: location) else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let altitude = location.position.z ?? 0
***REMOVED******REMOVED***
***REMOVED******REMOVED***if !initialCameraIsSet {
***REMOVED******REMOVED******REMOVED***cameraController.originCamera = Camera(
***REMOVED******REMOVED******REMOVED******REMOVED***latitude: location.position.y,
***REMOVED******REMOVED******REMOVED******REMOVED***longitude: location.position.x,
***REMOVED******REMOVED******REMOVED******REMOVED***altitude: altitude,
***REMOVED******REMOVED******REMOVED******REMOVED***heading: 0,
***REMOVED******REMOVED******REMOVED******REMOVED***pitch: 90,
***REMOVED******REMOVED******REMOVED******REMOVED***roll: 0
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED*** Ignore location updates when calibrating heading and elevation.
***REMOVED******REMOVED******REMOVED***guard !calibrationViewIsPresented else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***cameraController.originCamera = Camera(
***REMOVED******REMOVED******REMOVED******REMOVED***latitude: location.position.y,
***REMOVED******REMOVED******REMOVED******REMOVED***longitude: location.position.x,
***REMOVED******REMOVED******REMOVED******REMOVED***altitude: altitude + calibrationViewModel.totalElevationCorrection,
***REMOVED******REMOVED******REMOVED******REMOVED***heading: calibrationViewModel.totalHeadingCorrection,
***REMOVED******REMOVED******REMOVED******REMOVED***pitch: 90,
***REMOVED******REMOVED******REMOVED******REMOVED***roll: 0
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** We have to do this or the error gets bigger and bigger.
***REMOVED******REMOVED***cameraController.transformationMatrix = .identity
***REMOVED******REMOVED***
***REMOVED******REMOVED***arViewProxy.session.run(configuration, options: .resetTracking)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** If initial camera is not set, then we set it the flag here to true
***REMOVED******REMOVED******REMOVED*** and set the status text to empty.
***REMOVED******REMOVED***if !initialCameraIsSet {
***REMOVED******REMOVED******REMOVED***initialCameraIsSet = true
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a Boolean value indicating if the camera should be updated for a location
***REMOVED******REMOVED***/ coming in from the location data source based on current camera deviation.
***REMOVED******REMOVED***/ - Parameter location: The location data source location.
***REMOVED******REMOVED***/ - Returns: A Boolean value indicating if the camera should be updated.
***REMOVED***func shouldUpdateCamera(for location: Location) -> Bool {
***REMOVED******REMOVED***guard let currentCamera, let currentLocation else { return false ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Measure the distance between the location datasource's reported location
***REMOVED******REMOVED******REMOVED*** and the camera's current location.
***REMOVED******REMOVED***guard let result = GeometryEngine.geodeticDistance(
***REMOVED******REMOVED******REMOVED***from: currentCamera.location,
***REMOVED******REMOVED******REMOVED***to: currentLocation.position,
***REMOVED******REMOVED******REMOVED***distanceUnit: .meters,
***REMOVED******REMOVED******REMOVED***azimuthUnit: nil,
***REMOVED******REMOVED******REMOVED***curveType: .geodesic
***REMOVED******REMOVED***) else {
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** If the location becomes off by over a certain threshold, then update the camera location.
***REMOVED******REMOVED***return result.distance.value > distanceThreshold ? true : false
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
