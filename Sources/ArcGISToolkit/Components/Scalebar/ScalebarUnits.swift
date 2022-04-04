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
import Foundation

public enum ScalebarUnits {
***REMOVED***case imperial
***REMOVED***case metric
***REMOVED***
***REMOVED***internal func baseUnits() -> LinearUnit {
***REMOVED******REMOVED***return self == .imperial ? LinearUnit.feet : LinearUnit.meters
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Get multiplier
***REMOVED***private static func multiplierAndMagnitudeForDistance(
***REMOVED******REMOVED***distance: Double) -> (multiplier: Double, magnitude: Double
***REMOVED***) {
***REMOVED******REMOVED***let magnitude = pow(10, floor(log10(distance)))
***REMOVED******REMOVED***let residual = distance / Double(magnitude)
***REMOVED******REMOVED***let multiplier: Double = ScalebarUnits.roundNumberMultipliers.filter { $0 <= residual ***REMOVED***.last ?? 0
***REMOVED******REMOVED***return (multiplier, magnitude)
***REMOVED***
***REMOVED***
***REMOVED***internal func closestDistanceWithoutGoingOver(
***REMOVED******REMOVED***to distance: Double,
***REMOVED******REMOVED***units: LinearUnit
***REMOVED***) -> Double {
***REMOVED******REMOVED***let mm = ScalebarUnits.multiplierAndMagnitudeForDistance(distance: distance)
***REMOVED******REMOVED***let roundNumber = mm.multiplier * mm.magnitude
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Because feet and miles are not relationally multiples of 10 with
***REMOVED******REMOVED******REMOVED*** each other, we have to convert to miles if we are dealing in miles.
***REMOVED******REMOVED***if units == .feet {
***REMOVED******REMOVED******REMOVED***let displayUnits = linearUnitsForDistance(distance: roundNumber)
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
***REMOVED******REMOVED***/ This function returns the best number of segments so that we get relatively round numbers when the
***REMOVED******REMOVED***/ distance is divided up.
***REMOVED***internal static func numSegmentsForDistance(
***REMOVED******REMOVED***distance: Double,
***REMOVED******REMOVED***maxNumSegments: Int
***REMOVED***) -> Int {
***REMOVED******REMOVED***let mm = multiplierAndMagnitudeForDistance(distance: distance)
***REMOVED******REMOVED***let options = segmentOptionsForMultiplier(multiplier: mm.multiplier)
***REMOVED******REMOVED***let num = options.filter { $0 <= maxNumSegments ***REMOVED***.last ?? 1
***REMOVED******REMOVED***return num
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ This table must begin with 1 and end with 10.
***REMOVED***private static let roundNumberMultipliers: [Double] =
***REMOVED******REMOVED***[1, 1.2, 1.25, 1.5, 1.75, 2, 2.4, 2.5, 3, 3.75, 4, 5, 6, 7.5, 8, 9, 10]
***REMOVED***
***REMOVED***internal func linearUnitsForDistance(distance: Double) -> LinearUnit {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .imperial:
***REMOVED******REMOVED******REMOVED***if distance >= 2640 {
***REMOVED******REMOVED******REMOVED******REMOVED***return LinearUnit.miles
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return LinearUnit.feet
***REMOVED******REMOVED***case .metric:
***REMOVED******REMOVED******REMOVED***if distance >= 1000 {
***REMOVED******REMOVED******REMOVED******REMOVED***return LinearUnit.kilometers
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return LinearUnit.meters
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private static func segmentOptionsForMultiplier(
***REMOVED******REMOVED***multiplier: Double
***REMOVED***) -> [Int] {
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
