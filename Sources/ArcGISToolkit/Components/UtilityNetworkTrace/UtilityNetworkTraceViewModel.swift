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
import Foundation
import SwiftUI

@MainActor final class UtilityNetworkTraceViewModel: ObservableObject {
    // MARK: Published Properties
    
    /// A list of completed traces.
    @Published private(set) var completedTraces = [Trace]()
    
    /// The available named trace configurations.
    @Published private(set) var configurations = [UtilityNamedTraceConfiguration]()
    
    /// The trace currently under configuration.
    @Published var pendingTrace = Trace()
    
    /// The index of the selected trace.
    @Published private(set) var selectedTraceIndex: Int? {
        didSet {
            if let lastIndex = oldValue {
                changeSelectedStateForTrace(
                    at: lastIndex,
                    to: false
                )
            }
            if let currentIndex = selectedTraceIndex {
                changeSelectedStateForTrace(
                    at: currentIndex,
                    to: true
                )
            }
        }
    }
    
    /// A Boolean value indicating if the pending trace is configured to the point that it can be run.
    var canRunTrace: Bool {
        pendingTrace.configuration != nil && !pendingTrace.startingPoints.isEmpty
    }
    
    /// The overlay on which trace graphics will be drawn.
    private var graphicsOverlay: GraphicsOverlay
    
    /// The utility network on which traces will be ran.
    private var network: UtilityNetwork?
    
    /// The selected trace.
    var selectedTrace: Trace? {
        if let index = selectedTraceIndex {
            return completedTraces[index]
        } else {
            return nil
        }
    }
    
    /// Performs required setup.
    ///
    /// - Parameters:
    ///   - map: The map to be loaded that contains at least one utility network.
    ///   - graphicsOverlay: The overlay on which trace graphics will be drawn.
    init(map: Map, graphicsOverlay: GraphicsOverlay) {
        self.graphicsOverlay = graphicsOverlay
        Task {
            try? await map.load()
            network = map.utilityNetworks.first
            configurations = await utilityNamedTraceConfigurations(from: map)
        }
    }
    
    /// Deletes the provided starting point from the pending trace.
    /// - Parameter startingPoint: The starting point to be deleted.
    func delete(_ startingPoint: UtilityNetworkTraceStartingPoint) {
        pendingTrace.startingPoints.removeAll {
            $0.utilityElement.globalID == startingPoint.utilityElement.globalID
        }
        graphicsOverlay.removeGraphic(startingPoint.graphic)
    }
    
    /// Deletes all of the completed traces.
    func deleteAllTraces() {
        selectedTraceIndex = nil
        completedTraces.forEach { traceResult in
            graphicsOverlay.removeGraphics(traceResult.startingPoints.map { $0.graphic })
            graphicsOverlay.removeGraphics(traceResult.graphics)
        }
        completedTraces.removeAll()
    }
    
    /// Selects the next trace from the list of completed traces.
    func selectNextTrace() {
        if let current = selectedTraceIndex {
            if current + 1 <= completedTraces.count - 1 {
                selectedTraceIndex = current + 1
            } else {
                selectedTraceIndex = 0
            }
        }
    }
    
    /// Selects the previous trace from the list of completed traces.
    func selectPreviousTrace() {
        if let current = selectedTraceIndex {
            if current - 1 >= 0 {
                selectedTraceIndex = current - 1
            } else {
                selectedTraceIndex = completedTraces.count - 1
            }
        }
    }
    
    /// Adds a new starting point to the pending trace.
    /// - Parameters:
    ///   - point: A point on the map in screen coordinates.
    ///   - mapPoint: A point on the map in map coordinates.
    ///   - proxy: Provides a method of layer identification.
    func setStartingPoint(
        at point: CGPoint,
        mapPoint: Point,
        with proxy: MapViewProxy
    ) async {
        let identifyLayerResults = try? await proxy.identifyLayers(
            screenPoint: point,
            tolerance: 10
        )
        identifyLayerResults?.forEach { identifyLayerResult in
            identifyLayerResult.geoElements.forEach { geoElement in
                Task {
                    guard let network = network,
                          let feature = geoElement as? ArcGISFeature,
                          let extent = feature.geometry?.extent,
                          let symbol = try? await (feature.featureTable?.layer as? FeatureLayer)?
                        .renderer?
                        .symbol(for: feature)?
                        .makeSwatch(scale: 1.0),
                          let utilityElement = network.makeElement(arcGISFeature: feature) else { return }
                    let graphic = Graphic(
                        geometry: mapPoint,
                        symbol: SimpleMarkerSymbol(
                            color: UIColor(pendingTrace.color),
                            size: 20
                        )
                    )
                    let startingPoint = UtilityNetworkTraceStartingPoint(
                        extent: extent,
                        geoElement: geoElement,
                        graphic: graphic,
                        image: symbol,
                        utilityElement: utilityElement
                    )
                    graphicsOverlay.addGraphic(graphic)
                    pendingTrace.startingPoints.append(startingPoint)
                }
            }
        }
    }
    
