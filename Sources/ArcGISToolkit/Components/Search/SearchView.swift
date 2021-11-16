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
***REMOVED******REMOVED***resultsOverlay: GraphicsOverlay? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.searchViewModel = searchViewModel ?? SearchViewModel(
***REMOVED******REMOVED******REMOVED***sources: [LocatorSearchSource()]
***REMOVED******REMOVED***)
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
***REMOVED***private var resultsOverlay: GraphicsOverlay? = nil
***REMOVED***
***REMOVED******REMOVED***/ The string shown in the search view when no user query is entered.
***REMOVED******REMOVED***/ Defaults to "Find a place or address". Note: this is set using the
***REMOVED******REMOVED***/ `searchFieldPrompt` modifier.
***REMOVED***private var searchFieldPrompt: String = "Find a place or address"
***REMOVED***
***REMOVED******REMOVED***/ Determines whether a built-in result view will be shown. Defaults to true.
***REMOVED******REMOVED***/ If false, the result display/selection list is not shown. Set to false if you want to hide the results
***REMOVED******REMOVED***/ or define a custom result list. You might use a custom result list to show results in a separate list,
***REMOVED******REMOVED***/ disconnected from the rest of the search view.
***REMOVED******REMOVED***/ Note: this is set using the `enableResultListView` modifier.
***REMOVED***private var enableResultListView = true
***REMOVED***
***REMOVED******REMOVED***/ Message to show when there are no results or suggestions.  Defaults to "No results found".
***REMOVED******REMOVED***/ Note: this is set using the `noResultsMessage` modifier.
***REMOVED***private var noResultsMessage = "No results found"
***REMOVED***
***REMOVED***@Environment(\.horizontalSizeClass)
***REMOVED***private var horizontalSizeClass: UserInterfaceSizeClass?
***REMOVED***
***REMOVED***@Environment(\.verticalSizeClass)
***REMOVED***private var verticalSizeClass: UserInterfaceSizeClass?
***REMOVED***
***REMOVED***private var searchBarWidth: CGFloat? {
***REMOVED******REMOVED***horizontalSizeClass == .compact && verticalSizeClass == .regular ? nil : 360
***REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchField(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***query: $searchViewModel.currentQuery,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchFieldPrompt: searchFieldPrompt,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isShowResultsHidden: !enableResultListView,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showResults: $showResultListView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit { searchViewModel.commitSearch() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.submitLabel(.search)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if enableResultListView, showResultListView {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let searchOutcome = searchViewModel.searchOutcome {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch searchOutcome {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .results(let results):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchResultList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchResults: results,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedResult: $searchViewModel.selectedResult,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***noResultsMessage: noResultsMessage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .suggestions(let suggestions):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchSuggestionList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***suggestionResults: suggestions,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentSuggestion: $searchViewModel.currentSuggestion,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***noResultsMessage: noResultsMessage
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder(padding: EdgeInsets())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: searchBarWidth)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if searchViewModel.isEligibleForRequery {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Repeat Search Here") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***shouldZoomToResults = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.repeatSearch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED***.onChange(of: searchViewModel.searchOutcome, perform: { newValue in
***REMOVED******REMOVED******REMOVED***switch newValue {
***REMOVED******REMOVED******REMOVED***case .results(let results):
***REMOVED******REMOVED******REMOVED******REMOVED***display(searchResults: (try? results.get()) ?? [])
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***display(searchResults: [])
***REMOVED******REMOVED***
***REMOVED***)
***REMOVED******REMOVED***.onChange(of: searchViewModel.selectedResult, perform: display(selectedResult:))
***REMOVED******REMOVED***.onReceive(searchViewModel.$currentQuery) { _ in
***REMOVED******REMOVED******REMOVED***searchViewModel.updateSuggestions()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Modifiers
***REMOVED***
***REMOVED******REMOVED***/ Specifies whether a built-in result view will be shown. If `false`, the result display/selection
***REMOVED******REMOVED***/ list is not shown. Set to `false` if you want to define a custom result list. You might use a
***REMOVED******REMOVED***/ custom result list to show results in a separate list, disconnected from the rest of the search view.
***REMOVED******REMOVED***/ Defaults to `true`.
***REMOVED******REMOVED***/ - Parameter enableResultListView: The new value.
***REMOVED******REMOVED***/ - Returns: A new `SearchView`.
***REMOVED***public func enableResultListView(_ enableResultListView: Bool) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.enableResultListView = enableResultListView
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The string shown in the search view when no user query is entered.
***REMOVED******REMOVED***/ Defaults to "Find a place or address".
***REMOVED******REMOVED***/ - Parameter searchFieldPrompt: The new value.
***REMOVED******REMOVED***/ - Returns: A new `SearchView`.
***REMOVED***public func searchFieldPrompt(_ searchFieldPrompt: String) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.searchFieldPrompt = searchFieldPrompt
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the message to show when there are no results or suggestions.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ The default message is "No results found".
***REMOVED******REMOVED***/ - Parameter noResultsMessage: The new value.
***REMOVED******REMOVED***/ - Returns: A new `SearchView`.
***REMOVED***public func noResultsMessage(_ noResultsMessage: String) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.noResultsMessage = noResultsMessage
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

private extension SearchView {
***REMOVED***func display(searchResults: [SearchResult]) {
***REMOVED******REMOVED***guard let resultsOverlay = resultsOverlay else { return ***REMOVED***
***REMOVED******REMOVED***let resultGraphics: [Graphic] = searchResults.compactMap { result in
***REMOVED******REMOVED******REMOVED***guard let graphic = result.geoElement as? Graphic else { return nil ***REMOVED***
***REMOVED******REMOVED******REMOVED***graphic.update(with: result)
***REMOVED******REMOVED******REMOVED***return graphic
***REMOVED***
***REMOVED******REMOVED***resultsOverlay.removeAllGraphics()
***REMOVED******REMOVED***resultsOverlay.addGraphics(resultGraphics)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Make sure we have a viewpoint to zoom to.
***REMOVED******REMOVED***guard let viewpoint = viewpoint else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if !resultGraphics.isEmpty,
***REMOVED******REMOVED***   let envelope = resultsOverlay.extent,
***REMOVED******REMOVED***   shouldZoomToResults {
***REMOVED******REMOVED******REMOVED***let builder = EnvelopeBuilder(envelope: envelope)
***REMOVED******REMOVED******REMOVED***builder.expand(factor: 1.1)
***REMOVED******REMOVED******REMOVED***let targetExtent = builder.toGeometry() as! Envelope
***REMOVED******REMOVED******REMOVED***viewpoint.wrappedValue = Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***targetExtent: targetExtent
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***searchViewModel.lastSearchExtent = targetExtent
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***viewpoint.wrappedValue = nil
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if !shouldZoomToResults { shouldZoomToResults = true ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func display(selectedResult: SearchResult?) {
***REMOVED******REMOVED***guard let selectedResult = selectedResult else { return ***REMOVED***
***REMOVED******REMOVED***viewpoint?.wrappedValue = selectedResult.selectionViewpoint
***REMOVED***
***REMOVED***

struct SearchResultList: View {
***REMOVED***var searchResults: Result<[SearchResult], SearchError>
***REMOVED***@Binding var selectedResult: SearchResult?
***REMOVED***var noResultsMessage: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch searchResults {
***REMOVED******REMOVED******REMOVED***case .success(let results):
***REMOVED******REMOVED******REMOVED******REMOVED***if results.count != 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if results.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Only show the list if we have more than one result.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(results) { result in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ResultRow(searchResult: result)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedResult = result
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if result == selectedResult {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "checkmark.circle.fill")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.accentColor)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else if results.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(noResultsMessage)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(error.localizedDescription)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

struct SearchSuggestionList: View {
***REMOVED***var suggestionResults: Result<[SearchSuggestion], SearchError>
***REMOVED***@Binding var currentSuggestion: SearchSuggestion?
***REMOVED***var noResultsMessage: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***switch suggestionResults {
***REMOVED******REMOVED******REMOVED***case .success(let suggestions):
***REMOVED******REMOVED******REMOVED******REMOVED***if !suggestions.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(suggestions) { suggestion in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ResultRow(searchSuggestion: suggestion)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentSuggestion = suggestion
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(noResultsMessage)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED***Text(error.errorDescription)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

struct ResultRow: View {
***REMOVED***var title: String
***REMOVED***var subtitle: String = ""
***REMOVED***var image: AnyView
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***image
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.callout)
***REMOVED******REMOVED******REMOVED******REMOVED***if !subtitle.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(subtitle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension ResultRow {
***REMOVED***init(searchSuggestion: SearchSuggestion) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: searchSuggestion.displayTitle,
***REMOVED******REMOVED******REMOVED***subtitle: searchSuggestion.displaySubtitle,
***REMOVED******REMOVED******REMOVED***image: AnyView(
***REMOVED******REMOVED******REMOVED******REMOVED***(searchSuggestion.isCollection ?
***REMOVED******REMOVED******REMOVED******REMOVED*** Image(systemName: "magnifyingglass") :
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***uiImage: UIImage(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***named: "pin",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***in: Bundle.module, with: nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***init(searchResult: SearchResult) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***title: searchResult.displayTitle,
***REMOVED******REMOVED******REMOVED***subtitle: searchResult.displaySubtitle,
***REMOVED******REMOVED******REMOVED***image: AnyView(
***REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: UIImage.mapPin)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.scaleEffect(0.65)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private extension Graphic {
***REMOVED***func update(with result: SearchResult) {
***REMOVED******REMOVED***if symbol == nil {
***REMOVED******REMOVED******REMOVED***symbol = Symbol.searchResult()
***REMOVED***
***REMOVED******REMOVED***setAttributeValue(result.displayTitle, forKey: "displayTitle")
***REMOVED******REMOVED***setAttributeValue(result.displaySubtitle, forKey: "displaySubtitle")
***REMOVED***
***REMOVED***

private extension Symbol {
***REMOVED******REMOVED***/ A search result marker symbol.
***REMOVED***static func searchResult() -> MarkerSymbol {
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
