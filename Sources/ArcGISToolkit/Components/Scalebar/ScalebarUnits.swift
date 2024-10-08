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
import Foundation

@available(visionOS, unavailable)
public enum ScalebarUnits: Sendable {
***REMOVED******REMOVED***/ Imperial units (feet, miles, etc)
***REMOVED***case imperial
***REMOVED***
***REMOVED******REMOVED***/ Metric units (meters, etc)
***REMOVED***case metric
***REMOVED***
***REMOVED******REMOVED***/ Multiplier options.
***REMOVED******REMOVED***/ This table must begin with 1 and end with 10.
***REMOVED***private static let roundNumberMultipliers: [Double] =
***REMOVED******REMOVED***[1, 1.2, 1.25, 1.5, 1.75, 2, 2.4, 2.5, 3, 3.75, 4, 5, 6, 7.5, 8, 9, 10]
***REMOVED***
***REMOVED******REMOVED***/ Determines an appropriate base linear unit for this scalebar unit.
***REMOVED******REMOVED***/ - Returns: `LinearUnit.feet` or `LinearUnit.meters` depending on this unit.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ `ScalebarUnits.imperial` will return `LinearUnit.feet` as feet is the smallest linear
***REMOVED******REMOVED***/ unit that will be displayed.
***REMOVED******REMOVED***/ `ScalebarUnits.metric` will return `LinearUnit.meters` as meter is the smallest linear
***REMOVED******REMOVED***/ unit that will be displayed.
***REMOVED***var baseLinearUnit: LinearUnit {
***REMOVED******REMOVED***return self == .imperial ? LinearUnit.feet : LinearUnit.meters
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Calculates a magnitude for a given distance.
***REMOVED******REMOVED***/ - Parameter distance: A distance to compute the magnitude for.
***REMOVED******REMOVED***/ - Returns: A magnitude for a given distance.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ For example:
***REMOVED******REMOVED***/ A distance of 25 will return 10 as 10 is the highest power of 10 that will fit into 25.
***REMOVED******REMOVED***/ A distance of 550 will return 100 as 100 is the highest power of 10 that will fit into 550.
***REMOVED******REMOVED***/ A distance of 2,222 will return 1000 as 1000 is the highest power of 10 that will fit into 2,222.
***REMOVED***private static func magnitude(forDistance distance: Double) -> Double {
***REMOVED******REMOVED***return pow(10, floor(log10(distance)))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a multiplier for a given distance.
***REMOVED******REMOVED***/ - Parameter distance: A distance to compute the multiplier for.
***REMOVED******REMOVED***/ - Returns: A multiplier for a given distance.
***REMOVED***private static func multiplier(forDistance distance: Double) -> Double {
***REMOVED******REMOVED***let residual = distance / ScalebarUnits.magnitude(forDistance: distance)
***REMOVED******REMOVED***let multiplier = ScalebarUnits.roundNumberMultipliers.filter { $0 <= residual ***REMOVED***.last ?? 0
***REMOVED******REMOVED***return multiplier
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a list of segment options for a given multiplier.
***REMOVED******REMOVED***/ - Parameter multiplier: A distance to compute the multiplier for.
***REMOVED******REMOVED***/ - Returns: A list of segment options for a given multiplier.
***REMOVED***private static func segmentOptions(forMultiplier multiplier: Double) -> [Int] {
***REMOVED******REMOVED***switch multiplier {
***REMOVED******REMOVED***case 1:
***REMOVED******REMOVED******REMOVED***return [1, 2, 4, 5]
***REMOVED******REMOVED***case 1.2:
***REMOVED******REMOVED******REMOVED***return [1, 2, 3, 4]
***REMOVED******REMOVED***case 1.25:
***REMOVED******REMOVED******REMOVED***return [1, 2]
***REMOVED******REMOVED***case 1.5:
***REMOVED******REMOVED******REMOVED***return [1, 2, 3, 5]
***REMOVED******REMOVED***case 1.75:
***REMOVED******REMOVED******REMOVED***return [1, 2]
***REMOVED******REMOVED***case 2:
***REMOVED******REMOVED******REMOVED***return [1, 2, 4, 5]
***REMOVED******REMOVED***case 2.4:
***REMOVED******REMOVED******REMOVED***return [1, 2, 3]
***REMOVED******REMOVED***case 2.5:
***REMOVED******REMOVED******REMOVED***return [1, 2, 5]
***REMOVED******REMOVED***case 3:
***REMOVED******REMOVED******REMOVED***return [1, 2, 3]
***REMOVED******REMOVED***case 3.75:
***REMOVED******REMOVED******REMOVED***return [1, 3]
***REMOVED******REMOVED***case 4:
***REMOVED******REMOVED******REMOVED***return [1, 2, 4]
***REMOVED******REMOVED***case 5:
***REMOVED******REMOVED******REMOVED***return [1, 2, 5]
***REMOVED******REMOVED***case 6:
***REMOVED******REMOVED******REMOVED***return [1, 2, 3]
***REMOVED******REMOVED***case 7.5:
***REMOVED******REMOVED******REMOVED***return [1, 2]
***REMOVED******REMOVED***case 8:
***REMOVED******REMOVED******REMOVED***return [1, 2, 4]
***REMOVED******REMOVED***case 9:
***REMOVED******REMOVED******REMOVED***return [1, 2, 3]
***REMOVED******REMOVED***case 10:
***REMOVED******REMOVED******REMOVED***return [1, 2, 5]
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return [1]
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ - Returns: The best number of segments so that we get relatively round numbers when the
***REMOVED******REMOVED***/ distance is divided up.
***REMOVED***static func numSegments(
***REMOVED******REMOVED***forDistance distance: Double,
***REMOVED******REMOVED***maxNumSegments: Int
***REMOVED***) -> Int {
***REMOVED******REMOVED***let multiplier = multiplier(forDistance: distance)
***REMOVED******REMOVED***let options = segmentOptions(forMultiplier: multiplier)
***REMOVED******REMOVED***let num = options.filter { $0 <= maxNumSegments ***REMOVED***.last ?? 1
***REMOVED******REMOVED***return num
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Calculates a round number suitable for display.
***REMOVED******REMOVED***/ - Returns: A displayable round number.
***REMOVED***func closestDistanceWithoutGoingOver(
***REMOVED******REMOVED***to distance: Double,
***REMOVED******REMOVED***units: LinearUnit
***REMOVED***) -> Double {
***REMOVED******REMOVED***let magnitude = ScalebarUnits.magnitude(forDistance: distance)
***REMOVED******REMOVED***let multiplier = ScalebarUnits.multiplier(forDistance: distance)
***REMOVED******REMOVED***let roundNumber = multiplier * magnitude
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Because feet and miles are not relationally multiples of 10 with
***REMOVED******REMOVED******REMOVED*** each other, we have to convert to miles if we are dealing in feet.
***REMOVED******REMOVED***if units == .feet {
***REMOVED******REMOVED******REMOVED***let displayUnits = linearUnits(forDistance: roundNumber)
***REMOVED******REMOVED******REMOVED***if units != displayUnits {
***REMOVED******REMOVED******REMOVED******REMOVED***let displayDistance = closestDistanceWithoutGoingOver(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***to: units.convert(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***to: displayUnits,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***value: distance
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***units: displayUnits
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***return displayUnits.convert(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***to: units,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***value: displayDistance
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return roundNumber
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines a suitable display unit for the given distance.
***REMOVED******REMOVED***/ - Parameter distance: The distance to be displayed.
***REMOVED******REMOVED***/ - Returns: A suitable linear unit.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ `ScalebarUnits.imperial` will return `LinearUnit.miles` if the given distance is greater
***REMOVED******REMOVED***/ than or equal to 1/2 mile, and `LinearUnit.feet` otherwise.
***REMOVED******REMOVED***/ `ScalebarUnits.metric` will return `LinearUnit.kilometers` if the given distance is
***REMOVED******REMOVED***/ greater than or equal to 1 kilometer, and `LinearUnit.meters` otherwise.
***REMOVED***func linearUnits(forDistance distance: Double) -> LinearUnit {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .imperial:
***REMOVED******REMOVED******REMOVED***return distance >= 2640 ? .miles : .feet
***REMOVED******REMOVED***case .metric:
***REMOVED******REMOVED******REMOVED***return distance >= 1000 ? .kilometers : .meters
***REMOVED***
***REMOVED***
***REMOVED***
