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
***REMOVED******REMOVED******REMOVED***/ A collection of asset labels for all elements returned in the trace.
***REMOVED******REMOVED***var assetLabels = [String]()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A user given color for the trace with a default value of green.
***REMOVED******REMOVED***var color: Color = .green {
***REMOVED******REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Update the color of any pre-existing starting points
***REMOVED******REMOVED******REMOVED******REMOVED***startingPoints.forEach { startingPoint in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let symbol = startingPoint.graphic.symbol as? SimpleMarkerSymbol else { return ***REMOVED***
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
***REMOVED******REMOVED******REMOVED***/ A user given name for the trace.
***REMOVED******REMOVED***var name: String = ""
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A collection of starting points for the trace.
***REMOVED******REMOVED***var startingPoints = [UtilityNetworkTraceStartingPoint]()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A trace result set comprised of an collection of UtilityElement objects.
***REMOVED******REMOVED***var utilityElementTraceResult: UtilityElementTraceResult?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A trace result set comprised of a collection of UtilityTraceFunctionOutput objects.
***REMOVED******REMOVED***var utilityFunctionTraceResult: UtilityFunctionTraceResult?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The trace result comprised of a set of Geometry objects representing the network elements
***REMOVED******REMOVED******REMOVED***/ identified by the trace.
***REMOVED******REMOVED***var utilityGeometryTraceResult: UtilityGeometryTraceResult?
***REMOVED***
***REMOVED***
