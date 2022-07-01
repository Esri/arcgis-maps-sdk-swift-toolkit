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
***REMOVED******REMOVED***/ A Boolean value indicating if the pending trace is configured to the point that it can be run.
***REMOVED***var canRunTrace: Bool {
***REMOVED******REMOVED***pendingTrace.configuration != nil && !pendingTrace.startingPoints.isEmpty
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The overlay on which trace graphics will be drawn.
***REMOVED***private var graphicsOverlay: GraphicsOverlay
***REMOVED***
***REMOVED******REMOVED***/ The utility network on which traces will be ran.
***REMOVED***private var network: UtilityNetwork?
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
***REMOVED******REMOVED***/ The first utility network in the provided map will be used.
***REMOVED******REMOVED***/ - Parameter map: The map to be loaded that contains at least one utility network.
***REMOVED******REMOVED***/ - Parameter graphicsOverlay: The overlay on which trace graphics will be drawn.
***REMOVED***init(map: Map, graphicsOverlay: GraphicsOverlay) {
***REMOVED******REMOVED***self.graphicsOverlay = graphicsOverlay
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***try? await map.load()
***REMOVED******REMOVED******REMOVED***network = map.utilityNetworks.first
***REMOVED******REMOVED******REMOVED***await loadNamedTraceConfigurations(map)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Deletes the provided starting point from the pending trace.
***REMOVED******REMOVED***/ - Parameter startingPoint: The starting point to be deleted.
***REMOVED***func delete(_ startingPoint: UtilityNetworkTraceStartingPoint) {
***REMOVED******REMOVED***pendingTrace.startingPoints.removeAll {
***REMOVED******REMOVED******REMOVED***$0.utilityElement.globalID == startingPoint.utilityElement.globalID
***REMOVED***
***REMOVED******REMOVED***graphicsOverlay.removeGraphic(startingPoint.graphic)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Deletes all of the completed traces.
***REMOVED***func deleteAllTraces() {
***REMOVED******REMOVED***selectedTraceIndex = nil
***REMOVED******REMOVED***completedTraces.forEach { traceResult in
***REMOVED******REMOVED******REMOVED***traceResult.startingPoints.forEach { startingPoint in
***REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay.removeGraphic(startingPoint.graphic)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***traceResult.graphics.forEach { graphic in
***REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay.removeGraphic(graphic)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***completedTraces.removeAll()
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
***REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let network = network,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let feature = geoElement as? ArcGISFeature,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let geometry = feature.geometry,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let symbol = try? await (feature.featureTable?.layer as? FeatureLayer)?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.renderer?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbol(for: feature)?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.makeSwatch(scale: 1.0),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let utilityElement = network.createElement(arcGISFeature: feature) else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if utilityElement.networkSource.kind == .edge && geometry is Polyline {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***utilityElement.fractionAlongEdge = fractionAlongEdge(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***of: geometry,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***at: mapPoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED*** else if utilityElement.networkSource.kind == .junction &&
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***utilityElement.assetType.terminalConfiguration?.terminals.count ?? 0 > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***utilityElement.terminal = utilityElement.assetType.terminalConfiguration?.terminals.first
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let graphic = Graphic(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geometry: mapPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***symbol: SimpleMarkerSymbol(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: UIColor(pendingTrace.color),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***size: 20
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let startingPoint = UtilityNetworkTraceStartingPoint(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***extent: geometry.extent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geoElement: geoElement,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphic: graphic,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***image: symbol,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***utilityElement: utilityElement
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay.addGraphic(graphic)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.startingPoints.append(startingPoint)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func setFractionAlongEdgeFor(
***REMOVED******REMOVED***startingPoint: UtilityNetworkTraceStartingPoint,
***REMOVED******REMOVED***to newValue: Double
***REMOVED***) {
***REMOVED******REMOVED***pendingTrace.startingPoints.first {
***REMOVED******REMOVED******REMOVED***$0.utilityElement.globalID == startingPoint.utilityElement.globalID
***REMOVED***?.utilityElement.fractionAlongEdge = newValue
***REMOVED******REMOVED***if let geometry = startingPoint.geoElement.geometry,
***REMOVED******REMOVED***   let polyline = geometry as? Polyline  {
***REMOVED******REMOVED******REMOVED***startingPoint.graphic.geometry = GeometryEngine.point(
***REMOVED******REMOVED******REMOVED******REMOVED***along: polyline,
***REMOVED******REMOVED******REMOVED******REMOVED***atDistance: GeometryEngine.length(of: geometry) * newValue
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func setTerminalConfigurationFor(
***REMOVED******REMOVED***startingPoint: UtilityNetworkTraceStartingPoint,
***REMOVED******REMOVED***to newValue: UtilityTerminal
***REMOVED***) {
***REMOVED******REMOVED***pendingTrace.startingPoints.first {
***REMOVED******REMOVED******REMOVED***$0.utilityElement.globalID == startingPoint.utilityElement.globalID
***REMOVED***?.utilityElement.terminal = newValue
***REMOVED******REMOVED***objectWillChange.send()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Runs the pending trace and stores it into the list of completed traces.
***REMOVED***func trace() {
***REMOVED******REMOVED***guard let config = pendingTrace.configuration,
***REMOVED******REMOVED******REMOVED***  let network = network else { return ***REMOVED***
***REMOVED******REMOVED***let params = UtilityTraceParameters(
***REMOVED******REMOVED******REMOVED***namedTraceConfiguration: config,
***REMOVED******REMOVED******REMOVED***startingLocations: pendingTrace.startingPoints.compactMap{ $0.utilityElement ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***let traceResults = try await network.trace(traceParameters: params)
***REMOVED******REMOVED******REMOVED***var assetGroups = [String: Int]()
***REMOVED******REMOVED******REMOVED***for result in traceResults {
***REMOVED******REMOVED******REMOVED******REMOVED***switch result {
***REMOVED******REMOVED******REMOVED******REMOVED***case let result as UtilityElementTraceResult:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***result.elements.forEach({ element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let count = assetGroups[element.assetGroup.name] ?? 0 + 1
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***assetGroups.updateValue(count, forKey: element.assetGroup.name)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***assetGroups.forEach { (key, value) in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.assetLabels.append("\(key): \(value)")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.utilityElementTraceResult = result
***REMOVED******REMOVED******REMOVED******REMOVED***case let result as UtilityGeometryTraceResult:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let polygon = result.polygon {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let graphic = Graphic(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geometry: polygon,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***symbol: SimpleLineSymbol(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .solid,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: UIColor(pendingTrace.color),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 5.0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay.addGraphic(graphic)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.graphics.append(graphic)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let polyline = result.polyline {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let graphic = Graphic(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geometry: polyline,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***symbol: SimpleLineSymbol(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .dash,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: UIColor(pendingTrace.color),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 5.0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay.addGraphic(graphic)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.graphics.append(graphic)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let multipoint = result.multipoint {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let graphic = Graphic(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geometry: multipoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***symbol: SimpleLineSymbol(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .dot,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: UIColor(pendingTrace.color),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 5.0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay.addGraphic(graphic)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.graphics.append(graphic)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.utilityGeometryTraceResult = result
***REMOVED******REMOVED******REMOVED******REMOVED***case let result as UtilityFunctionTraceResult:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let functionOutputs = result.functionOutputs
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***functionOutputs.forEach { functionOutput in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.functionOutputs.append(functionOutput)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pendingTrace.utilityFunctionTraceResult = result
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***completedTraces.append(pendingTrace)
***REMOVED******REMOVED******REMOVED***selectedTraceIndex = completedTraces.count - 1
***REMOVED******REMOVED******REMOVED***pendingTrace = Trace()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Private Items
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
***REMOVED******REMOVED***completedTraces[index].graphics.forEach({ graphic in
***REMOVED******REMOVED******REMOVED***graphic.isSelected = isSelected
***REMOVED***)
***REMOVED******REMOVED***completedTraces[index].startingPoints.forEach({ startingPoint in
***REMOVED******REMOVED******REMOVED***startingPoint.graphic.isSelected = isSelected
***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads the named trace configurations in the network on the provided map.
***REMOVED******REMOVED***/ - Parameter map: A web map containing one or more utility networks.
***REMOVED***private func loadNamedTraceConfigurations(_ map: Map) async {
***REMOVED******REMOVED***guard let network = network else { return ***REMOVED***
***REMOVED******REMOVED***configurations = (try? await map.getNamedTraceConfigurations(from: network)) ?? []
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

extension UtilityTraceFunctionOutput: Identifiable { ***REMOVED***
