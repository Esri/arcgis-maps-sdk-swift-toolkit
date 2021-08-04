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
***REMOVED***

***REMOVED***/ `OverviewMap` is a small, secondary `MapView` (sometimes called an "inset map"), superimposed
***REMOVED***/ on an existing `GeoView`, which shows the visible extent of that `GeoView`.
public struct BasemapGallery: View {
***REMOVED***public init(
***REMOVED******REMOVED***basemapGalleryItems: [BasemapGalleryItem] = [],
***REMOVED******REMOVED***selectedBasemapGalleryItem: Binding<BasemapGalleryItem?>
***REMOVED***) {
***REMOVED******REMOVED***self.basemapGalleryItems = basemapGalleryItems
***REMOVED******REMOVED***self._selectedBasemapGalleryItem = selectedBasemapGalleryItem
***REMOVED***
***REMOVED***
***REMOVED***public var basemapGalleryItems: [BasemapGalleryItem] = []
***REMOVED***
***REMOVED***@Binding
***REMOVED***public var selectedBasemapGalleryItem: BasemapGalleryItem?
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***PlainList {
***REMOVED******REMOVED******REMOVED***ForEach(basemapGalleryItems) { basemapGalleryItem in
***REMOVED******REMOVED******REMOVED******REMOVED***BasemapGalleryItemRow(item: basemapGalleryItem)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedBasemapGalleryItem = basemapGalleryItem
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder()
***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: makeOverviewViewpoint(),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlays: [graphicsOverlay]
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.attributionText(hidden: true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.interactionModes([])
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.border(.black, width: 1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear(perform: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphic.symbol = symbol
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: visibleArea, perform: { visibleArea in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let visibleArea = visibleArea {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphic.geometry = visibleArea
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: viewpoint, perform: { viewpoint in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if visibleArea == nil,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let viewpoint = viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let point = viewpoint.targetGeometry as? Point {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphic.geometry = point
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: symbol, perform: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphic.symbol = $0
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Modifiers
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***/ The `Map` displayed in the `OverviewMap`.
***REMOVED******REMOVED******REMOVED******REMOVED***/ - Parameter map: The new map.
***REMOVED******REMOVED******REMOVED******REMOVED***/ - Returns: The `OverviewMap`.
***REMOVED******REMOVED******REMOVED***public func map(_ map: Map) -> OverviewMap {
***REMOVED******REMOVED******REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED******REMOVED******REMOVED***copy._map = StateObject(wrappedValue: map)
***REMOVED******REMOVED******REMOVED******REMOVED***return copy
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***/ The factor to multiply the main `GeoView`'s scale by.  The `OverviewMap` will display
***REMOVED******REMOVED******REMOVED******REMOVED***/ at the a scale equal to: `viewpoint.targetScale` x `scaleFactor`.
***REMOVED******REMOVED******REMOVED******REMOVED***/ The default value is `25.0`.
***REMOVED******REMOVED******REMOVED******REMOVED***/ - Parameter scaleFactor: The new scale factor.
***REMOVED******REMOVED******REMOVED******REMOVED***/ - Returns: The `OverviewMap`.
***REMOVED******REMOVED******REMOVED***public func scaleFactor(_ scaleFactor: Double) -> OverviewMap {
***REMOVED******REMOVED******REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED******REMOVED******REMOVED***copy.scaleFactor = scaleFactor
***REMOVED******REMOVED******REMOVED******REMOVED***return copy
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***/ The `Symbol` used to display the main `GeoView` visible area. For `MapView`s, the symbol
***REMOVED******REMOVED******REMOVED******REMOVED***/ should be appropriate for visualizing a polygon, as it will be used to draw the visible area. For
***REMOVED******REMOVED******REMOVED******REMOVED***/ `SceneView`s, the symbol should be appropriate for visualizing a point, as it will be used to
***REMOVED******REMOVED******REMOVED******REMOVED***/ draw the current viewpoint's center. For `MapView`s, the default is a transparent
***REMOVED******REMOVED******REMOVED******REMOVED***/ `SimpleFillSymbol` with a red 1 point width outline; for `SceneView`s, the default is a
***REMOVED******REMOVED******REMOVED******REMOVED***/ red, crosshair `SimpleMarkerSymbol`.
***REMOVED******REMOVED******REMOVED******REMOVED***/ - Parameter symbol: The new symbol.
***REMOVED******REMOVED******REMOVED******REMOVED***/ - Returns: The `OverviewMap`.
***REMOVED******REMOVED******REMOVED***public func symbol(_ symbol: Symbol) -> OverviewMap {
***REMOVED******REMOVED******REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED******REMOVED******REMOVED***copy.symbol = symbol
***REMOVED******REMOVED******REMOVED******REMOVED***return copy
***REMOVED******REMOVED******REMOVED***
***REMOVED***

private struct BasemapGalleryItemRow: View {
***REMOVED***var item: BasemapGalleryItem
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if let thumbnail = item.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** TODO: thumbnail will have to be loaded.
***REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: thumbnail)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Text(item.name)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED***
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
