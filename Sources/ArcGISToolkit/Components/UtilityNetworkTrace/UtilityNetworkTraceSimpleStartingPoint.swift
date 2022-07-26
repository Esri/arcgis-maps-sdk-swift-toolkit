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
import UIKit

/// A simplified starting point of a utility network trace.
public struct UtilityNetworkTraceSimpleStartingPoint {
    /// The underlying geo element.
    let geoElement: GeoElement
    
    /// A unique identifier for the simple starting point.
    let id = UUID()
    
    /// A map point (useful for specifying a fractional starting location along an edge element).
    let point: Point?
    
    /// - Parameters:
    ///   - geoElement: The underlying geo element.
    ///   - point: A map point (useful for specifying a fractional starting location along an edge element).
    public init(
        geoElement: GeoElement,
        point: Point? = nil
    ) {
        self.geoElement = geoElement
        self.point = point
    }
}

extension UtilityNetworkTraceSimpleStartingPoint: Equatable {
    public static func == (lhs: UtilityNetworkTraceSimpleStartingPoint, rhs: UtilityNetworkTraceSimpleStartingPoint) -> Bool {
        lhs.id == rhs.id
    }
}
