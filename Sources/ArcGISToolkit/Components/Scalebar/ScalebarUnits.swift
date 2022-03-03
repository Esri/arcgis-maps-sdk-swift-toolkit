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

***REMOVED***internal func baseUnits() -> LinearUnit {
***REMOVED******REMOVED***return self == .imperial ? LinearUnit.feet : LinearUnit.meters
***REMOVED***

***REMOVED***private static func multiplierAndMagnitudeForDistance(distance: Double) -> (multiplier: Double, magnitude: Double) {
***REMOVED******REMOVED******REMOVED*** get multiplier

***REMOVED******REMOVED***let magnitude = pow(10, floor(log10(distance)))
***REMOVED******REMOVED***let residual = distance / Double(magnitude)
***REMOVED******REMOVED***let multiplier: Double = ScalebarUnits.roundNumberMultipliers.filter { $0 <= residual ***REMOVED***.last ?? 0
***REMOVED******REMOVED***return (multiplier, magnitude)
***REMOVED***

***REMOVED***internal func closestDistanceWithoutGoingOver(to distance: Double, units: LinearUnit) -> Double {
***REMOVED******REMOVED***let mm = ScalebarUnits.multiplierAndMagnitudeForDistance(distance: distance)
***REMOVED******REMOVED***let roundNumber = mm.multiplier * mm.magnitude

***REMOVED******REMOVED******REMOVED*** because feet and miles are not relationally multiples of 10 with each other,
***REMOVED******REMOVED******REMOVED*** we have to convert to miles if we are dealing in miles
***REMOVED******REMOVED***if units == .feet {
***REMOVED******REMOVED******REMOVED***let displayUnits = linearUnitsForDistance(distance: roundNumber)
***REMOVED******REMOVED******REMOVED***if units != displayUnits {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let displayDistance = closestDistanceWithoutGoingOver(to: units.convert(value: distance, to: displayUnits), units: displayUnits)
***REMOVED******REMOVED******REMOVED******REMOVED***let displayDistance = closestDistanceWithoutGoingOver(to: units.convert(to: displayUnits, value: distance), units: displayUnits)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return displayUnits.convert(displayDistance, to: units)
***REMOVED******REMOVED******REMOVED******REMOVED***return displayUnits.convert(to: units, value: displayDistance)
***REMOVED******REMOVED***
***REMOVED***

***REMOVED******REMOVED***return roundNumber
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED*** this table must begin with 1 and end with 10
***REMOVED***private static let roundNumberMultipliers: [Double] = [1, 1.2, 1.25, 1.5, 1.75, 2, 2.4, 2.5, 3, 3.75, 4, 5, 6, 7.5, 8, 9, 10]

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
