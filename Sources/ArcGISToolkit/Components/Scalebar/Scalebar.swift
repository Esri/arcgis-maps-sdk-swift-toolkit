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

***REMOVED***/ Displays the current scale on-screen
public struct Scalebar: View {
***REMOVED******REMOVED*** - MARK: Internal/Private vars
***REMOVED***
***REMOVED******REMOVED***/ The vertical amount of space used by the scalebar.
***REMOVED***@State private var height: Double?
***REMOVED***
***REMOVED******REMOVED***/ Controls the current opacity of the scalebar.
***REMOVED***@State var opacity: Double
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the `Scalebar`.
***REMOVED***@StateObject var viewModel: ScalebarViewModel
***REMOVED***
***REMOVED******REMOVED***/ The font used by the scalebar, available in both `Font` and `UIFont` types.
***REMOVED***static var font: (font: Font, uiFont: UIFont) {
***REMOVED******REMOVED***let size = 9.0
***REMOVED******REMOVED***let uiFont = UIFont.systemFont(
***REMOVED******REMOVED******REMOVED***ofSize: size,
***REMOVED******REMOVED******REMOVED***weight: .semibold
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let font = Font(uiFont as CTFont)
***REMOVED******REMOVED***return (font, uiFont)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The rendering height of the scalebar font.
***REMOVED***static var fontHeight: Double {
***REMOVED******REMOVED***return "".size(withAttributes: [.font: Scalebar.font.uiFont]).height
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The spatial reference to calculate the scale with.
***REMOVED***private var spatialReference: SpatialReference?
***REMOVED***
***REMOVED******REMOVED***/ The units per point to calculate the scale with.
***REMOVED***private var unitsPerPoint: Double?
***REMOVED***
***REMOVED******REMOVED***/ The viewpoint to calculate the scale with.
***REMOVED***private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED******REMOVED*** - MARK: Internal/Private constants
***REMOVED***
***REMOVED******REMOVED***/ The frame height allotted to bar style scalebar renders.
***REMOVED***static let barFrameHeight = 10.0
***REMOVED***
***REMOVED******REMOVED***/ The spacing between labels and the scalebar.
***REMOVED***static let labelYPad: CGFloat = 2.0
***REMOVED***
***REMOVED******REMOVED***/ The required padding between scalebar labels.
***REMOVED***static let labelXPad: CGFloat = 4.0
***REMOVED***
***REMOVED******REMOVED***/ The line height allotted to line style scalebar renders.
***REMOVED***static let lineFrameHeight = 6.0
***REMOVED***
***REMOVED******REMOVED***/ The width of the prominent scalebar line.
***REMOVED***static let lineWidth: Double = 2.0
***REMOVED***
***REMOVED******REMOVED***/ Appearance settings.
***REMOVED***let settings: ScalebarSettings
***REMOVED***
***REMOVED******REMOVED***/ The render style for this `Scalebar`.
***REMOVED***private let style: ScalebarStyle
***REMOVED***
***REMOVED******REMOVED*** - MARK: Public methods/vars
***REMOVED***
***REMOVED******REMOVED***/ A scalebar displays the current map scale.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - maxWidth: The maximum screen width allotted to the scalebar.
***REMOVED******REMOVED***/   - minScale: Set a minScale if you only want the scalebar to appear when you reach a large
***REMOVED******REMOVED***/***REMOVED*** enough scale maybe something like 10_000_000. This could be useful because the scalebar is
***REMOVED******REMOVED***/***REMOVED*** really only accurate for the center of the map on smaller scales (when zoomed way out). A
***REMOVED******REMOVED***/***REMOVED*** minScale of 0 means it will always be visible.
***REMOVED******REMOVED***/   - settings: Appearance settings.
***REMOVED******REMOVED***/   - spatialReference: The map's spatial reference.
***REMOVED******REMOVED***/   - style: The visual appearance of the scalebar.
***REMOVED******REMOVED***/   - units: The units to be displayed in the scalebar.
***REMOVED******REMOVED***/   - unitsPerPoint: The current number of device independent pixels to map display units.
***REMOVED******REMOVED***/   - useGeodeticCalculations: Set `false` to compute scale without a geodesic curve.
***REMOVED******REMOVED***/   - viewpoint: The map's current viewpoint.
***REMOVED***public init(
***REMOVED******REMOVED***maxWidth: Double,
***REMOVED******REMOVED***minScale: Double = .zero,
***REMOVED******REMOVED***settings: ScalebarSettings = ScalebarSettings(),
***REMOVED******REMOVED***spatialReference: SpatialReference?,
***REMOVED******REMOVED***style: ScalebarStyle = .alternatingBar,
***REMOVED******REMOVED***units: ScalebarUnits = NSLocale.current.usesMetricSystem ? .metric : .imperial,
***REMOVED******REMOVED***unitsPerPoint: Double?,
***REMOVED******REMOVED***useGeodeticCalculations: Bool = true,
***REMOVED******REMOVED***viewpoint: Viewpoint?
***REMOVED***) {
***REMOVED******REMOVED***_opacity = State(initialValue: settings.autoHide ? .zero : 1)
***REMOVED******REMOVED***self.settings = settings
***REMOVED******REMOVED***self.spatialReference = spatialReference
***REMOVED******REMOVED***self.style = style
***REMOVED******REMOVED***self.unitsPerPoint = unitsPerPoint
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***
***REMOVED******REMOVED***_viewModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: ScalebarViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED***maxWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***minScale,
***REMOVED******REMOVED******REMOVED******REMOVED***style,
***REMOVED******REMOVED******REMOVED******REMOVED***units,
***REMOVED******REMOVED******REMOVED******REMOVED***useGeodeticCalculations
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch style {
***REMOVED******REMOVED******REMOVED***case .alternatingBar:
***REMOVED******REMOVED******REMOVED******REMOVED***alternatingBarStyleRenderer
***REMOVED******REMOVED******REMOVED***case .bar:
***REMOVED******REMOVED******REMOVED******REMOVED***barStyleRenderer
***REMOVED******REMOVED******REMOVED***case .dualUnitLine:
***REMOVED******REMOVED******REMOVED******REMOVED***dualUnitLineStyleRenderer
***REMOVED******REMOVED******REMOVED***case .graduatedLine:
***REMOVED******REMOVED******REMOVED******REMOVED***graduatedLineStyleRenderer
***REMOVED******REMOVED******REMOVED***case .line:
***REMOVED******REMOVED******REMOVED******REMOVED***lineStyleRenderer
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.opacity(opacity)
***REMOVED******REMOVED***.onChange(of: spatialReference) { viewModel.update($0) ***REMOVED***
***REMOVED******REMOVED***.onChange(of: unitsPerPoint) { viewModel.update($0) ***REMOVED***
***REMOVED******REMOVED***.onChange(of: viewpoint) {
***REMOVED******REMOVED******REMOVED***viewModel.update($0)
***REMOVED******REMOVED******REMOVED***viewModel.updateScale()
***REMOVED******REMOVED******REMOVED***if settings.autoHide {
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***opacity = 1
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation(.default.delay(settings.autoHideDelay)) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***opacity = .zero
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED***height = $0.height
***REMOVED***
***REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED***width: $viewModel.displayLength.wrappedValue,
***REMOVED******REMOVED******REMOVED***height: height ?? .zero
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.environment(\.scalebarSettings, settings)
***REMOVED***
***REMOVED***
