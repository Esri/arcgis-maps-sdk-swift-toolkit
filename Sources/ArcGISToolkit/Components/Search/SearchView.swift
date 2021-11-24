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
import ArcGIS

/// `SearchView` presents a search experience, powered by an underlying `SearchViewModel`.
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
        self.searchViewModel = searchViewModel ?? SearchViewModel(
            sources: [LocatorSearchSource()]
        )
        self.resultsOverlay = resultsOverlay
        self.viewpoint = viewpoint
    }
    
    /// The view model used by the view. The `SearchViewModel` manages state and handles the
    /// activity of searching. The view observes `SearchViewModel` for changes in state. The view
    /// calls methods on `SearchViewModel` in response to user action.
    @ObservedObject
    var searchViewModel: SearchViewModel
    
    /// The `Viewpoint` used to pan/zoom to results.  If `nil`, there will be no zooming to results.
    private let viewpoint: Binding<Viewpoint?>?
    
    /// The `GraphicsOverlay` used to display results.  If `nil`, no results will be displayed.
    private let resultsOverlay: GraphicsOverlay?
    
    /// The string shown in the search view when no user query is entered.
    /// Defaults to "Find a place or address". Note: this is set using the
    /// `prompt` modifier.
    private var prompt: String = "Find a place or address"
    
    /// Determines whether a built-in result view will be shown. Defaults to true.
    /// If false, the result display/selection list is not shown. Set to false if you want to hide the results
    /// or define a custom result list. You might use a custom result list to show results in a separate list,
    /// disconnected from the rest of the search view.
    /// Note: this is set using the `enableResultListView` modifier.
    private var enableResultListView = true
    
    /// Message to show when there are no results or suggestions. Defaults to "No results found".
    /// Note: this is set using the `noResultsMessage` modifier.
    private var noResultsMessage = "No results found"
    
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?
    
    @Environment(\.verticalSizeClass)
    private var verticalSizeClass: UserInterfaceSizeClass?
    
    /// The width of the search bar, taking into account the horizontal and vertical size classes
    /// of the device.  This will cause the search field to display full-width on an iPhone in portrait
    /// orientation (and certain iPad multitasking configurations) and limit the width to `360` in other cases.
    private var searchBarWidth: CGFloat? {
        horizontalSizeClass == .compact && verticalSizeClass == .regular ? nil : 360
    }
    
    /// If `true`, will draw the results list view at half height, exposing a portion of the
    /// underlying map below the list on an iPhone in portrait orientation (and certain iPad multitasking
    /// configurations).  If `false`, will draw the results list view full size.
    private var useHalfHeightResults: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
    
    /// If `true`, will set the viewpoint to the extent of the results, plus a little buffer, which will
    /// cause the geoView to zoom to the extent of the results.  If `false`,
    /// no setting of the viewpoint will occur.
    @State
    private var shouldZoomToResults = true
    
    /// Determines whether the results lists are displayed.
    @State
    private var isResultListHidden: Bool = false
    
    public var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    Spacer()
                    VStack {
                        SearchField(
                            query: $searchViewModel.currentQuery,
                            prompt: prompt,
                            isResultsButtonHidden: !enableResultListView,
                            isResultListHidden: $isResultListHidden
                        )
                            .onSubmit { searchViewModel.commitSearch() }
                            .submitLabel(.search)
                            .esriBorder(padding: EdgeInsets())
                        if enableResultListView,
                           !isResultListHidden,
                           let searchOutcome = searchViewModel.searchOutcome {
                            Group {
                                switch searchOutcome {
                                case .results(let results):
                                    SearchResultList(
                                        searchResults: results,
                                        selectedResult: $searchViewModel.selectedResult,
                                        noResultsMessage: noResultsMessage
                                    )
                                        .frame(height: useHalfHeightResults ? geometry.size.height / 2 : nil)
                                case .suggestions(let suggestions):
                                    SearchSuggestionList(
                                        suggestionResults: suggestions,
                                        currentSuggestion: $searchViewModel.currentSuggestion,
                                        noResultsMessage: noResultsMessage
                                    )
                                case .failure(let errorString):
                                    List {
                                        Text(errorString)
                                    }
                                }
                            }
                            .esriBorder(padding: EdgeInsets())
                        }
                    }
                    .frame(width: searchBarWidth)
                }
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
        .onChange(of: searchViewModel.searchOutcome, perform: { newValue in
            switch newValue {
            case .results(let results):
                display(searchResults: results)
            default:
                display(searchResults: [])
            }
        })
        .onChange(of: searchViewModel.selectedResult, perform: display(selectedResult:))
        .onReceive(searchViewModel.$currentQuery) { _ in
            searchViewModel.updateSuggestions()
        }
    }
}

