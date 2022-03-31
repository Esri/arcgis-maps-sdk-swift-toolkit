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
import Combine
import Foundation
***REMOVED***

@MainActor
final class ScalebarViewModel: ObservableObject {
***REMOVED***@Published var displayLength: CGFloat = .zero
***REMOVED***
***REMOVED***@Published var displayLengthString = ""
***REMOVED***
***REMOVED***@Published var displayUnit: LinearUnit? = nil
***REMOVED***
***REMOVED***var visibleAreaSubject = PassthroughSubject<Polygon?, Never>()
***REMOVED***
***REMOVED***private var visibleAreaCancellable: AnyCancellable?
***REMOVED***
***REMOVED******REMOVED***/ The amount of time to wait between value calculations.
***REMOVED***private var delay = DispatchQueue.SchedulerTimeType.Stride.seconds(0.05)
***REMOVED***
***REMOVED***private var spatialReference: SpatialReference? = .wgs84
***REMOVED***
***REMOVED***private var targetWidth: Double
***REMOVED***
***REMOVED***private var unitsPerPoint: Binding<Double?>
***REMOVED***
***REMOVED******REMOVED***/ Allows a user to toggle geodetic calculations.
***REMOVED***private var useGeodeticCalculations: Bool
***REMOVED***
***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var viewpoint: Binding<Viewpoint?>
***REMOVED***
***REMOVED******REMOVED***/ Acts as a data provider of the current scale.
***REMOVED***private var visibleArea: Binding<Polygon?>
***REMOVED***
***REMOVED******REMOVED***/ Unit of measure in use.
***REMOVED***private var units: ScalebarUnits
***REMOVED***
***REMOVED***private var geodeticCurveType: GeometryEngine.GeodeticCurveType = .geodesic
***REMOVED***
***REMOVED******REMOVED***/ Set a minScale if you only want the scalebar to appear when you reach a large enough scale maybe
***REMOVED******REMOVED***/  something like 10_000_000. This could be useful because the scalebar is really only accurate for
***REMOVED******REMOVED***/  the center of the map on smaller scales (when zoomed way out). A minScale of 0 means it will
***REMOVED******REMOVED***/  always be visible
***REMOVED***private let minScale: Double = 0
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***_ spatialReference: SpatialReference? = .wgs84,
***REMOVED******REMOVED***_ targetWidth: Double,
***REMOVED******REMOVED***_ units: ScalebarUnits = NSLocale.current.usesMetricSystem ? .metric : .imperial,
***REMOVED******REMOVED***_ unitsPerPoint: Binding<Double?>,
***REMOVED******REMOVED***_ useGeodeticCalculations: Bool = true,
***REMOVED******REMOVED***_ viewpoint: Binding<Viewpoint?>,
***REMOVED******REMOVED***_ visibleArea: Binding<Polygon?>
***REMOVED******REMOVED***
***REMOVED***) {
***REMOVED******REMOVED***self.spatialReference = spatialReference
***REMOVED******REMOVED***self.targetWidth = targetWidth
***REMOVED******REMOVED***self.units = units
***REMOVED******REMOVED***self.unitsPerPoint = unitsPerPoint
***REMOVED******REMOVED***self.useGeodeticCalculations = useGeodeticCalculations
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***self.visibleArea = visibleArea
***REMOVED******REMOVED***
***REMOVED******REMOVED***visibleAreaCancellable = visibleAreaSubject
***REMOVED******REMOVED******REMOVED***.debounce(for: delay, scheduler: DispatchQueue.main)
***REMOVED******REMOVED******REMOVED***.sink(receiveValue: { [weak self] _ in
***REMOVED******REMOVED******REMOVED******REMOVED***self?.updateScaleDisplay()
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***updateScaleDisplay()
***REMOVED***
***REMOVED***
***REMOVED***private func updateScaleDisplay() {
***REMOVED******REMOVED***guard let scale = viewpoint.wrappedValue?.targetScale else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***guard minScale <= 0 || scale < minScale else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***guard let unitsPerPoint = unitsPerPoint.wrappedValue else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***guard let visibleArea = visibleArea.wrappedValue else {
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
***REMOVED******REMOVED***let displayLength: CGFloat
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
***REMOVED******REMOVED******REMOVED***displayLength = CGFloat( (roundNumberDistance * planarToGeodeticFactor) / unitsPerPoint )
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
***REMOVED******REMOVED******REMOVED***displayLength = CGFloat(
***REMOVED******REMOVED******REMOVED******REMOVED***baseUnits.convert(to: srUnit, value: closestLen) / unitsPerPoint)
***REMOVED******REMOVED******REMOVED***displayUnit = units.linearUnitsForDistance(distance: closestLen)
***REMOVED******REMOVED******REMOVED***lineMapLength = baseUnits.convert(
***REMOVED******REMOVED******REMOVED******REMOVED***to: displayUnit,
***REMOVED******REMOVED******REMOVED******REMOVED***value: closestLen
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard displayLength.isFinite, !displayLength.isNaN else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.displayLength = displayLength
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.displayUnit = displayUnit
***REMOVED******REMOVED***
***REMOVED******REMOVED***displayLengthString = Scalebar.numberFormatter.string(from: NSNumber(value: lineMapLength)) ?? ""
***REMOVED***
***REMOVED***
