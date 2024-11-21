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
import Combine
import Foundation
import SwiftUI

@available(visionOS, unavailable)
@MainActor final class UtilityNetworkTraceViewModel: ObservableObject {
    // MARK: Published Properties
    
    /// A list of completed traces.
    @Published private(set) var completedTraces = [Trace]()
    
    /// The available named trace configurations.
    @Published private(set) var configurations = [UtilityNamedTraceConfiguration]() {
        didSet {
            if configurations.isEmpty {
                userAlert = .noTraceTypesFound
            }
        }
    }
    
    /// The utility network on which traces will be ran.
    @Published private(set) var network: UtilityNetwork?
    
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
    
    /// Alert presented to the user
    @Published var userAlert: UtilityNetworkTraceUserAlert?
    
    /// A Boolean value indicating if the pending trace is configured to the point that it can be run.
    var canRunTrace: Bool {
        network != nil
        && pendingTrace.configuration != nil
        && !pendingTrace.startingPoints.isEmpty
    }
    
    /// The map's utility networks.
    var networks: [UtilityNetwork] {
        return map.utilityNetworks
    }
    
    /// The overlay on which trace graphics will be drawn.
    private var graphicsOverlay: GraphicsOverlay
    
    /// A map containing one or more utility networks.
    private var map: Map
    
    /// Starting points programmatically provided to the trace tool.
    var externalStartingPoints = [UtilityNetworkTraceStartingPoint]() {
        didSet {
            Task {
                await addExternalStartingPoints()
            }
        }
    }
    
