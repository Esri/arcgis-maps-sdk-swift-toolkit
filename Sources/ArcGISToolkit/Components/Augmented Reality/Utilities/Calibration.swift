// Copyright 2026 Esri
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

public import Observation

/// Stores incremental and total calibration corrections for heading and
/// elevation.
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
@Observable public final class Calibration {
    /// The most recently applied incremental heading correction in degrees.
    private(set) var headingCorrection = 0.0
    /// The most recently applied incremental elevation correction in meters.
    private(set) var elevationCorrection = 0.0
    
    /// The total heading correction.
    public private(set) var totalHeadingCorrection = 0.0
    /// The total elevation correction.
    public private(set) var totalElevationCorrection = 0.0
    
    /// Creates a new calibration state with zeroed corrections.
    init() {}
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
extension Calibration {
    /// Proposes a new heading correction.
    ///
    /// This will limit the total heading correction to -180...180.
    /// - Parameter headingCorrection: The proposed heading correction in
    /// degrees. Positive values will rotate the view to the right, and negative
    /// values will rotate the view to the left.
    func proposeHeadingCorrection(_ headingCorrection: Double) {
        let newTotalHeadingCorrection = (totalHeadingCorrection + headingCorrection)
            .clamped(to: -180...180)
        self.headingCorrection = newTotalHeadingCorrection - totalHeadingCorrection
        totalHeadingCorrection = newTotalHeadingCorrection
    }
    
    /// Proposes a new elevation correction.
    /// - Parameter elevationCorrection: The proposed elevation correction in
    /// meters.
    func proposeElevationCorrection(_ elevationCorrection: Double) {
        self.elevationCorrection = elevationCorrection
        totalElevationCorrection += elevationCorrection
    }
}
