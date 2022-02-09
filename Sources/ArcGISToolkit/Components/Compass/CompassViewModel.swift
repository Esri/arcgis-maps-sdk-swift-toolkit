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
import SwiftUI

/// Manages the state for a `Compass`
@MainActor
public class CompassViewModel: ObservableObject {
    /// Acts as link between the compass and the parent map or scene view.
    @Binding var viewpoint: Viewpoint

    /// Determines if the compass should automatically hide/show itself when the parent view is oriented
    /// north.
    @Published public var autoHide: Bool

    /// The height of the compass.
    @Published public var height: Double

    /// The width of the compass.
    @Published public var width: Double

    /// Indicates if the compass should be hidden or visible based on the current viewpoint rotation and
    /// autoHide preference.
    public var hidden: Bool {
        viewpoint.rotation.isZero && autoHide
    }

    public init(
        viewpoint: Binding<Viewpoint>,
        size: Double = 30.0,
        autoHide: Bool = true
    ) {
        self._viewpoint = viewpoint
        self.autoHide = autoHide
        height = size
        width = size
    }

    /// Resets the viewpoints `rotation` to zero.
    public func resetHeading() {
        self.viewpoint = Viewpoint(
            center: viewpoint.targetGeometry.extent.center,
            scale: viewpoint.targetScale,
            rotation: 0.0
        )
    }
}

internal extension Int {
    /// A representation of an integer's associated cardinal or intercardinal direction.
    var asCardinalOrIntercardinal: String {
        switch self {
        case 0...22, 338...360: return "north"
        case 23...67: return "northeast"
        case 68...112: return "east"
        case 113...157: return "southeast"
        case 158...202: return "south"
        case 203...247: return "southwest"
        case 248...292: return "west"
        case 293...337: return "northwest"
        default: return ""
        }
    }
}

internal extension Viewpoint {
    /// The viewpoint's `rotation` adjusted to offset any rotation applied to the parent view.
    var adjustedRotation: Double {
        self.rotation == 0 ? self.rotation : 360 - self.rotation
    }

    /// A text description of the current heading, sutiable for accessibility voiceover.
    var heading: String {
        "Compass, heading "
        + Int(self.adjustedRotation.rounded()).description
        + " degrees "
        + Int(self.adjustedRotation.rounded()).asCardinalOrIntercardinal
    }
}
