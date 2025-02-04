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

import ArcGIS
import SwiftUI

extension UtilityNetworkTraceViewModel {
    /// A trace performed on a utility network.
    struct Trace {
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
        
        /// A collection of all elements returned in the trace.
        var elementResults = [UtilityElement]()
        
        /// A collection of all feature results returned in the trace.
        ///
        /// Each feature corresponds to an element in `elementResults`.
        var featureResults = [ArcGISFeature]()
        
        /// A collection of utility trace function outputs.
        var functionOutputs = [UtilityTraceFunctionOutput]()
        
        /// A collection of graphics generated from the trace.
        var graphics = [Graphic]()
        
        /// A unique identifier for the trace.
        let id = UUID()
        
        /// A user given name for the trace.
        var name = ""
        
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

extension UtilityNetworkTraceViewModel.Trace {
    /// Finds the set of utility elements returned by the trace that belong to the provided
    /// asset group, grouped by type.
    /// - Parameter groupName: A name of a utility asset group.
    /// - Returns: The elements in the indicated group.
    func elementsByType(inGroupNamed groupName: String) -> [String: [UtilityElement]] {
        elements(inAssetGroupNamed: groupName)
            .reduce(into: [:]) { result, element in
                let key = element.assetType.name
                var assetTypeGroup = result[key, default: []]
                assetTypeGroup.append(element)
                result[key] = assetTypeGroup
            }
    }
    
    /// Finds the set of utility elements returned by the trace that belong to the provided
    /// asset group.
    /// - Parameter assetGroupName: A name of a utility asset group.
    /// - Returns: The elements in the indicated group.
    func elements(inAssetGroupNamed assetGroupName: String) -> [UtilityElement] {
        elementResults.filter { $0.assetGroup.name == assetGroupName }
    }
    
    /// Toggles the selection state on feature result.
    /// - Parameter selected: A Boolean value indicating whether the feature is selected or not.
    func toggleFeatureSelection(selected: Bool) {
        featureResults.forEach { feature in
            if let featureLayer = feature.table?.layer as? FeatureLayer {
                if selected {
                    featureLayer.selectFeature(feature)
                } else {
                    featureLayer.unselectFeature(feature)
                }
            }
        }
    }
    
    /// A set of the asset group names returned by the trace.
    var assetGroupNames: Set<String> {
        Set(elementResults.map(\.assetGroup.name))
    }
    
    /// The extent of the trace's geometry result with a small added buffer.
    var resultExtent: Envelope? {
        guard let utilityGeometryTraceResult else { return nil }
        
        let geometries = [
            utilityGeometryTraceResult.multipoint,
            utilityGeometryTraceResult.polygon,
            utilityGeometryTraceResult.polyline
        ]
            .compactMap { geometry in
                if let geometry, !geometry.isEmpty {
                    return geometry
                } else {
                    return nil
                }
            }
        
        guard let combinedExtents = GeometryEngine.combineExtents(of: geometries),
              let expandedEnvelope = GeometryEngine.buffer(around: combinedExtents, distance: 200) else {
            return nil
        }
        
        return expandedEnvelope.extent
    }
}

extension UtilityNetworkTraceViewModel.Trace: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
