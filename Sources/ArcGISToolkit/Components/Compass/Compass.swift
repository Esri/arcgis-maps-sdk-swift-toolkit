***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

***REMOVED***/ A `Compass` (alias North arrow) shows where north is in a `MapView` or
***REMOVED***/ `SceneView`.
public struct Compass: View {
***REMOVED******REMOVED***/ A Boolean value indicating whether  the compass should automatically
***REMOVED******REMOVED***/ hide/show itself when the heading is `0`.
***REMOVED***private let autoHide: Bool
***REMOVED***
***REMOVED******REMOVED***/ The opacity of the compass.
***REMOVED***@State private var opacity: Double = .zero
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the compass should hide based on the
***REMOVED******REMOVED***/  current heading and whether the compass automatically hides.
***REMOVED***var shouldHide: Bool {
***REMOVED******REMOVED***(heading.isZero || heading.isNaN) && autoHide
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The width and height of the compass.
***REMOVED***var size: CGFloat = 44
***REMOVED***
***REMOVED******REMOVED***/ The heading of the compass in degrees.
***REMOVED***@Binding private var heading: Double
***REMOVED***
***REMOVED******REMOVED***/ Creates a compass with a binding to a heading based on compass
***REMOVED******REMOVED***/ directions (0° indicates a direction toward true North, 90° indicates a
***REMOVED******REMOVED***/ direction toward true East, etc.).
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - heading: The heading of the compass.
***REMOVED******REMOVED***/   - autoHide: A Boolean value that determines whether the compass
***REMOVED******REMOVED***/   automatically hides itself when the heading is `0`.
***REMOVED***public init(
***REMOVED******REMOVED***heading: Binding<Double>,
***REMOVED******REMOVED***autoHide: Bool = true
***REMOVED***) {
***REMOVED******REMOVED***_heading = heading
***REMOVED******REMOVED***self.autoHide = autoHide
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***if !heading.isNaN {
***REMOVED******REMOVED******REMOVED***CompassBody()
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Needle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotationEffect(.degrees(heading))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(1, contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED***.opacity(opacity)
***REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture { heading = .zero ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: size, height: size)
***REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: heading) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let newOpacity: Double = shouldHide ? .zero : 1
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard opacity != newOpacity else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation(.default.delay(shouldHide ? 0.25 : 0)) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***opacity = newOpacity
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear { opacity = shouldHide ? 0 : 1 ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityLabel("Compass, heading \(Int(heading.rounded())) degrees \(CompassDirection(heading).rawValue)")
***REMOVED***
***REMOVED***
***REMOVED***

public extension Compass {
***REMOVED******REMOVED***/ Creates a compass with a binding to a viewpoint rotation (0° indicates
***REMOVED******REMOVED***/ a direction toward true North, 90° indicates a direction toward true
***REMOVED******REMOVED***/ West, etc.).
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - viewpointRotation: The viewpoint rotation whose value determines the
***REMOVED******REMOVED***/   heading of the compass.
***REMOVED******REMOVED***/   - autoHide: A Boolean value that determines whether the compass
***REMOVED******REMOVED***/   automatically hides itself when the viewpoint rotation is 0 degrees.
***REMOVED***init(
***REMOVED******REMOVED***viewpointRotation: Binding<Double>,
***REMOVED******REMOVED***autoHide: Bool = true
***REMOVED***) {
***REMOVED******REMOVED***let heading = Binding(get: {
***REMOVED******REMOVED******REMOVED***viewpointRotation.wrappedValue.isZero ? .zero : 360 - viewpointRotation.wrappedValue
***REMOVED***, set: { newHeading in
***REMOVED******REMOVED******REMOVED***viewpointRotation.wrappedValue = newHeading.isZero ? .zero : 360 - newHeading
***REMOVED***)
***REMOVED******REMOVED***self.init(heading: heading, autoHide: autoHide)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a compass with a binding to an optional viewpoint.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - viewpoint: The viewpoint whose rotation determines the heading of the compass.
***REMOVED******REMOVED***/   - autoHide: A Boolean value that determines whether the compass automatically hides itself
***REMOVED******REMOVED***/   when the viewpoint's rotation is 0 degrees.
***REMOVED***init(
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>,
***REMOVED******REMOVED***autoHide: Bool = true
***REMOVED***) {
***REMOVED******REMOVED***let viewpointRotation = Binding {
***REMOVED******REMOVED******REMOVED***viewpoint.wrappedValue?.rotation ?? .nan
***REMOVED*** set: { newViewpointRotation in
***REMOVED******REMOVED******REMOVED***guard let oldViewpoint = viewpoint.wrappedValue else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***viewpoint.wrappedValue = Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***center: oldViewpoint.targetGeometry.extent.center,
***REMOVED******REMOVED******REMOVED******REMOVED***scale: oldViewpoint.targetScale,
***REMOVED******REMOVED******REMOVED******REMOVED***rotation: newViewpointRotation
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***self.init(viewpointRotation: viewpointRotation, autoHide: autoHide)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Define a custom size for the compass.
***REMOVED******REMOVED***/ - Parameter size: A value for the compass' width and height.
***REMOVED***func compassSize(size: CGFloat) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.size = size
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
