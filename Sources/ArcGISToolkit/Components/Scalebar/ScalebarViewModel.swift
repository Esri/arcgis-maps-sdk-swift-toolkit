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
import Combine
import Foundation

@MainActor
@available(visionOS, unavailable)
final class ScalebarViewModel: ObservableObject {
***REMOVED******REMOVED*** - MARK: Published vars
***REMOVED***
***REMOVED******REMOVED***/ The computed display length of the scalebar.
***REMOVED***@Published var displayLength: CGFloat = .zero
***REMOVED***
***REMOVED******REMOVED***/ The current set of labels to be displayed by the scalebar.
***REMOVED***@Published var labels = [ScalebarLabel]()
***REMOVED***
***REMOVED******REMOVED*** - MARK: Public vars
***REMOVED***
***REMOVED******REMOVED***/ A screen length and displayable localized string for the equivalent length in the alternate unit.
***REMOVED***var alternateUnit: (screenLength: CGFloat, label: String) {
***REMOVED******REMOVED***guard let displayUnit = displayUnit else {
***REMOVED******REMOVED******REMOVED***return (.zero, "")
***REMOVED***
***REMOVED******REMOVED***let altUnit: ScalebarUnits = units == .imperial ? .metric : .imperial
***REMOVED******REMOVED***let altMapBaseLength = displayUnit.convert(
***REMOVED******REMOVED******REMOVED***to: altUnit.baseLinearUnit,
***REMOVED******REMOVED******REMOVED***value: lineMapLength
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let altClosestBaseLength = altUnit.closestDistanceWithoutGoingOver(
***REMOVED******REMOVED******REMOVED***to: altMapBaseLength,
***REMOVED******REMOVED******REMOVED***units: altUnit.baseLinearUnit
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let altDisplayUnits = altUnit.linearUnits(
***REMOVED******REMOVED******REMOVED***forDistance: altClosestBaseLength
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let altMapLength = altUnit.baseLinearUnit.convert(
***REMOVED******REMOVED******REMOVED***to: altDisplayUnits, value: altClosestBaseLength
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let displayFactor = lineMapLength / displayLength
***REMOVED******REMOVED***let convertedDisplayFactor = displayUnit.convert(
***REMOVED******REMOVED******REMOVED***to: altDisplayUnits,
***REMOVED******REMOVED******REMOVED***value: displayFactor
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let altScreenLength = altMapLength / convertedDisplayFactor
***REMOVED******REMOVED***
***REMOVED******REMOVED***let measurement = Measurement(value: altMapLength, linearUnit: altDisplayUnits)
***REMOVED******REMOVED***let label = measurement.formatted(.scaleMeasurement)
***REMOVED******REMOVED***
***REMOVED******REMOVED***return (altScreenLength, label)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** - MARK: Public methods
***REMOVED***
***REMOVED******REMOVED***/ A scalebar view model controls the underlying data used to render a scalebar.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - maxWidth: The maximum screen width allotted to the scalebar.
***REMOVED******REMOVED***/   - minScale: A value of 0 indicates the scalebar segments should always recalculate.
***REMOVED******REMOVED***/   - style: The visual appearance of the scalebar.
***REMOVED******REMOVED***/   - units: The units to be displayed in the scalebar.
***REMOVED******REMOVED***/   - useGeodeticCalculations: Determines if a geodesic curve should be used to compute
***REMOVED******REMOVED***/***REMOVED*** the scale.
***REMOVED***init(
***REMOVED******REMOVED***_ maxWidth: Double,
***REMOVED******REMOVED***_ minScale: Double,
***REMOVED******REMOVED***_ style: ScalebarStyle,
***REMOVED******REMOVED***_ units: ScalebarUnits,
***REMOVED******REMOVED***_ useGeodeticCalculations: Bool
***REMOVED***) {
***REMOVED******REMOVED***self.maxWidth = maxWidth
***REMOVED******REMOVED***self.minScale = minScale
***REMOVED******REMOVED***self.style = style
***REMOVED******REMOVED***self.units = units
***REMOVED******REMOVED***self.useGeodeticCalculations = useGeodeticCalculations
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** - MARK: Private constants
***REMOVED***
***REMOVED******REMOVED***/ The curve type to use when performing scale calculations.
***REMOVED***private let geodeticCurveType: GeometryEngine.GeodeticCurveType = .geodesic
***REMOVED***
***REMOVED******REMOVED***/ A `minScale` of 0 means the scalebar segments will always recalculate.
***REMOVED***private let minScale: Double
***REMOVED***
***REMOVED******REMOVED***/ The visual appearance of the scalebar.
***REMOVED***private let style: ScalebarStyle
***REMOVED***
***REMOVED******REMOVED*** - MARK: Private variables
***REMOVED***
***REMOVED******REMOVED***/ Determines the amount of display space to use based on the scalebar style.
***REMOVED***private var availableLineDisplayLength: CGFloat {
***REMOVED******REMOVED***switch style {
***REMOVED******REMOVED***case .alternatingBar, .dualUnitLine, .graduatedLine:
***REMOVED******REMOVED******REMOVED******REMOVED*** " km" will render wider than " mi"
***REMOVED******REMOVED******REMOVED***let maxUnitDisplayWidth = " km".size(withAttributes: [.font: Scalebar.font.uiFont]).width
***REMOVED******REMOVED******REMOVED***return maxWidth - (Scalebar.lineWidth / 2.0) - maxUnitDisplayWidth
***REMOVED******REMOVED***case .bar, .line:
***REMOVED******REMOVED******REMOVED***return maxWidth - Scalebar.lineWidth
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The units to be displayed in the scalebar.
***REMOVED***private var displayUnit: LinearUnit? = nil
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether an initial scale has been calculated.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ The scale requires 3 values (spatial reference, units per point and a viewpoint) to be
***REMOVED******REMOVED***/ calculated. As these values are initially received in a non-deterministic order, this allows
***REMOVED******REMOVED***/ a calculation to be attempted upon initial receipt of each of the 3 values.
***REMOVED***private var initialScaleWasCalculated = false
***REMOVED***
***REMOVED******REMOVED***/ The length of the line to display in map units.
***REMOVED***private var lineMapLength: Double = .zero
***REMOVED***
***REMOVED******REMOVED***/ The maximum screen width allotted to the scalebar.
***REMOVED***private var maxWidth: Double
***REMOVED***
***REMOVED******REMOVED***/ The spatial reference to calculate the scale with.
***REMOVED***private var spatialReference: SpatialReference?
***REMOVED***
***REMOVED******REMOVED***/ Unit of measure in use.
***REMOVED***private var units: ScalebarUnits
***REMOVED***
***REMOVED******REMOVED***/ The units per point to calculate the scale with.
***REMOVED***private var unitsPerPoint: Double?
***REMOVED***
***REMOVED******REMOVED***/ Allows a user to toggle geodetic calculations.
***REMOVED***private var useGeodeticCalculations: Bool
***REMOVED***
***REMOVED******REMOVED***/ The viewpoint to calculate the scale with.
***REMOVED***private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED******REMOVED*** - MARK: Methods
***REMOVED***
***REMOVED******REMOVED***/ Updates the labels to be displayed by the scalebar.
***REMOVED***private func updateLabels() {
***REMOVED******REMOVED***let lineDisplayLength = displayLength
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Use a string with at least a few characters in case the number string
***REMOVED******REMOVED******REMOVED*** only has 1. The dividers will be decimal values and we want to make
***REMOVED******REMOVED******REMOVED*** sure they all fit very basic heuristics.
***REMOVED******REMOVED***let minSegmentTestString: String
***REMOVED******REMOVED***if lineMapLength >= 100 {
***REMOVED******REMOVED******REMOVED***minSegmentTestString = String(Int(lineMapLength))
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***minSegmentTestString = "9.9"
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Multiply by 1.5 to accommodate the units in the last label
***REMOVED******REMOVED***let minSegmentWidth =
***REMOVED******REMOVED******REMOVED***minSegmentTestString.size(withAttributes: [.font: Scalebar.font.uiFont]).width * 1.5
***REMOVED******REMOVED******REMOVED***+
***REMOVED******REMOVED******REMOVED***Scalebar.labelXPad * 2
***REMOVED******REMOVED***
***REMOVED******REMOVED***let suggestedNumSegments = Int(lineDisplayLength / minSegmentWidth)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Cap segments at 4
***REMOVED******REMOVED***let maxNumSegments = min(suggestedNumSegments, 4)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let numSegments: Int = ScalebarUnits.numSegments(
***REMOVED******REMOVED******REMOVED***forDistance: lineMapLength,
***REMOVED******REMOVED******REMOVED***maxNumSegments: maxNumSegments
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let segmentScreenLength = CGFloat(lineDisplayLength / CGFloat(numSegments))
***REMOVED******REMOVED***var currSegmentX: CGFloat = 0
***REMOVED******REMOVED***var labels = [ScalebarLabel]()
***REMOVED******REMOVED***
***REMOVED******REMOVED***labels.append(
***REMOVED******REMOVED******REMOVED***ScalebarLabel(
***REMOVED******REMOVED******REMOVED******REMOVED***index: -1,
***REMOVED******REMOVED******REMOVED******REMOVED***xOffset: .zero,
***REMOVED******REMOVED******REMOVED******REMOVED***text: NumberFormatter.localizedString(from: 0, number: .decimal)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***for index in 0..<numSegments {
***REMOVED******REMOVED******REMOVED***currSegmentX += segmentScreenLength
***REMOVED******REMOVED******REMOVED***let segmentMapLength = Double((segmentScreenLength * CGFloat(index + 1)) / lineDisplayLength) * lineMapLength
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let segmentText: String
***REMOVED******REMOVED******REMOVED***if index == numSegments - 1, let displayUnit {
***REMOVED******REMOVED******REMOVED******REMOVED***let measurement = Measurement(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***value: segmentMapLength,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***linearUnit: displayUnit
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***segmentText = measurement.formatted(.scaleMeasurement)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***segmentText = segmentMapLength.formatted(.number)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let label = ScalebarLabel(
***REMOVED******REMOVED******REMOVED******REMOVED***index: index,
***REMOVED******REMOVED******REMOVED******REMOVED***xOffset: currSegmentX,
***REMOVED******REMOVED******REMOVED******REMOVED***text: segmentText
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***labels.append(label)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if style == .bar || style == .line, let last = labels.last {
***REMOVED******REMOVED******REMOVED***self.labels = [last]
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self.labels = labels
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Update the stored spatial reference value for use in the next scale calculation.
***REMOVED******REMOVED***/ - Parameter spatialReference: The spatial reference to calculate the scale with.
***REMOVED***func update(_ spatialReference: SpatialReference?) {
***REMOVED******REMOVED***self.spatialReference = spatialReference
***REMOVED******REMOVED***if !initialScaleWasCalculated { updateScale() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the stored units per point value for use in the next scale calculation.
***REMOVED******REMOVED***/ - Parameter unitsPerPoint: The units per point to calculate the scale with.
***REMOVED***func update(_ unitsPerPoint: Double?) {
***REMOVED******REMOVED***self.unitsPerPoint = unitsPerPoint
***REMOVED******REMOVED***if !initialScaleWasCalculated { updateScale() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the stored units viewpoint value for use in the next scale calculation.
***REMOVED******REMOVED***/ - Parameter viewpoint: The viewpoint to calculate the scale with.
***REMOVED***func update(_ viewpoint: Viewpoint?) {
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***if !initialScaleWasCalculated { updateScale() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Update the information necessary to render a scalebar based off the stored viewpoint, units
***REMOVED******REMOVED***/ per point and spatial reference values.
***REMOVED***func updateScale() {
***REMOVED******REMOVED***guard let spatialReference, let unitsPerPoint, let viewpoint,
***REMOVED******REMOVED******REMOVED***  minScale <= 0 || viewpoint.targetScale < minScale,
***REMOVED******REMOVED******REMOVED***  !unitsPerPoint.isNaN
***REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let mapCenter = viewpoint.targetGeometry.extent.center
***REMOVED******REMOVED***
***REMOVED******REMOVED***let maxLength = availableLineDisplayLength
***REMOVED******REMOVED***
***REMOVED******REMOVED***let lineMapLength: Double
***REMOVED******REMOVED***let displayUnit: LinearUnit
***REMOVED******REMOVED***let displayLength: CGFloat
***REMOVED******REMOVED***
***REMOVED******REMOVED***if useGeodeticCalculations || spatialReference.unit is AngularUnit {
***REMOVED******REMOVED******REMOVED***let maxLengthPlanar = unitsPerPoint * Double(maxLength)
***REMOVED******REMOVED******REMOVED***let p1 = Point(
***REMOVED******REMOVED******REMOVED******REMOVED***x: mapCenter.x - (maxLengthPlanar * 0.5),
***REMOVED******REMOVED******REMOVED******REMOVED***y: mapCenter.y,
***REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: spatialReference
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let p2 = Point(
***REMOVED******REMOVED******REMOVED******REMOVED***x: mapCenter.x + (maxLengthPlanar * 0.5),
***REMOVED******REMOVED******REMOVED******REMOVED***y: mapCenter.y,
***REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: spatialReference
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let polyline = Polyline(
***REMOVED******REMOVED******REMOVED******REMOVED***points: [p1, p2],
***REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: spatialReference
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let baseUnits = units.baseLinearUnit
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
***REMOVED******REMOVED******REMOVED***displayUnit = units.linearUnits(forDistance: roundNumberDistance)
***REMOVED******REMOVED******REMOVED***lineMapLength = baseUnits.convert(to: displayUnit, value: roundNumberDistance)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***guard let srUnit = spatialReference.unit as? LinearUnit else {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let unitsPerPoint = unitsPerPoint
***REMOVED******REMOVED******REMOVED***let baseUnits = units.baseLinearUnit
***REMOVED******REMOVED******REMOVED***let lenAvail = srUnit.convert(
***REMOVED******REMOVED******REMOVED******REMOVED***to: baseUnits,
***REMOVED******REMOVED******REMOVED******REMOVED***value: unitsPerPoint * Double(maxLength)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let closestLen = units.closestDistanceWithoutGoingOver(
***REMOVED******REMOVED******REMOVED******REMOVED***to: lenAvail,
***REMOVED******REMOVED******REMOVED******REMOVED***units: baseUnits
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***displayLength = CGFloat(
***REMOVED******REMOVED******REMOVED******REMOVED***baseUnits.convert(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***to: srUnit,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***value: closestLen
***REMOVED******REMOVED******REMOVED******REMOVED***) / unitsPerPoint
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***displayUnit = units.linearUnits(forDistance: closestLen)
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
***REMOVED******REMOVED***self.displayUnit = displayUnit
***REMOVED******REMOVED***self.lineMapLength = lineMapLength
***REMOVED******REMOVED***
***REMOVED******REMOVED***initialScaleWasCalculated = true
***REMOVED******REMOVED***
***REMOVED******REMOVED***updateLabels()
***REMOVED***
***REMOVED***

private extension Measurement where UnitType == UnitLength {
***REMOVED***init(value: Double, linearUnit: LinearUnit) {
***REMOVED******REMOVED***self.init(value: value, unit: .fromLinearUnit(linearUnit))
***REMOVED***
***REMOVED***

private extension FormatStyle where Self == Measurement<UnitLength>.FormatStyle {
***REMOVED***static var scaleMeasurement: Self {
***REMOVED******REMOVED***.measurement(width: .abbreviated, usage: .asProvided)
***REMOVED***
***REMOVED***
