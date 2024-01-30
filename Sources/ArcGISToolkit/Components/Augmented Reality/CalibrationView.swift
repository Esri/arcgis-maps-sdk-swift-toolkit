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

extension WorldScaleGeoTrackingSceneView {
***REMOVED******REMOVED***/ A view that allows the user to calibrate the heading of the scene view camera controller.
***REMOVED***struct CalibrationView: View {
***REMOVED******REMOVED***@ObservedObject var viewModel: ViewModel
***REMOVED******REMOVED******REMOVED***/ The slider value for the camera heading.
***REMOVED******REMOVED***@State private var headingSliderValue = 0.0
***REMOVED******REMOVED******REMOVED***/ The slider value for the camera elevation.
***REMOVED******REMOVED***@State private var elevationSliderValue = 0.0
***REMOVED******REMOVED******REMOVED***/ The elevation timer for the "joystick" behavior.
***REMOVED******REMOVED***@State private var headingTimer: Timer?
***REMOVED******REMOVED******REMOVED***/ The heading timer for the "joystick" behavior.
***REMOVED******REMOVED***@State private var elevationTimer: Timer?
***REMOVED******REMOVED******REMOVED***/ The heading delta amount based on the heading slider value.
***REMOVED******REMOVED***private var joystickHeadingDelta: Double {
***REMOVED******REMOVED******REMOVED***Double(signOf: headingSliderValue, magnitudeOf: headingSliderValue * headingSliderValue / 25)
***REMOVED***
***REMOVED******REMOVED******REMOVED***/ The elevation delta amount based on the elevation slider value.
***REMOVED******REMOVED***private var joystickElevationDelta: Double {
***REMOVED******REMOVED******REMOVED***Double(signOf: elevationSliderValue, magnitudeOf: elevationSliderValue * elevationSliderValue / 100)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Heading: \(viewModel.calibrationHeading?.rounded(.towardZero) ?? viewModel.cameraController.originCamera.heading.rounded(.towardZero), format: .number)")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let heading = viewModel.cameraController.originCamera.heading - 1
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateHeading(to: heading)
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "minus")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Slider(value: $headingSliderValue, in: -10...10) { editingChanged in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !editingChanged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***headingTimer?.invalidate()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***headingTimer = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***headingSliderValue = 0.0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: headingSliderValue) { heading in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard headingTimer == nil else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Create a timer which rotates the camera when fired.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let timer = Timer(timeInterval: 0.1, repeats: true) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***rotateHeading(by: joystickHeadingDelta)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***headingTimer = timer
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Add the timer to the main run loop.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***RunLoop.main.add(timer, forMode: .default)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let heading = viewModel.cameraController.originCamera.heading + 1
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateHeading(to: heading)
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "plus")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Elevation: \(viewModel.calibrationElevation?.rounded(.towardZero) ?? viewModel.cameraController.originCamera.location.z?.rounded(.towardZero) ?? 0, format: .number)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateElevation(by: -1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "minus")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Slider(value: $elevationSliderValue, in: -20...20) { editingChanged in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !editingChanged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elevationTimer?.invalidate()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elevationTimer = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elevationSliderValue = 0.0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: elevationSliderValue) { elevation in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard elevationTimer == nil else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Create a timer which rotates the camera when fired.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let timer = Timer(timeInterval: 0.1, repeats: true) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateElevation(by: joystickElevationDelta)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elevationTimer = timer
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Add the timer to the main run loop.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***RunLoop.main.add(timer, forMode: .default)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateElevation(by: 1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "plus")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.imageScale(.large)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED******REMOVED***guard !viewModel.isCalibrating else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setBasemapOpacity(0)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.isCalibrating = false
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Done")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(alignment: .topTrailing)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***.background(.regularMaterial)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Updates the heading of the scene view camera controller.
***REMOVED******REMOVED******REMOVED***/ - Parameter heading: The camera heading.
***REMOVED******REMOVED***private func updateHeading(to heading: Double) {
***REMOVED******REMOVED******REMOVED***viewModel.cameraController.originCamera = viewModel.cameraController.originCamera.rotatedTo(
***REMOVED******REMOVED******REMOVED******REMOVED***heading: heading,
***REMOVED******REMOVED******REMOVED******REMOVED***pitch: viewModel.cameraController.originCamera.pitch,
***REMOVED******REMOVED******REMOVED******REMOVED***roll: viewModel.cameraController.originCamera.roll
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***viewModel.calibrationHeading = heading
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Rotates the heading of the scene view camera controller by the heading delta in degrees.
***REMOVED******REMOVED******REMOVED***/ - Parameter headingDelta: The heading delta in degrees.
***REMOVED******REMOVED***private func rotateHeading(by headingDelta: Double) {
***REMOVED******REMOVED******REMOVED***let newHeading = viewModel.cameraController.originCamera.heading + headingDelta
***REMOVED******REMOVED******REMOVED***viewModel.cameraController.originCamera = viewModel.cameraController.originCamera.rotatedTo(
***REMOVED******REMOVED******REMOVED******REMOVED***heading: newHeading,
***REMOVED******REMOVED******REMOVED******REMOVED***pitch: viewModel.cameraController.originCamera.pitch,
***REMOVED******REMOVED******REMOVED******REMOVED***roll: viewModel.cameraController.originCamera.roll
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***viewModel.calibrationHeading = newHeading
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Elevates the scene view camera controller by the elevation delta.
***REMOVED******REMOVED******REMOVED***/ - Parameter elevationDelta: The elevation delta.
***REMOVED******REMOVED***private func updateElevation(by elevationDelta: Double) {
***REMOVED******REMOVED******REMOVED***viewModel.cameraController.originCamera = viewModel.cameraController.originCamera.elevated(by: elevationDelta)
***REMOVED******REMOVED******REMOVED***if let elevation = viewModel.cameraController.originCamera.location.z {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.calibrationElevation = elevation
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
