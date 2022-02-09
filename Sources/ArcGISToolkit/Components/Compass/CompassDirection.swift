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

import Foundation

***REMOVED***/ Represents a cardinal or intercardinal direction
internal enum CompassDirection: String {
***REMOVED***case north
***REMOVED***case northeast
***REMOVED***case east
***REMOVED***case southeast
***REMOVED***case south
***REMOVED***case southwest
***REMOVED***case west
***REMOVED***case northwest
***REMOVED***

internal extension CompassDirection {
***REMOVED******REMOVED***/ Initializes a `CompassDirection` from a given degree value. All values will be normalized
***REMOVED******REMOVED***/ between 0° and 360°.
***REMOVED***init(_ degrees: Double) {
***REMOVED******REMOVED***let angle = CompassDirection.normalizedAngle(degrees)
***REMOVED******REMOVED***switch angle {
***REMOVED******REMOVED***case 0..<23, 338..<360:
***REMOVED******REMOVED******REMOVED***self = .north
***REMOVED******REMOVED***case 23..<68:
***REMOVED******REMOVED******REMOVED***self = .northeast
***REMOVED******REMOVED***case 68..<113:
***REMOVED******REMOVED******REMOVED***self = .east
***REMOVED******REMOVED***case 113..<158:
***REMOVED******REMOVED******REMOVED***self = .southeast
***REMOVED******REMOVED***case 158..<203:
***REMOVED******REMOVED******REMOVED***self = .south
***REMOVED******REMOVED***case 203..<248:
***REMOVED******REMOVED******REMOVED***self = .southwest
***REMOVED******REMOVED***case 248..<293:
***REMOVED******REMOVED******REMOVED***self = .west
***REMOVED******REMOVED***case 293..<338:
***REMOVED******REMOVED******REMOVED***self = .northwest
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ Normalizes degree values between 0° and 360°.
***REMOVED***static private func normalizedAngle(_ degrees: Double) -> Double {
***REMOVED******REMOVED***let normalizded = degrees.truncatingRemainder(dividingBy: 360)
***REMOVED******REMOVED***if normalizded < 0 {
***REMOVED******REMOVED******REMOVED***return normalizded + 360
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return abs(normalizded)
***REMOVED***
***REMOVED***
***REMOVED***
