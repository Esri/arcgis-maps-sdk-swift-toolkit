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

***REMOVED***/ SearchView presents a search experience, powered by an underlying SearchViewModel.
public struct SearchView: View {
***REMOVED******REMOVED***/ Creates a new `SearchView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - searchViewModel: The view model used by `SearchView`.
***REMOVED******REMOVED***/   - viewpoint: The `Viewpoint` used to zoom to results.
***REMOVED******REMOVED***/   - resultsOverlay: The `GraphicsOverlay` used to display results.
***REMOVED***public init(
***REMOVED******REMOVED***searchViewModel: SearchViewModel? = nil,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>? = nil,
***REMOVED******REMOVED***resultsOverlay: Binding<GraphicsOverlay>? = nil
***REMOVED***) {
***REMOVED******REMOVED***if let searchViewModel = searchViewModel {
***REMOVED******REMOVED******REMOVED***self.searchViewModel = searchViewModel
***REMOVED***
***REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED***self.searchViewModel = SearchViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED***sources: [LocatorSearchSource()]
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***self.resultsOverlay = resultsOverlay
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the view. The `SearchViewModel` manages state and handles the
***REMOVED******REMOVED***/ activity of searching. The view observes `SearchViewModel` for changes in state. The view
***REMOVED******REMOVED***/ calls methods on `SearchViewModel` in response to user action.
***REMOVED***@ObservedObject
***REMOVED***var searchViewModel: SearchViewModel
***REMOVED***
***REMOVED******REMOVED***/ The `Viewpoint` used to pan/zoom to results.  If `nil`, there will be no zooming to results.
***REMOVED***private var viewpoint: Binding<Viewpoint?>? = nil
***REMOVED***
***REMOVED******REMOVED***/ The `GraphicsOverlay` used to display results.  If `nil`, no results will be displayed.
***REMOVED***private var resultsOverlay: Binding<GraphicsOverlay>? = nil
***REMOVED***
***REMOVED******REMOVED***/ Determines whether a built-in result view will be shown. Defaults to true.
***REMOVED******REMOVED***/ If false, the result display/selection list is not shown. Set to false if you want to hide the results
***REMOVED******REMOVED***/ or define a custom result list. You might use a custom result list to show results in a separate list,
***REMOVED******REMOVED***/ disconnected from the rest of the search view.
***REMOVED******REMOVED***/ Note: this is set using the `enableResultListView` modifier.
***REMOVED***private var enableResultListView = true
***REMOVED***
***REMOVED******REMOVED***/ Message to show when there are no results or suggestions.  Defaults to "No results found".
***REMOVED******REMOVED***/ Note: this is set using the `noResultMessage` modifier.
***REMOVED***private var noResultMessage = "No results found"
***REMOVED***
***REMOVED***private var searchBarWidth: CGFloat = 360.0
***REMOVED***
***REMOVED***@State
***REMOVED***private var shouldZoomToResults = true
***REMOVED***
***REMOVED******REMOVED***/ Determines whether the results lists are displayed.
***REMOVED***@State
***REMOVED***private var showResultListView: Bool = true
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***VStack (alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.defaultPlaceholder,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***text: $searchViewModel.currentQuery
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED*** onCommit: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.commitSearch()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriDeleteTextButton(text: $searchViewModel.currentQuery)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriSearchButton { searchViewModel.commitSearch() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriShowResultsButton(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: !enableResultListView,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showResults: $showResultListView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if enableResultListView, showResultListView {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let results = searchViewModel.results {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchResultList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchResults: results,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedResult: $searchViewModel.selectedResult,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***noResultMessage: noResultMessage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let suggestions = searchViewModel.suggestions {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchSuggestionList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***suggestionResults: suggestions,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentSuggestion: $searchViewModel.currentSuggestion,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***noResultMessage: noResultMessage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: searchBarWidth)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if searchViewModel.isEligibleForRequery {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Repeat Search Here") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***shouldZoomToResults = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.repeatSearch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED***.onChange(of: searchViewModel.results) {
***REMOVED******REMOVED******REMOVED***display(searchResults: $0)
***REMOVED***
***REMOVED******REMOVED***.onChange(of: searchViewModel.selectedResult) {
***REMOVED******REMOVED******REMOVED***display(selectedResult: $0)
***REMOVED***
***REMOVED******REMOVED***.onReceive(searchViewModel.$currentQuery) { _ in
***REMOVED******REMOVED******REMOVED***searchViewModel.updateSuggestions()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Modifiers
***REMOVED***
***REMOVED******REMOVED***/ Determines whether a built-in result view will be shown. If `false`, the result display/selection
***REMOVED******REMOVED***/ list is not shown. Set to `false` if you want to define a custom result list. You might use a
***REMOVED******REMOVED***/ custom result list to show results in a separate list, disconnected from the rest of the search view.
***REMOVED******REMOVED***/ Defaults to `true`.
***REMOVED******REMOVED***/ - Parameter enableResultListView: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func enableResultListView(_ enableResultListView: Bool) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.enableResultListView = enableResultListView
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Message to show when there are no results or suggestions.  Defaults to "No results found".
***REMOVED******REMOVED***/ - Parameter noResultMessage: The new value.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func noResultMessage(_ noResultMessage: String) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.noResultMessage = noResultMessage
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The width of the search bar.
***REMOVED******REMOVED***/ - Parameter searchBarWidth: The desired width of the search bar.
***REMOVED******REMOVED***/ - Returns: The `SearchView`.
***REMOVED***public func searchBarWidth(_ searchBarWidth: CGFloat) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.searchBarWidth = searchBarWidth
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

extension SearchView {
***REMOVED***private func display(searchResults: Result<[SearchResult], SearchError>?) {
***REMOVED******REMOVED***switch searchResults {
***REMOVED******REMOVED***case .success(let results):
***REMOVED******REMOVED******REMOVED***var resultGraphics = [Graphic]()
***REMOVED******REMOVED******REMOVED***results.forEach({ result in
***REMOVED******REMOVED******REMOVED******REMOVED***if let graphic = result.geoElement as? Graphic {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphic.updateGraphic(withResult: result)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***resultGraphics.append(graphic)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***resultsOverlay?.wrappedValue.removeAllGraphics()
***REMOVED******REMOVED******REMOVED***resultsOverlay?.wrappedValue.addGraphics(resultGraphics)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if resultGraphics.count > 0,
***REMOVED******REMOVED******REMOVED***   let envelope = resultsOverlay?.wrappedValue.extent,
***REMOVED******REMOVED******REMOVED***   shouldZoomToResults {
***REMOVED******REMOVED******REMOVED******REMOVED***let builder = EnvelopeBuilder(envelope: envelope)
***REMOVED******REMOVED******REMOVED******REMOVED***builder.expand(factor: 1.1)
***REMOVED******REMOVED******REMOVED******REMOVED***let targetExtent = builder.toGeometry() as! Envelope
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint?.wrappedValue = Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***targetExtent: targetExtent
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.lastSearchExtent = targetExtent
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint?.wrappedValue = nil
***REMOVED******REMOVED***
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***resultsOverlay?.wrappedValue.removeAllGraphics()
***REMOVED******REMOVED******REMOVED***viewpoint?.wrappedValue = nil
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if !shouldZoomToResults { shouldZoomToResults = true ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func display(selectedResult: SearchResult?) {
***REMOVED******REMOVED***guard let selectedResult = selectedResult else { return ***REMOVED***
***REMOVED******REMOVED***viewpoint?.wrappedValue = selectedResult.selectionViewpoint
***REMOVED***
***REMOVED***

struct SearchResultList: View {
***REMOVED***var searchResults: Result<[SearchResult], SearchError>
***REMOVED***@Binding var selectedResult: SearchResult?
***REMOVED***var noResultMessage: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch searchResults {
***REMOVED******REMOVED******REMOVED***case .success(let results):
***REMOVED******REMOVED******REMOVED******REMOVED***if results.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Only show the list if we have more than one result.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(results) { result in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchResultRow(result: result)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedResult = result
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if result == selectedResult {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "checkmark.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.accentColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***else if results.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(noResultMessage)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(error.localizedDescription)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder(padding: EdgeInsets())
***REMOVED***
***REMOVED***

struct SearchSuggestionList: View {
***REMOVED***var suggestionResults: Result<[SearchSuggestion], SearchError>
***REMOVED***@Binding var currentSuggestion: SearchSuggestion?
***REMOVED***var noResultMessage: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch suggestionResults {
***REMOVED******REMOVED******REMOVED***case .success(let suggestions):
***REMOVED******REMOVED******REMOVED******REMOVED***if !suggestions.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if suggestions.count > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(suggestions) { suggestion in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SuggestionResultRow(suggestion: suggestion)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentSuggestion = suggestion
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(noResultMessage)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(error.errorDescription)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder(padding: EdgeInsets())
***REMOVED***
***REMOVED***

struct SearchResultRow: View {
***REMOVED***var result: SearchResult
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Image(uiImage: UIImage.mapPin)
***REMOVED******REMOVED******REMOVED******REMOVED***.scaleEffect(0.65)
***REMOVED******REMOVED******REMOVED***ResultRow(
***REMOVED******REMOVED******REMOVED******REMOVED***title: result.displayTitle,
***REMOVED******REMOVED******REMOVED******REMOVED***subtitle: result.displaySubtitle
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

struct SuggestionResultRow: View {
***REMOVED***var suggestion: SearchSuggestion
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***mapPinImage()
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***ResultRow(
***REMOVED******REMOVED******REMOVED******REMOVED***title: suggestion.displayTitle,
***REMOVED******REMOVED******REMOVED******REMOVED***subtitle: suggestion.displaySubtitle
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func mapPinImage() -> Image {
***REMOVED***  suggestion.isCollection ?
***REMOVED******REMOVED***Image(systemName: "magnifyingglass") :
***REMOVED******REMOVED***Image(uiImage: UIImage(named: "pin", in: Bundle.module, with: nil)!)
***REMOVED***
***REMOVED***

struct ResultRow: View {
***REMOVED***var title: String
***REMOVED***var subtitle: String?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack (alignment: .leading){
***REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.callout)
***REMOVED******REMOVED******REMOVED***if let subtitle = subtitle {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(subtitle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension Graphic {
***REMOVED***func updateGraphic(withResult result: SearchResult) {
***REMOVED******REMOVED***if symbol == nil {
***REMOVED******REMOVED******REMOVED***symbol = .resultSymbol
***REMOVED***
***REMOVED******REMOVED***setAttributeValue(result.displayTitle, forKey: "displayTitle")
***REMOVED******REMOVED***setAttributeValue(result.displaySubtitle, forKey: "displaySubtitle")
***REMOVED***
***REMOVED***

private extension Symbol {
***REMOVED******REMOVED***/ A search result marker symbol.
***REMOVED***static var resultSymbol: MarkerSymbol {
***REMOVED******REMOVED***let image = UIImage.mapPin
***REMOVED******REMOVED***let symbol = PictureMarkerSymbol(image: image)
***REMOVED******REMOVED***symbol.offsetY = Float(image.size.height / 2.0)
***REMOVED******REMOVED***return symbol
***REMOVED***
***REMOVED***

extension UIImage {
***REMOVED***static var mapPin: UIImage {
***REMOVED******REMOVED***return UIImage(named: "MapPin", in: Bundle.module, with: nil)!
***REMOVED***
***REMOVED***
