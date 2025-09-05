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

import SwiftUI

/// Represents a cardinal or intercardinal direction.
enum CompassDirection {
    case north
    case northeast
    case east
    case southeast
    case south
    case southwest
    case west
    case northwest
}

extension CompassDirection {
    /// Initializes a `CompassDirection` from a given degree value. All values will be normalized
    /// between 0° and 360°.
    init(_ degrees: Double) {
        let angle = Angle(degrees: degrees).normalizedDegrees
        self = switch angle {
        case 0..<22.5, 337.5..<360:
            .north
        case 22.5..<67.5:
            .northeast
        case 67.5..<112.5:
            .east
        case 112.5..<157.5:
            .southeast
        case 157.5..<202.5:
            .south
        case 202.5..<247.5:
            .southwest
        case 247.5..<292.5:
            .west
        case 292.5..<337.5:
            .northwest
        default:
            fatalError()
        }
    }
    
    /// The name of this compass direction.
    var name: Text {
        switch self {
        case .north:
            Text(
                "North",
                bundle: .toolkitModule,
                comment: "The cardinal direction North."
            )
        case .northeast:
            Text(
                "Northeast",
                bundle: .toolkitModule,
                comment: "The intercardinal direction Northeast."
            )
        case .east:
            Text(
                "East",
                bundle: .toolkitModule,
                comment: "The cardinal direction East."
            )
        case .southeast:
            Text(
                "Southeast",
                bundle: .toolkitModule,
                comment: "The intercardinal direction Southeast."
            )
        case .south:
            Text(
                "South",
                bundle: .toolkitModule,
                comment: "The cardinal direction South."
            )
        case .southwest:
            Text(
                "Southwest",
                bundle: .toolkitModule,
                comment: "The intercardinal direction Southwest."
            )
        case .west:
            Text(
                "West",
                bundle: .toolkitModule,
                comment: "The cardinal direction West."
            )
        case .northwest:
            Text(
                "Northwest",
                bundle: .toolkitModule,
                comment: "The intercardinal direction Northwest."
            )
        }
    }
}