    /// The selected trace.
    var selectedTrace: Trace? {
        if let index = selectedTraceIndex,
           index >= 0, index < completedTraces.count {
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
    ///   - startingPoints: Starting points programmatically provided to the trace tool.
    ///   - autoLoad: If set `false`, `load()` will need to be manually called.
    init(
        map: Map,
        graphicsOverlay: GraphicsOverlay,
        startingPoints: [UtilityNetworkTraceStartingPoint] = [],
        autoLoad: Bool = true
    ) {
        self.map = map
        self.graphicsOverlay = graphicsOverlay
        self.externalStartingPoints = startingPoints
        if autoLoad {
            Task { await load() }
        }
    }
    
    /// Adds new starting points to the pending trace.
    /// - Parameters:
    ///   - mapPoint: A point on the map in map coordinates.
    ///   - proxy: Provides a method of layer identification.
    ///
    /// An identify operation will run on each layer in the network. Every element returned from
    /// each layer will be added as a new starting point.
    func addStartingPoints(mapPoint: Point, with proxy: MapViewProxy) async {
        await withTaskGroup(of: Void.self) { [weak self] taskGroup in
            guard let self else { return }
            for layer in network?.layers ?? [] {
                taskGroup.addTask { @MainActor @Sendable in
                    if let screenPoint = proxy.screenPoint(fromLocation: mapPoint),
                       let result = try? await proxy.identify(on: layer, screenPoint: screenPoint, tolerance: 10) {
                        for element in result.geoElements {
                            await self.processAndAdd(
                                startingPoint: UtilityNetworkTraceStartingPoint(geoElement: element, mapPoint: mapPoint)
                            )
                        }
                    }
                }
            }
        }
    }
    
    /// Deletes all of the completed traces.
    func deleteAllTraces() {
        selectedTraceIndex = nil
        completedTraces.forEach { traceResult in
            deleteGraphics(for: traceResult)
        }
        completedTraces.removeAll()
    }
    
    /// Deletes the provided starting point from the pending trace.
    /// - Parameter startingPoint: The starting point to be deleted.
    func deleteStartingPoint(_ startingPoint: UtilityNetworkTraceStartingPoint) {
        pendingTrace.startingPoints.removeAll {
            $0 == startingPoint
        }
        if let graphic = startingPoint.graphic {
            graphicsOverlay.removeGraphic(graphic)
        }
    }
    
    /// Deletes the provided trace from the list of completed traces.
    /// - Parameter trace: The trace to be deleted.
    func deleteTrace(_ trace: Trace) {
        trace.toggleFeatureSelection(selected: false)
        deleteGraphics(for: trace)
        completedTraces.removeAll { $0 == trace }
        selectPreviousTrace()
    }
    
    /// Returns a feature for the given utility element
    /// - Parameter element: The utility element to query the network for
    /// - Returns: A feature for the given element
    func feature(for element: UtilityElement) async -> ArcGISFeature? {
        do {
            return try await network?.features(for: [element]).first ?? nil
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /// Manually loads the components necessary to use the trace tool.
    func load() async {
        do {
            try await map.load()
            for network in map.utilityNetworks {
                try await network.load()
            }
        } catch {
            print(error.localizedDescription)
        }
        network = map.utilityNetworks.first
        configurations = await utilityNamedTraceConfigurations(from: map)
        if map.utilityNetworks.isEmpty {
            userAlert = .noUtilityNetworksFound
        }
        await addExternalStartingPoints()
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
    
    /// Updates the fractional portion of an edge based starting point.
    /// - Parameters:
    ///   - startingPoint: The starting point to be updated.
    ///   - newValue: A fraction along the starting point's edge.
    func setFractionAlongEdgeFor(
        startingPoint: UtilityNetworkTraceStartingPoint,
        to newValue: Double
    ) {
        pendingTrace.startingPoints.first {
            $0 == startingPoint
        }?.utilityElement?.fractionAlongEdge = newValue
        if let geometry = startingPoint.geoElement.geometry,
           let polyline = geometry as? Polyline {
            startingPoint.graphic?.geometry = GeometryEngine.point(
                along: polyline,
                atDistance: GeometryEngine.length(of: geometry) * newValue
            )
        }
    }
    
    /// Changes the selected network.
    ///
    /// This function also clears any set starting points in the pending trace and reloads the list of available
    /// trace configurations.
    /// - Parameter network: The new utility network to be selected.
    func setNetwork(_ network: UtilityNetwork) {
        self.network = network
        pendingTrace.startingPoints.removeAll()
        Task {
            configurations = await utilityNamedTraceConfigurations(from: map)
        }
    }
    
    /// Updates the pending trace's configuration and name, if applicable.
    ///
    /// The pending trace's name will only be updated if the user hasn't specified one already.
    /// - Parameter configuration: The selected configuration for the pending trace.
    func setPendingTrace(configuration: UtilityNamedTraceConfiguration) {
        pendingTrace.configuration = configuration
        if !pendingTrace.userDidSpecifyName {
            // If the user didn't specify a custom trace name, generate one consisting of trace
            // configuration name followed by the number of completed traces in memory performed with
            // that configuration.
            pendingTrace.name = "\(configuration.name) \((completedTraces.filter({ $0.configuration?.name == configuration.name }).count + 1).description)"
        }
    }
    
    /// Sets the nullable members of the provided starting point and adds it to the pending trace.
    /// - Parameter startingPoint: The starting point to be processed and added to the pending trace.
    func processAndAdd(startingPoint: UtilityNetworkTraceStartingPoint) async {
        guard let feature = startingPoint.geoElement as? ArcGISFeature,
              let globalID = feature.globalID else {
            userAlert = .unableToIdentifyElement
            return
        }
        
        // Block duplicate starting point selection
        guard !pendingTrace.startingPoints.contains(where: { startingPoint in
            return startingPoint.utilityElement?.globalID == globalID
        }) else {
            userAlert = .duplicateStartingPoint
            return
        }
        
        guard let network = self.network,
              let geometry = feature.geometry,
              let symbol = try? await (feature.table?.layer as? FeatureLayer)?
            .renderer?
            .symbol(for: feature)?
            .makeSwatch(scale: 1.0),
              let utilityElement = network.makeElement(arcGISFeature: feature) else { return }
        
        if utilityElement.networkSource.kind == .edge && geometry is Polyline {
            if let mapPoint = startingPoint.mapPoint {
                utilityElement.fractionAlongEdge = fractionAlongEdge(
                    of: geometry,
                    at: mapPoint
                )
            } else {
                utilityElement.fractionAlongEdge = 0.5
            }
        } else if utilityElement.networkSource.kind == .junction &&
                    utilityElement.assetType.terminalConfiguration?.terminals.count ?? 0 > 1 {
            utilityElement.terminal = utilityElement.assetType.terminalConfiguration?.terminals.first
        }
        
        let graphic = Graphic(
            geometry: startingPoint.mapPoint ?? feature.geometry?.extent.center,
            symbol: SimpleMarkerSymbol(
                style: .cross,
                color: UIColor(self.pendingTrace.color),
                size: 20
            )
        )
        
        var newStartingPoint = startingPoint
        newStartingPoint.graphic = graphic
        newStartingPoint.image = symbol
        newStartingPoint.utilityElement = utilityElement
        
        graphicsOverlay.addGraphic(graphic)
        pendingTrace.startingPoints.append(newStartingPoint)
    }
    
    /// Sets the terminal configuration of the provided starting point.
    /// - Parameters:
    ///   - startingPoint: The starting point to be modified.
    ///   - newValue: The new utility terminal to be set on the provided starting point.
    func setTerminalConfigurationFor(
        startingPoint: UtilityNetworkTraceStartingPoint,
        to newValue: UtilityTerminal
    ) {
        pendingTrace.startingPoints.first {
            $0 == startingPoint
        }?.utilityElement?.terminal = newValue
        objectWillChange.send()
    }
    
    /// Runs the pending trace and stores it into the list of completed traces.
    /// - Returns: A Boolean value indicating whether the trace was successful or not.
    func trace() async -> Bool {
        guard let configuration = pendingTrace.configuration,
              let network = network else { return false }
        
        if pendingTrace.startingPoints.isEmpty && configuration.minimumStartingLocations == .one {
            userAlert = .startingLocationNotDefined
            return false
        }
        
        if pendingTrace.startingPoints.count < 2 && configuration.minimumStartingLocations == .many {
            userAlert = .startingLocationsNotDefined
            return false
        }
        
        let parameters = UtilityTraceParameters(
            namedTraceConfiguration: configuration,
            startingLocations: pendingTrace.startingPoints.compactMap { $0.utilityElement }
        )
        
        let traceResults: [UtilityTraceResult]
        
        do {
            traceResults = try await network.trace(using: parameters)
        } catch(let serviceError as ServiceError) {
            userAlert = .init(description: serviceError.details)
            return false
        } catch {
            userAlert = .init(description: error.localizedDescription)
            return false
        }
        
        for result in traceResults {
            switch result {
            case let result as UtilityElementTraceResult:
                pendingTrace.elementResults = result.elements
                if let features = try? await network.features(for: result.elements) {
                    pendingTrace.featureResults = features
                }
            case let result as UtilityGeometryTraceResult:
                let createGraphic: ((Geometry, SimpleLineSymbol.Style, Color) -> (Graphic)) = { geometry, style, color in
                    return Graphic(
                        geometry: geometry,
                        symbol: SimpleLineSymbol(
                            style: style,
                            color: UIColor(color),
                            width: 5.0
                        )
                    )
                }
                if let polygon = result.polygon {
                    let graphic = createGraphic(polygon, .solid, pendingTrace.color)
                    graphicsOverlay.addGraphic(graphic)
                    pendingTrace.graphics.append(graphic)
                }
                if let polyline = result.polyline {
                    let graphic = createGraphic(polyline, .dash, pendingTrace.color)
                    graphicsOverlay.addGraphic(graphic)
                    pendingTrace.graphics.append(graphic)
                }
                if let multipoint = result.multipoint {
                    let graphic = createGraphic(multipoint, .dot, pendingTrace.color)
                    graphicsOverlay.addGraphic(graphic)
                    pendingTrace.graphics.append(graphic)
                }
                pendingTrace.utilityGeometryTraceResult = result
            case let result as UtilityFunctionTraceResult:
                result.functionOutputs.forEach { functionOutput in
                    pendingTrace.functionOutputs.append(functionOutput)
                }
                pendingTrace.utilityFunctionTraceResult = result
            default:
                break
            }
        }
        
        // Save the starting points used in this trace
        let previousStartingPoints = pendingTrace.startingPoints
        
        // Save the completed trace and select it
        completedTraces.append(pendingTrace)
        selectedTraceIndex = completedTraces.count - 1
        
        // Create and configure a new trace
        pendingTrace = Trace()
        for startingPoint in previousStartingPoints {
            await processAndAdd(startingPoint: startingPoint)
        }
        
        return true
    }
    
    /// Updates the matching completed trace.
    /// - Parameter newValue: The new completed trace.
    func update(completedTrace newValue: Trace) {
        guard let traceIndex = completedTraces.firstIndex( where: { trace in
            trace == newValue
        }) else { return }
        completedTraces[traceIndex] = newValue
    }
    
    // MARK: Private Methods
    
    /// Adds programatic starting points to the pending trace.
    private func addExternalStartingPoints() async {
        pendingTrace.startingPoints.forEach { startingPoint in
            deleteStartingPoint(startingPoint)
        }
        
        for startingPoint in externalStartingPoints {
            await processAndAdd(startingPoint: startingPoint)
        }
    }
    
    /// Changes the selection and visibility state of the graphics and feature results, as well the starting
    /// points for the completed trace at the provided index.
    /// - Parameters:
    ///   - index: The index of the completed trace.
    ///   - isSelected: The new selection state.
    private func changeSelectedStateForTrace(
        at index: Int,
        to isSelected: Bool
    ) {
        guard index >= 0, index <= completedTraces.count - 1 else { return }
        
        // Toggle visibility of graphic results
        _ = completedTraces[index].graphics.map { $0.isVisible = isSelected }
        
        // Toggle visibility and selection of starting points
        _ = completedTraces[index].startingPoints.map {
            $0.graphic?.isVisible = isSelected
            $0.graphic?.isSelected = isSelected
        }
        
        // Toggle selection of feature results
        completedTraces[index].toggleFeatureSelection(selected: isSelected)
    }
    
    /// Deletes all graphics for the provided trace.
    /// - Parameter trace: The trace to which delete graphics for.
    private func deleteGraphics(for trace: Trace) {
        graphicsOverlay.removeGraphics(trace.startingPoints.compactMap { $0.graphic })
        graphicsOverlay.removeGraphics(trace.graphics)
    }
    
    /// - Parameter map: A web map containing one or more utility networks.
    /// - Returns: The named trace configurations in the network on the provided map.
    func utilityNamedTraceConfigurations(from map: Map) async -> [UtilityNamedTraceConfiguration] {
        guard let network = network else { return [] }
        do {
            return try await map.namedTraceConfigurations(from: network)
        } catch {
            print(
                "Failed to retrieve configurations.",
                error.localizedDescription
            )
            return []
        }
    }
}

@available(visionOS, unavailable)
extension UtilityNetworkTraceViewModel {
    /// Finds the location on a polyline nearest the point.
    /// - Parameters:
    ///   - inputGeometry: The polyline to be evaluated.
    ///   - point: A location along the polyline.
    /// - Returns: A location along the polyline expressed as a fraction of its total length.
    private func fractionAlongEdge(
        of inputGeometry: Geometry,
        at point: Point
    ) -> Double {
        guard var geometry = inputGeometry as? Polyline else { return .zero }
        // Remove Z
        if geometry.hasZ {
            geometry = GeometryEngine.makeGeometry(
                from: geometry,
                z: nil
            )
        }
        
        // Confirm spatial references match
        if let spatialReference = point.spatialReference,
           spatialReference != geometry.spatialReference,
           let projectedGeometry = GeometryEngine.project(
            geometry,
            into: spatialReference
           ) {
            geometry = projectedGeometry
        }
        
        return GeometryEngine.polyline(
            geometry,
            fractionalLengthClosestTo: point,
            tolerance: 10
        )
    }
}

extension UtilityNetwork {
    /// The defined in the network.
    var layers: [Layer] {
        definition?.networkSources.compactMap { $0.featureTable.layer } ?? []
    }
}
