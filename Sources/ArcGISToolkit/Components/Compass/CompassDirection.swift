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

import SwiftUI

/// Represents a cardinal or intercardinal direction.
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
        let angle = Angle(degrees: degrees).normalizedDegrees
        switch angle {
        case 0..<22.5, 337.5..<360:
            self = .north
        case 22.5..<67.5:
            self = .northeast
        case 67.5..<112.5:
            self = .east
        case 112.5..<157.5:
            self = .southeast
        case 157.5..<202.5:
            self = .south
        case 202.5..<247.5:
            self = .southwest
        case 247.5..<292.5:
            self = .west
        case 292.5..<337.5:
            self = .northwest
        default:
            fatalError()
        }
    }
}
