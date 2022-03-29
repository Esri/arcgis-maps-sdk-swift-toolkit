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
***REMOVED***private var viewModel: ScalebarViewModel
***REMOVED***
***REMOVED******REMOVED***/ The vertical amount of space used by the scalebar.
***REMOVED***@State private var height: Double = 50
***REMOVED***
***REMOVED***@State private var finalLengthWidth: Double = .zero
***REMOVED***
***REMOVED***private var alignment: ScalebarAlignment
***REMOVED***
***REMOVED***private var alternateFillColor = Color.black
***REMOVED***
***REMOVED***private var fillColor = Color(uiColor: .lightGray).opacity(0.5)
***REMOVED***
***REMOVED***private var font: Font
***REMOVED***
***REMOVED***private var lineColor = Color.white
***REMOVED***
***REMOVED***private var shadowColor = Color(uiColor: .black).opacity(0.65)
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
***REMOVED******REMOVED******REMOVED***if style == .alternatingBar {
***REMOVED******REMOVED******REMOVED******REMOVED***alternatingBarView
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***barView
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: visibleArea.wrappedValue) {
***REMOVED******REMOVED******REMOVED***viewModel.subject.send($0)
***REMOVED***
***REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED***height = $0.height
***REMOVED***
***REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED***width: $viewModel.displayLength.wrappedValue,
***REMOVED******REMOVED******REMOVED***height: height
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.border(.red)
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

extension Scalebar {
***REMOVED***var alternatingBarView: some View {
***REMOVED******REMOVED***VStack(spacing: 2) {
***REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED***.fill(.gray)
***REMOVED******REMOVED******REMOVED******REMOVED***.border(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.white,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 1.5
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: $viewModel.displayLength.wrappedValue,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height: 7,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .leading
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: Color(uiColor: .lightGray),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: 1
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("0")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(font)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.semibold)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED***Text("\($viewModel.mapLengthString.wrappedValue) \($viewModel.displayUnit.wrappedValue?.abbreviation ?? "")")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(font)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.semibold)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***finalLengthWidth = $0.width
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .trailing)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.offset(x: finalLengthWidth / 2)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var barView: some View {
***REMOVED******REMOVED***VStack(spacing: 2) {
***REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED***.fill(.gray)
***REMOVED******REMOVED******REMOVED******REMOVED***.border(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.white,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 1.5
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: $viewModel.displayLength.wrappedValue,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height: 7,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .leading
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: Color(uiColor: .lightGray),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: 1
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("\($viewModel.mapLengthString.wrappedValue) \($viewModel.displayUnit.wrappedValue?.abbreviation ?? "")")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(font)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.semibold)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***finalLengthWidth = $0.width
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***


***REMOVED*** - TODO: Temporary as another PR in-flight contains this extension.
extension View {
***REMOVED******REMOVED***/ Returns a new `View` that allows a parent `View` to be informed of a child view's size.
***REMOVED******REMOVED***/ - Parameter perform: The closure to be executed when the content size of the receiver
***REMOVED******REMOVED***/ changes.
***REMOVED******REMOVED***/ - Returns: A new `View`.
***REMOVED***func onSizeChange(perform: @escaping (CGSize) -> Void) -> some View {
***REMOVED******REMOVED***background(
***REMOVED******REMOVED******REMOVED***GeometryReader { geometry in
***REMOVED******REMOVED******REMOVED******REMOVED***Color.clear
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.preference(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***key: SizePreferenceKey.self, value: geometry.size
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.onPreferenceChange(SizePreferenceKey.self, perform: perform)
***REMOVED***

***REMOVED***

***REMOVED*** - TODO: Temporary as another PR in-flight contains this extension.
***REMOVED***/ A `PreferenceKey` that specifies a size.
struct SizePreferenceKey: PreferenceKey {
***REMOVED***static let defaultValue: CGSize = .zero
***REMOVED***static func reduce(value: inout CGSize, nextValue: () -> CGSize) {***REMOVED***
***REMOVED***
