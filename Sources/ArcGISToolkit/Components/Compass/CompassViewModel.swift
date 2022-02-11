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

/// Manages the state for a `Compass`.
@MainActor
final internal class CompassViewModel: ObservableObject {
    /// Acts as link between the compass and the parent map or scene view.
    @Binding var viewpoint: Viewpoint

    /// Determines if the compass should automatically hide/show itself when the parent view is oriented
    /// north.
    @Published public var autoHide: Bool

    /// Indicates if the compass should be hidden or visible based on the current viewpoint rotation and
    /// autoHide preference.
    public var hidden: Bool {
        viewpoint.rotation.isZero && autoHide
    }

    /// Creates a `CompassViewModel`
    /// - Parameters:
    ///   - viewpoint: Acts a communication link between the MapView or SceneView and the compass.
    ///   - size: Enables a custom size configuuration for the compass. Default is 30.
    ///   - autoHide: Determines if the compass automatically hides itself when the MapView or
    ///   SceneView is oriented north.
    public init(
        viewpoint: Binding<Viewpoint>,
        autoHide: Bool = true
    ) {
        self._viewpoint = viewpoint
        self.autoHide = autoHide
    }

    /// Resets the viewpoints `rotation` to zero.
    public func resetHeading() {
        self.viewpoint = Viewpoint(
            center: viewpoint.targetGeometry.extent.center,
            scale: viewpoint.targetScale,
            rotation: .zero
        )
    }
}

internal extension Viewpoint {
    /// The viewpoint's `rotation` adjusted to offset any rotation applied to the parent view.
    var adjustedRotation: Double {
        rotation.isZero ? .zero : 360 - rotation
    }

    /// A text description of the current heading, sutiable for accessibility voiceover.
    var heading: String {
        "Compass, heading "
        + Int(self.adjustedRotation.rounded()).description
        + " degrees "
        + CompassDirection(self.adjustedRotation).rawValue
    }
}
