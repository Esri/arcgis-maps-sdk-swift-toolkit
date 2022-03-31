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
    @Published var displayLength: CGFloat = .zero
    
    @Published var displayLengthString = ""
    
    @Published var displayUnit: LinearUnit? = nil
    
    var visibleAreaSubject = PassthroughSubject<Polygon?, Never>()
    
    private var visibleAreaCancellable: AnyCancellable?
    
    /// The amount of time to wait between value calculations.
    private var delay = DispatchQueue.SchedulerTimeType.Stride.seconds(0.05)
    
    private var spatialReference: SpatialReference? = .wgs84
    
    private var targetWidth: Double
    
    private var unitsPerPoint: Binding<Double?>
    
    /// Allows a user to toggle geodetic calculations.
    private var useGeodeticCalculations: Bool
    
    /// Acts as a data provider of the current scale.
    private var viewpoint: Binding<Viewpoint?>
    
    /// Acts as a data provider of the current scale.
    private var visibleArea: Binding<Polygon?>
    
    /// Unit of measure in use.
    private var units: ScalebarUnits
    
    private var geodeticCurveType: GeometryEngine.GeodeticCurveType = .geodesic
    
    /// Set a minScale if you only want the scalebar to appear when you reach a large enough scale maybe
    ///  something like 10_000_000. This could be useful because the scalebar is really only accurate for
    ///  the center of the map on smaller scales (when zoomed way out). A minScale of 0 means it will
    ///  always be visible
    private let minScale: Double = 0
    
    init(
        _ spatialReference: SpatialReference? = .wgs84,
        _ targetWidth: Double,
        _ units: ScalebarUnits = NSLocale.current.usesMetricSystem ? .metric : .imperial,
        _ unitsPerPoint: Binding<Double?>,
        _ useGeodeticCalculations: Bool = true,
        _ viewpoint: Binding<Viewpoint?>,
        _ visibleArea: Binding<Polygon?>
        
    ) {
        self.spatialReference = spatialReference
        self.targetWidth = targetWidth
        self.units = units
        self.unitsPerPoint = unitsPerPoint
        self.useGeodeticCalculations = useGeodeticCalculations
        self.viewpoint = viewpoint
        self.visibleArea = visibleArea
        
        visibleAreaCancellable = visibleAreaSubject
            .debounce(for: delay, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updateScaleDisplay()
            })
        
        updateScaleDisplay()
    }
    
    private func updateScaleDisplay() {
        guard let scale = viewpoint.wrappedValue?.targetScale else {
            return
        }
        guard minScale <= 0 || scale < minScale else {
            return
        }
        guard let unitsPerPoint = unitsPerPoint.wrappedValue else {
            return
        }
        guard let visibleArea = visibleArea.wrappedValue else {
            return
        }
        guard let sr = spatialReference else {
            return
        }
        let totalWidthAvailable = targetWidth
        
        // TODO: - Removal of hardcoded sample renderer property (~16 - 2) derived from sample renderer
        let maxLength =  totalWidthAvailable - 16.30243742465973 - 2
        
        let lineMapLength: Double
        let displayUnit: LinearUnit
        let mapCenter = visibleArea.extent.center
        let displayLength: CGFloat
        
        if useGeodeticCalculations || spatialReference?.unit is AngularUnit {
            let maxLengthPlanar = unitsPerPoint * Double(maxLength)
            let p1 = Point(
                x: mapCenter.x - (maxLengthPlanar * 0.5),
                y: mapCenter.y,
                spatialReference: sr
            )
            let p2 = Point(
                x: mapCenter.x + (maxLengthPlanar * 0.5),
                y: mapCenter.y,
                spatialReference: sr
            )
            let polyline = Polyline(
                points: [p1, p2], spatialReference: spatialReference
            )
            let baseUnits = units.baseUnits()
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
            guard let srUnit = sr.unit as? LinearUnit else {
                return
            }
            let unitsPerPoint = unitsPerPoint
            let baseUnits = units.baseUnits()
            let lenAvail = srUnit.convert(
                to: baseUnits,
                value: unitsPerPoint * Double(maxLength)
            )
            let closestLen = units.closestDistanceWithoutGoingOver(
                to: lenAvail,
                units: baseUnits
            )
            displayLength = CGFloat(
                baseUnits.convert(to: srUnit, value: closestLen) / unitsPerPoint)
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
        
        displayLengthString = Scalebar.numberFormatter.string(from: NSNumber(value: lineMapLength)) ?? ""
    }
}
