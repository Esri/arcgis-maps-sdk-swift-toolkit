***REMOVED***.

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
import Combine
***REMOVED***

***REMOVED***/ OverviewMap is a small, secondary MapView (sometimes called an "inset map"), superimposed on an existing MapView, which shows the visible extent of the main MapView.
public struct OverviewMap: View {
***REMOVED******REMOVED***/ A binding to an optional `MapViewProxy`. When a proxy is
***REMOVED******REMOVED***/   available, the binding will be updated by the view. The proxy is
***REMOVED******REMOVED***/   necessary for accessing `MapView` functionality to get and set viewpoints.
***REMOVED***public var proxy: Binding<MapViewProxy?>
***REMOVED***
***REMOVED******REMOVED***/ The Map displayed in the OverviewMap.
***REMOVED***public var map: Map
***REMOVED***
***REMOVED******REMOVED***/ The fill symbol used to display the main MapView extent.
***REMOVED******REMOVED***/ The default is a transparent SimpleFillSymbol with a red, 1 point width outline.
***REMOVED***public var extentSymbol: FillSymbol
***REMOVED***
***REMOVED******REMOVED***/ The factor to multiply the main GeoView's scale by. The OverviewMap will display
***REMOVED******REMOVED***/ at the product of mainGeoViewScale * scaleFactor.  The default is 25.0.
***REMOVED***public var scaleFactor: Double
***REMOVED***
***REMOVED******REMOVED***/ The geometry of the extent Graphic displaying the main map view's extent.  Updating
***REMOVED******REMOVED***/ this property will update the display of the OverviewMap.
***REMOVED***@State private var extentGeometry: Envelope?
***REMOVED***
***REMOVED******REMOVED***/ The viewpoint of the OverviewMap's MapView.  Updating
***REMOVED******REMOVED***/ this property will update the display of the OverviewMap.
***REMOVED***@State private var overviewMapViewpoint: Viewpoint?
***REMOVED***
***REMOVED******REMOVED***/ Creates an OverviewMap.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - proxy: The binding to an optional MapViewProxy.
***REMOVED******REMOVED***/   - map: The Map to display in the OverviewMap.
***REMOVED******REMOVED***/   - extentSymbol: The FillSymbol used to display the main MapView's extent.
***REMOVED******REMOVED***/   - scaleFactor: The scale factor used to calculate the OverviewMap's scale.
***REMOVED***public init(proxy: Binding<MapViewProxy?>,
***REMOVED******REMOVED******REMOVED******REMOVED***map: Map = Map(basemap: Basemap.topographic()),
***REMOVED******REMOVED******REMOVED******REMOVED***extentSymbol: FillSymbol = SimpleFillSymbol(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .solid,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: .clear,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***outline: SimpleLineSymbol(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .solid,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: .red,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 1.0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***scaleFactor: Double = 25.0
***REMOVED***) {
***REMOVED******REMOVED***self.proxy = proxy
***REMOVED******REMOVED***self.map = map
***REMOVED******REMOVED***self.extentSymbol = extentSymbol
***REMOVED******REMOVED***self.scaleFactor = scaleFactor
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***MapView(map: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $overviewMapViewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlays: [GraphicsOverlay(graphics: [Graphic(geometry: extentGeometry,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  symbol: extentSymbol)])]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.attributionTextHidden()
***REMOVED******REMOVED******REMOVED***.interactionModes([])
***REMOVED******REMOVED******REMOVED***.border(Color.black, width: 1)
***REMOVED******REMOVED******REMOVED***.onReceive(proxy.wrappedValue?.viewpointChangedPublisher
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.receive(on: DispatchQueue.main)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.throttle(for: .seconds(0.25),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  scheduler: DispatchQueue.main,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  latest: true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.eraseToAnyPublisher() ?? Empty<Void, Never>().eraseToAnyPublisher()
***REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***guard let centerAndScaleViewpoint = proxy.wrappedValue?.currentViewpoint(type: .centerAndScale),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let boundingGeometryViewpoint = proxy.wrappedValue?.currentViewpoint(type: .boundingGeometry)
***REMOVED******REMOVED******REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if let newExtent = boundingGeometryViewpoint.targetGeometry as? Envelope {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***extentGeometry = newExtent
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if let viewpointGeometry = centerAndScaleViewpoint.targetGeometry as? Point {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let viewpoint = Viewpoint(center: viewpointGeometry,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  scale: centerAndScaleViewpoint.targetScale * scaleFactor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***overviewMapViewpoint = viewpoint
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
