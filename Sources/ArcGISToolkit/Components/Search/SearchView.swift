// Copyright 2021 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import Combine
import ArcGIS

/// SearchView presents a search experience, powered by an underlying SearchViewModel.
public struct SearchView: View {
    /// Creates a new `SearchView`.
    /// - Parameters:
    ///   - searchViewModel: The view model used by `SearchView`.
    ///   - viewpoint: The `Viewpoint` used to zoom to results.
    ///   - resultsOverlay: The `GraphicsOverlay` used to display results.
    public init(
        searchViewModel: SearchViewModel? = nil,
        viewpoint: Binding<Viewpoint?>? = nil,
        resultsOverlay: GraphicsOverlay? = nil
    ) {
        if let searchViewModel = searchViewModel {
            self.searchViewModel = searchViewModel
        }
        else {
            self.searchViewModel = SearchViewModel(
                sources: [LocatorSearchSource()]
            )
        }
        self.resultsOverlay = resultsOverlay
        self.viewpoint = viewpoint
    }
    
    /// The view model used by the view. The `SearchViewModel` manages state and handles the
    /// activity of searching. The view observes `SearchViewModel` for changes in state. The view
    /// calls methods on `SearchViewModel` in response to user action.
    @ObservedObject
    var searchViewModel: SearchViewModel
    
    /// The `Viewpoint` used to pan/zoom to results.  If `nil`, there will be no zooming to results.
    private var viewpoint: Binding<Viewpoint?>? = nil
    
    /// The `GraphicsOverlay` used to display results.  If `nil`, no results will be displayed.
    private var resultsOverlay: GraphicsOverlay? = nil
    
    /// The string shown in the search view when no user query is entered.
    /// Defaults to "Find a place or address". Note: this is set using the
    /// `defaultPlaceholder` modifier.
    private var defaultPlaceholder: String = "Find a place or address"

    /// Determines whether a built-in result view will be shown. Defaults to true.
    /// If false, the result display/selection list is not shown. Set to false if you want to hide the results
    /// or define a custom result list. You might use a custom result list to show results in a separate list,
    /// disconnected from the rest of the search view.
    /// Note: this is set using the `enableResultListView` modifier.
    private var enableResultListView = true
    
    /// Message to show when there are no results or suggestions.  Defaults to "No results found".
    /// Note: this is set using the `noResultMessage` modifier.
    private var noResultMessage = "No results found"

    private var searchBarWidth: CGFloat = 360.0
    
    @State
    private var shouldZoomToResults = true
    
    /// Determines whether the results lists are displayed.
    @State
    private var showResultListView: Bool = true
    
    public var body: some View {
        VStack {
            HStack {
                VStack (alignment: .center) {
                    SearchField(
                        currentQuery: $searchViewModel.currentQuery,
                        defaultPlaceholder: defaultPlaceholder,
                        isShowResultsHidden: !enableResultListView,
                        showResults: $showResultListView,
                        onCommit: { searchViewModel.commitSearch() }
                    )

                    if enableResultListView, showResultListView {
                        if let results = searchViewModel.results {
                            SearchResultList(
                                searchResults: results,
                                selectedResult: $searchViewModel.selectedResult,
                                noResultMessage: noResultMessage
                            )
                        } else if let suggestions = searchViewModel.suggestions {
                            SearchSuggestionList(
                                suggestionResults: suggestions,
                                currentSuggestion: $searchViewModel.currentSuggestion,
                                noResultMessage: noResultMessage
                            )
                        }
                    }
                }
                .frame(width: searchBarWidth)
            }
            Spacer()
            if searchViewModel.isEligibleForRequery {
                Button("Repeat Search Here") {
                    shouldZoomToResults = false
                    searchViewModel.repeatSearch()
                }
                .esriBorder()
            }
        }
        .listStyle(.plain)
        .onChange(of: searchViewModel.results, perform: { newValue in
            display(searchResults: (try? newValue?.get()) ?? [])
        })
        .onChange(of: searchViewModel.selectedResult, perform: display(selectedResult:))
        .onReceive(searchViewModel.$currentQuery) { _ in
            searchViewModel.updateSuggestions()
        }
    }
    
    // MARK: Modifiers
    
    /// Determines whether a built-in result view will be shown. If `false`, the result display/selection
    /// list is not shown. Set to `false` if you want to define a custom result list. You might use a
    /// custom result list to show results in a separate list, disconnected from the rest of the search view.
    /// Defaults to `true`.
    /// - Parameter enableResultListView: The new value.
    /// - Returns: A new `SearchView`.
    public func enableResultListView(_ enableResultListView: Bool) -> Self {
        var copy = self
        copy.enableResultListView = enableResultListView
        return copy
    }
    
    /// The string shown in the search view when no user query is entered.
    /// Defaults to "Find a place or address".
    /// - Parameter defaultPlaceholder: The new value.
    /// - Returns: A new `SearchView`.
    public func defaultPlaceholder(_ defaultPlaceholder: String) -> Self {
        var copy = self
        copy.defaultPlaceholder = defaultPlaceholder
        return copy
    }
    
