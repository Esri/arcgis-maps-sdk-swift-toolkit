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
import Foundation

public enum ScalebarUnits {
    case imperial
    case metric
    
    internal func baseUnits() -> LinearUnit {
        return self == .imperial ? LinearUnit.feet : LinearUnit.meters
    }
    
    /// Get multiplier
    private static func multiplierAndMagnitudeForDistance(
        distance: Double) -> (multiplier: Double, magnitude: Double
    ) {
        let magnitude = pow(10, floor(log10(distance)))
        let residual = distance / Double(magnitude)
        let multiplier: Double = ScalebarUnits.roundNumberMultipliers.filter { $0 <= residual }.last ?? 0
        return (multiplier, magnitude)
    }
    
    internal func closestDistanceWithoutGoingOver(
        to distance: Double,
        units: LinearUnit
    ) -> Double {
        let mm = ScalebarUnits.multiplierAndMagnitudeForDistance(distance: distance)
        let roundNumber = mm.multiplier * mm.magnitude
        
        // Because feet and miles are not relationally multiples of 10 with
        // each other, we have to convert to miles if we are dealing in miles.
        if units == .feet {
            let displayUnits = linearUnitsForDistance(distance: roundNumber)
            if units != displayUnits {
                let displayDistance = closestDistanceWithoutGoingOver(
                    to: units.convert(
                        to: displayUnits,
                        value: distance
                    ),
                    units: displayUnits
                )
                return displayUnits.convert(
                    to: units,
                    value: displayDistance
                )
            }
        }
        
        return roundNumber
    }
    
    /// This function returns the best number of segments so that we get relatively round numbers when the
    /// distance is divided up.
    internal static func numSegmentsForDistance(
        distance: Double,
        maxNumSegments: Int
    ) -> Int {
        let mm = multiplierAndMagnitudeForDistance(distance: distance)
        let options = segmentOptionsForMultiplier(multiplier: mm.multiplier)
        let num = options.filter { $0 <= maxNumSegments }.last ?? 1
        return num
    }
    
    /// This table must begin with 1 and end with 10.
    private static let roundNumberMultipliers: [Double] =
        [1, 1.2, 1.25, 1.5, 1.75, 2, 2.4, 2.5, 3, 3.75, 4, 5, 6, 7.5, 8, 9, 10]
    
    internal func linearUnitsForDistance(distance: Double) -> LinearUnit {
        switch self {
        case .imperial:
            if distance >= 2640 {
                return LinearUnit.miles
            }
            return LinearUnit.feet
        case .metric:
            if distance >= 1000 {
                return LinearUnit.kilometers
            }
            return LinearUnit.meters
        }
    }
    
    private static func segmentOptionsForMultiplier(
        multiplier: Double
    ) -> [Int] {
        switch multiplier {
        case 1:
            return [1, 2, 4, 5]
        case 1.2:
            return [1, 2, 3, 4]
        case 1.25:
            return [1, 2]
        case 1.5:
            return [1, 2, 3, 5]
        case 1.75:
            return [1, 2]
        case 2:
            return [1, 2, 4, 5]
        case 2.4:
            return [1, 2, 3]
        case 2.5:
            return [1, 2, 5]
        case 3:
            return [1, 2, 3]
        case 3.75:
            return [1, 3]
        case 4:
            return [1, 2, 4]
        case 5:
            return [1, 2, 5]
        case 6:
            return [1, 2, 3]
        case 7.5:
            return [1, 2]
        case 8:
            return [1, 2, 4]
        case 9:
            return [1, 2, 3]
        case 10:
            return [1, 2, 5]
        default:
            return [1]
        }
    }
}
