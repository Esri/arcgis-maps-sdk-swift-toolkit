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
***REMOVED******REMOVED***/ The view model used by the `Scalebar`.
***REMOVED***@StateObject
***REMOVED***internal var viewModel: ScalebarViewModel
***REMOVED***
***REMOVED******REMOVED***/ The vertical amount of space used by the scalebar.
***REMOVED***@State private var height: Double = 50
***REMOVED***
***REMOVED***@State internal var finalLengthWidth: Double = .zero
***REMOVED***
***REMOVED***private var alignment: ScalebarAlignment
***REMOVED***
***REMOVED***private var alternateFillColor = Color.black
***REMOVED***
***REMOVED***internal var fillColor = Color(uiColor: .lightGray).opacity(0.5)
***REMOVED***
***REMOVED***internal var shadowColor = Color(uiColor: .black).opacity(0.65)
***REMOVED***
***REMOVED***internal var font: Font
***REMOVED***
***REMOVED***private var style: ScalebarStyle
***REMOVED***
***REMOVED***private var textColor = Color.black
***REMOVED***
***REMOVED***private var textShadowColor = Color.white
***REMOVED***
***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var viewpoint: Binding<Viewpoint?>
***REMOVED***
***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var visibleArea: Binding<Polygon?>
***REMOVED***
***REMOVED***public init(
***REMOVED******REMOVED***alignment: ScalebarAlignment = .left,
***REMOVED******REMOVED***_ spatialReference: SpatialReference? = .wgs84,
***REMOVED******REMOVED***_ style: ScalebarStyle = .alternatingBar,
***REMOVED******REMOVED***_ targetWidth: Double,
***REMOVED******REMOVED***_ unitsPerPoint: Binding<Double?>,
***REMOVED******REMOVED***_ viewpoint: Binding<Viewpoint?>,
***REMOVED******REMOVED***_ visibleArea: Binding<Polygon?>,
***REMOVED******REMOVED***
***REMOVED******REMOVED***font: Font = .system(size: 10.0, weight: .semibold),
***REMOVED******REMOVED***
***REMOVED******REMOVED***units: ScalebarUnits = NSLocale.current.usesMetricSystem ? .metric : .imperial,
***REMOVED******REMOVED***useGeodeticCalculations: Bool = true
***REMOVED***) {
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***self.visibleArea = visibleArea
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.alignment = alignment
***REMOVED******REMOVED***self.font = font
***REMOVED******REMOVED***self.style = style
***REMOVED******REMOVED***
***REMOVED******REMOVED***_viewModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: ScalebarViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED***spatialReference,
***REMOVED******REMOVED******REMOVED******REMOVED***targetWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***units,
***REMOVED******REMOVED******REMOVED******REMOVED***unitsPerPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***useGeodeticCalculations,
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED***visibleArea
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch style {
***REMOVED******REMOVED******REMOVED***case .line:
***REMOVED******REMOVED******REMOVED******REMOVED***lineStyleRender
***REMOVED******REMOVED******REMOVED***case .bar:
***REMOVED******REMOVED******REMOVED******REMOVED***barStyleRender
***REMOVED******REMOVED******REMOVED***case .graduatedLine:
***REMOVED******REMOVED******REMOVED******REMOVED***#warning(".graduatedLine not yet implemented")
***REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED***case .alternatingBar:
***REMOVED******REMOVED******REMOVED******REMOVED***#warning(".alternatingBar not yet implemented")
***REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED***case .dualUnitLine:
***REMOVED******REMOVED******REMOVED******REMOVED***#warning(".dualUnitLine not yet implemented")
***REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: visibleArea.wrappedValue) {
***REMOVED******REMOVED******REMOVED***viewModel.visibleAreaSubject.send($0)
***REMOVED***
***REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED***height = $0.height
***REMOVED***
***REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED***width: $viewModel.displayLength.wrappedValue,
***REMOVED******REMOVED******REMOVED***height: height
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***internal static let labelYPad: CGFloat = 2.0
***REMOVED***internal static let labelXPad: CGFloat = 4.0
***REMOVED***internal static let tickHeight: CGFloat = 6.0
***REMOVED***internal static let tick2Height: CGFloat = 4.5
***REMOVED***internal static let notchHeight: CGFloat = 6.0
***REMOVED***internal static var numberFormatter: NumberFormatter = {
***REMOVED******REMOVED***let numberFormatter = NumberFormatter()
***REMOVED******REMOVED***numberFormatter.numberStyle = .decimal
***REMOVED******REMOVED***numberFormatter.formatterBehavior = .behavior10_4
***REMOVED******REMOVED***numberFormatter.maximumFractionDigits = 2
***REMOVED******REMOVED***numberFormatter.minimumFractionDigits = 0
***REMOVED******REMOVED***return numberFormatter
***REMOVED***()
***REMOVED***
***REMOVED***internal static let lineCap = CGLineCap.round
***REMOVED***
***REMOVED***internal var fontHeight: CGFloat = 0
***REMOVED***internal var zeroStringWidth: CGFloat = 0
***REMOVED***internal var maxRightUnitsPad: CGFloat = 0
***REMOVED***
***REMOVED******REMOVED***/ Set a minScale if you only want the scalebar to appear when you reach a large enough scale maybe
***REMOVED******REMOVED***/  something like 10_000_000. This could be useful because the scalebar is really only accurate for
***REMOVED******REMOVED***/  the center of the map on smaller scales (when zoomed way out). A minScale of 0 means it will
***REMOVED******REMOVED***/  always be visible
***REMOVED***private let minScale: Double = 0
***REMOVED***
