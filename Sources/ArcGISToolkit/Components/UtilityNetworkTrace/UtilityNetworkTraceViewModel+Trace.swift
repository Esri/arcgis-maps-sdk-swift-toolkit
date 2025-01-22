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
***REMOVED***

extension UtilityNetworkTraceViewModel {
***REMOVED******REMOVED***/ A trace performed on a utility network.
***REMOVED***struct Trace {
***REMOVED******REMOVED******REMOVED***/ A user given color for the trace with a default value of green.
***REMOVED******REMOVED***var color: Color = .green {
***REMOVED******REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Update the color of any pre-existing starting points
***REMOVED******REMOVED******REMOVED******REMOVED***startingPoints.forEach { startingPoint in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let symbol = startingPoint.graphic?.symbol as? SimpleMarkerSymbol else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***symbol.color = UIColor(color)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***graphics.forEach { graphic in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let symbol = graphic.symbol as? SimpleLineSymbol else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***symbol.color = UIColor(color)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The chosen named trace configuration.
***REMOVED******REMOVED***var configuration: UtilityNamedTraceConfiguration?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A collection of all elements returned in the trace.
***REMOVED******REMOVED***var elementResults = [UtilityElement]()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A collection of all feature results returned in the trace.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ Each feature corresponds to an element in `elementResults`.
***REMOVED******REMOVED***var featureResults = [ArcGISFeature]()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A collection of utility trace function outputs.
***REMOVED******REMOVED***var functionOutputs = [UtilityTraceFunctionOutput]()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A collection of graphics generated from the trace.
***REMOVED******REMOVED***var graphics = [Graphic]()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A unique identifier for the trace.
***REMOVED******REMOVED***let id = UUID()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A user given name for the trace.
***REMOVED******REMOVED***var name = ""
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A collection of starting points for the trace.
***REMOVED******REMOVED***var startingPoints = [UtilityNetworkTraceStartingPoint]()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value that indicates that the user has specified a name for the trace.
***REMOVED******REMOVED***var userDidSpecifyName = false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A trace result comprised of a collection of UtilityElement objects.
***REMOVED******REMOVED***var utilityElementTraceResult: UtilityElementTraceResult?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A trace result comprised of a collection of UtilityTraceFunctionOutput objects.
***REMOVED******REMOVED***var utilityFunctionTraceResult: UtilityFunctionTraceResult?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A trace result comprised of Geometry objects
***REMOVED******REMOVED***var utilityGeometryTraceResult: UtilityGeometryTraceResult?
***REMOVED***
***REMOVED***

extension UtilityNetworkTraceViewModel.Trace {
***REMOVED******REMOVED***/ Finds the set of utility elements returned by the trace that belong to the provided
***REMOVED******REMOVED***/ asset group, grouped by type.
***REMOVED******REMOVED***/ - Parameter groupName: A name of a utility asset group.
***REMOVED******REMOVED***/ - Returns: The elements in the indicated group.
***REMOVED***func elementsByType(inGroupNamed groupName: String) -> [String: [UtilityElement]] {
***REMOVED******REMOVED***elements(inAssetGroupNamed: groupName)
***REMOVED******REMOVED******REMOVED***.reduce(into: [:]) { result, element in
***REMOVED******REMOVED******REMOVED******REMOVED***let key = element.assetType.name
***REMOVED******REMOVED******REMOVED******REMOVED***var assetTypeGroup = result[key, default: []]
***REMOVED******REMOVED******REMOVED******REMOVED***assetTypeGroup.append(element)
***REMOVED******REMOVED******REMOVED******REMOVED***result[key] = assetTypeGroup
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Finds the set of utility elements returned by the trace that belong to the provided
***REMOVED******REMOVED***/ asset group.
***REMOVED******REMOVED***/ - Parameter assetGroupName: A name of a utility asset group.
***REMOVED******REMOVED***/ - Returns: The elements in the indicated group.
***REMOVED***func elements(inAssetGroupNamed assetGroupName: String) -> [UtilityElement] {
***REMOVED******REMOVED***elementResults.filter { $0.assetGroup.name == assetGroupName ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Toggles the selection state on feature result.
***REMOVED******REMOVED***/ - Parameter selected: A Boolean value indicating whether the feature is selected or not.
***REMOVED***func toggleFeatureSelection(selected: Bool) {
***REMOVED******REMOVED***featureResults.forEach { feature in
***REMOVED******REMOVED******REMOVED***if let featureLayer = feature.table?.layer as? FeatureLayer {
***REMOVED******REMOVED******REMOVED******REMOVED***if selected {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureLayer.selectFeature(feature)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureLayer.unselectFeature(feature)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A set of the asset group names returned by the trace.
***REMOVED***var assetGroupNames: Set<String> {
***REMOVED******REMOVED***Set(elementResults.map(\.assetGroup.name))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The extent of the trace's geometry result with a small added buffer.
***REMOVED***var resultExtent: Envelope? {
***REMOVED******REMOVED***guard let utilityGeometryTraceResult else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let geometries = [
***REMOVED******REMOVED******REMOVED***utilityGeometryTraceResult.multipoint,
***REMOVED******REMOVED******REMOVED***utilityGeometryTraceResult.polygon,
***REMOVED******REMOVED******REMOVED***utilityGeometryTraceResult.polyline
***REMOVED******REMOVED***]
***REMOVED******REMOVED******REMOVED***.compactMap { geometry in
***REMOVED******REMOVED******REMOVED******REMOVED***if let geometry, !geometry.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return geometry
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let combinedExtents = GeometryEngine.combineExtents(of: geometries),
***REMOVED******REMOVED******REMOVED***  let expandedEnvelope = GeometryEngine.buffer(around: combinedExtents, distance: 200) else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return expandedEnvelope.extent
***REMOVED***
***REMOVED***

extension UtilityNetworkTraceViewModel.Trace: Equatable {
***REMOVED***static func == (lhs: Self, rhs: Self) -> Bool {
***REMOVED******REMOVED***return lhs.id == rhs.id
***REMOVED***
***REMOVED***
