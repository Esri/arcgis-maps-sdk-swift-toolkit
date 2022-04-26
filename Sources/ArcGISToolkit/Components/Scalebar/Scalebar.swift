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
***REMOVED******REMOVED***/ The view model used by the `Scalebar`.
***REMOVED***@StateObject var viewModel: ScalebarViewModel
***REMOVED***
***REMOVED******REMOVED***/ The font used by the scalebar, available in both `Font` and `UIFont` types.
***REMOVED***internal static var font: (font: Font, uiFont: UIFont) {
***REMOVED******REMOVED***let size = 10.0
***REMOVED******REMOVED***let uiFont = UIFont.systemFont(
***REMOVED******REMOVED******REMOVED***ofSize: size,
***REMOVED******REMOVED******REMOVED***weight: .semibold
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let font = Font(uiFont as CTFont)
***REMOVED******REMOVED***return (font, uiFont)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The rendering height of the scalebar font.
***REMOVED***internal static var fontHeight: Double {
***REMOVED******REMOVED***return "".size(withAttributes: [.font: Scalebar.font.uiFont]).height
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var viewpoint: Binding<Viewpoint?>
***REMOVED***
***REMOVED******REMOVED*** - MARK: Internal/Private constants
***REMOVED***
***REMOVED******REMOVED***/ The corner radius used by bar style scalebar renders.
***REMOVED***internal static let barCornerRadius = 2.5
***REMOVED***
***REMOVED******REMOVED***/ The frame height allotted to bar style scalebar renders.
***REMOVED***internal static let barFrameHeight = 10.0
***REMOVED***
***REMOVED******REMOVED***/ The darker fill color used by the alternating bar style render.
***REMOVED***internal static let fillColor1 = Color.black
***REMOVED***
***REMOVED******REMOVED***/ The lighter fill color used by the bar style renders.
***REMOVED***internal static let fillColor2 = Color(uiColor: .lightGray).opacity(0.5)
***REMOVED***
***REMOVED******REMOVED***/ The spacing between labels and the scalebar.
***REMOVED***internal static let labelYPad: CGFloat = 2.0
***REMOVED***
***REMOVED******REMOVED***/ The required padding between scalebar labels.
***REMOVED***internal static let labelXPad: CGFloat = 4.0
***REMOVED***
***REMOVED******REMOVED***/ The color of the prominent scalebar line.
***REMOVED***internal static let lineColor = Color.white
***REMOVED***
***REMOVED******REMOVED***/ The line height alloted to line style scalebar renders.
***REMOVED***internal static let lineFrameHeight = 6.0
***REMOVED***
***REMOVED******REMOVED***/ The width of the prominent scalebar line.
***REMOVED***internal static let lineWidth = 3.0
***REMOVED***
***REMOVED******REMOVED***/ The shadow color used by all scalebar style renders.
***REMOVED***internal static let shadowColor = Color(uiColor: .black).opacity(0.65)
***REMOVED***
***REMOVED******REMOVED***/ The shadow radius used by all scalebar style renders.
***REMOVED***internal static let shadowRadius = 1.0
***REMOVED***
***REMOVED******REMOVED***/ The text shadow color used by all scalebar style renders.
***REMOVED***internal static let textShadowColor = Color.white
***REMOVED***
***REMOVED******REMOVED***/ The render style for this `Scalebar`.
***REMOVED***private let style: ScalebarStyle
***REMOVED***
***REMOVED******REMOVED*** - MARK: Public methods/vars
***REMOVED***
***REMOVED******REMOVED***/ A scalebar displays the current map scale.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - autoHide: Set this to `true` to have the scalebar automatically show & hide itself.
***REMOVED******REMOVED***/   - minScale: Set a minScale if you only want the scalebar to appear when you reach a large
***REMOVED******REMOVED***/***REMOVED*** enough scale maybe something like 10_000_000. This could be useful because the scalebar is
***REMOVED******REMOVED***/***REMOVED*** really only accurate for the center of the map on smaller scales (when zoomed way out). A
***REMOVED******REMOVED***/***REMOVED*** minScale of 0 means it will always be visible.
***REMOVED******REMOVED***/   - spatialReference: The map's spatial reference.
***REMOVED******REMOVED***/   - style: The visual appearance of the scalebar.
***REMOVED******REMOVED***/   - units: The units to be displayed in the scalebar.
***REMOVED******REMOVED***/   - unitsPerPoint: The current number of device independent pixels to map display units.
***REMOVED******REMOVED***/   - useGeodeticCalculations: Set `false` to compute scale without a geodesic curve.
***REMOVED******REMOVED***/   - viewpoint: The map's current viewpoint.
***REMOVED******REMOVED***/   - width: The screen width alloted to the scalebar.
***REMOVED***public init(
***REMOVED******REMOVED***autoHide: Bool = false,
***REMOVED******REMOVED***minScale: Double = .zero,
***REMOVED******REMOVED***spatialReference: SpatialReference? = nil,
***REMOVED******REMOVED***style: ScalebarStyle = .alternatingBar,
***REMOVED******REMOVED***units: ScalebarUnits = NSLocale.current.usesMetricSystem ? .metric : .imperial,
***REMOVED******REMOVED***unitsPerPoint: Binding<Double?>,
***REMOVED******REMOVED***useGeodeticCalculations: Bool = true,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>,
***REMOVED******REMOVED***width: Double
***REMOVED***) {
***REMOVED******REMOVED***self.style = style
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***
***REMOVED******REMOVED***_viewModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: ScalebarViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED***autoHide,
***REMOVED******REMOVED******REMOVED******REMOVED***minScale,
***REMOVED******REMOVED******REMOVED******REMOVED***spatialReference,
***REMOVED******REMOVED******REMOVED******REMOVED***style,
***REMOVED******REMOVED******REMOVED******REMOVED***width,
***REMOVED******REMOVED******REMOVED******REMOVED***units,
***REMOVED******REMOVED******REMOVED******REMOVED***unitsPerPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***useGeodeticCalculations,
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint.wrappedValue
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if $viewModel.isVisible.wrappedValue {
***REMOVED******REMOVED******REMOVED******REMOVED***switch style {
***REMOVED******REMOVED******REMOVED******REMOVED***case .alternatingBar:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alternatingBarStyleRender
***REMOVED******REMOVED******REMOVED******REMOVED***case .bar:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***barStyleRender
***REMOVED******REMOVED******REMOVED******REMOVED***case .dualUnitLine:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dualUnitLineStyleRender
***REMOVED******REMOVED******REMOVED******REMOVED***case .graduatedLine:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graduatedLineStyleRender
***REMOVED******REMOVED******REMOVED******REMOVED***case .line:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lineStyleRender
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: viewpoint.wrappedValue) {
***REMOVED******REMOVED******REMOVED***viewModel.viewpointSubject.send($0)
***REMOVED***
***REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED***height = $0.height
***REMOVED***
***REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED***width: $viewModel.displayLength.wrappedValue,
***REMOVED******REMOVED******REMOVED***height: height ?? .zero
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
