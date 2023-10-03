// Copyright 2023 Esri.

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

public extension Viewpoint {
    /// Creates a new viewpoint with the same target geometry and scale but with a new rotation.
    /// - Parameter rotation: The rotation for the new viewpoint.
    /// - Returns: A new viewpoint.
    func withRotation(_ rotation: Double) -> Viewpoint {
        switch kind {
        case .centerAndScale:
            return Viewpoint(
                center: targetGeometry as! Point,
                scale: targetScale,
                rotation: rotation
            )
        case .boundingGeometry:
            return Viewpoint(
                boundingGeometry: targetGeometry,
                rotation: rotation
            )
        @unknown default:
            return self
        }
    }
}
