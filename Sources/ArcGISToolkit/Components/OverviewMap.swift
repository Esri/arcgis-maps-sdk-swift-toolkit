***REMOVED***
***REMOVED***  SwiftUIView.swift
***REMOVED***  
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

***REMOVED***/ <#Description#>
public struct OverviewMap: View {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***public var proxy: Binding<MapViewProxy?>

***REMOVED******REMOVED***/ <#Description#>
***REMOVED***public var map: Map

***REMOVED******REMOVED***/ <#Description#>
***REMOVED***public var extentSymbol: SimpleFillSymbol
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***public var scaleFactor: Double
***REMOVED***
***REMOVED******REMOVED***/ The geometry of the extent Graphic displaying the main map view's extent.
***REMOVED***@State private var extentGeometry: Envelope?

***REMOVED***@State private var overviewMapViewpoint: Viewpoint?
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - proxy: <#proxy description#>
***REMOVED******REMOVED***/   - map: <#map description#>
***REMOVED******REMOVED***/   - extentSymbol: <#extentSymbol description#>
***REMOVED***public init(proxy: Binding<MapViewProxy?>,
***REMOVED******REMOVED******REMOVED******REMOVED***map: Map = Map(basemap: Basemap.topographic()),
***REMOVED******REMOVED******REMOVED******REMOVED***extentSymbol: SimpleFillSymbol = SimpleFillSymbol(
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

***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***MapView(map: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $overviewMapViewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlays: [GraphicsOverlay(graphics: [Graphic(geometry: extentGeometry,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  symbol: extentSymbol)])]
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.attributionTextHidden()
***REMOVED******REMOVED******REMOVED******REMOVED***.interactionModes([])
***REMOVED******REMOVED******REMOVED******REMOVED***.border(Color.black, width: 1)
***REMOVED******REMOVED******REMOVED******REMOVED***.onReceive(proxy.wrappedValue?.viewpointChangedPublisher
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.receive(on: DispatchQueue.main)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** I think "throttle" is what we need here because that does
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** not reset the timer when a new value is published, whereas
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** debounce will reset the timer, so if there are multiple
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** values published that arriver faster than the timeout,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** none of them will be sent because the timer gets reset.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** That said, neither of these solve the issue of the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** extent rectangle not getting drawn while the user is
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** panning the map.  The extent rectangle disappears when the user
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** starts panning and will not reappear until the panning stops.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.debounce(for: .seconds(0.25),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  scheduler: DispatchQueue.main)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.throttle(for: .seconds(0.25),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  scheduler: DispatchQueue.main,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  latest: true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.eraseToAnyPublisher() ?? Empty<Void, Never>().eraseToAnyPublisher()
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let centerAndScaleViewpoint = proxy.wrappedValue?.currentViewpoint(type: .centerAndScale),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  centerAndScaleViewpoint.objectType != .unknown,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let boundingGeometryViewpoint = proxy.wrappedValue?.currentViewpoint(type: .boundingGeometry),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  boundingGeometryViewpoint.objectType != .unknown
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else { return ***REMOVED***

***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let newExtent = boundingGeometryViewpoint.targetGeometry as? Envelope {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***extentGeometry = newExtent
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let viewpointGeometry = centerAndScaleViewpoint.targetGeometry as? Point {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let viewpoint = Viewpoint(center: viewpointGeometry,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  scale: centerAndScaleViewpoint.targetScale * scaleFactor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("overviewMapViewpoint updated")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***overviewMapViewpoint = viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
