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
***REMOVED***

extension UtilityNetworkTraceViewModel {
***REMOVED******REMOVED***/ A trace performed on a utility network.
***REMOVED***struct Trace {
***REMOVED******REMOVED******REMOVED***/ The number of assets returned by the trace.
***REMOVED******REMOVED***var assetCount: Int = 0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A collection of all elements returned in the trace, grouped by asset group and asset type.
***REMOVED******REMOVED***var assets = [String: [String: [UtilityElement]]]()
***REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED***/ The extent of the trace's geometry result with a small added buffer.
***REMOVED******REMOVED***var resultExtent: Envelope? {
***REMOVED******REMOVED******REMOVED***if let resultEnvelope = GeometryEngine.combineExtents(of: [
***REMOVED******REMOVED******REMOVED******REMOVED***utilityGeometryTraceResult?.multipoint,
***REMOVED******REMOVED******REMOVED******REMOVED***utilityGeometryTraceResult?.polygon,
***REMOVED******REMOVED******REMOVED******REMOVED***utilityGeometryTraceResult?.polyline
***REMOVED******REMOVED******REMOVED***].compactMap { $0 ***REMOVED***),
***REMOVED******REMOVED******REMOVED***   let expandedEnvelope = GeometryEngine.buffer(
***REMOVED******REMOVED******REMOVED******REMOVED***around: resultEnvelope,
***REMOVED******REMOVED******REMOVED******REMOVED***distance: 200
***REMOVED******REMOVED******REMOVED***   ) {
***REMOVED******REMOVED******REMOVED******REMOVED***return expandedEnvelope.extent
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A collection of starting points for the trace.
***REMOVED******REMOVED***var startingPoints = [UtilityNetworkTraceStartingPoint]()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Indicates that the user has specified a name for the trace.
***REMOVED******REMOVED***var userDidSpecifyName: Bool = false
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

extension UtilityNetworkTraceViewModel.Trace: Equatable {
***REMOVED***static func == (
***REMOVED******REMOVED***lhs: UtilityNetworkTraceViewModel.Trace,
***REMOVED******REMOVED***rhs: UtilityNetworkTraceViewModel.Trace
***REMOVED***) -> Bool {
***REMOVED******REMOVED***return lhs.id == rhs.id
***REMOVED***
***REMOVED***
