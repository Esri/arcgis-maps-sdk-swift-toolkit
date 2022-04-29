// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import Combine
import Foundation
import SwiftUI

@MainActor
final class ScalebarViewModel: ObservableObject {
    // - MARK: Published vars
    
    /// The computed display length of the scalebar.
    @Published var displayLength: CGFloat = .zero
    
    /// The current set of labels to be displayed by the scalebar.
    @Published var labels = [ScalebarLabel]()
    
    // - MARK: Public vars
    
    /// A screen length and displayable string for the equivalent length in the alternate unit.
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
        let numberString = numberFormatter.string(
            from: NSNumber(value: altMapLength)
        ) ?? ""
        let bottomUnitsText = " \(altDisplayUnits.abbreviation)"
        let label = "\(numberString)\(bottomUnitsText)"
        return (altScreenLength, label)
    }
    
    /// A subject to which viewpoint updates can be submitted.
    var viewpointSubject = PassthroughSubject<Viewpoint?, Never>()
    
    // - MARK: Public methods
    
    /// A scalebar view model controls the underlying data used to render a scalebar.
    /// - Parameters:
    ///   - maxWidth: The maximum screen width allotted to the scalebar.
    ///   - minScale: A value of 0 indicates the scalebar segments should always recalculate.
    ///   - spatialReference: The map's spatial reference.
    ///   - style: The visual appearance of the scalebar.
    ///   - units: The units to be displayed in the scalebar.
    ///   - unitsPerPoint: The current number of device independent pixels to map display units.
    ///   - useGeodeticCalculations: Determines if a geodesic curve should be used to compute
    ///     the scale.
    ///   - viewpoint: The map's current viewpoint.
    init(
        _ maxWidth: Double,
        _ minScale: Double,
        _ spatialReference: Binding<SpatialReference?>,
        _ style: ScalebarStyle,
        _ units: ScalebarUnits,
        _ unitsPerPoint: Binding<Double?>,
        _ useGeodeticCalculations: Bool,
        _ viewpoint: Viewpoint?
    ) {
        self.maxWidth = maxWidth
        self.minScale = minScale
        self.spatialReference = spatialReference
        self.style = style
        self.units = units
        self.unitsPerPoint = unitsPerPoint
        self.useGeodeticCalculations = useGeodeticCalculations
        self.viewpoint = viewpoint
        
        viewpointSubscription = viewpointSubject
            .debounce(for: delay, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                guard let self = self else {
                    return
                }
                self.viewpoint = $0
                self.updateScaleDisplay()
            })
        
        updateScaleDisplay()
    }
    
    // - MARK: Private constants
    
    /// The amount of time to wait between value calculations.
    private let delay = DispatchQueue.SchedulerTimeType.Stride.seconds(0.05)
    
    /// The curve type to use when performing scale calculations.
    private let geodeticCurveType: GeometryEngine.GeodeticCurveType = .geodesic
    
    /// A `minScale` of 0 means the scalebar segments will always recalculate.
    private let minScale: Double
    
    /// Converts numbers into a readable format.
    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 0
        return numberFormatter
    }()
    
    /// The visual appearance of the scalebar.
    private let style: ScalebarStyle
    
    // - MARK: Private vars
    
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
    
    /// The length of the line to display in map units.
    private var lineMapLength: Double = .zero
    
    /// The maximum screen width allotted to the scalebar.
    private var maxWidth: Double
    
    /// The map's spatial reference.
    private var spatialReference: Binding<SpatialReference?>
    
    /// Unit of measure in use.
    private var units: ScalebarUnits
    
    /// The current number of device independent pixels to map display units.
    private var unitsPerPoint: Binding<Double?>
    
    /// Allows a user to toggle geodetic calculations.
    private var useGeodeticCalculations: Bool
    
    /// Acts as a data provider of the current scale.
    private var viewpoint: Viewpoint?
    
    /// A subscription to handle listening for viewpoint changes.
    private var viewpointSubscription: AnyCancellable?
    
    // - MARK: Private methods
    
    /// Updates the labels to be displayed by the scalebar.
    private func updateLabels() {
        let lineDisplayLength = displayLength
        
        // Use a string with at least a few characters in case the number string
        // only has 1. The dividers will be decimal values and we want to make
        // sure they all fit very basic hueristics.
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
                text: "0"
            )
        )
        
        for index in 0..<numSegments {
            currSegmentX += segmentScreenLength
            let segmentMapLength = Double((segmentScreenLength * CGFloat(index + 1)) / lineDisplayLength) * lineMapLength
            
            var segmentText = numberFormatter.string(from: NSNumber(value: segmentMapLength)) ?? ""
            if index == numSegments - 1, let displayUnit = displayUnit?.abbreviation {
                segmentText += " \(displayUnit)"
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
    
    /// Updates the information necessary to render a scalebar based off the latest viewpoint and units per
    /// point information.
    private func updateScaleDisplay() {
        guard let spatialReference = spatialReference.wrappedValue,
              let unitsPerPoint = unitsPerPoint.wrappedValue,
              let viewpoint = viewpoint,
              minScale <= 0 || viewpoint.targetScale < minScale else {
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
        
        updateLabels()
    }
}
