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
***REMOVED******REMOVED******REMOVED***/ The view model for the calibration view.
***REMOVED******REMOVED***@ObservedObject var viewModel: ViewModel
***REMOVED******REMOVED******REMOVED***/ The scene camera controller heading.
***REMOVED******REMOVED***@State private var heading: Double = 0
***REMOVED******REMOVED******REMOVED***/ The scene camera controller elevation.
***REMOVED******REMOVED***@State private var elevation: Double = 0
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .firstTextBaseline) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Calibration")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismissButton
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.layoutPriority(1)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.bottom)
***REMOVED******REMOVED******REMOVED******REMOVED***headingSlider
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***elevationSlider
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***.background(.regularMaterial)
***REMOVED******REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 15))
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: 350)
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***heading = viewModel.cameraController.originCamera.heading
***REMOVED******REMOVED******REMOVED******REMOVED***elevation = viewModel.cameraController.originCamera.location.z ?? 0
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***@ViewBuilder
***REMOVED******REMOVED***var headingSlider: some View {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Stepper() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Heading")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.body.smallCaps())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text((viewModel.calibrationHeading ?? viewModel.cameraController.originCamera.heading).formatted(.number.noFractionalDigits))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** onIncrement: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***rotateHeading(by: 1)
***REMOVED******REMOVED******REMOVED******REMOVED*** onDecrement: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***rotateHeading(by: -1)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***JoystickSliderView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSliderValueChanged { delta in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***rotateHeading(by: delta)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***@ViewBuilder
***REMOVED******REMOVED***var elevationSlider: some View {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Stepper() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Elevation (m)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.body.smallCaps())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text((viewModel.calibrationElevation ?? viewModel.cameraController.originCamera.location.z ?? 0).formatted(.number.noFractionalDigits))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** onIncrement: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateElevation(by: 1)
***REMOVED******REMOVED******REMOVED******REMOVED*** onDecrement: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateElevation(by: -1)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***JoystickSliderView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSliderValueChanged { delta in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateElevation(by: delta)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***@ViewBuilder
***REMOVED******REMOVED***var dismissButton: some View {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.isCalibrating = false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbolRenderingMode(.hierarchical)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 28, height: 28)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Rotates the heading of the scene view camera controller by the heading delta in degrees.
***REMOVED******REMOVED******REMOVED***/ - Parameter headingDelta: The heading delta in degrees.
***REMOVED******REMOVED***private func rotateHeading(by headingDelta: Double) {
***REMOVED******REMOVED******REMOVED***let originCamera = viewModel.cameraController.originCamera
***REMOVED******REMOVED******REMOVED***let newHeading = originCamera.heading + headingDelta
***REMOVED******REMOVED******REMOVED***viewModel.cameraController.originCamera = originCamera.rotatedTo(
***REMOVED******REMOVED******REMOVED******REMOVED***heading: newHeading,
***REMOVED******REMOVED******REMOVED******REMOVED***pitch: originCamera.pitch,
***REMOVED******REMOVED******REMOVED******REMOVED***roll: originCamera.roll
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

***REMOVED***/ A view for a joystick style slider.
struct JoystickSliderView: View {
***REMOVED******REMOVED***/ The slider value.
***REMOVED***@State private var value = 0.0
***REMOVED******REMOVED***/ The timer for the "joystick" behavior.
***REMOVED***@State private var timer: Timer?
***REMOVED******REMOVED***/ The delta amount based on the slider value.
***REMOVED***private var joystickDelta: Double {
***REMOVED******REMOVED***Double(signOf: value, magnitudeOf: value * value / 25)
***REMOVED***
***REMOVED******REMOVED***/ User defined action to be performed when the slider value changes.
***REMOVED***var sliderValueChangedAction: ((Double) -> Void)? = nil
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Slider(value: $value, in: -10...10) { editingChanged in
***REMOVED******REMOVED******REMOVED***if !editingChanged {
***REMOVED******REMOVED******REMOVED******REMOVED***timer?.invalidate()
***REMOVED******REMOVED******REMOVED******REMOVED***timer = nil
***REMOVED******REMOVED******REMOVED******REMOVED***value = 0.0
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: value) { value in
***REMOVED******REMOVED******REMOVED***guard timer == nil else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Create a timer which rotates the camera when fired.
***REMOVED******REMOVED******REMOVED***let timer = Timer(timeInterval: 0.1, repeats: true) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***if let onSliderValueChanged = sliderValueChangedAction {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Returns the joystick slider delta value
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** when the slider value changes.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onSliderValueChanged(joystickDelta)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***self.timer = timer
***REMOVED******REMOVED******REMOVED******REMOVED*** Add the timer to the main run loop.
***REMOVED******REMOVED******REMOVED***RunLoop.main.add(timer, forMode: .default)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets an action to perform when the slider value changes.
***REMOVED******REMOVED***/ - Parameter action: The action to perform when the slider value has changed.
***REMOVED***public func onSliderValueChanged(
***REMOVED******REMOVED***perform action: @escaping (Double) -> Void
***REMOVED***) -> JoystickSliderView {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.sliderValueChangedAction = action
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

private extension FloatingPointFormatStyle {
***REMOVED***var noFractionalDigits: FloatingPointFormatStyle<Value> {
***REMOVED******REMOVED***precision(.fractionLength(0...0))
***REMOVED***
***REMOVED***
