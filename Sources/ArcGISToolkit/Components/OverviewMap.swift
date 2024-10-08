***REMOVED***
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
import Combine
***REMOVED***

***REMOVED***/ `OverviewMap` is a small, secondary `MapView` (sometimes called an "inset map"), superimposed
***REMOVED***/ on an existing `GeoView`, which shows a representation of the current `visibleArea` (for a `MapView`) or `viewpoint` (for a `SceneView`).
***REMOVED***/
***REMOVED***/ | MapView | SceneView |
***REMOVED***/ | ------- | --------- |
***REMOVED***/ | ![OverviewMap - MapView](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/assets/16397058/61415dd8-cdbc-4048-a439-92cf13729e3e) | ![OverviewMap - SceneView](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/assets/16397058/5a201035-c303-48a5-bc95-1324796385ea) |
***REMOVED***/
***REMOVED***/ > Note: OverviewMap uses metered ArcGIS basemaps by default, so you will need to configure an API key. See [Security and authentication documentation](https:***REMOVED***developers.arcgis.com/documentation/mapping-apis-and-services/security/#api-keys) for more information.
***REMOVED***/
***REMOVED***/ **Features**
***REMOVED***/
***REMOVED***/ - Displays a representation of the current visible area or viewpoint for a connected `GeoView`.
***REMOVED***/ - Supports a configurable scaling factor for setting the overview map's zoom level relative to
***REMOVED***/ the connected view.
***REMOVED***/ - Supports a configurable symbol for visualizing the current visible area or viewpoint
***REMOVED***/ representation (a `FillSymbol` for a connected `MapView`; a `MarkerSymbol` for a connected
***REMOVED***/ `SceneView`).
***REMOVED***/ - Supports using a custom map in the overview map display.
***REMOVED***/
***REMOVED***/ **Behavior**
***REMOVED***/
***REMOVED***/ For an `OverviewMap` on a `MapView`, the `MapView`'s `visibleArea` property will be represented in the `OverviewMap` as a polygon, which will rotate as the `MapView` rotates.
***REMOVED***/
***REMOVED***/ For an `OverviewMap` on a `SceneView`, the center point of the `SceneView`'s `currentViewpoint` property will be represented in the `OverviewMap` by a point.
***REMOVED***/
***REMOVED***/ To use a custom map in the `OverviewMap`, use the `map` argument in either ``OverviewMap/forMapView(with:visibleArea:map:)`` or ``OverviewMap/forSceneView(with:map:)``.
***REMOVED***/
***REMOVED***/ To see the `OverviewMap` in action, and for examples of `OverviewMap` customization, check out
***REMOVED***/ the [Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
***REMOVED***/ and refer to [OverviewMapExampleView.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/OverviewMapExampleView.swift)
***REMOVED***/ in the project. To learn more about using the `OverviewMap` see the <doc:OverviewMapTutorial>.
@available(visionOS, unavailable)
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
***REMOVED***@StateObject private var dataModel = DataModel()
***REMOVED***
***REMOVED******REMOVED***/ The user-defined map used in the overview map. Defaults to `nil`.
***REMOVED***private let userProvidedMap: Map?
***REMOVED***
***REMOVED******REMOVED***/ The actual map used in the overview map.
***REMOVED***private var effectiveMap: Map {
***REMOVED******REMOVED***userProvidedMap ?? dataModel.defaultMap
***REMOVED***
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
***REMOVED******REMOVED******REMOVED***symbol: .defaultFill(),
***REMOVED******REMOVED******REMOVED***map: map
***REMOVED******REMOVED***)
***REMOVED***
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
***REMOVED******REMOVED***OverviewMap(viewpoint: viewpoint, symbol: .defaultMarker(), map: map)
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
***REMOVED******REMOVED***userProvidedMap = map
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED***map: effectiveMap,
***REMOVED******REMOVED******REMOVED***viewpoint: makeOverviewViewpoint(),
***REMOVED******REMOVED******REMOVED***graphicsOverlays: [dataModel.graphicsOverlay]
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.attributionBarHidden(true)
***REMOVED******REMOVED***.interactionModes([])
***REMOVED******REMOVED***.border(
***REMOVED******REMOVED******REMOVED***.black,
***REMOVED******REMOVED******REMOVED***width: 1
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***dataModel.graphic.geometry = visibleArea
***REMOVED******REMOVED******REMOVED***dataModel.graphic.symbol = symbol
***REMOVED***
***REMOVED******REMOVED***.onChange(visibleArea) { visibleArea in
***REMOVED******REMOVED******REMOVED***if let visibleArea = visibleArea {
***REMOVED******REMOVED******REMOVED******REMOVED***dataModel.graphic.geometry = visibleArea
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(viewpoint) { viewpoint in
***REMOVED******REMOVED******REMOVED***if visibleArea == nil,
***REMOVED******REMOVED******REMOVED***   let viewpoint = viewpoint,
***REMOVED******REMOVED******REMOVED***   let point = viewpoint.targetGeometry as? Point {
***REMOVED******REMOVED******REMOVED******REMOVED***dataModel.graphic.geometry = point
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(symbol) {
***REMOVED******REMOVED******REMOVED***dataModel.graphic.symbol = $0
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
***REMOVED***static func defaultMarker() -> Symbol {
***REMOVED******REMOVED***return SimpleMarkerSymbol(style: .cross, color: .red, size: 12)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The default fill symbol.
***REMOVED***static func defaultFill() -> Symbol {
***REMOVED******REMOVED***return SimpleFillSymbol(
***REMOVED******REMOVED******REMOVED***style: .solid,
***REMOVED******REMOVED******REMOVED***color: .clear,
***REMOVED******REMOVED******REMOVED***outline: SimpleLineSymbol(style: .solid, color: .red, width: 1)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

@available(visionOS, unavailable)
private extension OverviewMap {
***REMOVED***@MainActor
***REMOVED***private class DataModel: ObservableObject {
***REMOVED******REMOVED******REMOVED***/ The default `Map` used for display in a `MapView`.
***REMOVED******REMOVED***private(set) lazy var defaultMap = Map(basemapStyle: .arcGISTopographic)
***REMOVED******REMOVED***let graphic: Graphic
***REMOVED******REMOVED***let graphicsOverlay: GraphicsOverlay
***REMOVED******REMOVED***
***REMOVED******REMOVED***init() {
***REMOVED******REMOVED******REMOVED***graphic = Graphic()
***REMOVED******REMOVED******REMOVED***graphicsOverlay = GraphicsOverlay(graphics: [graphic])
***REMOVED***
***REMOVED***
***REMOVED***
