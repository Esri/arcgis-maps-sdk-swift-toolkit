***REMOVED*** Copyright 2022 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import Combine
import Foundation
***REMOVED***

@available(visionOS, unavailable)
@MainActor final class UtilityNetworkTraceViewModel: ObservableObject {
***REMOVED******REMOVED*** MARK: Published Properties
***REMOVED***
***REMOVED******REMOVED***/ A list of completed traces.
***REMOVED***@Published private(set) var completedTraces = [Trace]()
***REMOVED***
***REMOVED******REMOVED***/ The available named trace configurations.
***REMOVED***@Published private(set) var configurations = [UtilityNamedTraceConfiguration]() {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***if configurations.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***userAlert = .noTraceTypesFound
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
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
***REMOVED******REMOVED***/ Alert presented to the user
***REMOVED***@Published var userAlert: UtilityNetworkTraceUserAlert?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the pending trace is configured to the point that it can be run.
***REMOVED***var canRunTrace: Bool {
***REMOVED******REMOVED***network != nil
***REMOVED******REMOVED***&& pendingTrace.configuration != nil
***REMOVED******REMOVED***&& !pendingTrace.startingPoints.isEmpty
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
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***await addExternalStartingPoints()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The selected trace.
***REMOVED***var selectedTrace: Trace? {
***REMOVED******REMOVED***if let index = selectedTraceIndex,
***REMOVED******REMOVED***   index >= 0, index < completedTraces.count {
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
***REMOVED******REMOVED***/   - autoLoad: If set `false`, `load()` will need to be manually called.
***REMOVED***init(
***REMOVED******REMOVED***map: Map,
***REMOVED******REMOVED***graphicsOverlay: GraphicsOverlay,
***REMOVED******REMOVED***startingPoints: [UtilityNetworkTraceStartingPoint] = [],
***REMOVED******REMOVED***autoLoad: Bool = true
***REMOVED***) {
***REMOVED******REMOVED***self.map = map
***REMOVED******REMOVED***self.graphicsOverlay = graphicsOverlay
***REMOVED******REMOVED***self.externalStartingPoints = startingPoints
***REMOVED******REMOVED***if autoLoad {
***REMOVED******REMOVED******REMOVED***Task { await load() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Adds new starting points to the pending trace.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - screenPoint: A point on the map in screen coordinates.
***REMOVED******REMOVED***/   - mapPoint: A point on the map in map coordinates.
***REMOVED******REMOVED***/   - proxy: Provides a method of layer identification.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ An identify operation will run on each layer in the network. Every element returned from
***REMOVED******REMOVED***/ each layer will be added as a new starting point.
***REMOVED***func addStartingPoints(at screenPoint: CGPoint, mapPoint: Point, with proxy: MapViewProxy) async {
***REMOVED******REMOVED***await withTaskGroup(of: Void.self) { [weak self] taskGroup in
***REMOVED******REMOVED******REMOVED***guard let self else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***for layer in network?.layers ?? [] {
***REMOVED******REMOVED******REMOVED******REMOVED***taskGroup.addTask { @MainActor @Sendable in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let result = try? await proxy.identify(on: layer, screenPoint: screenPoint, tolerance: 10) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for element in result.geoElements {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await self.processAndAdd(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***startingPoint: UtilityNetworkTraceStartingPoint(geoElement: element, mapPoint: mapPoint)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Deletes all of the completed traces.
***REMOVED***func deleteAllTraces() {
***REMOVED******REMOVED***selectedTraceIndex = nil
***REMOVED******REMOVED***completedTraces.forEach { traceResult in
***REMOVED******REMOVED******REMOVED***deleteGraphics(for: traceResult)
***REMOVED***
***REMOVED******REMOVED***completedTraces.removeAll()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Deletes the provided starting point from the pending trace.
***REMOVED******REMOVED***/ - Parameter startingPoint: The starting point to be deleted.
***REMOVED***func deleteStartingPoint(_ startingPoint: UtilityNetworkTraceStartingPoint) {
***REMOVED******REMOVED***pendingTrace.startingPoints.removeAll {
***REMOVED******REMOVED******REMOVED***$0 == startingPoint
***REMOVED***
***REMOVED******REMOVED***if let graphic = startingPoint.graphic {
***REMOVED******REMOVED******REMOVED***graphicsOverlay.removeGraphic(graphic)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Deletes the provided trace from the list of completed traces.
***REMOVED******REMOVED***/ - Parameter trace: The trace to be deleted.
***REMOVED***func deleteTrace(_ trace: Trace) {
***REMOVED******REMOVED***trace.toggleFeatureSelection(selected: false)
***REMOVED******REMOVED***deleteGraphics(for: trace)
***REMOVED******REMOVED***completedTraces.removeAll { $0 == trace ***REMOVED***
***REMOVED******REMOVED***selectPreviousTrace()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a feature for the given utility element
***REMOVED******REMOVED***/ - Parameter element: The utility element to query the network for
***REMOVED******REMOVED***/ - Returns: A feature for the given element
***REMOVED***func feature(for element: UtilityElement) async -> ArcGISFeature? {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***return try await network?.features(for: [element]).first ?? nil
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***print(error.localizedDescription)
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Manually loads the components necessary to use the trace tool.
***REMOVED***func load() async {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED******REMOVED***for network in map.utilityNetworks {
***REMOVED******REMOVED******REMOVED******REMOVED***try await network.load()
***REMOVED******REMOVED***
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***print(error.localizedDescription)
***REMOVED***
***REMOVED******REMOVED***network = map.utilityNetworks.first
***REMOVED******REMOVED***configurations = await utilityNamedTraceConfigurations(from: map)
***REMOVED******REMOVED***if map.utilityNetworks.isEmpty {
***REMOVED******REMOVED******REMOVED***userAlert = .noUtilityNetworksFound
***REMOVED***
***REMOVED******REMOVED***await addExternalStartingPoints()
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
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This function also clears any set starting points in the pending trace and reloads the list of available
***REMOVED******REMOVED***/ trace configurations.
***REMOVED******REMOVED***/ - Parameter network: The new utility network to be selected.
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
***REMOVED******REMOVED******REMOVED******REMOVED*** If the user didn't specify a custom trace name, generate one consisting of trace
***REMOVED******REMOVED******REMOVED******REMOVED*** configuration name followed by the number of completed traces in memory performed with
***REMOVED******REMOVED******REMOVED******REMOVED*** that configuration.
***REMOVED******REMOVED******REMOVED***pendingTrace.name = "\(configuration.name) \((completedTraces.filter({ $0.configuration?.name == configuration.name ***REMOVED***).count + 1).description)"
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the nullable members of the provided starting point and adds it to the pending trace.
***REMOVED******REMOVED***/ - Parameter startingPoint: The starting point to be processed and added to the pending trace.
***REMOVED***func processAndAdd(startingPoint: UtilityNetworkTraceStartingPoint) async {
***REMOVED******REMOVED***guard let feature = startingPoint.geoElement as? ArcGISFeature,
***REMOVED******REMOVED******REMOVED***  let globalID = feature.globalID else {
***REMOVED******REMOVED******REMOVED***userAlert = .unableToIdentifyElement
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Block duplicate starting point selection
***REMOVED******REMOVED***guard !pendingTrace.startingPoints.contains(where: { startingPoint in
***REMOVED******REMOVED******REMOVED***return startingPoint.utilityElement?.globalID == globalID
***REMOVED***) else {
***REMOVED******REMOVED******REMOVED***userAlert = .duplicateStartingPoint
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let network = self.network,
***REMOVED******REMOVED******REMOVED***  let geometry = feature.geometry,
***REMOVED******REMOVED******REMOVED***  let symbol = try? await (feature.table?.layer as? FeatureLayer)?
***REMOVED******REMOVED******REMOVED***.renderer?
***REMOVED******REMOVED******REMOVED***.symbol(for: feature)?
***REMOVED******REMOVED******REMOVED***.makeSwatch(scale: 1.0),
***REMOVED******REMOVED******REMOVED***  let utilityElement = network.makeElement(arcGISFeature: feature) else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if utilityElement.networkSource.kind == .edge && geometry is Polyline {
***REMOVED******REMOVED******REMOVED***if let mapPoint = startingPoint.mapPoint {
***REMOVED******REMOVED******REMOVED******REMOVED***utilityElement.fractionAlongEdge = fractionAlongEdge(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***of: geometry,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***at: mapPoint
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***utilityElement.fractionAlongEdge = 0.5
***REMOVED******REMOVED***
***REMOVED*** else if utilityElement.networkSource.kind == .junction &&
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***utilityElement.assetType.terminalConfiguration?.terminals.count ?? 0 > 1 {
***REMOVED******REMOVED******REMOVED***utilityElement.terminal = utilityElement.assetType.terminalConfiguration?.terminals.first
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let graphic = Graphic(
***REMOVED******REMOVED******REMOVED***geometry: startingPoint.mapPoint ?? feature.geometry?.extent.center,
***REMOVED******REMOVED******REMOVED***symbol: SimpleMarkerSymbol(
***REMOVED******REMOVED******REMOVED******REMOVED***style: .cross,
***REMOVED******REMOVED******REMOVED******REMOVED***color: UIColor(self.pendingTrace.color),
***REMOVED******REMOVED******REMOVED******REMOVED***size: 20
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var newStartingPoint = startingPoint
***REMOVED******REMOVED***newStartingPoint.graphic = graphic
***REMOVED******REMOVED***newStartingPoint.image = symbol
***REMOVED******REMOVED***newStartingPoint.utilityElement = utilityElement
***REMOVED******REMOVED***
***REMOVED******REMOVED***graphicsOverlay.addGraphic(graphic)
***REMOVED******REMOVED***pendingTrace.startingPoints.append(newStartingPoint)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the terminal configuration of the provided starting point.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - startingPoint: The starting point to be modified.
***REMOVED******REMOVED***/   - newValue: The new utility terminal to be set on the provided starting point.
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
***REMOVED******REMOVED***if pendingTrace.startingPoints.isEmpty && configuration.minimumStartingLocations == .one {
***REMOVED******REMOVED******REMOVED***userAlert = .startingLocationNotDefined
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if pendingTrace.startingPoints.count < 2 && configuration.minimumStartingLocations == .many {
***REMOVED******REMOVED******REMOVED***userAlert = .startingLocationsNotDefined
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
***REMOVED******REMOVED******REMOVED***traceResults = try await network.trace(using: parameters)
***REMOVED*** catch(let serviceError as ServiceError) {
***REMOVED******REMOVED******REMOVED***userAlert = .init(description: serviceError.details)
***REMOVED******REMOVED******REMOVED***return false
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***userAlert = .init(description: error.localizedDescription)
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***for result in traceResults {
***REMOVED******REMOVED******REMOVED***switch result {
***REMOVED******REMOVED******REMOVED***case let result as UtilityElementTraceResult:
***REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.elementResults = result.elements
***REMOVED******REMOVED******REMOVED******REMOVED***if let features = try? await network.features(for: result.elements) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.featureResults = features
***REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Save the starting points used in this trace
***REMOVED******REMOVED***let previousStartingPoints = pendingTrace.startingPoints
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Save the completed trace and select it
***REMOVED******REMOVED***completedTraces.append(pendingTrace)
***REMOVED******REMOVED***selectedTraceIndex = completedTraces.count - 1
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Create and configure a new trace
***REMOVED******REMOVED***pendingTrace = Trace()
***REMOVED******REMOVED***for startingPoint in previousStartingPoints {
***REMOVED******REMOVED******REMOVED***await processAndAdd(startingPoint: startingPoint)
***REMOVED***
***REMOVED******REMOVED***
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
***REMOVED***private func addExternalStartingPoints() async {
***REMOVED******REMOVED***pendingTrace.startingPoints.forEach { startingPoint in
***REMOVED******REMOVED******REMOVED***if startingPoint.isExternalStartingPoint {
***REMOVED******REMOVED******REMOVED******REMOVED***deleteStartingPoint(startingPoint)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***for var startingPoint in externalStartingPoints {
***REMOVED******REMOVED******REMOVED***startingPoint.isExternalStartingPoint = true
***REMOVED******REMOVED******REMOVED***await processAndAdd(startingPoint: startingPoint)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Changes the selection and visibility state of the graphics and feature results, as well the starting
***REMOVED******REMOVED***/ points for the completed trace at the provided index.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - index: The index of the completed trace.
***REMOVED******REMOVED***/   - isSelected: The new selection state.
***REMOVED***private func changeSelectedStateForTrace(
***REMOVED******REMOVED***at index: Int,
***REMOVED******REMOVED***to isSelected: Bool
***REMOVED***) {
***REMOVED******REMOVED***guard index >= 0, index <= completedTraces.count - 1 else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Toggle visibility of graphic results
***REMOVED******REMOVED***_ = completedTraces[index].graphics.map { $0.isVisible = isSelected ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Toggle visibility and selection of starting points
***REMOVED******REMOVED***_ = completedTraces[index].startingPoints.map {
***REMOVED******REMOVED******REMOVED***$0.graphic?.isVisible = isSelected
***REMOVED******REMOVED******REMOVED***$0.graphic?.isSelected = isSelected
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Toggle selection of feature results
***REMOVED******REMOVED***completedTraces[index].toggleFeatureSelection(selected: isSelected)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Deletes all graphics for the provided trace.
***REMOVED******REMOVED***/ - Parameter trace: The trace to which delete graphics for.
***REMOVED***private func deleteGraphics(for trace: Trace) {
***REMOVED******REMOVED***graphicsOverlay.removeGraphics(trace.startingPoints.compactMap { $0.graphic ***REMOVED***)
***REMOVED******REMOVED***graphicsOverlay.removeGraphics(trace.graphics)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ - Parameter map: A web map containing one or more utility networks.
***REMOVED******REMOVED***/ - Returns: The named trace configurations in the network on the provided map.
***REMOVED***func utilityNamedTraceConfigurations(from map: Map) async -> [UtilityNamedTraceConfiguration] {
***REMOVED******REMOVED***guard let network = network else { return [] ***REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***return try await map.namedTraceConfigurations(from: network)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***print(
***REMOVED******REMOVED******REMOVED******REMOVED***"Failed to retrieve configurations.",
***REMOVED******REMOVED******REMOVED******REMOVED***error.localizedDescription
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***return []
***REMOVED***
***REMOVED***
***REMOVED***

@available(visionOS, unavailable)
extension UtilityNetworkTraceViewModel {
***REMOVED******REMOVED***/ Finds the location on a polyline nearest the point.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - inputGeometry: The polyline to be evaluated.
***REMOVED******REMOVED***/   - point: A location along the polyline.
***REMOVED******REMOVED***/ - Returns: A location along the polyline expressed as a fraction of its total length.
***REMOVED***private func fractionAlongEdge(
***REMOVED******REMOVED***of inputGeometry: Geometry,
***REMOVED******REMOVED***at point: Point
***REMOVED***) -> Double {
***REMOVED******REMOVED***guard var geometry = inputGeometry as? Polyline else { return .zero ***REMOVED***
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
***REMOVED******REMOVED******REMOVED***geometry,
***REMOVED******REMOVED******REMOVED***fractionalLengthClosestTo: point,
***REMOVED******REMOVED******REMOVED***tolerance: 10
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

extension UtilityNetwork {
***REMOVED******REMOVED***/ The defined in the network.
***REMOVED***var layers: [Layer] {
***REMOVED******REMOVED***definition?.networkSources.compactMap { $0.featureTable.layer ***REMOVED*** ?? []
***REMOVED***
***REMOVED***
