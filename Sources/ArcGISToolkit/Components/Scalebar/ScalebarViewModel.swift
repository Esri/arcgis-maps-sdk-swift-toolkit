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
    
    /// Indicates if the scalebar should be hidden or not.
    @Published var isVisible: Bool
    
    /// The current set of labels to be displayed by the scalebar.
    @Published var labels = [ScalebarLabel]()
    
    // - MARK: Public vars
    
    /// A sreen length and displayable string for the equivalent length in the alternate unit.
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
        let altDisplayUnits = altUnit.linearUnitsForDistance(
            distance: altClosestBaseLength
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
    ///   - autoHide: Determines if the scalebar should automatically show & hide itself.
    ///   - minScale: A value of 0 indicates the scalebar segments should always recalculate.
    ///   - spatialReference: The map's spatial reference.
    ///   - style: The visual appearance of the scalebar.
    ///   - targetWidth: The screen width allotted to the scalebar.
    ///   - units: The units to be displayed in the scalebar.
    ///   - unitsPerPoint: The current number of device independent pixels to map display units.
    ///   - useGeodeticCalculations: Determines if a geodesic curve should be used to compute
    ///     the scale.
    ///   - viewpoint: The map's current viewpoint.
    init(
        _ autoHide: Bool,
        _ minScale: Double,
        _ spatialReference: SpatialReference?,
        _ style: ScalebarStyle,
        _ targetWidth: Double,
        _ units: ScalebarUnits,
        _ unitsPerPoint: Binding<Double?>,
        _ useGeodeticCalculations: Bool,
        _ viewpoint: Viewpoint?
    ) {
        self.isVisible = autoHide ? false : true
        self.minScale = minScale
        self.spatialReference = spatialReference
        self.style = style
        self.targetWidth = targetWidth
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
                if autoHide {
                    self.performVisibilityAnimation()
                }
            })
        
        updateScaleDisplay()
    }
    
    // - MARK: Private constants
    
    /// The amount of time to wait between value calculations.
    private let delay = DispatchQueue.SchedulerTimeType.Stride.seconds(0.05)
    
    /// The speed at which to animate `isVisible` to `true`.
    private let displaySpeed = 3.0
    
    /// The curve type to use when performing scale calculations.
    private let geodeticCurveType: GeometryEngine.GeodeticCurveType = .geodesic
    
    /// The time to wait in seconds before animating `isVisible` to `false`.
    private let hideTimeInterval = 1.75
    
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
    
    /// The map's spatial reference.
    private let spatialReference: SpatialReference?
    
    /// The visual appearance of the scalebar.
    private let style: ScalebarStyle
    
    // - MARK: Private vars
    
    /// The timer to determine when to autohide the scalebar.
    private var autoHideTimer: Timer?
    
    /// Determines the amount of display space to use based on the scalebar style.
    private var availableLineDisplayLength: CGFloat {
        switch style {
        case .alternatingBar, .dualUnitLine, .graduatedLine:
            let unitDisplayWidth = max(
                " mi".size(withAttributes: [.font: Scalebar.font.uiFont]).width,
                " km".size(withAttributes: [.font: Scalebar.font.uiFont]).width
            )
            return targetWidth - (Scalebar.lineWidth / 2.0) - unitDisplayWidth
        case .bar, .line:
            return targetWidth - Scalebar.lineWidth
        }
    }
    
    /// The units to be displayed in the scalebar.
    private var displayUnit: LinearUnit? = nil
    
    /// The length of the line to display in map units.
    private var lineMapLength: Double = .zero
    
    /// The maximum width allowed for the scalebar.
    private var targetWidth: Double
    
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
    
    /// Animates `isVisible` between `true` and `false` as necessary.
    private func performVisibilityAnimation() {
        self.autoHideTimer?.invalidate()
        withAnimation(.easeInOut.speed(displaySpeed)) {
            self.isVisible = true
        }
        self.autoHideTimer = Timer.scheduledTimer(
            withTimeInterval: hideTimeInterval,
            repeats: false,
            block: { _ in
                withAnimation {
                    self.isVisible = false
                }
            }
        )
    }
    
    /// Updates the labels to be displayed by the scalebar.
    private func updateLabels() {
        let lineDisplayLength = displayLength
        
        // Use a string with at least a few characters in case the number string
        // only has 1. The dividers will be decimal values and we want to make
        // sure they all fit very basic hueristics.
        let minSegmentTestString: String
        if let longestString = labels.last?.text, longestString.count > 3 {
            minSegmentTestString = longestString
        } else {
            minSegmentTestString = "9.9"
        }
        
        // Use 1.5 because in the text is longer in the last label
        let minSegmentWidth =
            minSegmentTestString.size(withAttributes: [.font: Scalebar.font.uiFont]).width * 1.5
            +
            Scalebar.labelXPad * 2
        
        let suggestedNumSegments = Int(lineDisplayLength / minSegmentWidth)
        
        // Cap segments at 4
        let maxNumSegments = min(suggestedNumSegments, 4)
        
        let numSegments: Int = ScalebarUnits.numSegmentsForDistance(
            distance: lineMapLength,
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
        self.labels = labels
    }
    
    /// Updates the information necessary to render a scalebar based off the latest viewpoint and units per
    /// point information.
    private func updateScaleDisplay() {
        guard let spatialReference = spatialReference,
              let unitsPerPoint = unitsPerPoint.wrappedValue,
              let viewpoint = viewpoint,
              minScale <= 0 || viewpoint.targetScale < minScale else {
            return
        }
        
        let mapCenter = viewpoint.targetGeometry.extent.center
        
        let maxLength =  availableLineDisplayLength
        
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
            displayUnit = units.linearUnitsForDistance(distance: roundNumberDistance)
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
            displayUnit = units.linearUnitsForDistance(distance: closestLen)
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
