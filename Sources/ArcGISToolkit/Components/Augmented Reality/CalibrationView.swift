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
***REMOVED******REMOVED******REMOVED***/ The camera controller heading.
***REMOVED******REMOVED***@Binding var heading: Double
***REMOVED******REMOVED******REMOVED***/ The camera controller elevation.
***REMOVED******REMOVED***@Binding var elevation: Double
***REMOVED******REMOVED******REMOVED***/ A Boolean value that indicates if the user is calibrating.
***REMOVED******REMOVED***@Binding var isCalibrating: Bool
***REMOVED******REMOVED******REMOVED***/ The initial camera controller elevation.
***REMOVED******REMOVED***@Binding var initialElevation: Double
***REMOVED******REMOVED******REMOVED***/ The elevation delta value after calibrating.
***REMOVED******REMOVED***@State private var elevationDelta = 0.0
***REMOVED******REMOVED***
***REMOVED******REMOVED***private let numberFormat = FloatingPointFormatStyle<Double>.number
***REMOVED******REMOVED******REMOVED***.precision(.fractionLength(0))
***REMOVED******REMOVED******REMOVED***.sign(strategy: .always(includingZero: false))
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Heading")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.body.smallCaps())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(heading, format: numberFormat) + Text("°")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** onIncrement: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***heading = (heading + 1).clamped(to: -180...180)
***REMOVED******REMOVED******REMOVED******REMOVED*** onDecrement: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***heading = (heading - 1).clamped(to: -180...180)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Joyslider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChanged { delta in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***heading = (heading + delta).clamped(to: -180...180)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onEnded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Round the value now that it stopped changing.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***heading = heading.rounded()
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Elevation")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.body.smallCaps())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(elevationDelta, format: numberFormat) + Text(" m")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** onIncrement: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elevation += 1
***REMOVED******REMOVED******REMOVED******REMOVED*** onDecrement: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elevation -= 1
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Joyslider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChanged { delta in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elevation += delta
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onEnded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Round the value now that it stopped changing.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***elevation = elevation.rounded()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: elevation) { elevation in
***REMOVED******REMOVED******REMOVED******REMOVED***elevationDelta =  elevation - initialElevation
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***elevationDelta =  elevation - initialElevation
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***@ViewBuilder
***REMOVED******REMOVED***var dismissButton: some View {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isCalibrating = false
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
