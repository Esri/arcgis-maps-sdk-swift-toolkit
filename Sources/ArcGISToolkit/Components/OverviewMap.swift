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

public struct OverviewMap: View {
***REMOVED***public var proxy: Binding<MapViewProxy?>?
***REMOVED***public var map = Map(basemap: Basemap.topographic())
***REMOVED***public var width: CGFloat = 200.0
***REMOVED***public var height: CGFloat = 132.0
***REMOVED***public var extentSymbol = SimpleFillSymbol(style: .solid,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   color: .clear,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   outline: SimpleLineSymbol(style: .solid,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** color: .red,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** width: 1.0)
***REMOVED***)
***REMOVED***
***REMOVED***public var scaleFactor = 25.0
***REMOVED***
***REMOVED******REMOVED***/ The geometry of the extent Graphic displaying the main map view's extent.
***REMOVED***@State private var extentGeometry: Envelope?
***REMOVED***
***REMOVED******REMOVED***/ The proxy for the overviewMap's map view.
***REMOVED***private var overviewMapViewProxy: Binding<MapViewProxy?>?

***REMOVED***private var subscriptions = Set<AnyCancellable>()
***REMOVED***
***REMOVED***public init(proxy: Binding<MapViewProxy?>?,
***REMOVED******REMOVED******REMOVED******REMOVED***map: Map = Map(basemap: Basemap.topographic()),
***REMOVED******REMOVED******REMOVED******REMOVED***width: CGFloat = 200.0,
***REMOVED******REMOVED******REMOVED******REMOVED***height: CGFloat = 132.0,
***REMOVED******REMOVED******REMOVED******REMOVED***extentSymbol: SimpleFillSymbol = SimpleFillSymbol(style: .solid,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  color: .clear,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  outline: SimpleLineSymbol(style: .solid,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: .red,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 1.0))
***REMOVED***) {
***REMOVED******REMOVED***self.proxy = proxy
***REMOVED******REMOVED***self.map = map
***REMOVED******REMOVED***self.width = width
***REMOVED******REMOVED***self.height = height
***REMOVED******REMOVED***self.extentSymbol = extentSymbol
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.proxy?.wrappedValue?.viewpointChangedPublisher.sink(receiveValue: {
***REMOVED******REMOVED******REMOVED***guard let centerAndScaleViewpoint = (proxy?.wrappedValue)?.currentViewpoint(type: .centerAndScale),
***REMOVED******REMOVED******REMOVED******REMOVED***  let boundingGeometryViewpoint = (proxy?.wrappedValue)?.currentViewpoint(type: .boundingGeometry)
***REMOVED******REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let newExtent = boundingGeometryViewpoint.targetGeometry as? Envelope {
***REMOVED******REMOVED******REMOVED******REMOVED***extentGeometry = newExtent
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***(overviewMapViewProxy?.wrappedValue)?.setViewpoint(viewpoint: Viewpoint(center: centerAndScaleViewpoint.targetGeometry as! Point,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** scale: centerAndScaleViewpoint.targetScale * scaleFactor))
***REMOVED***)
***REMOVED******REMOVED***.store(in: &subscriptions)
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***makeMapView()
***REMOVED******REMOVED******REMOVED******REMOVED***.attributionTextHidden()
***REMOVED******REMOVED******REMOVED******REMOVED***.interactionModes([])
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: width, height: height)
***REMOVED******REMOVED******REMOVED******REMOVED***.border(Color.black, width: 1)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func makeMapView() -> MapView {
***REMOVED******REMOVED***let extentGraphic = Graphic(geometry: extentGeometry, symbol: extentSymbol)
***REMOVED******REMOVED***return MapView(map: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   graphicsOverlays: [GraphicsOverlay(graphics: [extentGraphic])],
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   proxy: overviewMapViewProxy
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
