***REMOVED*** Copyright 2022 Esri
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

***REMOVED***
***REMOVED***

***REMOVED***/ A `Compass` (alias North arrow) shows where north is in a `MapView` or `SceneView`.
***REMOVED***/
***REMOVED***/ ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202810369-a0b82778-77d4-404e-bebf-1a84841fbb1b.png)
***REMOVED***/ - Automatically hides when the rotation is zero.
***REMOVED***/ - Can be configured to be always visible.
***REMOVED***/ - Will reset the map/scene rotation to North when tapped on.
***REMOVED***/
***REMOVED***/ Whenever the map is not orientated North (non-zero bearing) the compass appears. When reset to
***REMOVED***/ north, it disappears. The `automaticallyHides` view modifier allows you to disable the auto-hide
***REMOVED***/ feature so that it is always displayed.
***REMOVED***/ When the compass is tapped, the map orients back to north (zero bearing).
***REMOVED***/
***REMOVED***/ To see it in action, try out the [Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
***REMOVED***/ and refer to [CompassExampleView.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/CompassExampleView.swift)
***REMOVED***/ in the project. To learn more about using the `Compass` see the <doc:CompassTutorial>.
public struct Compass: View {
***REMOVED******REMOVED***/ The opacity of the compass.
***REMOVED***@State private var opacity: Double = .zero
***REMOVED***
***REMOVED******REMOVED***/ An action to perform when the compass is tapped.
***REMOVED***private var action: (() -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the compass should automatically
***REMOVED******REMOVED***/ hide/show itself when the heading is `0`.
***REMOVED***private var autoHide: Bool = true
***REMOVED***
***REMOVED******REMOVED***/ The heading of the compass in degrees.
***REMOVED***private var heading: Double
***REMOVED***
***REMOVED******REMOVED***/ The proxy to provide access to map view operations.
***REMOVED***private var mapViewProxy: MapViewProxy?
***REMOVED***
***REMOVED******REMOVED***/ The width and height of the compass.
***REMOVED***private var size: CGFloat = 44
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether sensory feedback is enabled
***REMOVED******REMOVED***/ when the heading snaps to zero.
***REMOVED***private var snapToZeroSensoryFeedbackEnabled: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ Creates a compass with a heading based on compass directions (0° indicates a direction
***REMOVED******REMOVED***/ toward true North, 90° indicates a direction toward true East, etc.).
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - rotation: The rotation whose value determines the heading of the compass.
***REMOVED******REMOVED***/   - mapViewProxy: The proxy to provide access to map view operations.
***REMOVED******REMOVED***/   - action: The action to perform when the compass is tapped.
***REMOVED***init(
***REMOVED******REMOVED***rotation: Double?,
***REMOVED******REMOVED***mapViewProxy: MapViewProxy?,
***REMOVED******REMOVED***action: (() -> Void)?
***REMOVED***) {
***REMOVED******REMOVED***let heading: Double
***REMOVED******REMOVED***if let rotation {
***REMOVED******REMOVED******REMOVED***heading = rotation.isZero ? .zero : 360 - rotation
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***heading = .nan
***REMOVED***
***REMOVED******REMOVED***self.heading = heading
***REMOVED******REMOVED***self.mapViewProxy = mapViewProxy
***REMOVED******REMOVED***self.action = action
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
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: size, height: size)
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear { opacity = shouldHide(forHeading: heading) ? 0 : 1 ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onChange(heading) { newHeading in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let newOpacity: Double = shouldHide(forHeading: newHeading) ? .zero : 1
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard opacity != newOpacity else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation(.default.delay(shouldHide(forHeading: newHeading) ? 0.25 : 0)) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***opacity = newOpacity
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let mapViewProxy {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task { await mapViewProxy.setViewpointRotation(0) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** else if let action {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityLabel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***localized: "Compass, heading \(Int(heading.rounded())) degrees \(CompassDirection(heading).rawValue)",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** An compass description to be read by a screen reader describing the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** current heading. The first variable being a degree value and the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** second being a corresponding cardinal direction (north, northeast,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** east, etc.).
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.snapToZeroSensoryFeedback(enabled: snapToZeroSensoryFeedbackEnabled, heading: heading)
#if os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED***.hoverEffect()
***REMOVED******REMOVED******REMOVED******REMOVED***.hoverEffect { effect, isActive, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***effect.scaleEffect(isActive ? 1.05 : 1.0)
***REMOVED******REMOVED******REMOVED***
#endif
***REMOVED***
***REMOVED***
***REMOVED***

private extension View {
***REMOVED******REMOVED***/ Enables the snap to zero sensory feedback
***REMOVED******REMOVED***/ when it is available.
***REMOVED***@available(visionOS, unavailable)
***REMOVED***@ViewBuilder
***REMOVED***func snapToZeroSensoryFeedback(enabled: Bool, heading: Double) -> some View {
***REMOVED******REMOVED***if #available(iOS 17.0, *) {
***REMOVED******REMOVED******REMOVED***if enabled {
***REMOVED******REMOVED******REMOVED******REMOVED***sensoryFeedback(.selection, trigger: heading) { oldValue, newValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if (!oldValue.isZero && newValue.isZero) ||
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***(oldValue.isZero && !newValue.isZero) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***self
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED*** Fallback on earlier versions
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***

extension Compass {
***REMOVED******REMOVED***/ Returns a Boolean value indicating whether the compass should hide based on the
***REMOVED******REMOVED***/ provided heading and whether the compass has been configured to automatically hide.
***REMOVED******REMOVED***/ - Parameter heading: The heading used to determine if the compass should hide.
***REMOVED******REMOVED***/ - Returns: `true` if the compass should hide, `false` otherwise.
***REMOVED***func shouldHide(forHeading heading: Double) -> Bool {
***REMOVED******REMOVED***(heading.isZero || heading.isNaN) && autoHide
***REMOVED***
***REMOVED***

public extension Compass {
***REMOVED******REMOVED***/ Creates a compass with a rotation (0° indicates a direction toward true North, 90° indicates
***REMOVED******REMOVED***/ a direction toward true West, etc.).
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - rotation: The rotation whose value determines the heading of the compass.
***REMOVED******REMOVED***/   - mapViewProxy: The proxy to provide access to map view operations.
***REMOVED***init(
***REMOVED******REMOVED***rotation: Double?,
***REMOVED******REMOVED***mapViewProxy: MapViewProxy
***REMOVED***) {
***REMOVED******REMOVED***self.init(rotation: rotation, mapViewProxy: mapViewProxy, action: nil)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a compass with a rotation (0° indicates a direction toward true North, 90° indicates
***REMOVED******REMOVED***/ a direction toward true West, etc.).
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - rotation: The rotation whose value determines the heading of the compass.
***REMOVED******REMOVED***/   - action: The action to perform when the compass is tapped.
***REMOVED***init(
***REMOVED******REMOVED***rotation: Double?,
***REMOVED******REMOVED***action: @escaping () -> Void
***REMOVED***) {
***REMOVED******REMOVED***self.init(rotation: rotation, mapViewProxy: nil, action: action)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Define a custom size for the compass.
***REMOVED******REMOVED***/ - Parameter size: The width and height of the compass.
***REMOVED***func compassSize(size: CGFloat) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.size = size
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Specifies whether the ``Compass`` should automatically hide when the heading is 0.
***REMOVED******REMOVED***/ - Parameter disable: A Boolean value indicating whether the compass should automatically
***REMOVED******REMOVED***/ hide/show itself when the heading is `0`.
***REMOVED***func autoHideDisabled(_ disable: Bool = true) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.autoHide = !disable
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Enables sensory feedback when the heading snaps to `zero`.
***REMOVED***@available(iOS 17, *)
***REMOVED***func snapToZeroSensoryFeedback() -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.snapToZeroSensoryFeedbackEnabled = true
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

#Preview("Compass") {
***REMOVED***Compass(rotation: .zero) { ***REMOVED***
***REMOVED******REMOVED***.autoHideDisabled()
***REMOVED******REMOVED***.compassSize(size: 100)
***REMOVED***

#Preview("Compass - Right To Left") {
***REMOVED***Compass(rotation: .zero) { ***REMOVED***
***REMOVED******REMOVED***.autoHideDisabled()
***REMOVED******REMOVED***.compassSize(size: 100)
***REMOVED******REMOVED***.environment(\.layoutDirection, .rightToLeft)
***REMOVED***
