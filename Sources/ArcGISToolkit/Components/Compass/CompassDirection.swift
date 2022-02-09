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

import Foundation

/// Represents a cardinal or intercardinal direction
internal enum CompassDirection: String {
    case north
    case northeast
    case east
    case southeast
    case south
    case southwest
    case west
    case northwest
}

internal extension CompassDirection {
    /// Initializes a `CompassDirection` from a given degree value. All values will be normalized
    /// between 0° and 360°.
    init(_ degrees: Double) {
        let angle = CompassDirection.normalizedAngle(degrees)
        switch angle {
        case 0..<23, 338..<360:
            self = .north
        case 23..<68:
            self = .northeast
        case 68..<113:
            self = .east
        case 113..<158:
            self = .southeast
        case 158..<203:
            self = .south
        case 203..<248:
            self = .southwest
        case 248..<293:
            self = .west
        case 293..<338:
            self = .northwest
        default:
            fatalError()
        }
    }

    /// Normalizes degree values between 0° and 360°.
    static private func normalizedAngle(_ degrees: Double) -> Double {
        let normalizded = degrees.truncatingRemainder(dividingBy: 360)
        if normalizded < 0 {
            return normalizded + 360
        } else {
            return abs(normalizded)
        }
    }
}
