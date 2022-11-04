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
***REMOVED***Toolkit
***REMOVED***

***REMOVED***/ A demonstration of the utility network trace tool which runs traces on a web map published with a utility
***REMOVED***/ network and trace configurations.
struct UtilityNetworkTraceExampleView: View {
***REMOVED******REMOVED***/ The map containing the utility networks.
***REMOVED***@StateObject private var map = makeMap()
***REMOVED***
***REMOVED******REMOVED***/ The current detent of the floating panel presenting the trace tool.
***REMOVED***@State var activeDetent: FloatingPanelDetent = .half
***REMOVED***
***REMOVED******REMOVED***/ Provides the ability to inspect map components.
***REMOVED***@State var mapViewProxy: MapViewProxy?
***REMOVED***
***REMOVED******REMOVED***/ Provides the ability to detect tap locations in the context of the map view.
***REMOVED***@State var mapPoint: Point?
***REMOVED***
***REMOVED******REMOVED***/ Provides the ability to detect tap locations in the context of the screen.
***REMOVED***@State var viewPoint: CGPoint?
***REMOVED***
***REMOVED******REMOVED***/ A container for graphical trace results.
***REMOVED***@State var resultGraphicsOverlay = GraphicsOverlay()
***REMOVED***
***REMOVED******REMOVED***/ The map viewpoint used by the `UtilityNetworkTrace` to pan/zoom the map to selected features.
***REMOVED***@State var viewpoint: Viewpoint?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlays: [resultGraphicsOverlay]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onSingleTapGesture { viewPoint, mapPoint in
***REMOVED******REMOVED******REMOVED******REMOVED***self.viewPoint = viewPoint
***REMOVED******REMOVED******REMOVED******REMOVED***self.mapPoint = mapPoint
***REMOVED******REMOVED******REMOVED******REMOVED***self.mapViewProxy = mapViewProxy
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = $0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***await ArcGISRuntimeEnvironment.credentialStore.add(try! await .publicSample)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***backgroundColor: Color(uiColor: .systemGroupedBackground),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: $activeDetent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .trailing,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: .constant(true)
***REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***UtilityNetworkTrace(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay: $resultGraphicsOverlay,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapPoint: $mapPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewPoint: $viewPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapViewProxy: $mapViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanelDetent($activeDetent)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes a map from a portal item.
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED***let portalItem = PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(requiresLogin: false),
***REMOVED******REMOVED******REMOVED***id: Item.ID(rawValue: "471eb0bf37074b1fbb972b1da70fb310")!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return Map(item: portalItem)
***REMOVED***
***REMOVED***

private extension ArcGISCredential {
***REMOVED***static var publicSample: ArcGISCredential {
***REMOVED******REMOVED***get async throws {
***REMOVED******REMOVED******REMOVED***try await .token(
***REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***sampleserver7.arcgisonline.com/portal/sharing/rest")!,
***REMOVED******REMOVED******REMOVED******REMOVED***username: "viewer01",
***REMOVED******REMOVED******REMOVED******REMOVED***password: "I68VGU^nMurF"
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
