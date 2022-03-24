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
***REMOVED***@State private var displayLength: CGFloat = .zero
***REMOVED***
***REMOVED******REMOVED***/ The vertical amount of space used by the scalebar.
***REMOVED***@State private var height: Double = 50
***REMOVED***
***REMOVED***@available(*, deprecated)
***REMOVED***@State private var extentWidth: CGFloat = .zero
***REMOVED***
***REMOVED***@State private var mapLengthString: String = "none"
***REMOVED***
***REMOVED***private var alignment: ScalebarAlignment
***REMOVED***
***REMOVED***private var alternateFillColor = Color.black
***REMOVED***
***REMOVED***private var fillColor = Color(uiColor: .lightGray).opacity(0.5)
***REMOVED***
***REMOVED***private var font: Font
***REMOVED***
***REMOVED***private var geodeticCurveType: GeometryEngine.GeodeticCurveType = .geodesic
***REMOVED***
***REMOVED***private var lineColor = Color.white
***REMOVED***
***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var scale: Double?
***REMOVED***
***REMOVED***private var shadowColor = Color(uiColor: .black).opacity(0.65)
***REMOVED***
***REMOVED***private var spatialReference: SpatialReference?
***REMOVED***
***REMOVED***private var style: ScalebarStyle
***REMOVED***
***REMOVED***private var targetWidth: Double
***REMOVED***
***REMOVED***private var textColor = Color.black
***REMOVED***
***REMOVED***private var textShadowColor = Color.white
***REMOVED***
***REMOVED******REMOVED***/ Unit of measure in use.
***REMOVED***private var units: ScalebarUnits
***REMOVED***
***REMOVED***private var unitsPerPoint: Double {
***REMOVED******REMOVED***(visibleArea?.extent.width ?? .zero) / extentWidth
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Allows a user to toggle geodetic calculations.
***REMOVED***private var useGeodeticCalculations: Bool
***REMOVED***
***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var visibleArea: Polygon?
***REMOVED***
***REMOVED***public init(
***REMOVED******REMOVED***_ scale: Double?,
***REMOVED******REMOVED***_ spatialReference: SpatialReference? = .wgs84,
***REMOVED******REMOVED***_ targetWidth: Double,
***REMOVED******REMOVED***_ viewpoint: Viewpoint?,
***REMOVED******REMOVED***_ visibleArea: Polygon?,
***REMOVED******REMOVED***
***REMOVED******REMOVED***alignment: ScalebarAlignment = .left,
***REMOVED******REMOVED***font: Font = .system(size: 9.0, weight: .semibold),
***REMOVED******REMOVED***style: ScalebarStyle = .line,
***REMOVED******REMOVED***units: ScalebarUnits = NSLocale.current.usesMetricSystem ? .metric : .imperial,
***REMOVED******REMOVED***useGeodeticCalculations: Bool = true
***REMOVED***) {
***REMOVED******REMOVED***self.scale = scale
***REMOVED******REMOVED***self.targetWidth = targetWidth
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***self.visibleArea = visibleArea
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.alignment = alignment
***REMOVED******REMOVED***self.font = font
***REMOVED******REMOVED***self.spatialReference = spatialReference
***REMOVED******REMOVED***self.style = style
***REMOVED******REMOVED***self.units = units
***REMOVED******REMOVED***self.useGeodeticCalculations = useGeodeticCalculations
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***GeometryReader { geometryProxy in
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fill(.gray)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.border(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.white,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 1.5
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: displayLength,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height: 7,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .leading
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: Color(uiColor: .lightGray),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: 1
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***Text(mapLengthString)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: scale) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***updateScaleDisplay()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: geometryProxy.size) {
***REMOVED******REMOVED******REMOVED******REMOVED***extentWidth = $0.width
***REMOVED******REMOVED******REMOVED******REMOVED***updateScaleDisplay()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***extentWidth = geometryProxy.size.width
***REMOVED******REMOVED******REMOVED******REMOVED***updateScaleDisplay()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED***height = $0.height
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.frame(height: height)
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
***REMOVED***private func updateScaleDisplay() {
***REMOVED******REMOVED***guard let scale = scale else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***guard minScale <= 0 || scale < minScale else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***guard let visibleArea = visibleArea else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***guard let sr = spatialReference else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***let totalWidthAvailable = targetWidth
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** TODO: - Removal of hardcoded sample renderer property (~16 - 2) derived from sample renderer
***REMOVED******REMOVED***let maxLength =  totalWidthAvailable - 16.30243742465973 - 2
***REMOVED******REMOVED***
***REMOVED******REMOVED***let lineMapLength: Double
***REMOVED******REMOVED***let displayUnit: LinearUnit
***REMOVED******REMOVED***let mapCenter = visibleArea.extent.center
***REMOVED******REMOVED***let lineDisplayLength: CGFloat
***REMOVED******REMOVED***
***REMOVED******REMOVED***if useGeodeticCalculations || spatialReference?.unit is AngularUnit {
***REMOVED******REMOVED******REMOVED***let maxLengthPlanar = unitsPerPoint * Double(maxLength)
***REMOVED******REMOVED******REMOVED***let p1 = Point(
***REMOVED******REMOVED******REMOVED******REMOVED***x: mapCenter.x - (maxLengthPlanar * 0.5),
***REMOVED******REMOVED******REMOVED******REMOVED***y: mapCenter.y,
***REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: sr
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let p2 = Point(
***REMOVED******REMOVED******REMOVED******REMOVED***x: mapCenter.x + (maxLengthPlanar * 0.5),
***REMOVED******REMOVED******REMOVED******REMOVED***y: mapCenter.y,
***REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: sr
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let polyline = Polyline(
***REMOVED******REMOVED******REMOVED******REMOVED***points: [p1, p2], spatialReference: spatialReference
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let baseUnits = units.baseUnits()
***REMOVED******REMOVED******REMOVED***let maxLengthGeodetic = GeometryEngine.geodeticLength(
***REMOVED******REMOVED******REMOVED******REMOVED***of: polyline,
***REMOVED******REMOVED******REMOVED******REMOVED***lengthUnit: baseUnits,
***REMOVED******REMOVED******REMOVED******REMOVED***curveType: geodeticCurveType
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let roundNumberDistance = units.closestDistanceWithoutGoingOver(
***REMOVED******REMOVED******REMOVED******REMOVED***to: maxLengthGeodetic,
***REMOVED******REMOVED******REMOVED******REMOVED***units: baseUnits
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let planarToGeodeticFactor = maxLengthPlanar / maxLengthGeodetic
***REMOVED******REMOVED******REMOVED***lineDisplayLength = CGFloat( (roundNumberDistance * planarToGeodeticFactor) / unitsPerPoint )
***REMOVED******REMOVED******REMOVED***displayUnit = units.linearUnitsForDistance(distance: roundNumberDistance)
***REMOVED******REMOVED******REMOVED***lineMapLength = baseUnits.convert(to: displayUnit, value: roundNumberDistance)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***guard let srUnit = sr.unit as? LinearUnit else {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let unitsPerPoint = unitsPerPoint
***REMOVED******REMOVED******REMOVED***let baseUnits = units.baseUnits()
***REMOVED******REMOVED******REMOVED***let lenAvail = srUnit.convert(
***REMOVED******REMOVED******REMOVED******REMOVED***to: baseUnits,
***REMOVED******REMOVED******REMOVED******REMOVED***value: unitsPerPoint * Double(maxLength)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let closestLen = units.closestDistanceWithoutGoingOver(
***REMOVED******REMOVED******REMOVED******REMOVED***to: lenAvail,
***REMOVED******REMOVED******REMOVED******REMOVED***units: baseUnits
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***lineDisplayLength = CGFloat(
***REMOVED******REMOVED******REMOVED******REMOVED***baseUnits.convert(to: srUnit, value: closestLen) / unitsPerPoint)
***REMOVED******REMOVED******REMOVED***displayUnit = units.linearUnitsForDistance(distance: closestLen)
***REMOVED******REMOVED******REMOVED***lineMapLength = baseUnits.convert(
***REMOVED******REMOVED******REMOVED******REMOVED***to: displayUnit,
***REMOVED******REMOVED******REMOVED******REMOVED***value: closestLen
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard lineDisplayLength.isFinite, !lineDisplayLength.isNaN else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***displayLength = lineDisplayLength
***REMOVED******REMOVED***
***REMOVED******REMOVED***mapLengthString = Scalebar.numberFormatter.string(from: NSNumber(value: lineMapLength)) ?? ""
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