    /// Runs the pending trace and stores it into the list of completed traces.
    func trace() {
        guard let config = pendingTrace.configuration,
              let network = network else { return }
        let params = UtilityTraceParameters(
            namedTraceConfiguration: config,
            startingLocations: pendingTrace.startingPoints.compactMap { $0.utilityElement }
        )
        Task {
            let traceResults = try await network.trace(traceParameters: params)
            var assetGroups = [String: Int]()
            for result in traceResults {
                switch result {
                case let result as UtilityElementTraceResult:
                    result.elements.forEach { element in
                        let count = assetGroups[element.assetGroup.name] ?? 0 + 1
                        assetGroups.updateValue(count, forKey: element.assetGroup.name)
                    }
                    assetGroups.forEach { (key, value) in
                        pendingTrace.assetLabels.append("\(key): \(value)")
                    }
                    pendingTrace.utilityElementTraceResult = result
                case let result as UtilityGeometryTraceResult:
                    if let polygon = result.polygon {
                        let graphic = Graphic(
                            geometry: polygon,
                            symbol: SimpleLineSymbol(
                                style: .solid,
                                color: UIColor(pendingTrace.color),
                                width: 5.0
                            )
                        )
                        graphicsOverlay.addGraphic(graphic)
                        pendingTrace.graphics.append(graphic)
                    }
                    if let polyline = result.polyline {
                        let graphic = Graphic(
                            geometry: polyline,
                            symbol: SimpleLineSymbol(
                                style: .dash,
                                color: UIColor(pendingTrace.color),
                                width: 5.0
                            )
                        )
                        graphicsOverlay.addGraphic(graphic)
                        pendingTrace.graphics.append(graphic)
                    }
                    if let multipoint = result.multipoint {
                        let graphic = Graphic(
                            geometry: multipoint,
                            symbol: SimpleLineSymbol(
                                style: .dot,
                                color: UIColor(pendingTrace.color),
                                width: 5.0
                            )
                        )
                        graphicsOverlay.addGraphic(graphic)
                        pendingTrace.graphics.append(graphic)
                    }
                    pendingTrace.utilityGeometryTraceResult = result
                case let result as UtilityFunctionTraceResult:
                    let functionOutputs = result.functionOutputs
                    functionOutputs.forEach { functionOutput in
                        pendingTrace.functionOutputs.append(functionOutput)
                    }
                    pendingTrace.utilityFunctionTraceResult = result
                default:
                    break
                }
            }
            completedTraces.append(pendingTrace)
            selectedTraceIndex = completedTraces.count - 1
            pendingTrace = Trace()
        }
    }
    
    // MARK: Private Methods
    
    /// Changes the selected state of the graphics for the completed trace at the provided index.
    /// - Parameters:
    ///   - index: The index of the completed trace.
    ///   - isSelected: The new selection state.
    private func changeSelectedStateForTrace(
        at index: Int,
        to isSelected: Bool
    ) {
        guard index >= 0, index <= completedTraces.count - 1 else { return }
        _ = completedTraces[index].graphics.map { $0.isSelected = isSelected }
        _ = completedTraces[index].startingPoints.map { $0.graphic.isSelected = isSelected }
    }
    
    /// Returns the named trace configurations in the network on the provided map.
    /// - Parameter map: A web map containing one or more utility networks.
    private func utilityNamedTraceConfigurations(from map: Map) async -> [UtilityNamedTraceConfiguration] {
        guard let network = network else { return [] }
        return (try? await map.getNamedTraceConfigurations(from: network)) ?? []
    }
}

extension UtilityTraceFunctionOutput: Identifiable { }
