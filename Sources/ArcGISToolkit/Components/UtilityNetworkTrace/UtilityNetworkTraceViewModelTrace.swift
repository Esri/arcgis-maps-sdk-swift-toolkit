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

extension UtilityNetworkTraceViewModel {
    /// A trace performed on a utility network.
    struct Trace {
        /// The number of assets returned by the trace.
        var assetCount = 0
        
        /// A collection of all elements returned in the trace, grouped by asset group and asset type.
        var assets = [String: [String: [UtilityElement]]]()
        
        /// A user given color for the trace with a default value of green.
        var color: Color = .green {
            didSet {
                // Update the color of any pre-existing starting points
                startingPoints.forEach { startingPoint in
                    guard let symbol = startingPoint.graphic?.symbol as? SimpleMarkerSymbol else { return }
                    symbol.color = UIColor(color)
                }
                graphics.forEach { graphic in
                    guard let symbol = graphic.symbol as? SimpleLineSymbol else { return }
                    symbol.color = UIColor(color)
                }
            }
        }
        
        /// The chosen named trace configuration.
        var configuration: UtilityNamedTraceConfiguration?
        
        /// A collection of utility trace function outputs.
        var functionOutputs = [UtilityTraceFunctionOutput]()
        
        /// A collection of graphics generated from the trace.
        var graphics = [Graphic]()
        
        /// A unique identifier for the trace.
        let id = UUID()
        
        /// A user given name for the trace.
        var name = ""
        
        /// The extent of the trace's geometry result with a small added buffer.
        var resultExtent: Envelope? {
            if let resultEnvelope = GeometryEngine.combineExtents(of: [
                utilityGeometryTraceResult?.multipoint,
                utilityGeometryTraceResult?.polygon,
                utilityGeometryTraceResult?.polyline
            ].compactMap { $0 }),
               let expandedEnvelope = GeometryEngine.buffer(
                around: resultEnvelope,
                distance: 200
               ) {
                return expandedEnvelope.extent
            } else {
                return nil
            }
        }
        
        /// A collection of starting points for the trace.
        var startingPoints = [UtilityNetworkTraceStartingPoint]()
        
        /// A Boolean value that indicates that the user has specified a name for the trace.
        var userDidSpecifyName = false
        
        /// A trace result comprised of a collection of UtilityElement objects.
        var utilityElementTraceResult: UtilityElementTraceResult?
        
        /// A trace result comprised of a collection of UtilityTraceFunctionOutput objects.
        var utilityFunctionTraceResult: UtilityFunctionTraceResult?
        
        /// A trace result comprised of Geometry objects
        var utilityGeometryTraceResult: UtilityGeometryTraceResult?
    }
}

extension UtilityNetworkTraceViewModel.Trace: Equatable {
    static func == (
        lhs: UtilityNetworkTraceViewModel.Trace,
        rhs: UtilityNetworkTraceViewModel.Trace
    ) -> Bool {
        return lhs.id == rhs.id
    }
}
