***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import Foundation
***REMOVED***

@MainActor final class UtilityNetworkTraceViewModel: ObservableObject {
***REMOVED******REMOVED*** MARK: Published Properties
***REMOVED***
***REMOVED******REMOVED***/ A list of completed traces.
***REMOVED***@Published private(set) var completedTraces = [Trace]()
***REMOVED***
***REMOVED******REMOVED***/ The available named trace configurations.
***REMOVED***@Published private(set) var configurations = [UtilityNamedTraceConfiguration]()
***REMOVED***
***REMOVED******REMOVED***/ The utility network on which traces will be ran.
***REMOVED***@Published private(set) var network: UtilityNetwork?
***REMOVED***
***REMOVED******REMOVED***/ The trace currently under configuration.
***REMOVED***@Published var pendingTrace = Trace()
***REMOVED***
***REMOVED******REMOVED***/ The index of the selected trace.
***REMOVED***@Published private(set) var selectedTraceIndex: Int? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***if let lastIndex = oldValue {
***REMOVED******REMOVED******REMOVED******REMOVED***changeSelectedStateForTrace(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***at: lastIndex,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***to: false
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let currentIndex = selectedTraceIndex {
***REMOVED******REMOVED******REMOVED******REMOVED***changeSelectedStateForTrace(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***at: currentIndex,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***to: true
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Warning message presented to the user
***REMOVED***@Published var userWarning = ""
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the pending trace is configured to the point that it can be run.
***REMOVED***var canRunTrace: Bool {
***REMOVED******REMOVED***network != nil &&
***REMOVED******REMOVED***pendingTrace.configuration != nil &&
***REMOVED******REMOVED***!pendingTrace.startingPoints.isEmpty
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The map's utility networks.
***REMOVED***var networks: [UtilityNetwork] {
***REMOVED******REMOVED***return map.utilityNetworks
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The overlay on which trace graphics will be drawn.
***REMOVED***private var graphicsOverlay: GraphicsOverlay
***REMOVED***
***REMOVED******REMOVED***/ A map containing one or more utility networks.
***REMOVED***private var map: Map
***REMOVED***
***REMOVED******REMOVED***/ Starting points programmatically provided to the trace tool.
***REMOVED***var externalStartingPoints = [UtilityNetworkTraceStartingPoint]() {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***addExternalStartingPoints()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The selected trace.
***REMOVED***var selectedTrace: Trace? {
***REMOVED******REMOVED***if let index = selectedTraceIndex {
***REMOVED******REMOVED******REMOVED***return completedTraces[index]
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Performs required setup.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - map: The map to be loaded that contains at least one utility network.
***REMOVED******REMOVED***/   - graphicsOverlay: The overlay on which trace graphics will be drawn.
***REMOVED******REMOVED***/   - startingPoints: Starting points programmatically provided to the trace tool.
***REMOVED***init(
***REMOVED******REMOVED***map: Map,
***REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay,
***REMOVED******REMOVED***startingPoints: [UtilityNetworkTraceStartingPoint]
***REMOVED***) {
***REMOVED******REMOVED***self.map = map
***REMOVED******REMOVED***self.graphicsOverlay = graphicsOverlay
***REMOVED******REMOVED***self.externalStartingPoints = startingPoints
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED******REMOVED******REMOVED***for network in map.utilityNetworks {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await network.load()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***print(error.localizedDescription)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***network = map.utilityNetworks.first
***REMOVED******REMOVED******REMOVED***configurations = await utilityNamedTraceConfigurations(from: map)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Deletes the provided starting point from the pending trace.
***REMOVED******REMOVED***/ - Parameter startingPoint: The starting point to be deleted.
***REMOVED***func delete(_ startingPoint: UtilityNetworkTraceStartingPoint) {
***REMOVED******REMOVED***pendingTrace.startingPoints.removeAll {
***REMOVED******REMOVED******REMOVED***$0 == startingPoint
***REMOVED***
***REMOVED******REMOVED***if let graphic = startingPoint.graphic {
***REMOVED******REMOVED******REMOVED***graphicsOverlay.removeGraphic(graphic)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Deletes all of the completed traces.
***REMOVED***func deleteAllTraces() {
***REMOVED******REMOVED***selectedTraceIndex = nil
***REMOVED******REMOVED***completedTraces.forEach { traceResult in
***REMOVED******REMOVED******REMOVED***graphicsOverlay.removeGraphics(traceResult.startingPoints.compactMap { $0.graphic ***REMOVED***)
***REMOVED******REMOVED******REMOVED***graphicsOverlay.removeGraphics(traceResult.graphics)
***REMOVED***
***REMOVED******REMOVED***completedTraces.removeAll()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a feature for the given utility element
***REMOVED******REMOVED***/ - Parameter element: The utility element to query the network for
***REMOVED******REMOVED***/ - Returns: A feature for the given element
***REMOVED***func getFeatureFor(element: UtilityElement) async -> ArcGISFeature? {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***return try await network?.getFeatures(for: [element]).first ?? nil
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***print(error.localizedDescription)
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Selects the next trace from the list of completed traces.
***REMOVED***func selectNextTrace() {
***REMOVED******REMOVED***if let current = selectedTraceIndex {
***REMOVED******REMOVED******REMOVED***if current + 1 <= completedTraces.count - 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***selectedTraceIndex = current + 1
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***selectedTraceIndex = 0
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Selects the previous trace from the list of completed traces.
***REMOVED***func selectPreviousTrace() {
***REMOVED******REMOVED***if let current = selectedTraceIndex {
***REMOVED******REMOVED******REMOVED***if current - 1 >= 0 {
***REMOVED******REMOVED******REMOVED******REMOVED***selectedTraceIndex = current - 1
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***selectedTraceIndex = completedTraces.count - 1
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the fractional portion of an edge based starting point.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - startingPoint: The starting point to be updated.
***REMOVED******REMOVED***/   - newValue: A fraction along the starting point's edge.
***REMOVED***func setFractionAlongEdgeFor(
***REMOVED******REMOVED***startingPoint: UtilityNetworkTraceStartingPoint,
***REMOVED******REMOVED***to newValue: Double
***REMOVED***) {
***REMOVED******REMOVED***pendingTrace.startingPoints.first {
***REMOVED******REMOVED******REMOVED***$0 == startingPoint
***REMOVED***?.utilityElement?.fractionAlongEdge = newValue
***REMOVED******REMOVED***if let geometry = startingPoint.geoElement.geometry,
***REMOVED******REMOVED***   let polyline = geometry as? Polyline {
***REMOVED******REMOVED******REMOVED***startingPoint.graphic?.geometry = GeometryEngine.point(
***REMOVED******REMOVED******REMOVED******REMOVED***along: polyline,
***REMOVED******REMOVED******REMOVED******REMOVED***atDistance: GeometryEngine.length(of: geometry) * newValue
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Changes the selected network.
***REMOVED******REMOVED***/ - Parameter network: The new utility network to be selected.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This function also clears any set starting points in the pending trace and reloads the list of available
***REMOVED******REMOVED***/ trace configurations.
***REMOVED***func setNetwork(_ network: UtilityNetwork) {
***REMOVED******REMOVED***self.network = network
***REMOVED******REMOVED***pendingTrace.startingPoints.removeAll()
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***configurations = await utilityNamedTraceConfigurations(from: map)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the pending trace's configuration and name, if applicable.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ The pending trace's name will only be updated if the user hasn't specified one already.
***REMOVED******REMOVED***/ - Parameter configuration: The selected configuration for the pending trace.
***REMOVED***func setPendingTrace(configuration: UtilityNamedTraceConfiguration) {
***REMOVED******REMOVED***pendingTrace.configuration = configuration
***REMOVED******REMOVED***if !pendingTrace.userDidSpecifyName {
***REMOVED******REMOVED******REMOVED***pendingTrace.name = "\(configuration.name) \((completedTraces.filter({ $0.configuration == configuration ***REMOVED***).count + 1).description)"
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Adds a new starting point to the pending trace.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - point: A point on the map in screen coordinates.
***REMOVED******REMOVED***/   - mapPoint: A point on the map in map coordinates.
***REMOVED******REMOVED***/   - proxy: Provides a method of layer identification.
***REMOVED***func setStartingPoint(
***REMOVED******REMOVED***at point: CGPoint,
***REMOVED******REMOVED***mapPoint: Point,
***REMOVED******REMOVED***with proxy: MapViewProxy
***REMOVED***) async {
***REMOVED******REMOVED***let identifyLayerResults = try? await proxy.identifyLayers(
***REMOVED******REMOVED******REMOVED***screenPoint: point,
***REMOVED******REMOVED******REMOVED***tolerance: 10
***REMOVED******REMOVED***)
***REMOVED******REMOVED***identifyLayerResults?.forEach { identifyLayerResult in
***REMOVED******REMOVED******REMOVED***identifyLayerResult.geoElements.forEach { geoElement in
***REMOVED******REMOVED******REMOVED******REMOVED***let startingPoint = UtilityNetworkTraceStartingPoint(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoElement: geoElement,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapPoint: mapPoint
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***setStartingPoint(startingPoint: startingPoint)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Adds a new starting point to the pending trace.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - geoElement: An element that corresponds to another within the utility network.
***REMOVED******REMOVED***/   - mapPoint: A point on the map in map coordinates.
***REMOVED******REMOVED***/   - startingPoint: <#startingPoint description#>
***REMOVED***func setStartingPoint(startingPoint: UtilityNetworkTraceStartingPoint) {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***guard let feature = startingPoint.geoElement as? ArcGISFeature,
***REMOVED******REMOVED******REMOVED******REMOVED***  let globalid = feature.attributes["globalid"] as? UUID else {
***REMOVED******REMOVED******REMOVED******REMOVED***userWarning = "Element could not be identified"
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Block duplicate starting point selection
***REMOVED******REMOVED******REMOVED***guard !pendingTrace.startingPoints.contains(where: { startingPoint in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  return startingPoint.utilityElement?.globalID == globalid
***REMOVED******REMOVED***  ***REMOVED***) else {
***REMOVED******REMOVED******REMOVED******REMOVED***userWarning = "Duplicate starting points cannot be added"
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard let network = self.network,
***REMOVED******REMOVED******REMOVED******REMOVED***  let geometry = feature.geometry,
***REMOVED******REMOVED******REMOVED******REMOVED***  let symbol = try? await (feature.featureTable?.layer as? FeatureLayer)?
***REMOVED******REMOVED******REMOVED******REMOVED***.renderer?
***REMOVED******REMOVED******REMOVED******REMOVED***.symbol(for: feature)?
***REMOVED******REMOVED******REMOVED******REMOVED***.makeSwatch(scale: 1.0),
***REMOVED******REMOVED******REMOVED******REMOVED***  let utilityElement = network.createElement(arcGISFeature: feature) else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if utilityElement.networkSource.kind == .edge && geometry is Polyline {
***REMOVED******REMOVED******REMOVED******REMOVED***if let mapPoint = startingPoint.mapPoint {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***utilityElement.fractionAlongEdge = fractionAlongEdge(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***of: geometry,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***at: mapPoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***utilityElement.fractionAlongEdge = 0.5
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else if utilityElement.networkSource.kind == .junction &&
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***utilityElement.assetType.terminalConfiguration?.terminals.count ?? 0 > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***utilityElement.terminal = utilityElement.assetType.terminalConfiguration?.terminals.first
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let graphic = Graphic(
***REMOVED******REMOVED******REMOVED******REMOVED***geometry: startingPoint.mapPoint ?? feature.geometry?.extent.center,
***REMOVED******REMOVED******REMOVED******REMOVED***symbol: SimpleMarkerSymbol(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .cross,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: UIColor(self.pendingTrace.color),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***size: 20
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***var newStartingPoint = startingPoint
***REMOVED******REMOVED******REMOVED***newStartingPoint.graphic = graphic
***REMOVED******REMOVED******REMOVED***newStartingPoint.image = symbol
***REMOVED******REMOVED******REMOVED***newStartingPoint.utilityElement = utilityElement
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***graphicsOverlay.addGraphic(graphic)
***REMOVED******REMOVED******REMOVED***pendingTrace.startingPoints.append(newStartingPoint)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func setTerminalConfigurationFor(
***REMOVED******REMOVED***startingPoint: UtilityNetworkTraceStartingPoint,
***REMOVED******REMOVED***to newValue: UtilityTerminal
***REMOVED***) {
***REMOVED******REMOVED***pendingTrace.startingPoints.first {
***REMOVED******REMOVED******REMOVED***$0 == startingPoint
***REMOVED***?.utilityElement?.terminal = newValue
***REMOVED******REMOVED***objectWillChange.send()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Runs the pending trace and stores it into the list of completed traces.
***REMOVED******REMOVED***/ - Returns: A Boolean value indicating whether the trace was successful or not.
***REMOVED***func trace() async -> Bool {
***REMOVED******REMOVED***guard let configuration = pendingTrace.configuration,
***REMOVED******REMOVED******REMOVED***  let network = network else { return false ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let minStartingPoints = configuration.minimumStartingLocations.rawValue
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard pendingTrace.startingPoints.count >= minStartingPoints else {
***REMOVED******REMOVED******REMOVED***userWarning = "Please set at least \(minStartingPoints) starting location\(minStartingPoints > 1 ? "s" : "")."
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let parameters = UtilityTraceParameters(
***REMOVED******REMOVED******REMOVED***namedTraceConfiguration: configuration,
***REMOVED******REMOVED******REMOVED***startingLocations: pendingTrace.startingPoints.compactMap { $0.utilityElement ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let traceResults: [UtilityTraceResult]
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***traceResults = try await network.trace(traceParameters: parameters)
***REMOVED*** catch(let serviceError as ServiceError) {
***REMOVED******REMOVED******REMOVED***if let reason = serviceError.failureReason {
***REMOVED******REMOVED******REMOVED******REMOVED***userWarning = reason
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return false
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***userWarning = "An unknown error occurred"
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var assets = [String: [String: [UtilityElement]]]()
***REMOVED******REMOVED***for result in traceResults {
***REMOVED******REMOVED******REMOVED***switch result {
***REMOVED******REMOVED******REMOVED***case let result as UtilityElementTraceResult:
***REMOVED******REMOVED******REMOVED******REMOVED***result.elements.forEach { element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***var assetGroup = assets[element.assetGroup.name, default: [:]]
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***var assetTypeGroup = assetGroup[element.assetType.name, default: []]
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***assetTypeGroup.append(element)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***assetGroup.updateValue(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***assetTypeGroup,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***forKey: element.assetType.name
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***assets.updateValue(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***assetGroup,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***forKey: element.assetGroup.name
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.assetCount = result.elements.count
***REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.assets = assets
***REMOVED******REMOVED******REMOVED***case let result as UtilityGeometryTraceResult:
***REMOVED******REMOVED******REMOVED******REMOVED***let createGraphic: ((Geometry, SimpleLineSymbol.Style, Color) -> (Graphic)) = { geometry, style, color in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return Graphic(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geometry: geometry,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***symbol: SimpleLineSymbol(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: style,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: UIColor(color),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 5.0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if let polygon = result.polygon {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let graphic = createGraphic(polygon, .solid, pendingTrace.color)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay.addGraphic(graphic)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.graphics.append(graphic)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if let polyline = result.polyline {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let graphic = createGraphic(polyline, .dash, pendingTrace.color)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay.addGraphic(graphic)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.graphics.append(graphic)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if let multipoint = result.multipoint {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let graphic = createGraphic(multipoint, .dot, pendingTrace.color)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay.addGraphic(graphic)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.graphics.append(graphic)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.utilityGeometryTraceResult = result
***REMOVED******REMOVED******REMOVED***case let result as UtilityFunctionTraceResult:
***REMOVED******REMOVED******REMOVED******REMOVED***result.functionOutputs.forEach { functionOutput in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.functionOutputs.append(functionOutput)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.utilityFunctionTraceResult = result
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***completedTraces.append(pendingTrace)
***REMOVED******REMOVED***selectedTraceIndex = completedTraces.count - 1
***REMOVED******REMOVED***pendingTrace = Trace()
***REMOVED******REMOVED***addExternalStartingPoints()
***REMOVED******REMOVED***return true
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the matching completed trace.
***REMOVED******REMOVED***/ - Parameter newValue: The new completed trace.
***REMOVED***func update(completedTrace newValue: Trace) {
***REMOVED******REMOVED***guard let traceIndex = completedTraces.firstIndex( where: { trace in
***REMOVED******REMOVED******REMOVED***trace == newValue
***REMOVED***) else { return ***REMOVED***
***REMOVED******REMOVED***completedTraces[traceIndex] = newValue
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Private Methods
***REMOVED***
***REMOVED******REMOVED***/ Adds programatic starting points to the pending trace.
***REMOVED***private func addExternalStartingPoints() {
***REMOVED******REMOVED***externalStartingPoints.forEach {
***REMOVED******REMOVED******REMOVED***setStartingPoint(startingPoint: $0)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Changes the selected state of the graphics for the completed trace at the provided index.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - index: The index of the completed trace.
***REMOVED******REMOVED***/   - isSelected: The new selection state.
***REMOVED***private func changeSelectedStateForTrace(
***REMOVED******REMOVED***at index: Int,
***REMOVED******REMOVED***to isSelected: Bool
***REMOVED***) {
***REMOVED******REMOVED***guard index >= 0, index <= completedTraces.count - 1 else { return ***REMOVED***
***REMOVED******REMOVED***_ = completedTraces[index].graphics.map { $0.isSelected = isSelected ***REMOVED***
***REMOVED******REMOVED***_ = completedTraces[index].startingPoints.map { $0.graphic?.isSelected = isSelected ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads the named trace configurations in the network.
***REMOVED******REMOVED***/ Returns the named trace configurations in the network on the provided map.
***REMOVED******REMOVED***/ - Parameter map: A web map containing one or more utility networks.
***REMOVED***private func utilityNamedTraceConfigurations(from map: Map) async -> [UtilityNamedTraceConfiguration] {
***REMOVED******REMOVED***guard let network = network else { return [] ***REMOVED***
***REMOVED******REMOVED***return (try? await map.getNamedTraceConfigurations(from: network)) ?? []
***REMOVED***
***REMOVED***

extension UtilityNetworkTraceViewModel {
***REMOVED******REMOVED***/ Finds the location on the line nearest the input point, expressed as the fraction along the line’s total
***REMOVED******REMOVED***/ geodesic length.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - inputGeometry: The line to be measured.
***REMOVED******REMOVED***/   - point: A location along the line.
***REMOVED***private func fractionAlongEdge(
***REMOVED******REMOVED***of inputGeometry: Geometry,
***REMOVED******REMOVED***at point: Point
***REMOVED***) -> Double {
***REMOVED******REMOVED***var geometry = inputGeometry
***REMOVED******REMOVED******REMOVED*** Remove Z
***REMOVED******REMOVED***if geometry.hasZ {
***REMOVED******REMOVED******REMOVED***geometry = GeometryEngine.makeGeometry(
***REMOVED******REMOVED******REMOVED******REMOVED***from: geometry,
***REMOVED******REMOVED******REMOVED******REMOVED***z: nil
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Confirm spatial references match
***REMOVED******REMOVED***if let spatialReference = point.spatialReference,
***REMOVED******REMOVED***   spatialReference != geometry.spatialReference,
***REMOVED******REMOVED***   let projectedGeometry = GeometryEngine.project(
***REMOVED******REMOVED******REMOVED***geometry,
***REMOVED******REMOVED******REMOVED***into: spatialReference
***REMOVED******REMOVED***   ) {
***REMOVED******REMOVED******REMOVED***geometry = projectedGeometry
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return GeometryEngine.polyline(
***REMOVED******REMOVED******REMOVED***geometry as! Polyline,
***REMOVED******REMOVED******REMOVED***fractionalLengthClosestTo: point,
***REMOVED******REMOVED******REMOVED***tolerance: 10
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