// MARK: Modifiers
extension SearchView {
    /// Specifies whether a built-in result view will be shown. If `false`, the result display/selection
    /// list is not shown. Set to `false` if you want to define a custom result list. You might use a
    /// custom result list to show results in a separate list, disconnected from the rest of the search view.
    /// Defaults to `true`.
    /// - Parameter newEnableResultListView: The new value.
    /// - Returns: A new `SearchView`.
    public func enableResultListView(_ newEnableResultListView: Bool) -> Self {
        var copy = self
        copy.enableResultListView = newEnableResultListView
        return copy
    }
    
    /// The string shown in the search view when no user query is entered.
    /// Defaults to "Find a place or address".
    /// - Parameter newPrompt: The new value.
    /// - Returns: A new `SearchView`.
    public func prompt(_ newPrompt: String) -> Self {
        var copy = self
        copy.prompt = newPrompt
        return copy
    }
    
    /// Sets the message to show when there are no results or suggestions.
    ///
    /// The default message is "No results found".
    /// - Parameter newNoResultsMessage: The new value.
    /// - Returns: A new `SearchView`.
    public func noResultsMessage(_ newNoResultsMessage: String) -> Self {
        var copy = self
        copy.noResultsMessage = newNoResultsMessage
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
        
        // Make sure we have a viewpoint to zoom to.
        guard let viewpoint = viewpoint else { return }
        
        if !resultGraphics.isEmpty,
           let envelope = resultsOverlay.extent,
           shouldZoomToResults {
            let builder = EnvelopeBuilder(envelope: envelope)
            builder.expand(factor: 1.1)
            let targetExtent = builder.toGeometry() as! Envelope
            viewpoint.wrappedValue = Viewpoint(
                targetExtent: targetExtent
            )
            searchViewModel.lastSearchExtent = targetExtent
        } else {
            viewpoint.wrappedValue = nil
        }
        
        if !shouldZoomToResults { shouldZoomToResults = true }
    }
    
    func display(selectedResult: SearchResult?) {
        guard let selectedResult = selectedResult else { return }
        viewpoint?.wrappedValue = selectedResult.selectionViewpoint
    }
}

struct SearchResultList: View {
    var searchResults: [SearchResult]
    @Binding var selectedResult: SearchResult?
    var noResultsMessage: String
    
    var body: some View {
        if searchResults.count != 1 {
            if searchResults.count > 1 {
                List {
                    // Only show the list if we have more than one result.
                    ForEach(searchResults) { result in
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
            } else if searchResults.isEmpty {
                NoResultsView(message: noResultsMessage)
            }
        }
    }
}

struct SearchSuggestionList: View {
    var suggestionResults: [SearchSuggestion]
    @Binding var currentSuggestion: SearchSuggestion?
    var noResultsMessage: String
    
    var body: some View {
        if !suggestionResults.isEmpty {
            List {
                ForEach(suggestionResults) { suggestion in
                    ResultRow(searchSuggestion: suggestion)
                        .onTapGesture() {
                            currentSuggestion = suggestion
                        }
                }
            }
        } else {
            NoResultsView(message: noResultsMessage)
        }
    }
}

struct NoResultsView: View {
    var message: String
    
    var body: some View {
        LazyVStack {
            Text(message)
                .padding()
        }
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
