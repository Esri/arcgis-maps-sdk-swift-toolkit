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
***REMOVED***Toolkit
***REMOVED***

***REMOVED***/ A demonstration of the utility network trace tool which runs traces on a web map published with
***REMOVED***/ a utility network and trace configurations.
struct UtilityNetworkTraceExampleView: View {
***REMOVED***@Environment(\.isPortraitOrientation)
***REMOVED***private var isPortraitOrientation
***REMOVED***
***REMOVED******REMOVED***/ The current detent of the floating panel presenting the trace tool.
***REMOVED***@State private var activeDetent: FloatingPanelDetent = .half
***REMOVED***
***REMOVED******REMOVED***/ The height of the map view's attribution bar.
***REMOVED***@State private var attributionBarHeight: CGFloat = 0
***REMOVED***
***REMOVED******REMOVED***/ The map with the utility networks.
***REMOVED***@State private var map = makeMap()
***REMOVED***
***REMOVED******REMOVED***/ Provides the ability to detect tap locations in the context of the map view.
***REMOVED***@State private var mapPoint: Point?
***REMOVED***
***REMOVED******REMOVED***/ A container for graphical trace results.
***REMOVED***@State private var resultGraphicsOverlay = GraphicsOverlay()
***REMOVED***
***REMOVED***init() {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***let publicSample = try? await ArcGISCredential.publicSample
***REMOVED******REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(publicSample!)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { geometryProxy in
***REMOVED******REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED******REMOVED***let mapView = MapView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlays: [resultGraphicsOverlay]
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.onAttributionBarHeightChanged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight = $0
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { _, mapPoint in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.mapPoint = mapPoint
***REMOVED******REMOVED******REMOVED***
#if os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED***mapView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight: attributionBarHeight,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: $activeDetent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .trailing,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: .constant(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UtilityNetworkTrace(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay: $resultGraphicsOverlay,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapPoint: $mapPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapViewProxy: mapViewProxy
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanelDetent($activeDetent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Manually account for a device's bottom safe area when using a Floating Panel.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** See also #518.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.bottom, isPortraitOrientation ? geometryProxy.safeAreaInsets.bottom : nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.top)
***REMOVED******REMOVED******REMOVED******REMOVED***
#else
***REMOVED******REMOVED******REMOVED******REMOVED***mapView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***attributionBarHeight: attributionBarHeight,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***backgroundColor: Color(uiColor: .systemGroupedBackground),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedDetent: $activeDetent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***horizontalAlignment: .trailing,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: .constant(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UtilityNetworkTrace(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay: $resultGraphicsOverlay,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapPoint: $mapPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapViewProxy: mapViewProxy
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.floatingPanelDetent($activeDetent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Manually account for a device's bottom safe area when using a Floating Panel.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** See also #518.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.bottom, isPortraitOrientation ? geometryProxy.safeAreaInsets.bottom : nil)
***REMOVED******REMOVED******REMOVED******REMOVED***
#endif
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Makes a map from a portal item.
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED***let portalItem = PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: Item.ID(rawValue: "471eb0bf37074b1fbb972b1da70fb310")!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return Map(item: portalItem)
***REMOVED***
***REMOVED***

private extension ArcGISCredential {
***REMOVED***static var publicSample: ArcGISCredential {
***REMOVED******REMOVED***get async throws {
***REMOVED******REMOVED******REMOVED***try await TokenCredential.credential(
***REMOVED******REMOVED******REMOVED******REMOVED***for: URL(string: "https:***REMOVED***sampleserver7.arcgisonline.com/portal/sharing/rest")!,
***REMOVED******REMOVED******REMOVED******REMOVED***username: "viewer01",
***REMOVED******REMOVED******REMOVED******REMOVED***password: "I68VGU^nMurF"
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

private extension EnvironmentValues {
***REMOVED******REMOVED***/ A Boolean value indicating whether this environment has a compact horizontal size class and
***REMOVED******REMOVED***/ a regular vertical size class.
***REMOVED***var isPortraitOrientation: Bool {
***REMOVED******REMOVED***horizontalSizeClass == .compact && verticalSizeClass == .regular
***REMOVED***
***REMOVED***
