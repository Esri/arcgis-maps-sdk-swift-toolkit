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
    /// Creates a `SearchView`.
    /// - Parameters:
    ///   - queryArea: The search area to be used for the current query.
    ///   - queryCenter: Defines the center for the search.
    ///   - resultMode: Defines how many results to return.
    ///   - sources: Collection of search sources to be used.
    public init(
        queryArea: Binding<Geometry?>? = nil,
        queryCenter: Binding<Point?>? = nil,
        resultMode: SearchResultMode = .automatic,
        sources: [SearchSource] = [],
        geoViewExtent: Binding<Envelope?>? = nil,
        isGeoViewNavigating: Binding<Bool>? = nil
    ) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(
            queryArea: queryArea,
            queryCenter: queryCenter,
            resultMode: resultMode,
            sources: sources.isEmpty ? [LocatorSearchSource()] : sources
        ))
  
        _geoViewExtent = geoViewExtent ?? Binding.constant(nil)
        _isGeoViewNavigating = isGeoViewNavigating ?? Binding.constant(false)
    }
    
    /// The view model used by the view. The `SearchViewModel` manages state and handles the
    /// activity of searching. The view observes `SearchViewModel` for changes in state. The view
    /// calls methods on `SearchViewModel` in response to user action.
    @StateObject private var viewModel: SearchViewModel

    /// Tracks the current user-entered query. This property drives both suggestions and searches.
    var currentQuery: String = ""
    
    /// The current map/scene view extent. Defaults to `nil`.
    ///
    /// This should be updated via `geoViewExtent(:)`as the user navigates the map/scene. It will be
    /// used to determine the value of `isEligibleForRequery` for the 'Repeat
    /// search here' behavior. If that behavior is not wanted, it should be left `nil`.
    @Binding var geoViewExtent: Envelope?

    /// The `Viewpoint` used to pan/zoom to results. If `nil`, there will be no zooming to results.
    var viewpoint: Binding<Viewpoint?>? = nil
    
    /// The `GraphicsOverlay` used to display results. If `nil`, no results will be displayed.
    var resultsOverlay: GraphicsOverlay? = nil
    
    /// Collection of search sources to be used. This list is maintained over time and is not nullable.
    /// The view should observe this list for changes. Consumers should add and remove sources from
    /// this list as needed.
    /// NOTE: Only the first source is currently used; multiple sources are not yet supported.
    var sources: [SearchSource] {
        viewModel.sources
    }
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    /// The string shown in the search view when no user query is entered.
    /// Defaults to "Find a place or address". Note: this is set using the
    /// `prompt` modifier.
    private var prompt: String = "Find a place or address"
    
    /// Determines whether a built-in result view will be shown. Defaults to `true`.
    /// If `false`, the result display/selection list is not shown. Set to false if you want to hide the results
    /// or define a custom result list. You might use a custom result list to show results in a separate list,
    /// disconnected from the rest of the search view.
    /// Note: this is set using the `enableResultListView` modifier.
    private var enableResultListView = true
    
    /// Message to show when there are no results or suggestions. Defaults to "No results found".
    /// Note: this is set using the `noResultsMessage` modifier.
    private var noResultsMessage = "No results found"

    /// The width of the search bar, taking into account the horizontal and vertical size classes
    /// of the device. This will cause the search field to display full-width on an iPhone in portrait
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
    
    /// Determines whether the results lists are displayed.
    @State private var isResultListHidden: Bool = false
    
    /// Determines whether the geoView is navigating in response to user interaction.
    @Binding private var isGeoViewNavigating: Bool

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    Spacer()
                    VStack {
                        SearchField(
                            query: $viewModel.currentQuery,
                            prompt: prompt,
                            isResultsButtonHidden: !enableResultListView,
                            isResultListHidden: $isResultListHidden
                        )
                            .onSubmit { viewModel.commitSearch() }
                            .submitLabel(.search)
                        if enableResultListView,
                           !isResultListHidden,
                           let searchOutcome = viewModel.searchOutcome {
                            Group {
                                switch searchOutcome {
                                case .results(let results):
                                    SearchResultList(
                                        searchResults: results,
                                        selectedResult: $viewModel.selectedResult,
                                        noResultsMessage: noResultsMessage
                                    )
                                        .frame(height: useHalfHeightResults ? geometry.size.height / 2 : nil)
                                case .suggestions(let suggestions):
                                    SearchSuggestionList(
                                        suggestionResults: suggestions,
                                        currentSuggestion: $viewModel.currentSuggestion,
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
            if viewModel.isEligibleForRequery {
                Button("Repeat Search Here") {
                    viewModel.repeatSearch()
                }
                .esriBorder()
            }
        }
        .listStyle(.plain)
        .onReceive(viewModel.$currentQuery) { _ in
            viewModel.updateSuggestions()
        }
        .onChange(of: geoViewExtent) { _ in
            viewModel.geoViewExtent = geoViewExtent
        }
        .onChange(of: isGeoViewNavigating) { _ in
            viewModel.isGeoViewNavigating = isGeoViewNavigating
        }
        .onAppear() {
            viewModel.currentQuery = currentQuery
            viewModel.viewpoint = viewpoint
            viewModel.resultsOverlay = resultsOverlay
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

    /// Sets the current query.
    /// - Parameter newQueryString: The new value.
    /// - Returns: The `SearchView`.
    public func currentQuery(_ newQuery: String) -> Self {
        var copy = self
        copy.currentQuery = newQuery
        return copy
    }
    
    /// The `Viewpoint` used to pan/zoom to results. If `nil`, there will be no zooming to results.
    /// - Parameter newViewpoint: The new value.
    /// - Returns: The `SearchView`.
    public func viewpoint(_ newViewpoint: Binding<Viewpoint?>?) -> Self {
        var copy = self
        copy.viewpoint = newViewpoint
        return copy
    }

    /// The `GraphicsOverlay` used to display results. If `nil`, no results will be displayed.
    /// - Parameter newResultsOverlay: The new value.
    /// - Returns: The `SearchView`.
    public func resultsOverlay(_ newResultsOverlay: GraphicsOverlay?) -> Self {
        var copy = self
        copy.resultsOverlay = newResultsOverlay
        return copy
    }
}

/// A View displaying the list of search results.
struct SearchResultList: View {
    /// The array of search results to display.
    var searchResults: [SearchResult]
    /// The result the user selects.
    @Binding var selectedResult: SearchResult?
    /// The message to display when there are no results.
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
                            Spacer()
                        }
                        .selected(result == selectedResult)
                    }
                }
            } else if searchResults.isEmpty {
                NoResultsView(message: noResultsMessage)
            }
        }
    }
}

/// A View displaying the list of search suggestion results.
struct SearchSuggestionList: View {
    /// The array of suggestion results to display.
    var suggestionResults: [SearchSuggestion]
    /// The suggestion the user selects.
    @Binding var currentSuggestion: SearchSuggestion?
    /// The message to display when there are no results.
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

/// A View displaying the "no results" message when there are no search or suggestion results.
struct NoResultsView: View {
    /// The message to display when there are no results.
    var message: String
    
    var body: some View {
        LazyVStack {
            Text(message)
                .padding()
        }
    }
}

/// A view representing a row containing one search or suggestion result.
struct ResultRow: View {
    /// The title of the result.
    var title: String
    /// Additional result information, if available.
    var subtitle: String = ""
    /// The image to display for the result.
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
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
    }
}

extension ResultRow {
    /// Creates a `ResultRow` from a search suggestion.
    /// - Parameter searchSuggestion: The search suggestion displayed in the row.
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
    
    /// Creates a `ResultRow` from a search result.
    /// - Parameter searchResult: The search result displayed in the view.
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
