// Copyright 2022 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import Combine
import Foundation

@MainActor
final class ScalebarViewModel: ObservableObject {
    // - MARK: Published vars
    
    /// The computed display length of the scalebar.
    @Published var displayLength: CGFloat = .zero
    
    /// The current set of labels to be displayed by the scalebar.
    @Published var labels = [ScalebarLabel]()
    
    // - MARK: Public vars
    
    /// A screen length and displayable localized string for the equivalent length in the alternate unit.
    var alternateUnit: (screenLength: CGFloat, label: String) {
        guard let displayUnit = displayUnit else {
            return (.zero, "")
        }
        let altUnit: ScalebarUnits = units == .imperial ? .metric : .imperial
        let altMapBaseLength = displayUnit.convert(
            to: altUnit.baseLinearUnit,
            value: lineMapLength
        )
        let altClosestBaseLength = altUnit.closestDistanceWithoutGoingOver(
            to: altMapBaseLength,
            units: altUnit.baseLinearUnit
        )
        let altDisplayUnits = altUnit.linearUnits(
            forDistance: altClosestBaseLength
        )
        let altMapLength = altUnit.baseLinearUnit.convert(
            to: altDisplayUnits, value: altClosestBaseLength
        )
        let displayFactor = lineMapLength / displayLength
        let convertedDisplayFactor = displayUnit.convert(
            to: altDisplayUnits,
            value: displayFactor
        )
        let altScreenLength = altMapLength / convertedDisplayFactor
        
        let measurement = Measurement(value: altMapLength, linearUnit: altDisplayUnits)
        let label = measurement.formatted(.scaleMeasurement)
        
        return (altScreenLength, label)
    }
    
    // - MARK: Public methods
    
    /// A scalebar view model controls the underlying data used to render a scalebar.
    /// - Parameters:
    ///   - maxWidth: The maximum screen width allotted to the scalebar.
    ///   - minScale: A value of 0 indicates the scalebar segments should always recalculate.
    ///   - style: The visual appearance of the scalebar.
    ///   - units: The units to be displayed in the scalebar.
    ///   - useGeodeticCalculations: Determines if a geodesic curve should be used to compute
    ///     the scale.
    init(
        _ maxWidth: Double,
        _ minScale: Double,
        _ style: ScalebarStyle,
        _ units: ScalebarUnits,
        _ useGeodeticCalculations: Bool
    ) {
        self.maxWidth = maxWidth
        self.minScale = minScale
        self.style = style
        self.units = units
        self.useGeodeticCalculations = useGeodeticCalculations
    }
    
    // - MARK: Private constants
    
    /// The curve type to use when performing scale calculations.
    private let geodeticCurveType: GeometryEngine.GeodeticCurveType = .geodesic
    
    /// A `minScale` of 0 means the scalebar segments will always recalculate.
    private let minScale: Double
    
    /// The visual appearance of the scalebar.
    private let style: ScalebarStyle
    
    // - MARK: Private variables
    
    /// Determines the amount of display space to use based on the scalebar style.
    private var availableLineDisplayLength: CGFloat {
        switch style {
        case .alternatingBar, .dualUnitLine, .graduatedLine:
            // " km" will render wider than " mi"
            let maxUnitDisplayWidth = " km".size(withAttributes: [.font: Scalebar.font.uiFont]).width
            return maxWidth - (Scalebar.lineWidth / 2.0) - maxUnitDisplayWidth
        case .bar, .line:
            return maxWidth - Scalebar.lineWidth
        }
    }
    
    /// The units to be displayed in the scalebar.
    private var displayUnit: LinearUnit? = nil
    
    /// A Boolean value indicating whether an initial scale has been calculated.
    ///
    /// The scale requires 3 values (spatial reference, units per point and a viewpoint) to be
    /// calculated. As these values are initially received in a non-deterministic order, this allows
    /// a calculation to be attempted upon initial receipt of each of the 3 values.
    private var initialScaleWasCalculated = false
    
    /// The length of the line to display in map units.
    private var lineMapLength: Double = .zero
    
    /// The maximum screen width allotted to the scalebar.
    private var maxWidth: Double
    
    /// The spatial reference to calculate the scale with.
    private var spatialReference: SpatialReference?
    
    /// Unit of measure in use.
    private var units: ScalebarUnits
    
    /// The units per point to calculate the scale with.
    private var unitsPerPoint: Double?
    
    /// Allows a user to toggle geodetic calculations.
    private var useGeodeticCalculations: Bool
    
    /// The viewpoint to calculate the scale with.
    private var viewpoint: Viewpoint?
    
    // - MARK: Methods
    
