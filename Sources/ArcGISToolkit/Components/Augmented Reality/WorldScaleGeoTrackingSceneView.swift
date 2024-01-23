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

***REMOVED***/ A scene view that provides an augmented reality world scale experience using geotracking.
public struct WorldScaleGeoTrackingSceneView: View {
***REMOVED******REMOVED***/ The proxy for the ARSwiftUIView.
***REMOVED***@State private var arViewProxy = ARSwiftUIViewProxy()
***REMOVED******REMOVED***/ The camera controller that will be set on the scene view.
***REMOVED***@State private var cameraController: TransformationMatrixCameraController
***REMOVED******REMOVED***/ The current interface orientation.
***REMOVED***@State private var interfaceOrientation: InterfaceOrientation?
***REMOVED******REMOVED***/ The location datasource that is used to access the device location.
***REMOVED***@State private var locationDataSource: LocationDataSource
***REMOVED******REMOVED***/ A Boolean value indicating if the camera was initially set.
***REMOVED***@State private var initialCameraIsSet = false
***REMOVED******REMOVED***/ A Boolean value that indicates whether the coaching overlay view is active.
***REMOVED***@State private var coachingOverlayIsActive = false
***REMOVED******REMOVED***/ The current camera of the scene view.
***REMOVED***@State private var currentCamera: Camera?
***REMOVED******REMOVED***/ A Boolean value that indicates whether the calibration view is hidden.
***REMOVED***private var calibrationViewIsHidden = false
***REMOVED******REMOVED***/ The calibrated camera heading.
***REMOVED***@State private var calibrationHeading: Double?
***REMOVED******REMOVED***/ The calibrated camera elevation.
***REMOVED***@State private var calibrationElevation: Double?
***REMOVED******REMOVED***/ The closure that builds the scene view.
***REMOVED***private let sceneViewBuilder: (SceneViewProxy) -> SceneView
***REMOVED******REMOVED***/ The configuration for the AR session.
***REMOVED***private let configuration: ARConfiguration
***REMOVED******REMOVED***/ The timestamp of the last received location.
***REMOVED***@State private var lastLocationTimestamp: Date?
***REMOVED******REMOVED***/ The current device location.
***REMOVED***@State private var currentLocation: Location?
***REMOVED******REMOVED***/ The valid accuracy threshold for a location in meters.
***REMOVED***private var validAccuracyThreshold = 0.0
***REMOVED******REMOVED***/ The basemap opacity.
***REMOVED***@State private var basemapOpacity = 0.0
***REMOVED******REMOVED***/ A Boolean value that indicates if the AR experince is being calibrated.
***REMOVED***@State private var isCalibrating = false
***REMOVED******REMOVED***/ The slider value for the camera heading.
***REMOVED***@State private var headingSliderValue = 0.0
***REMOVED******REMOVED***/ The slider value for the camera elevation.
***REMOVED***@State private var elevationSliderValue = 0.0
***REMOVED******REMOVED***/ The elevation timer for the "joystick" behavior.
***REMOVED***@State private var headingTimer: Timer?
***REMOVED******REMOVED***/ The heading timer for the "joystick" behavior.
***REMOVED***@State private var elevationTimer: Timer?
***REMOVED******REMOVED***/ The heading delta amount based on the heading slider value.
***REMOVED***private var joystickHeadingDelta: Double {
***REMOVED******REMOVED***Double(signOf: headingSliderValue, magnitudeOf: headingSliderValue * headingSliderValue / 25)
***REMOVED***
***REMOVED******REMOVED***/ The elevation delta amount based on the elevation slider value.
***REMOVED***private var joystickElevationDelta: Double {
***REMOVED******REMOVED***Double(signOf: elevationSliderValue, magnitudeOf: elevationSliderValue * elevationSliderValue / 100)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a world scale scene view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - locationDataSource: The location datasource used to acquire the device's location.
***REMOVED******REMOVED***/   - clippingDistance: Determines the clipping distance in meters around the camera. A value
***REMOVED******REMOVED***/   of `nil` means that no data will be clipped.
***REMOVED******REMOVED***/   - sceneView: A closure that builds the scene view to be overlayed on top of the
***REMOVED******REMOVED***/   augmented reality video feed.
***REMOVED******REMOVED***/ - Remark: The provided scene view will have certain properties overridden in order to
***REMOVED******REMOVED***/ be effectively viewed in augmented reality. Properties such as the camera controller,
***REMOVED******REMOVED***/ and view drawing mode.
***REMOVED***public init(
***REMOVED******REMOVED***locationDataSource: LocationDataSource = SystemLocationDataSource(),
***REMOVED******REMOVED***clippingDistance: Double? = nil,
***REMOVED******REMOVED***@ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
***REMOVED***) {
***REMOVED******REMOVED***sceneViewBuilder = sceneView
***REMOVED******REMOVED***
***REMOVED******REMOVED***let cameraController = TransformationMatrixCameraController()
***REMOVED******REMOVED***cameraController.translationFactor = 1
***REMOVED******REMOVED***cameraController.clippingDistance = clippingDistance
***REMOVED******REMOVED***_cameraController = .init(initialValue: cameraController)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if ARGeoTrackingConfiguration.isSupported {
***REMOVED******REMOVED******REMOVED***configuration = ARGeoTrackingConfiguration()
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***configuration = ARWorldTrackingConfiguration()
***REMOVED******REMOVED******REMOVED***configuration.worldAlignment = .gravityAndHeading
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***_locationDataSource = .init(initialValue: locationDataSource)
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
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
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if initialCameraIsSet {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sceneViewBuilder(sceneViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.cameraController(cameraController)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.attributionBarHidden(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.spaceEffect(.transparent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.atmosphereEffect(.off)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.interactiveNavigationDisabled(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onCameraChanged { camera in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentCamera = camera
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateSceneView(for: currentLocation)
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
***REMOVED******REMOVED******REMOVED***Task { await locationDataSource.stop() ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try await locationDataSource.start()
***REMOVED******REMOVED******REMOVED******REMOVED***await withTaskGroup(of: Void.self) { group in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***group.addTask {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for await location in locationDataSource.locations {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lastLocationTimestamp = location.timestamp
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentLocation = location
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await updateSceneView(for: location)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {***REMOVED***
***REMOVED***
***REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .bottomBar) {
***REMOVED******REMOVED******REMOVED******REMOVED***if !calibrationViewIsHidden {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***calibrationView
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.overlay(alignment: .top) {
***REMOVED******REMOVED******REMOVED***accuracyView
***REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(8)
***REMOVED******REMOVED******REMOVED******REMOVED***.background(.regularMaterial, ignoresSafeAreaEdges: .horizontal)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ If necessary, updates the scene view's camera controller for a new location coming
***REMOVED******REMOVED***/ from the location datasource.
***REMOVED******REMOVED***/ - Parameter location: The location data source location.
***REMOVED***@MainActor
***REMOVED***private func updateSceneView(for location: Location) {
***REMOVED******REMOVED******REMOVED*** Do not update the scene view when the coaching overlay is in place.
***REMOVED******REMOVED***guard !coachingOverlayIsActive else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Do not use cached location more than 10 seconds old.
***REMOVED******REMOVED***guard abs(lastLocationTimestamp?.timeIntervalSinceNow ?? 0) < 10 else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Make sure that horizontal and vertical accuracy are valid.
***REMOVED******REMOVED***guard location.horizontalAccuracy > validAccuracyThreshold,
***REMOVED******REMOVED******REMOVED***  location.verticalAccuracy > validAccuracyThreshold else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Make sure either the initial camera is not set, or we need to update the camera.
***REMOVED******REMOVED***guard !initialCameraIsSet || shouldUpdateCamera(for: location) else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Add some of the vertical accuracy to the z value of the position, that way if the
***REMOVED******REMOVED******REMOVED*** GPS location is not accurate, we won't end up below the earth's surface.
***REMOVED******REMOVED***let altitude = (location.position.z ?? 0) + location.verticalAccuracy
***REMOVED******REMOVED***
***REMOVED******REMOVED***if !initialCameraIsSet {
***REMOVED******REMOVED******REMOVED***let heading = 0.0
***REMOVED******REMOVED******REMOVED***cameraController.originCamera = Camera(
***REMOVED******REMOVED******REMOVED******REMOVED***latitude: location.position.y,
***REMOVED******REMOVED******REMOVED******REMOVED***longitude: location.position.x,
***REMOVED******REMOVED******REMOVED******REMOVED***altitude: altitude,
***REMOVED******REMOVED******REMOVED******REMOVED***heading: heading,
***REMOVED******REMOVED******REMOVED******REMOVED***pitch: 90,
***REMOVED******REMOVED******REMOVED******REMOVED***roll: 0
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***calibrationElevation = altitude
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED*** Ignore location updates when calibrating heading and elevation.
***REMOVED******REMOVED******REMOVED***guard !isCalibrating else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***cameraController.originCamera = Camera(
***REMOVED******REMOVED******REMOVED******REMOVED***latitude: location.position.y,
***REMOVED******REMOVED******REMOVED******REMOVED***longitude: location.position.x,
***REMOVED******REMOVED******REMOVED******REMOVED***altitude: calibrationElevation ?? altitude,
***REMOVED******REMOVED******REMOVED******REMOVED***heading: calibrationHeading ?? 0,
***REMOVED******REMOVED******REMOVED******REMOVED***pitch: 90,
***REMOVED******REMOVED******REMOVED******REMOVED***roll: 0
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** We have to do this or the error gets bigger and bigger.
***REMOVED******REMOVED***cameraController.transformationMatrix = .identity
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
***REMOVED******REMOVED***/ coming in from the location datasource.
***REMOVED******REMOVED***/ - Parameter location: The location datasource location.
***REMOVED******REMOVED***/ - Returns: A Boolean value indicating if the camera should be updated.
***REMOVED***func shouldUpdateCamera(for location: Location) -> Bool {
***REMOVED******REMOVED******REMOVED*** Do not update unless the horizontal accuracy is less than a threshold.
***REMOVED******REMOVED***guard let currentCamera,
***REMOVED******REMOVED******REMOVED***  let spatialReference = currentCamera.location.spatialReference,
***REMOVED******REMOVED******REMOVED***  ***REMOVED*** Project point from the location datasource spatial reference
***REMOVED******REMOVED******REMOVED***  ***REMOVED*** to the scene view spatial reference.
***REMOVED******REMOVED******REMOVED******REMOVED***let currentPosition = GeometryEngine.project(location.position, into: spatialReference)
***REMOVED******REMOVED***else { return false ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Measure the distance between the location datasource's reported location
***REMOVED******REMOVED******REMOVED*** and the camera's current location.
***REMOVED******REMOVED***guard let result = GeometryEngine.geodeticDistance(
***REMOVED******REMOVED******REMOVED***from: currentCamera.location,
***REMOVED******REMOVED******REMOVED***to: currentPosition,
***REMOVED******REMOVED******REMOVED***distanceUnit: .meters,
***REMOVED******REMOVED******REMOVED***azimuthUnit: nil,
***REMOVED******REMOVED******REMOVED***curveType: .geodesic
***REMOVED******REMOVED***) else {
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** If the location becomes off by over a certain threshold, then update the camera location.
***REMOVED******REMOVED***let threshold = 2.0
***REMOVED******REMOVED***return result.distance.value > threshold ? true : false
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
***REMOVED******REMOVED***/ Updates the heading of the scene view camera controller.
***REMOVED******REMOVED***/ - Parameter heading: The camera heading.
***REMOVED***func updateHeading(_ heading: Double) {
***REMOVED******REMOVED***cameraController.originCamera = cameraController.originCamera.rotatedTo(
***REMOVED******REMOVED******REMOVED***heading: heading,
***REMOVED******REMOVED******REMOVED***pitch: cameraController.originCamera.pitch,
***REMOVED******REMOVED******REMOVED***roll: cameraController.originCamera.roll
***REMOVED******REMOVED***)
***REMOVED******REMOVED***calibrationHeading = heading
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Rotates the heading of the scene view camera controller by the heading delta in degrees.
***REMOVED******REMOVED***/ - Parameter headingDelta: The heading delta in degrees.
***REMOVED***func rotateHeading(_ headingDelta: Double) {
***REMOVED******REMOVED***let newHeading = cameraController.originCamera.heading + headingDelta
***REMOVED******REMOVED***cameraController.originCamera = cameraController.originCamera.rotatedTo(
***REMOVED******REMOVED******REMOVED***heading: newHeading,
***REMOVED******REMOVED******REMOVED***pitch: cameraController.originCamera.pitch,
***REMOVED******REMOVED******REMOVED***roll: cameraController.originCamera.roll
***REMOVED******REMOVED***)
***REMOVED******REMOVED***calibrationHeading = newHeading
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Elevates the scene view camera controller by the elevation delta.
***REMOVED******REMOVED***/ - Parameter elevationDelta: The elevation delta.
***REMOVED***func updateElevation(_ elevationDelta: Double) {
***REMOVED******REMOVED***cameraController.originCamera = cameraController.originCamera.elevated(by: elevationDelta)
***REMOVED******REMOVED***if let elevation = cameraController.originCamera.location.z {
***REMOVED******REMOVED******REMOVED***calibrationElevation = elevation
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view that allows the user to calibrate the heading of the scene view camera controller.
***REMOVED***var calibrationView: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***isCalibrating = true
***REMOVED******REMOVED******REMOVED***basemapOpacity = 0.5
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text("Calibrate")
***REMOVED***
***REMOVED******REMOVED***.popover(isPresented: $isCalibrating) {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Heading: \(calibrationHeading?.rounded(.towardZero) ?? cameraController.originCamera.heading.rounded(.towardZero), format: .number)")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let heading = cameraController.originCamera.heading - 1
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateHeading(heading)
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "minus")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Slider(value: $headingSliderValue, in: -10...10) { editingChanged in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !editingChanged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***headingTimer?.invalidate()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***headingTimer = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***headingSliderValue = 0.0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: headingSliderValue) { heading in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard headingTimer == nil else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Create a timer which rotates the camera when fired.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let timer = Timer(timeInterval: 0.1, repeats: true) { [self] (_) in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***rotateHeading(joystickHeadingDelta)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***headingTimer = timer
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Add the timer to the main run loop.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***RunLoop.main.add(timer, forMode: .default)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let heading = cameraController.originCamera.heading + 1
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateHeading(heading)
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "plus")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Elevation: \(calibrationElevation?.rounded(.towardZero) ?? cameraController.originCamera.location.z?.rounded(.towardZero) ?? 0, format: .number)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateElevation(-1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "minus")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Slider(value: $elevationSliderValue, in: -20...20) { editingChanged in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !editingChanged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elevationTimer?.invalidate()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elevationTimer = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elevationSliderValue = 0.0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: elevationSliderValue) { elevation in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard elevationTimer == nil else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Create a timer which rotates the camera when fired.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let timer = Timer(timeInterval: 0.1, repeats: true) { [self] (_) in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateElevation(joystickElevationDelta)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elevationTimer = timer
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Add the timer to the main run loop.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***RunLoop.main.add(timer, forMode: .default)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateElevation(1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "plus")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(minWidth: 200, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED***basemapOpacity = 0.0
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view that displays the horizontal and vertical accuracy of the current location datasource location.
***REMOVED***var accuracyView: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if let currentLocation {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("horizontalAccuracy: \(currentLocation.horizontalAccuracy, format: .number)")
***REMOVED******REMOVED******REMOVED******REMOVED***Text("verticalAccuracy: \(currentLocation.verticalAccuracy, format: .number)")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
