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
***REMOVED***private var alignment: ScalebarAlignment

***REMOVED***private var alternateFillColor = Color.black

***REMOVED***@State
***REMOVED***private var displayLength: CGFloat = .zero

***REMOVED***@State
***REMOVED***private var extentWidth: CGFloat = .zero

***REMOVED***private var fillColor = Color(uiColor: .lightGray).opacity(0.5)

***REMOVED***private var font: Font

***REMOVED***private var geodeticCurveType: GeometryEngine.GeodeticCurveType = .geodesic

***REMOVED***private var lineColor = Color.white

***REMOVED***@State
***REMOVED***private var mapLengthString: String = "none"

***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var scale: Double?

***REMOVED***private var shadowColor = Color(uiColor: .black).opacity(0.65)

***REMOVED***private var spatialReference: SpatialReference?

***REMOVED***private var style: ScalebarStyle

***REMOVED***private var targetWidth: Double

***REMOVED***private var textColor = Color.black

***REMOVED***private var textShadowColor = Color.white

***REMOVED******REMOVED***/ Unit of measure for the scalebar.
***REMOVED***private var units: ScalebarUnits

***REMOVED***private var unitsPerPoint: Double {
***REMOVED******REMOVED***(visibleArea?.extent.width ?? .zero) / extentWidth
***REMOVED***

***REMOVED******REMOVED***/ Allows a user to toggle geodetic calculations.
***REMOVED***private var useGeodeticCalculations: Bool

***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var viewpoint: Viewpoint?

***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var visibleArea: Polygon?

***REMOVED***public init(
***REMOVED******REMOVED***_ scale: Double?,
***REMOVED******REMOVED***_ spatialReference: SpatialReference? = .wgs84,
***REMOVED******REMOVED***_ targetWidth: Double,
***REMOVED******REMOVED***_ viewpoint: Viewpoint?,
***REMOVED******REMOVED***_ visibleArea: Polygon?,

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

***REMOVED******REMOVED***self.alignment = alignment
***REMOVED******REMOVED***self.font = font
***REMOVED******REMOVED***self.spatialReference = spatialReference
***REMOVED******REMOVED***self.style = style
***REMOVED******REMOVED***self.units = units
***REMOVED******REMOVED***self.useGeodeticCalculations = useGeodeticCalculations
***REMOVED***

***REMOVED***public var body: some View {
***REMOVED******REMOVED***GeometryReader { geometryProxy in
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fill(.white)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.border(.red)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: displayLength, height: 5, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateScaleDisplay(forceRedraw: false)
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Force Update")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Text(mapLengthString)

***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onChange(of: scale, perform: { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED***updateScaleDisplay(forceRedraw: false)
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onChange(of: geometryProxy.size) {
***REMOVED******REMOVED******REMOVED******REMOVED***extentWidth = $0.width
***REMOVED******REMOVED******REMOVED******REMOVED***updateScaleDisplay(forceRedraw: false)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***extentWidth = geometryProxy.size.width
***REMOVED******REMOVED******REMOVED******REMOVED***updateScaleDisplay(forceRedraw: false)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.frame(height: 100, alignment: .bottomLeading)
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

***REMOVED***internal static let lineCap = CGLineCap.round

***REMOVED***internal var fontHeight: CGFloat = 0
***REMOVED***internal var zeroStringWidth: CGFloat = 0
***REMOVED***internal var maxRightUnitsPad: CGFloat = 0

***REMOVED******REMOVED***/ Set a minScale if you only want the scalebar to appear when you reach a large enough scale maybe
***REMOVED******REMOVED***/  something like 10_000_000. This could be useful because the scalebar is really only accurate for
***REMOVED******REMOVED***/  the center of the map on smaller scales (when zoomed way out). A minScale of 0 means it will
***REMOVED******REMOVED***/  always be visible
***REMOVED***private let minScale: Double = 0

***REMOVED***private func updateScaleDisplay(forceRedraw: Bool) {
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

***REMOVED******REMOVED******REMOVED*** TODO: - Removal of hardcoded sample renderer property (~16 - 2) derived from sample renderer
***REMOVED******REMOVED***let maxLength =  totalWidthAvailable - 16.30243742465973 - 2

***REMOVED******REMOVED***let lineMapLength: Double
***REMOVED******REMOVED***let displayUnit: LinearUnit
***REMOVED******REMOVED***let mapCenter = visibleArea.extent.center
***REMOVED******REMOVED***let lineDisplayLength: CGFloat

***REMOVED******REMOVED***if useGeodeticCalculations || spatialReference?.unit is AngularUnit {
***REMOVED******REMOVED******REMOVED***let maxLengthPlanar = unitsPerPoint * Double(maxLength)
***REMOVED******REMOVED******REMOVED***let p1 = Point(x: mapCenter.x - (maxLengthPlanar * 0.5), y: mapCenter.y, spatialReference: sr)
***REMOVED******REMOVED******REMOVED***let p2 = Point(x: mapCenter.x + (maxLengthPlanar * 0.5), y: mapCenter.y, spatialReference: sr)
***REMOVED******REMOVED******REMOVED***let polyline = Polyline(points: [p1, p2], spatialReference: spatialReference)
***REMOVED******REMOVED******REMOVED***let baseUnits = units.baseUnits()
***REMOVED******REMOVED******REMOVED***let maxLengthGeodetic = GeometryEngine.lengthGeodetic(geometry: polyline, lengthUnit: baseUnits, curveType: geodeticCurveType)
***REMOVED******REMOVED******REMOVED***let roundNumberDistance = units.closestDistanceWithoutGoingOver(to: maxLengthGeodetic, units: baseUnits)
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
***REMOVED******REMOVED******REMOVED***let lenAvail = srUnit.convert(to: baseUnits, value: unitsPerPoint * Double(maxLength))
***REMOVED******REMOVED******REMOVED***let closestLen = units.closestDistanceWithoutGoingOver(to: lenAvail, units: baseUnits)
***REMOVED******REMOVED******REMOVED***lineDisplayLength = CGFloat(baseUnits.convert(to: srUnit, value: closestLen) / unitsPerPoint)
***REMOVED******REMOVED******REMOVED***displayUnit = units.linearUnitsForDistance(distance: closestLen)
***REMOVED******REMOVED******REMOVED***lineMapLength = baseUnits.convert(to: displayUnit, value: closestLen)
***REMOVED***

***REMOVED******REMOVED***guard lineDisplayLength.isFinite, !lineDisplayLength.isNaN else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***

***REMOVED******REMOVED***displayLength = lineDisplayLength

***REMOVED******REMOVED***mapLengthString = Scalebar.numberFormatter.string(from: NSNumber(value: lineMapLength)) ?? ""
***REMOVED***
***REMOVED***