    /// Updates the labels to be displayed by the scalebar.
    private func updateLabels() {
        let lineDisplayLength = displayLength
        
        // Use a string with at least a few characters in case the number string
        // only has 1. The dividers will be decimal values and we want to make
        // sure they all fit very basic heuristics.
        let minSegmentTestString: String
        if lineMapLength >= 100 {
            minSegmentTestString = String(Int(lineMapLength))
        } else {
            minSegmentTestString = "9.9"
        }
        
        // Multiply by 1.5 to accommodate the units in the last label
        let minSegmentWidth =
            minSegmentTestString.size(withAttributes: [.font: Scalebar.font.uiFont]).width * 1.5
            +
            Scalebar.labelXPad * 2
        
        let suggestedNumSegments = Int(lineDisplayLength / minSegmentWidth)
        
        // Cap segments at 4
        let maxNumSegments = min(suggestedNumSegments, 4)
        
        let numSegments: Int = ScalebarUnits.numSegments(
            forDistance: lineMapLength,
            maxNumSegments: maxNumSegments
        )
        
        let segmentScreenLength = CGFloat(lineDisplayLength / CGFloat(numSegments))
        var currSegmentX: CGFloat = 0
        var labels = [ScalebarLabel]()
        
        labels.append(
            ScalebarLabel(
                index: -1,
                xOffset: .zero,
                text: NumberFormatter.localizedString(from: 0, number: .decimal)
            )
        )
        
        for index in 0..<numSegments {
            currSegmentX += segmentScreenLength
            let segmentMapLength = Double((segmentScreenLength * CGFloat(index + 1)) / lineDisplayLength) * lineMapLength
            
            let segmentText: String
            if index == numSegments - 1, let displayUnit {
                let measurement = Measurement(
                    value: segmentMapLength,
                    linearUnit: displayUnit
                )
                segmentText = measurement.formatted(.scaleMeasurement)
            } else {
                segmentText = segmentMapLength.formatted(.number)
            }
            
            let label = ScalebarLabel(
                index: index,
                xOffset: currSegmentX,
                text: segmentText
            )
            labels.append(label)
        }
        
        if style == .bar || style == .line, let last = labels.last {
            self.labels = [last]
        } else {
            self.labels = labels
        }
    }
    
    /// Update the stored spatial reference value for use in the next scale calculation.
    /// - Parameter spatialReference: The spatial reference to calculate the scale with.
    func update(_ spatialReference: SpatialReference?) {
        self.spatialReference = spatialReference
        if !initialScaleWasCalculated { updateScale() }
    }
    
    /// Updates the stored units per point value for use in the next scale calculation.
    /// - Parameter unitsPerPoint: The units per point to calculate the scale with.
    func update(_ unitsPerPoint: Double?) {
        self.unitsPerPoint = unitsPerPoint
        if !initialScaleWasCalculated { updateScale() }
    }
    
    /// Updates the stored units viewpoint value for use in the next scale calculation.
    /// - Parameter viewpoint: The viewpoint to calculate the scale with.
    func update(_ viewpoint: Viewpoint?) {
        self.viewpoint = viewpoint
        if !initialScaleWasCalculated { updateScale() }
    }
    
    /// Update the information necessary to render a scalebar based off the stored viewpoint, units
    /// per point and spatial reference values.
    func updateScale() {
        guard let spatialReference, let unitsPerPoint, let viewpoint,
              minScale <= 0 || viewpoint.targetScale < minScale,
              !unitsPerPoint.isNaN
        else {
            return
        }
        
        let mapCenter = viewpoint.targetGeometry.extent.center
        
        let maxLength = availableLineDisplayLength
        
        let lineMapLength: Double
        let displayUnit: LinearUnit
        let displayLength: CGFloat
        
        if useGeodeticCalculations || spatialReference.unit is AngularUnit {
            let maxLengthPlanar = unitsPerPoint * Double(maxLength)
            let p1 = Point(
                x: mapCenter.x - (maxLengthPlanar * 0.5),
                y: mapCenter.y,
                spatialReference: spatialReference
            )
            let p2 = Point(
                x: mapCenter.x + (maxLengthPlanar * 0.5),
                y: mapCenter.y,
                spatialReference: spatialReference
            )
            let polyline = Polyline(
                points: [p1, p2],
                spatialReference: spatialReference
            )
            let baseUnits = units.baseLinearUnit
            let maxLengthGeodetic = GeometryEngine.geodeticLength(
                of: polyline,
                lengthUnit: baseUnits,
                curveType: geodeticCurveType
            )
            let roundNumberDistance = units.closestDistanceWithoutGoingOver(
                to: maxLengthGeodetic,
                units: baseUnits
            )
            let planarToGeodeticFactor = maxLengthPlanar / maxLengthGeodetic
            displayLength = CGFloat( (roundNumberDistance * planarToGeodeticFactor) / unitsPerPoint )
            displayUnit = units.linearUnits(forDistance: roundNumberDistance)
            lineMapLength = baseUnits.convert(to: displayUnit, value: roundNumberDistance)
        } else {
            guard let srUnit = spatialReference.unit as? LinearUnit else {
                return
            }
            let unitsPerPoint = unitsPerPoint
            let baseUnits = units.baseLinearUnit
            let lenAvail = srUnit.convert(
                to: baseUnits,
                value: unitsPerPoint * Double(maxLength)
            )
            let closestLen = units.closestDistanceWithoutGoingOver(
                to: lenAvail,
                units: baseUnits
            )
            displayLength = CGFloat(
                baseUnits.convert(
                    to: srUnit,
                    value: closestLen
                ) / unitsPerPoint
            )
            displayUnit = units.linearUnits(forDistance: closestLen)
            lineMapLength = baseUnits.convert(
                to: displayUnit,
                value: closestLen
            )
        }
        
        guard displayLength.isFinite, !displayLength.isNaN else {
            return
        }
        
        self.displayLength = displayLength
        self.displayUnit = displayUnit
        self.lineMapLength = lineMapLength
        
        initialScaleWasCalculated = true
        
        updateLabels()
    }
}

private extension Measurement where UnitType == UnitLength {
    init(value: Double, linearUnit: LinearUnit) {
        self.init(value: value, unit: .fromLinearUnit(linearUnit))
    }
}

private extension FormatStyle where Self == Measurement<UnitLength>.FormatStyle {
    static var scaleMeasurement: Self {
        .measurement(width: .abbreviated, usage: .asProvided)
    }
}
