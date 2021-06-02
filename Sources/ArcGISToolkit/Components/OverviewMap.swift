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
***REMOVED***public var geoView: MapView
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
***REMOVED***@State private var extentGeometry = Envelope(center: Point(x: -9813416.487598, y: 5126112.596989), width: 5000000, height: 10000000)
***REMOVED***
***REMOVED***@State private var overviewViewpoint: Viewpoint = Viewpoint(latitude: 0.0, longitude: 0.0, scale: 100000000000)
***REMOVED***
***REMOVED***private var subscriptions = Set<AnyCancellable>()
***REMOVED***
***REMOVED***private var scale = 10000000.0
***REMOVED***
***REMOVED***public init(geoView: MapView,
***REMOVED******REMOVED******REMOVED******REMOVED***map: Map = Map(basemap: Basemap.topographic()),
***REMOVED******REMOVED******REMOVED******REMOVED***width: CGFloat = 200.0,
***REMOVED******REMOVED******REMOVED******REMOVED***height: CGFloat = 132.0,
***REMOVED******REMOVED******REMOVED******REMOVED***extentSymbol: SimpleFillSymbol = SimpleFillSymbol(style: .solid,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  color: .clear,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  outline: SimpleLineSymbol(style: .solid,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: .red,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 1.0))
***REMOVED***) {
***REMOVED******REMOVED***self.geoView = geoView
***REMOVED******REMOVED***self.map = map
***REMOVED******REMOVED***self.width = width
***REMOVED******REMOVED***self.height = height
***REMOVED******REMOVED***self.extentSymbol = extentSymbol
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Ugh.
***REMOVED******REMOVED******REMOVED*** Figure out how to pass in Viewpoint binding to OverviewMap and then do the `onchange` of that.
***REMOVED******REMOVED******REMOVED*** figure out how to set an initial viewpoint on the MapView, although maybe "Binding" is not the correct
***REMOVED******REMOVED******REMOVED*** way to go, since the MapView's viewpoint binding is nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Figure out how to get the publisher stuff working given the fact that we're already hooked
***REMOVED******REMOVED******REMOVED*** into the coreGeoView.viewpointChanged stuff; it's just propagating that out to the client.
***REMOVED******REMOVED******REMOVED*** The issue is that you can't use "subscription", so need a SwiftUI way to do it...
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***geoView.onChange(of: geoView.viewpoint?.wrappedValue, perform: { (viewpoint) in
***REMOVED******REMOVED******REMOVED******REMOVED***print("viewpoint changed")
***REMOVED******REMOVED***)

***REMOVED******REMOVED***geoView.viewpointChangedPublisher.sink(receiveValue: {
***REMOVED******REMOVED******REMOVED******REMOVED***viewpointDidChange()
***REMOVED******REMOVED******REMOVED***print("wow")
***REMOVED***)
***REMOVED******REMOVED***.store(in: &subscriptions)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** Need to watch for changes to geoView.viewpoint
***REMOVED******REMOVED*** When geoView.viewpoint changes, update overviewViewpoint
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED***makeMapView()
***REMOVED******REMOVED******REMOVED***.attributionTextHidden()
***REMOVED******REMOVED******REMOVED***.interactionModes([])
***REMOVED******REMOVED******REMOVED***.frame(width: width, height: height)
***REMOVED******REMOVED******REMOVED***.border(Color.black, width: 1)
***REMOVED******REMOVED******REMOVED***Button("Zoom") {
***REMOVED******REMOVED******REMOVED******REMOVED***extentGeometry = Envelope(center: Point(x: -9813416.487598, y: 5126112.596989), width: 2000000, height: 10000000)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func makeMapView() -> MapView {
***REMOVED******REMOVED***let extentGraphic = Graphic(geometry: extentGeometry, symbol: extentSymbol)
***REMOVED******REMOVED***return MapView(map: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   viewpoint: $overviewViewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   graphicsOverlays: [GraphicsOverlay(graphics: [extentGraphic])]
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***Ideally component would take a binding to a viewpoint, use the onchange thing to be notified when it changes.
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** OverviewMap needs to:
***REMOVED******REMOVED*** - be notified when a geoview's viewpoint changes
***REMOVED******REMOVED*** - be able to get a viewpoint from a geoview (both .centerAndScale and .boundingGeometry)
***REMOVED******REMOVED*** - be able to set a viewpoint on a geoview

***REMOVED******REMOVED*** BasemapGallery needs to:
***REMOVED******REMOVED*** - load a Portal's basemaps
***REMOVED******REMOVED*** - get and display a thumbnail from a basemap's "item" property
***REMOVED******REMOVED*** - set a new basemap on a map/scene contained in a geoview

***REMOVED******REMOVED*** Search needs to:
***REMOVED******REMOVED*** - search using a LocatorTask
***REMOVED******REMOVED*** - support both online and local (MMPK) locators
***REMOVED******REMOVED*** - show suggestions from a LocatorTask
***REMOVED******REMOVED*** - dynamically update list of suggestions as the user types
***REMOVED******REMOVED*** - zoom a map/scene view to a given location and scale
***REMOVED******REMOVED*** - zoom a map/scene view to a given extent
***REMOVED******REMOVED*** - add one or more graphics to a map/scene view
***REMOVED***
***REMOVED******REMOVED******REMOVED***TODO:  Look at phil's viewpoint issue and figure out:
***REMOVED******REMOVED******REMOVED***- where to put get/set_viewpoint methods
***REMOVED******REMOVED******REMOVED***- where to put viewpointChanged publisher (and how)
***REMOVED***
***REMOVED******REMOVED*** Need...
***REMOVED******REMOVED*** - to be notified when a geoview's viewpoint changes
***REMOVED******REMOVED*** - to be able to get a viewpoint from a geoview (either .centerAndScale or .boundingGeometry)
***REMOVED******REMOVED*** - to be able to set a viewpoint on a geoview
***REMOVED***
***REMOVED******REMOVED*** When geoView.viewpoint changes...
***REMOVED***func viewpointDidChange() {
***REMOVED******REMOVED***let centerAndScaleViewpoint = geoView.currentViewpoint(type: .centerAndScale)
***REMOVED******REMOVED***let boundingGeometryViewpoint = geoView.currentViewpoint(type: .boundingGeometry)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let newExtent = boundingGeometryViewpoint?.targetGeometry as? Envelope {
***REMOVED******REMOVED******REMOVED***extentGeometry = newExtent
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let centerAndScaleViewpoint = centerAndScaleViewpoint {
***REMOVED******REMOVED******REMOVED***overviewViewpoint = Viewpoint(center: centerAndScaleViewpoint.targetGeometry as! Point,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scale: centerAndScaleViewpoint.targetScale * scale)
***REMOVED***
***REMOVED***
***REMOVED***