    /// Message to show when there are no results or suggestions.  Defaults to "No results found".
    /// - Parameter noResultMessage: The new value.
    /// - Returns: A new `SearchView`.
    public func noResultMessage(_ noResultMessage: String) -> Self {
        var copy = self
        copy.noResultMessage = noResultMessage
        return copy
    }

    /// The width of the search bar.
    /// - Parameter searchBarWidth: The desired width of the search bar.
    /// - Returns: A new `SearchView`.
    public func searchBarWidth(_ searchBarWidth: CGFloat) -> Self {
        var copy = self
        copy.searchBarWidth = searchBarWidth
        return copy
    }
}

private extension SearchView {
    func display(searchResults: [SearchResult]) {
        guard let resultsOverlay = resultsOverlay else { return }
        let resultGraphics: [Graphic] = searchResults.compactMap { result in
            guard let graphic = result.geoElement as? Graphic else { return nil }
            graphic.update(with: result)
            return graphic
        }
        resultsOverlay.removeAllGraphics()
        resultsOverlay.addGraphics(resultGraphics)
        
        if !resultGraphics.isEmpty,
           let envelope = resultsOverlay.extent,
           shouldZoomToResults {
            let builder = EnvelopeBuilder(envelope: envelope)
            builder.expand(factor: 1.1)
            let targetExtent = builder.toGeometry() as! Envelope
            viewpoint?.wrappedValue = Viewpoint(
                targetExtent: targetExtent
            )
            searchViewModel.lastSearchExtent = targetExtent
        } else {
            viewpoint?.wrappedValue = nil
        }
        
        if !shouldZoomToResults { shouldZoomToResults = true }
    }
    
    func display(selectedResult: SearchResult?) {
        guard let selectedResult = selectedResult else { return }
        viewpoint?.wrappedValue = selectedResult.selectionViewpoint
    }
}

struct SearchResultList: View {
    var searchResults: Result<[SearchResult], SearchError>
    @Binding var selectedResult: SearchResult?
    var noResultMessage: String
    
    var body: some View {
        Group {
            switch searchResults {
            case .success(let results):
                if results.count > 1 {
                    // Only show the list if we have more than one result.
                    List {
                        ForEach(results) { result in
                            HStack {
                                ResultRow(searchResult: result)
                                    .onTapGesture {
                                        selectedResult = result
                                    }
                                if result == selectedResult {
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                } else if results.isEmpty {
                    List {
                        Text(noResultMessage)
                    }
                }
            case .failure(let error):
                List {
                    Text(error.localizedDescription)
                }
            }
        }
        .esriBorder(padding: EdgeInsets())
    }
}

struct SearchSuggestionList: View {
    var suggestionResults: Result<[SearchSuggestion], SearchError>
    @Binding var currentSuggestion: SearchSuggestion?
    var noResultMessage: String
    
    var body: some View {
        List {
            switch suggestionResults {
            case .success(let suggestions):
                if !suggestions.isEmpty {
                    if suggestions.count > 0 {
                        ForEach(suggestions) { suggestion in
                            ResultRow(searchSuggestion: suggestion)
                                .onTapGesture() {
                                    currentSuggestion = suggestion
                                }
                        }
                    }
                }
                else {
                    Text(noResultMessage)
                }
            case .failure(let error):
                Text(error.errorDescription)
            }
        }
        .esriBorder(padding: EdgeInsets())
    }
}

struct ResultRow: View {
    var title: String
    var subtitle: String = ""
    var image: AnyView

    var body: some View {
        HStack {
            image
            VStack(alignment: .leading) {
                Text(title)
                    .font(.callout)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                }
            }
        }
    }
}

extension ResultRow {
    init(searchSuggestion: SearchSuggestion) {
        self.init(
            title: searchSuggestion.displayTitle,
            subtitle: searchSuggestion.displaySubtitle,
            image: AnyView(
                (searchSuggestion.isCollection ?
                 Image(systemName: "magnifyingglass") :
                    Image(
                        uiImage: UIImage(
                            named: "pin",
                            in: Bundle.module, with: nil
                        )!
                    )
                )
                    .foregroundColor(.secondary)
            )
        )
    }
    
    init(searchResult: SearchResult) {
        self.init(
            title: searchResult.displayTitle,
            subtitle: searchResult.displaySubtitle,
            image: AnyView(
                Image(uiImage: UIImage.mapPin)
                    .scaleEffect(0.65)
            )
        )
    }
}

private extension Graphic {
    func update(with result: SearchResult) {
        if symbol == nil {
            symbol = Symbol.searchResult()
        }
        setAttributeValue(result.displayTitle, forKey: "displayTitle")
        setAttributeValue(result.displaySubtitle, forKey: "displaySubtitle")
    }
}

private extension Symbol {
    /// A search result marker symbol.
    static func searchResult() -> MarkerSymbol {
        let image = UIImage.mapPin
        let symbol = PictureMarkerSymbol(image: image)
        symbol.offsetY = Float(image.size.height / 2.0)
        return symbol
    }
}

extension UIImage {
    static var mapPin: UIImage {
        return UIImage(named: "MapPin", in: Bundle.module, with: nil)!
    }
}
