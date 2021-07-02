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

***REMOVED***/ `OverviewMap` is a small, secondary `MapView` (sometimes called an "inset map"), superimposed
***REMOVED***/ on an existing `GeoView`, which shows the visible extent of that `GeoView`.
public struct OverviewMap: View {
***REMOVED******REMOVED***/ The `Viewpoint` of the main `GeoView`
***REMOVED***let viewpoint: Viewpoint?
***REMOVED***
***REMOVED******REMOVED***/ The visible area of the main `GeoView`.
***REMOVED***let visibleArea: Polygon?
***REMOVED***
***REMOVED******REMOVED***/ The `Graphic` displaying the visible area of the main `GeoView`.
***REMOVED***@StateObject var graphic: Graphic
***REMOVED***
***REMOVED******REMOVED***/ The `GraphicsOverlay` used to display the visible area graphic.
***REMOVED***@StateObject var graphicsOverlay: GraphicsOverlay
***REMOVED***
***REMOVED******REMOVED***/ The `Map` displayed in the `OverviewMap`.
***REMOVED***@StateObject var map: Map = Map(basemap: .topographic())
***REMOVED***
***REMOVED******REMOVED***/ The `FillSymbol` used to display the main `GeoView` visible area.
***REMOVED***private(set) var extentSymbol: FillSymbol
***REMOVED***
***REMOVED******REMOVED***/ The factor to multiply the main `GeoView`'s scale by.  The `OverviewMap` will display
***REMOVED******REMOVED***/ at the a scale equal to: `viewpoint.targetscale` x `scaleFactor.
***REMOVED***private(set) var scaleFactor: Double
***REMOVED***
***REMOVED******REMOVED***/ Creates an `OverviewMap`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - viewpoint: Viewpoint of the main `GeoView` used to update the `OverviewMap` view.
***REMOVED******REMOVED***/   - visibleArea: Visible area of the main `GeoView`.
***REMOVED******REMOVED***/   - extentSymbol: The `FillSymbol` used to display the main `GeoView`'s visible area.
***REMOVED******REMOVED***/   The default is a transparent `SimpleFillSymbol` with a red, 1 point width outline.
***REMOVED******REMOVED***/   - scaleFactor: The factor to multiply the main `GeoView`'s scale by.
***REMOVED******REMOVED***/   The default value is 25.0
***REMOVED***public init(viewpoint: Viewpoint?,
***REMOVED******REMOVED******REMOVED******REMOVED***visibleArea: Polygon?,
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
***REMOVED******REMOVED***self.visibleArea = visibleArea
***REMOVED******REMOVED***self.extentSymbol = extentSymbol
***REMOVED******REMOVED***self.scaleFactor = scaleFactor
***REMOVED******REMOVED***
***REMOVED******REMOVED***let graphic = Graphic(geometry: visibleArea,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  symbol: extentSymbol)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** It is necessary to set the graphic and graphicsOverlay this way
***REMOVED******REMOVED******REMOVED*** in order to prevent the main geoview from recreating the
***REMOVED******REMOVED******REMOVED*** graphicsOverlay every draw cycle.  That was causing refresh issues
***REMOVED******REMOVED******REMOVED*** with the graphic during panning/zooming/rotating.
***REMOVED******REMOVED***_graphic = StateObject(wrappedValue: graphic)
***REMOVED******REMOVED***_graphicsOverlay = StateObject(wrappedValue: GraphicsOverlay(graphics: [graphic]))
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let viewpoint = viewpoint,
***REMOVED******REMOVED***   let center = viewpoint.targetGeometry as? Point {
***REMOVED******REMOVED******REMOVED***self.viewpoint = Viewpoint(center: center,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   scale: viewpoint.targetScale * scaleFactor
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED***self.viewpoint = nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint,
***REMOVED******REMOVED******REMOVED***graphicsOverlays: [graphicsOverlay]
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.attributionTextHidden()
***REMOVED******REMOVED******REMOVED***.interactionModes([])
***REMOVED******REMOVED******REMOVED***.border(Color.black, width: 1)
***REMOVED******REMOVED******REMOVED***.onChange(of: visibleArea, perform: { graphic.geometry = $0 ***REMOVED***)
***REMOVED******REMOVED******REMOVED***.onChange(of: extentSymbol, perform: { graphic.symbol = $0 ***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***public func map(_ map: Map) -> OverviewMap {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy._map = StateObject(wrappedValue: map)
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

extension Graphic: ObservableObject {***REMOVED***
extension GraphicsOverlay: ObservableObject {***REMOVED***
