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

***REMOVED***/ A Compass (alias North arrow) shows where north is in a `MapView` or `SceneView`.
public struct Compass: View {
***REMOVED******REMOVED***/ Determines if the compass should automatically hide/show itself when the parent view is oriented
***REMOVED******REMOVED***/ north.
***REMOVED***private let autoHide: Bool

***REMOVED******REMOVED***/ Indicates if the compass is hidden based on the current viewpoint rotation and
***REMOVED******REMOVED***/ autoHide preference.
***REMOVED***public var isHidden: Bool {
***REMOVED******REMOVED***guard let viewpoint = viewpoint else { return autoHide ***REMOVED***
***REMOVED******REMOVED***return viewpoint.rotation.isZero && autoHide
***REMOVED***

***REMOVED******REMOVED***/ Controls the current opacity of the compass.
***REMOVED***@State
***REMOVED***private var opacity: Double

***REMOVED******REMOVED***/ Acts as link between the compass and the parent map or scene view.
***REMOVED***@Binding
***REMOVED***private var viewpoint: Viewpoint?

***REMOVED******REMOVED***/ Creates a `Compass`
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - viewpoint: Acts a communication link between the `MapView` or `SceneView` and the
***REMOVED******REMOVED***/   compass.
***REMOVED******REMOVED***/   - autoHide: Determines if the compass automatically hides itself when the `MapView` or
***REMOVED******REMOVED***/   `SceneView` is oriented north.
***REMOVED***public init(
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>,
***REMOVED******REMOVED***autoHide: Bool = true
***REMOVED***) {
***REMOVED******REMOVED***_viewpoint = viewpoint
***REMOVED******REMOVED***_opacity = State(initialValue: .zero)
***REMOVED******REMOVED***self.autoHide = autoHide
***REMOVED***

***REMOVED***public var body: some View {
***REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***CompassBody()
***REMOVED******REMOVED******REMOVED******REMOVED***Needle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotationEffect(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Angle(degrees: viewpoint?.adjustedRotation ?? .zero)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED***width: min(geometry.size.width, geometry.size.height),
***REMOVED******REMOVED******REMOVED******REMOVED***height: min(geometry.size.width, geometry.size.height)
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***.opacity(opacity)
***REMOVED******REMOVED***.onTapGesture { resetHeading() ***REMOVED***
***REMOVED******REMOVED***.onChange(of: viewpoint) { _ in
***REMOVED******REMOVED******REMOVED***let newOpacity: Double = isHidden ? .zero : 1
***REMOVED******REMOVED******REMOVED***guard opacity != newOpacity else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***withAnimation(.default.delay(isHidden ? 0.25 : 0)) {
***REMOVED******REMOVED******REMOVED******REMOVED***opacity = newOpacity
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onAppear { opacity = isHidden ? 0 : 1 ***REMOVED***
***REMOVED******REMOVED***.accessibilityLabel(viewpoint?.compassHeadingDescription ?? "Compass")
***REMOVED***

***REMOVED******REMOVED***/ Resets the viewpoints `rotation` to zero.
***REMOVED***func resetHeading() {
***REMOVED******REMOVED***guard let viewpoint = viewpoint else { return ***REMOVED***
***REMOVED******REMOVED***self.viewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: viewpoint.targetGeometry.extent.center,
***REMOVED******REMOVED******REMOVED***scale: viewpoint.targetScale,
***REMOVED******REMOVED******REMOVED***rotation: .zero
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

internal extension Viewpoint {
***REMOVED******REMOVED***/ The viewpoint's `rotation` adjusted to offset any rotation applied to the parent view.
***REMOVED***var adjustedRotation: Double {
***REMOVED******REMOVED***rotation.isZero ? .zero : 360 - rotation
***REMOVED***

***REMOVED******REMOVED***/ A text description of the current heading, sutiable for accessibility voiceover.
***REMOVED***var compassHeadingDescription: String {
***REMOVED******REMOVED***"Compass, heading "
***REMOVED******REMOVED***+ Int(self.adjustedRotation.rounded()).description
***REMOVED******REMOVED***+ " degrees "
***REMOVED******REMOVED***+ CompassDirection(self.adjustedRotation).rawValue
***REMOVED***
***REMOVED***
