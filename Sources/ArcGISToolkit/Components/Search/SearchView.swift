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
        resultsOverlay: Binding<GraphicsOverlay>? = nil
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
    private var resultsOverlay: Binding<GraphicsOverlay>? = nil
    
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
                Spacer()
                VStack {
                    TextField(
                        searchViewModel.defaultPlaceholder,
                        text: $searchViewModel.currentQuery
                    ) { _ in
                    } onCommit: {
                        searchViewModel.commitSearch()
                    }
                    .esriDeleteTextButton(text: $searchViewModel.currentQuery)
                    .esriSearchButton { searchViewModel.commitSearch() }
                    .esriShowResultsButton(
                        isHidden: !enableResultListView,
                        showResults: $showResultListView
                    )
                    .esriBorder()
                    if enableResultListView, showResultListView {
                        if let results = searchViewModel.results {
                            SearchResultList(
                                searchResults: results,
                                selectedResult: $searchViewModel.selectedResult,
                                noResultMessage: noResultMessage
                            )
                        }
                        if let suggestions = searchViewModel.suggestions {
                            SearchSuggestionList(
                                suggestionResults: suggestions,
                                currentSuggestion: $searchViewModel.currentSuggestion,
                                noResultMessage: noResultMessage
                            )
                        }
                    }
                    Spacer()
                }
                .frame(width: searchBarWidth)
            }
            if searchViewModel.isEligibleForRequery {
                Button("Repeat Search Here") {
                    shouldZoomToResults = false
                    searchViewModel.repeatSearch()
                }
                .esriBorder()
            }
        }
        .listStyle(.plain)
        .onChange(of: searchViewModel.results) {
            display(searchResults: $0)
        }
        .onChange(of: searchViewModel.selectedResult) {
            display(selectedResult: $0)
        }
        .onReceive(searchViewModel.$currentQuery) { _ in
            searchViewModel.updateSuggestions()
        }
        
        Spacer()
    }
    
    // MARK: Modifiers
    
    /// Determines whether a built-in result view will be shown. If `false`, the result display/selection
    /// list is not shown. Set to `false` if you want to define a custom result list. You might use a
    /// custom result list to show results in a separate list, disconnected from the rest of the search view.
    /// Defaults to `true`.
    /// - Parameter enableResultListView: The new value.
    /// - Returns: The `SearchView`.
    public func enableResultListView(_ enableResultListView: Bool) -> Self {
        var copy = self
        copy.enableResultListView = enableResultListView
        return copy
    }
    
    /// Message to show when there are no results or suggestions.  Defaults to "No results found".
    /// - Parameter noResultMessage: The new value.
    /// - Returns: The `SearchView`.
    public func noResultMessage(_ noResultMessage: String) -> Self {
        var copy = self
        copy.noResultMessage = noResultMessage
        return copy
    }
    
    /// The width of the search bar.
    /// - Parameter searchBarWidth: The desired width of the search bar.
    /// - Returns: The `SearchView`.
    public func searchBarWidth(_ searchBarWidth: CGFloat) -> Self {
        var copy = self
        copy.searchBarWidth = searchBarWidth
        return copy
    }
}

extension SearchView {
    private func display(searchResults: Result<[SearchResult], SearchError>?) {
        switch searchResults {
        case .success(let results):
            var resultGraphics = [Graphic]()
            results.forEach({ result in
                if let graphic = result.geoElement as? Graphic {
                    graphic.updateGraphic(withResult: result)
                    resultGraphics.append(graphic)
                }
            })
            resultsOverlay?.wrappedValue.removeAllGraphics()
            resultsOverlay?.wrappedValue.addGraphics(resultGraphics)
            
            if resultGraphics.count > 0,
               let envelope = resultsOverlay?.wrappedValue.extent,
               shouldZoomToResults {
                let builder = EnvelopeBuilder(envelope: envelope)
                builder.expand(factor: 1.1)
                let targetExtent = builder.toGeometry() as! Envelope
                viewpoint?.wrappedValue = Viewpoint(
                    targetExtent: targetExtent
                )
                searchViewModel.lastSearchExtent = targetExtent
            }
            else {
                viewpoint?.wrappedValue = nil
            }
        default:
            resultsOverlay?.wrappedValue.removeAllGraphics()
            viewpoint?.wrappedValue = nil
        }
        
        if !shouldZoomToResults { shouldZoomToResults = true }
    }
    
    private func display(selectedResult: SearchResult?) {
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
                                SearchResultRow(result: result)
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
                }
                else if results.isEmpty {
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
        Group {
            switch suggestionResults {
            case .success(let suggestions):
                if !suggestions.isEmpty {
                    List {
                        if suggestions.count > 0 {
                            ForEach(suggestions) { suggestion in
                                SuggestionResultRow(suggestion: suggestion)
                                    .onTapGesture() {
                                        currentSuggestion = suggestion
                                    }
                            }
                        }
                    }
                }
                else {
                    List {
                        Text(noResultMessage)
                    }
                }
            case .failure(let error):
                List {
                    Text(error.errorDescription)
                }
            }
        }
        .esriBorder(padding: EdgeInsets())
    }
}

struct SearchResultRow: View {
    var result: SearchResult
    
    var body: some View {
        HStack {
            Image(uiImage: UIImage.mapPin)
                .scaleEffect(0.65)
            ResultRow(
                title: result.displayTitle,
                subtitle: result.displaySubtitle
            )
        }
    }
}

struct SuggestionResultRow: View {
    var suggestion: SearchSuggestion
    
    var body: some View {
        HStack {
            mapPinImage()
                .foregroundColor(.secondary)
            ResultRow(
                title: suggestion.displayTitle,
                subtitle: suggestion.displaySubtitle
            )
        }
    }
    
    func mapPinImage() -> Image {
      suggestion.isCollection ?
        Image(systemName: "magnifyingglass") :
        Image(uiImage: UIImage(named: "pin", in: Bundle.module, with: nil)!)
    }
}

struct ResultRow: View {
    var title: String
    var subtitle: String?
    
    var body: some View {
        VStack (alignment: .leading){
            Text(title)
                .font(.callout)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
            }
        }
    }
}

private extension Graphic {
    func updateGraphic(withResult result: SearchResult) {
        if symbol == nil {
            symbol = .resultSymbol
        }
        setAttributeValue(result.displayTitle, forKey: "displayTitle")
        setAttributeValue(result.displaySubtitle, forKey: "displaySubtitle")
    }
}

private extension Symbol {
    /// A search result marker symbol.
    static var resultSymbol: MarkerSymbol {
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
