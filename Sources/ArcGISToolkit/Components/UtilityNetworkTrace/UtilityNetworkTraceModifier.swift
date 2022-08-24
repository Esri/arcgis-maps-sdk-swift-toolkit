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

public extension MapView {
***REMOVED******REMOVED***/ Adds a graphical interface to run pre-configured traces on a map's utility networks.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating if the view is presented.
***REMOVED******REMOVED***/   - graphicsOverlay: The graphics overlay to hold generated starting point and trace graphics.
***REMOVED******REMOVED***/   - map: The map containing the utility network(s).
***REMOVED******REMOVED***/   - mapPoint: Acts as the point at which newly selected starting point graphics will be created.
***REMOVED******REMOVED***/   - viewPoint: Acts as the point of identification for items tapped in the utility network.
***REMOVED******REMOVED***/   - mapViewProxy: Provides a method of layer identification when starting points are being
***REMOVED******REMOVED***/   chosen.
***REMOVED******REMOVED***/   - viewpoint: Allows the utility network trace tool to update the parent map view's viewpoint.
***REMOVED******REMOVED***/   - startingPoints: An optional list of programmatically provided starting points.
***REMOVED***@ViewBuilder func utilityNetworkTrace(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***graphicsOverlay: Binding<GraphicsOverlay>,
***REMOVED******REMOVED***map: Map,
***REMOVED******REMOVED***mapPoint: Binding<Point?>,
***REMOVED******REMOVED***viewPoint: Binding<CGPoint?>,
***REMOVED******REMOVED***mapViewProxy: Binding<MapViewProxy?>,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>,
***REMOVED******REMOVED***startingPoints: Binding<[UtilityNetworkTraceStartingPoint]> = .constant([])
***REMOVED***) -> some View {
***REMOVED******REMOVED***modifier(
***REMOVED******REMOVED******REMOVED***UtilityNetworkTraceModifier(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay: graphicsOverlay,
***REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED***mapPoint: mapPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***viewPoint: viewPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***mapViewProxy: mapViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED***startingPoints: startingPoints,
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED***/ Overlays the provided content with a Floating Panel that contains a Utility Network Trace.
struct UtilityNetworkTraceModifier: ViewModifier {
***REMOVED******REMOVED***/ A Boolean value indicating if the view is presented.
***REMOVED***@Binding var isPresented: Bool
***REMOVED***
***REMOVED******REMOVED***/ The current detent of the floating panel.
***REMOVED***@State var activeDetent: FloatingPanelDetent = .half
***REMOVED***
***REMOVED******REMOVED***/ The graphics overlay to hold generated starting point and trace graphics.
***REMOVED***@Binding var graphicsOverlay: GraphicsOverlay
***REMOVED***
***REMOVED******REMOVED***/ The map containing the utility network(s).
***REMOVED***let map: Map
***REMOVED***
***REMOVED******REMOVED***/ Acts as the point at which newly selected starting point graphics will be created
***REMOVED***@Binding var mapPoint: Point?
***REMOVED***
***REMOVED******REMOVED***/ Acts as the point of identification for items tapped in the utility network.
***REMOVED***@Binding var viewPoint: CGPoint?
***REMOVED***
***REMOVED******REMOVED***/ Provides a method of layer identification when starting points are being chosen.
***REMOVED***@Binding var mapViewProxy: MapViewProxy?
***REMOVED***
***REMOVED******REMOVED***/ An optional list of programmatically provided starting points.
***REMOVED***@Binding var startingPoints: [UtilityNetworkTraceStartingPoint]
***REMOVED***
***REMOVED******REMOVED***/ Allows the utility network trace tool to update the parent map view's viewpoint.
***REMOVED***@Binding var viewpoint: Viewpoint?
***REMOVED***
***REMOVED***@ViewBuilder func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED***backgroundColor: Color(uiColor: .systemGroupedBackground),
***REMOVED******REMOVED******REMOVED******REMOVED***detent: $activeDetent,
***REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .trailing,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $isPresented
***REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***UtilityNetworkTrace(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***activeDetent: $activeDetent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay: $graphicsOverlay,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapPoint: $mapPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewPoint: $viewPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapViewProxy: $mapViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***startingPoints: $startingPoints
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
