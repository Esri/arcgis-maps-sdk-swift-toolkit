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
***REMOVED***var searchViewModel = SearchViewModel(
***REMOVED******REMOVED***sources: [LocatorSearchSource(
***REMOVED******REMOVED******REMOVED***displayName: "Locator One",
***REMOVED******REMOVED******REMOVED***maximumResults: 16,
***REMOVED******REMOVED******REMOVED***maximumSuggestions: 16)]/*,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** LocatorSearchSource(displayName: "Locator Two")]*/
***REMOVED***)
***REMOVED***
***REMOVED***@State
***REMOVED***var showResults = true
***REMOVED***
***REMOVED***let map = Map(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED***@State
***REMOVED***var searchResultViewpoint: Viewpoint? = nil
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
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged {
***REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.queryArea = $0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showResults.toggle()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(showResults ? "Hide results" : "Show results")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***SearchView(searchViewModel: searchViewModel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.enableResultListView(showResults)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 360)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED***alignment: .topTrailing
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onChange(of: searchViewModel.results, perform: { searchResults in
***REMOVED******REMOVED******REMOVED******REMOVED***display(searchResults: searchResults)
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onChange(of: searchViewModel.selectedResult, perform: { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***display(selectedResult: searchViewModel.selectedResult)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***fileprivate func display(searchResults: Result<[SearchResult]?, RuntimeError>) {
***REMOVED******REMOVED***let searchResultEnvelopeBuilder = EnvelopeBuilder(spatialReference: .wgs84)
***REMOVED******REMOVED***switch searchResults {
***REMOVED******REMOVED***case .success(let results):
***REMOVED******REMOVED******REMOVED***var resultGraphics = [Graphic]()
***REMOVED******REMOVED******REMOVED***results?.forEach({ result in
***REMOVED******REMOVED******REMOVED******REMOVED***if let extent = result.selectionViewpoint?.targetGeometry as? Envelope {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchResultEnvelopeBuilder.union(envelope: extent)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***let graphic = Graphic(geometry: result.geoElement?.geometry,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  symbol: .resultSymbol)
***REMOVED******REMOVED******REMOVED******REMOVED***resultGraphics.append(graphic)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let currentGraphics = searchResultsOverlay.graphics
***REMOVED******REMOVED******REMOVED***searchResultsOverlay.removeGraphics(currentGraphics)
***REMOVED******REMOVED******REMOVED***searchResultsOverlay.addGraphics(resultGraphics)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if resultGraphics.count > 0,
***REMOVED******REMOVED******REMOVED***   let envelope = searchResultEnvelopeBuilder.toGeometry() as? Envelope {
***REMOVED******REMOVED******REMOVED******REMOVED***searchResultViewpoint = Viewpoint(targetExtent: envelope)
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

struct SearchExampleView_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***SearchExampleView()
***REMOVED***
***REMOVED***

private extension Symbol {
***REMOVED******REMOVED***/ A search result marker symbol.
***REMOVED***static let resultSymbol: MarkerSymbol = SimpleMarkerSymbol(
***REMOVED******REMOVED***style: .diamond,
***REMOVED******REMOVED***color: .red,
***REMOVED******REMOVED***size: 12.0
***REMOVED***)
***REMOVED***
