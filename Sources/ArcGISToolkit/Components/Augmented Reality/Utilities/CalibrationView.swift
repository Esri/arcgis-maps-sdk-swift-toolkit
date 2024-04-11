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

***REMOVED***/ A view model that stores state information for the calibration.
@MainActor
class WorldScaleCalibrationViewModel: ObservableObject {
***REMOVED******REMOVED***/ The total heading correction.
***REMOVED***@Published
***REMOVED***private(set) var totalHeadingCorrection: Double = 0
***REMOVED***
***REMOVED******REMOVED***/ The total elevation correction.
***REMOVED***@Published
***REMOVED***private(set) var totalElevationCorrection: Double = 0
***REMOVED***
***REMOVED******REMOVED***/ The camera controller for which corrections will be applied.
***REMOVED***let cameraController = TransformationMatrixCameraController()
***REMOVED***
***REMOVED******REMOVED***/ Creates a calibration view model.
***REMOVED***init() {
***REMOVED******REMOVED***cameraController.translationFactor = 1
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Proposes a heading correction.
***REMOVED******REMOVED***/ This will limit the total heading correction to -180...180.
***REMOVED***fileprivate func propose(headingCorrection: Double) {
***REMOVED******REMOVED***let newTotalHeadingCorrection = (totalHeadingCorrection + headingCorrection)
***REMOVED******REMOVED******REMOVED***.clamped(to: -180...180)
***REMOVED******REMOVED***let allowedHeadingCorrection = newTotalHeadingCorrection - totalHeadingCorrection
***REMOVED******REMOVED***totalHeadingCorrection = newTotalHeadingCorrection
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Update camera controller.
***REMOVED******REMOVED***let originCamera = cameraController.originCamera
***REMOVED******REMOVED***cameraController.originCamera = originCamera.rotatedTo(
***REMOVED******REMOVED******REMOVED***heading: originCamera.heading + allowedHeadingCorrection,
***REMOVED******REMOVED******REMOVED***pitch: originCamera.pitch,
***REMOVED******REMOVED******REMOVED***roll: originCamera.roll
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Proposes an elevation correction.
***REMOVED***fileprivate func propose(elevationCorrection: Double) {
***REMOVED******REMOVED***totalElevationCorrection += elevationCorrection
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Update camera controller.
***REMOVED******REMOVED***cameraController.originCamera = cameraController.originCamera.elevated(by: elevationCorrection)
***REMOVED***
***REMOVED***

extension WorldScaleSceneView {
***REMOVED******REMOVED***/ A view that allows the user to calibrate the heading of the scene view camera controller.
***REMOVED***struct CalibrationView: View {
***REMOVED******REMOVED***@ObservedObject
***REMOVED******REMOVED***var viewModel: WorldScaleCalibrationViewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value that indicates if the user is presenting the calibration view.
***REMOVED******REMOVED***@Binding
***REMOVED******REMOVED***var isPresented: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A number format style for signed values with their fractional component removed.
***REMOVED******REMOVED***private let numberFormat = FloatingPointFormatStyle<Double>.number
***REMOVED******REMOVED******REMOVED***.precision(.fractionLength(1))
***REMOVED******REMOVED******REMOVED***.sign(strategy: .always(includingZero: false))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The total heading correction measurement in degrees.
***REMOVED******REMOVED***private var totalHeadingCorrectionMeasurement: Measurement<UnitAngle> {
***REMOVED******REMOVED******REMOVED***Measurement<UnitAngle>(value: viewModel.totalHeadingCorrection, unit: .degrees)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The total elevation correction measurement in meters.
***REMOVED******REMOVED***private var totalElevationCorrectionMeasurement: Measurement<UnitLength> {
***REMOVED******REMOVED******REMOVED***Measurement<UnitLength>(value: viewModel.totalElevationCorrection, unit: .meters)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .firstTextBaseline) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(calibrationLabel)
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
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: 430)
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***@ViewBuilder
***REMOVED******REMOVED***var headingSlider: some View {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Stepper() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(headingLabel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.body.smallCaps())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(totalHeadingCorrectionMeasurement, format: .measurement(width: .narrow, numberFormatStyle: numberFormat))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** onIncrement: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.propose(headingCorrection: 1)
***REMOVED******REMOVED******REMOVED******REMOVED*** onDecrement: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.propose(headingCorrection: -1)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Joyslider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChanged { delta in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.propose(headingCorrection: delta)
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(elevationLabel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.body.smallCaps())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(totalElevationCorrectionMeasurement, format: .measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: numberFormat))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** onIncrement: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.propose(elevationCorrection: 1)
***REMOVED******REMOVED******REMOVED******REMOVED*** onDecrement: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.propose(elevationCorrection: -1)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Joyslider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChanged { delta in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.propose(elevationCorrection: delta)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***@ViewBuilder
***REMOVED******REMOVED***var dismissButton: some View {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
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
***REMOVED***
***REMOVED***

private extension WorldScaleSceneView.CalibrationView {
***REMOVED***var calibrationLabel: String {
***REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED***localized: "Calibration",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED*** A label for the calibration view used to calibrate the camera
***REMOVED******REMOVED******REMOVED******REMOVED*** for the AR experience.
***REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***var headingLabel: String {
***REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED***localized: "heading",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED*** A label for the slider that adjusts the camera heading for the
***REMOVED******REMOVED******REMOVED******REMOVED*** AR experience.
***REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***var elevationLabel: String {
***REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED***localized: "elevation",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED*** A label for the slider that adjusts the camera elevation for the
***REMOVED******REMOVED******REMOVED******REMOVED*** AR experience.
***REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
