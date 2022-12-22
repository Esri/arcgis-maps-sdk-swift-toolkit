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
***REMOVED******REMOVED***/ The `Viewpoint` of the main `GeoView`.
***REMOVED***let viewpoint: Viewpoint?
***REMOVED***
***REMOVED******REMOVED***/ The visible area of the main `GeoView`. Not applicable to `SceneView`s.
***REMOVED***let visibleArea: ArcGIS.Polygon?
***REMOVED***
***REMOVED***private var symbol: Symbol
***REMOVED***
***REMOVED***private var scaleFactor = 25.0
***REMOVED***
***REMOVED******REMOVED***/ The data model containing the `Map` displayed in the overview map.
***REMOVED***@StateObject private var dataModel: MapDataModel
***REMOVED***
***REMOVED******REMOVED***/ The `Graphic` displaying the visible area of the main `GeoView`.
***REMOVED***@StateObject private var graphic: Graphic
***REMOVED***
***REMOVED******REMOVED***/ The `GraphicsOverlay` used to display the visible area graphic.
***REMOVED***@StateObject private var graphicsOverlay: GraphicsOverlay
***REMOVED***
***REMOVED******REMOVED***/ Creates an `OverviewMap` for use on a `MapView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - viewpoint: Viewpoint of the main `MapView` used to update the `OverviewMap` view.
***REMOVED******REMOVED***/   - visibleArea: Visible area of the main `MapView ` used to display the extent graphic.
***REMOVED******REMOVED***/   - map: The `Map` displayed in the `OverviewMap`. Defaults to `nil`, in which case
***REMOVED******REMOVED***/   a map with the `arcGISTopographic` basemap style is used.
***REMOVED******REMOVED***/ - Returns: A new `OverviewMap`.
***REMOVED***public static func forMapView(
***REMOVED******REMOVED***with viewpoint: Viewpoint?,
***REMOVED******REMOVED***visibleArea: ArcGIS.Polygon?,
***REMOVED******REMOVED***map: Map? = nil
***REMOVED***) -> OverviewMap {
***REMOVED******REMOVED***OverviewMap(
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint,
***REMOVED******REMOVED******REMOVED***visibleArea: visibleArea,
***REMOVED******REMOVED******REMOVED***symbol: .defaultFill,
***REMOVED******REMOVED******REMOVED***map: map
***REMOVED******REMOVED***)
***REMOVED***

***REMOVED******REMOVED***/ Creates an `OverviewMap` for use on a `SceneView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - viewpoint: Viewpoint of the main `SceneView` used to update the
***REMOVED******REMOVED***/ `OverviewMap` view.
***REMOVED******REMOVED***/   - map: The `Map` displayed in the `OverviewMap`. Defaults to `nil`, in which case
***REMOVED******REMOVED***/   a map with the `arcGISTopographic` basemap style is used.
***REMOVED******REMOVED***/ - Returns: A new `OverviewMap`.
***REMOVED***public static func forSceneView(
***REMOVED******REMOVED***with viewpoint: Viewpoint?,
***REMOVED******REMOVED***map: Map? = nil
***REMOVED***) -> OverviewMap {
***REMOVED******REMOVED***OverviewMap(viewpoint: viewpoint, symbol: .defaultMarker, map: map)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates an `OverviewMap`. Used for creating an `OverviewMap` for use on a `MapView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - viewpoint: Viewpoint of the main `GeoView` used to update the `OverviewMap` view.
***REMOVED******REMOVED***/   - visibleArea: Visible area of the main `GeoView` used to display the extent graphic.
***REMOVED******REMOVED***/   - map: The `Map` displayed in the `OverviewMap`.
***REMOVED***init(
***REMOVED******REMOVED***viewpoint: Viewpoint?,
***REMOVED******REMOVED***visibleArea: ArcGIS.Polygon? = nil,
***REMOVED******REMOVED***symbol: Symbol,
***REMOVED******REMOVED***map: Map?
***REMOVED***) {
***REMOVED******REMOVED***self.visibleArea = visibleArea
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***self.symbol = symbol
***REMOVED******REMOVED***
***REMOVED******REMOVED***_dataModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: MapDataModel(
***REMOVED******REMOVED******REMOVED******REMOVED***map: map ?? Map(basemapStyle: .arcGISTopographic)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let graphic = Graphic(symbol: self.symbol)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** It is necessary to set the graphic and graphicsOverlay this way
***REMOVED******REMOVED******REMOVED*** in order to prevent the main geoview from recreating the
***REMOVED******REMOVED******REMOVED*** graphicsOverlay every draw cycle. That was causing refresh issues
***REMOVED******REMOVED******REMOVED*** with the graphic during panning/zooming/rotating.
***REMOVED******REMOVED***_graphic = StateObject(wrappedValue: graphic)
***REMOVED******REMOVED***_graphicsOverlay = StateObject(wrappedValue: GraphicsOverlay(graphics: [graphic]))
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED***map: dataModel.map,
***REMOVED******REMOVED******REMOVED***viewpoint: makeOverviewViewpoint(),
***REMOVED******REMOVED******REMOVED***graphicsOverlays: [graphicsOverlay]
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.attributionBarHidden(true)
***REMOVED******REMOVED***.interactionModes([])
***REMOVED******REMOVED***.border(
***REMOVED******REMOVED******REMOVED***.black,
***REMOVED******REMOVED******REMOVED***width: 1
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***graphic.symbol = symbol
***REMOVED***
***REMOVED******REMOVED***.onChange(of: visibleArea) { visibleArea in
***REMOVED******REMOVED******REMOVED***if let visibleArea = visibleArea {
***REMOVED******REMOVED******REMOVED******REMOVED***graphic.geometry = visibleArea
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: viewpoint) { viewpoint in
***REMOVED******REMOVED******REMOVED***if visibleArea == nil,
***REMOVED******REMOVED******REMOVED***   let viewpoint = viewpoint,
***REMOVED******REMOVED******REMOVED***   let point = viewpoint.targetGeometry as? Point {
***REMOVED******REMOVED******REMOVED******REMOVED***graphic.geometry = point
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: symbol) {
***REMOVED******REMOVED******REMOVED***graphic.symbol = $0
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates an overview viewpoint based on the observed `viewpoint` center, scale, and `scaleFactor`.
***REMOVED******REMOVED***/ - Returns: The new `Viewpoint`.
***REMOVED***func makeOverviewViewpoint() -> Viewpoint? {
***REMOVED******REMOVED***guard let viewpoint = viewpoint,
***REMOVED******REMOVED******REMOVED***  let center = viewpoint.targetGeometry as? Point else { return nil ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***return Viewpoint(
***REMOVED******REMOVED******REMOVED***center: center,
***REMOVED******REMOVED******REMOVED***scale: viewpoint.targetScale * scaleFactor
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Modifiers
***REMOVED***
***REMOVED******REMOVED***/ The factor to multiply the main `GeoView`'s scale by.  The `OverviewMap` will display
***REMOVED******REMOVED***/ at the a scale equal to: `viewpoint.targetScale` x `scaleFactor`.
***REMOVED******REMOVED***/ The default value is `25.0`.
***REMOVED******REMOVED***/ - Parameter scaleFactor: The new scale factor.
***REMOVED******REMOVED***/ - Returns: The `OverviewMap`.
***REMOVED***public func scaleFactor(_ scaleFactor: Double) -> OverviewMap {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.scaleFactor = scaleFactor
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `Symbol` used to display the main `GeoView` visible area. For `MapView`s, the symbol
***REMOVED******REMOVED***/ should be appropriate for visualizing a polygon, as it will be used to draw the visible area. For
***REMOVED******REMOVED***/ `SceneView`s, the symbol should be appropriate for visualizing a point, as it will be used to
***REMOVED******REMOVED***/ draw the current viewpoint's center. For `MapView`s, the default is a transparent
***REMOVED******REMOVED***/ `SimpleFillSymbol` with a red 1 point width outline; for `SceneView`s, the default is a
***REMOVED******REMOVED***/ red, crosshair `SimpleMarkerSymbol`.
***REMOVED******REMOVED***/ - Parameter symbol: The new symbol.
***REMOVED******REMOVED***/ - Returns: The `OverviewMap`.
***REMOVED***public func symbol(_ symbol: Symbol) -> OverviewMap {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.symbol = symbol
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

***REMOVED*** MARK: Extensions

private extension Symbol {
***REMOVED******REMOVED***/ The default marker symbol.
***REMOVED***static let defaultMarker: MarkerSymbol = SimpleMarkerSymbol(
***REMOVED******REMOVED***style: .cross,
***REMOVED******REMOVED***color: .red,
***REMOVED******REMOVED***size: 12.0
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ The default fill symbol.
***REMOVED***static let defaultFill: FillSymbol = SimpleFillSymbol(
***REMOVED******REMOVED***style: .solid,
***REMOVED******REMOVED***color: .clear,
***REMOVED******REMOVED***outline: SimpleLineSymbol(
***REMOVED******REMOVED******REMOVED***style: .solid,
***REMOVED******REMOVED******REMOVED***color: .red,
***REMOVED******REMOVED******REMOVED***width: 1.0
***REMOVED******REMOVED***)
***REMOVED***)
***REMOVED***

***REMOVED***/ A very basic data model class containing a Map.
class MapDataModel: ObservableObject {
***REMOVED******REMOVED***/ The `Map` used for display in a `MapView`.
***REMOVED***@Published var map: Map
***REMOVED***
***REMOVED******REMOVED***/ Creates a `MapDataModel`.
***REMOVED******REMOVED***/ - Parameter map: The `Map` used for display.
***REMOVED***init(map: Map) {
***REMOVED******REMOVED***self.map = map
***REMOVED***
***REMOVED***
