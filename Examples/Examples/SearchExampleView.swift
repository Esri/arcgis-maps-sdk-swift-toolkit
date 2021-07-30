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
***REMOVED***Toolkit

struct SearchExampleView: View {
***REMOVED***@ObservedObject
***REMOVED***var searchViewModel = SearchViewModel()
***REMOVED***
***REMOVED***let map = Map(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED***@State
***REMOVED***var searchResultViewpoint: Viewpoint? = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1000000
***REMOVED***)
***REMOVED***
***REMOVED***var searchResultsOverlay = GraphicsOverlay()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***viewpoint: searchResultViewpoint,
***REMOVED******REMOVED******REMOVED***graphicsOverlays: [searchResultsOverlay]
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) {
***REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.queryCenter = $0.targetGeometry as? Point
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Reset `searchResultViewpoint` here when the user pans/zooms
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** the map, so if the user commits the same search with the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** same result, the Map will pan/zoom to the result.  Otherwise
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** `searchResultViewpoint` doesn't change which doesn't
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** redraw the map with the new viewpoint.
***REMOVED******REMOVED******REMOVED******REMOVED***searchResultViewpoint = nil
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged {
***REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.queryArea = $0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(
***REMOVED******REMOVED******REMOVED******REMOVED***SearchView(searchViewModel: searchViewModel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 360)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(),
***REMOVED******REMOVED******REMOVED******REMOVED***alignment: .topTrailing
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onChange(of: searchViewModel.results, perform: { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED***display(searchResults: newValue)
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onChange(of: searchViewModel.selectedResult, perform: { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED***display(selectedResult: newValue)
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***setupSearchViewModel()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets up any desired customization on `searchViewModel`.
***REMOVED***private func setupSearchViewModel() {
***REMOVED******REMOVED***let smartLocator = SmartLocatorSearchSource(
***REMOVED******REMOVED******REMOVED***displayName: "Locator One",
***REMOVED******REMOVED******REMOVED***maximumResults: 16,
***REMOVED******REMOVED******REMOVED***maximumSuggestions: 16
***REMOVED******REMOVED***)
***REMOVED******REMOVED***searchViewModel.sources = [smartLocator]
***REMOVED***
***REMOVED***
***REMOVED***fileprivate func display(searchResults: Result<[SearchResult]?, SearchError>) {
***REMOVED******REMOVED***switch searchResults {
***REMOVED******REMOVED***case .success(let results):
***REMOVED******REMOVED******REMOVED***var resultGraphics = [Graphic]()
***REMOVED******REMOVED******REMOVED***results?.forEach({ result in
***REMOVED******REMOVED******REMOVED******REMOVED***let graphic = Graphic(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***geometry: result.geoElement?.geometry,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***symbol: .resultSymbol
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***resultGraphics.append(graphic)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let currentGraphics = searchResultsOverlay.graphics
***REMOVED******REMOVED******REMOVED***searchResultsOverlay.removeGraphics(currentGraphics)
***REMOVED******REMOVED******REMOVED***searchResultsOverlay.addGraphics(resultGraphics)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if resultGraphics.count > 0,
***REMOVED******REMOVED******REMOVED***   let envelope = searchResultsOverlay.extent {
***REMOVED******REMOVED******REMOVED******REMOVED***let builder = EnvelopeBuilder(envelope: envelope)
***REMOVED******REMOVED******REMOVED******REMOVED***builder.expand(factor: 1.1)
***REMOVED******REMOVED******REMOVED******REMOVED***searchResultViewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***targetExtent: builder.toGeometry()
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED***searchResultViewpoint = nil
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .failure(_):
***REMOVED******REMOVED******REMOVED***break
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***fileprivate func display(selectedResult: SearchResult?) {
***REMOVED******REMOVED***guard let selectedResult = selectedResult,
***REMOVED******REMOVED******REMOVED***  let graphic = selectedResult.geoElement as? Graphic else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***searchResultViewpoint = selectedResult.selectionViewpoint
***REMOVED******REMOVED***if graphic.symbol == nil {
***REMOVED******REMOVED******REMOVED***graphic.symbol = .resultSymbol
***REMOVED***
***REMOVED******REMOVED***let currentGraphics = searchResultsOverlay.graphics
***REMOVED******REMOVED***searchResultsOverlay.removeGraphics(currentGraphics)
***REMOVED******REMOVED***searchResultsOverlay.addGraphic(graphic)
***REMOVED***
***REMOVED***

private extension Symbol {
***REMOVED******REMOVED***/ A search result marker symbol.
***REMOVED***static let resultSymbol: MarkerSymbol = PictureMarkerSymbol(
***REMOVED******REMOVED***image: UIImage(named: "MapPin")!
***REMOVED***)
***REMOVED***
