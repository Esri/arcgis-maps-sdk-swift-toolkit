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
import Foundation

public enum ScalebarUnits: Sendable {
    /// Imperial units (feet, miles, etc)
    case imperial
    
    /// Metric units (meters, etc)
    case metric
    
    /// Multiplier options.
    /// This table must begin with 1 and end with 10.
    private static let roundNumberMultipliers: [Double] =
        [1, 1.2, 1.25, 1.5, 1.75, 2, 2.4, 2.5, 3, 3.75, 4, 5, 6, 7.5, 8, 9, 10]
    
    /// Determines an appropriate base linear unit for this scalebar unit.
    /// - Returns: `LinearUnit.feet` or `LinearUnit.meters` depending on this unit.
    ///
    /// `ScalebarUnits.imperial` will return `LinearUnit.feet` as feet is the smallest linear
    /// unit that will be displayed.
    /// `ScalebarUnits.metric` will return `LinearUnit.meters` as meter is the smallest linear
    /// unit that will be displayed.
    var baseLinearUnit: LinearUnit {
        return self == .imperial ? LinearUnit.feet : LinearUnit.meters
    }
    
    /// Calculates a magnitude for a given distance.
    /// - Parameter distance: A distance to compute the magnitude for.
    /// - Returns: A magnitude for a given distance.
    ///
    /// For example:
    /// A distance of 25 will return 10 as 10 is the highest power of 10 that will fit into 25.
    /// A distance of 550 will return 100 as 100 is the highest power of 10 that will fit into 550.
    /// A distance of 2,222 will return 1000 as 1000 is the highest power of 10 that will fit into 2,222.
    private static func magnitude(forDistance distance: Double) -> Double {
        return pow(10, floor(log10(distance)))
    }
    
    /// Returns a multiplier for a given distance.
    /// - Parameter distance: A distance to compute the multiplier for.
    /// - Returns: A multiplier for a given distance.
    private static func multiplier(forDistance distance: Double) -> Double {
        let residual = distance / ScalebarUnits.magnitude(forDistance: distance)
        let multiplier = ScalebarUnits.roundNumberMultipliers.filter { $0 <= residual }.last ?? 0
        return multiplier
    }
    
    /// Returns a list of segment options for a given multiplier.
    /// - Parameter multiplier: A distance to compute the multiplier for.
    /// - Returns: A list of segment options for a given multiplier.
    private static func segmentOptions(forMultiplier multiplier: Double) -> [Int] {
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
    
    /// - Returns: The best number of segments so that we get relatively round numbers when the
    /// distance is divided up.
    static func numSegments(
        forDistance distance: Double,
        maxNumSegments: Int
    ) -> Int {
        let multiplier = multiplier(forDistance: distance)
        let options = segmentOptions(forMultiplier: multiplier)
        let num = options.filter { $0 <= maxNumSegments }.last ?? 1
        return num
    }
    
    /// Calculates a round number suitable for display.
    /// - Returns: A displayable round number.
    func closestDistanceWithoutGoingOver(
        to distance: Double,
        units: LinearUnit
    ) -> Double {
        let magnitude = ScalebarUnits.magnitude(forDistance: distance)
        let multiplier = ScalebarUnits.multiplier(forDistance: distance)
        let roundNumber = multiplier * magnitude
        
        // Because feet and miles are not relationally multiples of 10 with
        // each other, we have to convert to miles if we are dealing in feet.
        if units == .feet {
            let displayUnits = linearUnits(forDistance: roundNumber)
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
    
    /// Determines a suitable display unit for the given distance.
    /// - Parameter distance: The distance to be displayed.
    /// - Returns: A suitable linear unit.
    ///
    /// `ScalebarUnits.imperial` will return `LinearUnit.miles` if the given distance is greater
    /// than or equal to 1/2 mile, and `LinearUnit.feet` otherwise.
    /// `ScalebarUnits.metric` will return `LinearUnit.kilometers` if the given distance is
    /// greater than or equal to 1 kilometer, and `LinearUnit.meters` otherwise.
    func linearUnits(forDistance distance: Double) -> LinearUnit {
        switch self {
        case .imperial:
            return distance >= 2640 ? .miles : .feet
        case .metric:
            return distance >= 1000 ? .kilometers : .meters
        }
    }
}
