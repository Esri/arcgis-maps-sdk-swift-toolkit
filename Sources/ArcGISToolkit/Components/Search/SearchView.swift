// Copyright 2021 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS

/// `SearchView` enables searching using one or more locators, with support for suggestions,
/// automatic zooming, and custom search sources.
///
/// | iPhone | iPad |
/// | ------ | ---- |
/// | ![image](https://user-images.githubusercontent.com/3998072/203608897-5f3bf34a-0931-4d11-b3fc-18a5dd07131a.png) | ![image](https://user-images.githubusercontent.com/3998072/203608708-45a0096c-a8d6-457c-9ee1-8cdb9e5bb15a.png) |
///
/// **Features**
///
/// - Updates search suggestions as you type.
/// - Supports using the Esri world geocoder or any other ArcGIS locators.
/// - Supports searching using custom search sources.
/// - Allows for customization of the display of search results.
/// - Allows you to repeat a search within a defined area, and displays a button to enable that
/// search when the view's viewpoint changes.
///
/// `SearchView` uses search sources which implement the ``SearchSource`` protocol.
///
/// `SearchView` provides the following search sources:
///
/// - ``LocatorSearchSource``
/// - ``SmartLocatorSearchSource``
///
/// `SearchView` provides several instance methods, allowing customization and additional search
/// behaviors (such as displaying a "Repeat search here" button). See "Instance Methods" below.
///
/// **Behavior**
///
/// The `SearchView` will display the results list view at half height, exposing a portion of the
/// underlying map below the list, in compact environments. The user can hide or show the result
/// list after searching by clicking on the up/down chevron symbol on the right of the search bar.
///
/// **Associated Types**
///
/// `SearchView` has the following associated types:
///
/// - ``SearchField``
/// - ``SearchResult``
/// - ``SearchSuggestion``
/// - ``SearchOutcome``
/// - ``SearchResultMode``
///
/// To see the `SearchView` in action, and for examples of `Search` customization, check out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to [SearchExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/SearchExampleView.swift)
/// in the project. To learn more about using the `SearchView` see the <doc:SearchViewTutorial>.
public struct SearchView: View {
    /// Creates a `SearchView`.
    /// - Parameters:
    ///   - sources: A collection of search sources to be used.
    ///   - viewpoint: The `Viewpoint` used to pan/zoom to results. If `nil`, there will be
    ///   no zooming to results.
    ///   - geoViewProxy: The proxy to provide access to geo view operations.
    public init(
        sources: [SearchSource] = [],
        viewpoint: Binding<Viewpoint?>? = nil,
        geoViewProxy: GeoViewProxy? = nil
    ) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(
            sources: sources.isEmpty ? [LocatorSearchSource()] : sources,
            viewpoint: viewpoint,
            geoViewProxy: geoViewProxy
        ))
        
        _queryArea = .constant(nil)
        _queryCenter = .constant(nil)
        _geoViewExtent = .constant(nil)
        _isGeoViewNavigating = .constant(false)
    }
    
    /// The view model used by the view. The `SearchViewModel` manages state and handles the
    /// activity of searching. The view observes `SearchViewModel` for changes in state. The view
    /// calls methods on `SearchViewModel` in response to user action.
    @StateObject private var viewModel: SearchViewModel

    /// Tracks the current user-entered query. This property drives both suggestions and searches.
    var currentQuery = ""

    /// Tracks the current user-entered query. This property drives both suggestions and searches.
    var resultMode: SearchResultMode = .automatic

    /// The search area to be used for the current query. If `nil`, then there is no limiting of the
    /// search results to a given area.
    @Binding var queryArea: Geometry?

    /// Defines the center for the search. Defaults to `nil`.
    ///
    /// If `nil`, does not prioritize the search results around any point.
    @Binding var queryCenter: Point?
    
    /// A closure performed when the query has changed.
    private var onQueryChangedAction: ((String) -> Void)?
    
    /// The current map/scene view extent. Defaults to `nil`.
    ///
    /// This will be used to determine the value of `isEligibleForRequery` for the 'Repeat
    /// search here' behavior. If that behavior is not wanted, it should be left as `nil`.
    @Binding var geoViewExtent: Envelope?
    
    /// Determines whether the `geoView` is navigating in response to user interaction.
    @Binding private var isGeoViewNavigating: Bool

    /// The `GraphicsOverlay` used to display results. If `nil`, no results will be displayed.
    var resultsOverlay: GraphicsOverlay? = nil
    
    /// A collection of search sources to be used. This list is maintained over time.
    /// The view should observe this list for changes. Consumers should add and remove sources from
    /// this list as needed.
    /// NOTE: Only the first source is currently used; multiple sources are not yet supported.
    var sources: [SearchSource] {
        viewModel.sources
    }
    
    @Environment(\.isPortraitOrientation) var isPortraitOrientation
    
    /// The string shown in the search view when no user query is entered.
    /// Defaults to "Find a place or address". Note: this is set using the
    /// `prompt` modifier.
    private var prompt = String(
        localized: "Find a place or address",
        bundle: .toolkitModule,
        comment: "A hint for the user on what to search for in a search bar."
    )
    
    /// Determines whether a built-in result view will be shown. Defaults to `true`.
    /// If `false`, the result display/selection list is not shown. Set to false if you want to hide the results
    /// or define a custom result list. You might use a custom result list to show results in a separate list,
    /// disconnected from the rest of the search view.
    /// Note: this is set using the `enableResultListView` modifier.
    private var enableResultListView = true
    
    /// Message to show when there are no results or suggestions. Defaults to "No results found".
    /// Note: this is set using the `noResultsMessage` modifier.
    private var noResultsMessage = String(
        localized: "No results found",
        bundle: .toolkitModule,
        comment: "A message to show when there are no results or suggestions."
    )
    
    /// The width of the search bar, taking into account the horizontal and vertical size classes
    /// of the device. This will cause the search field to display full-width on an iPhone in portrait
    /// orientation (and certain iPad multitasking configurations) and limit the width to `360` in other cases.
    private var searchBarWidth: CGFloat? {
        isPortraitOrientation ? nil : 360
    }
    
    /// If `true`, will draw the results list view at half height, exposing a portion of the
    /// underlying map below the list on an iPhone in portrait orientation (and certain iPad multitasking
    /// configurations).  If `false`, will draw the results list view full size.
    private var useHalfHeightResults: Bool {
        isPortraitOrientation
    }
    
    /// Determines whether the results lists are displayed.
    @State private var isResultListHidden = false
    
    /// A Boolean value indicating whether the search field is focused or not.
    @FocusState private var searchFieldIsFocused: Bool
    
    public var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    Spacer()
                    VStack {
                        SearchField(
                            query: $viewModel.currentQuery,
                            prompt: prompt,
                            isFocused: $searchFieldIsFocused,
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
                Button {
                    viewModel.repeatSearch()
                } label: {
                    Text(
                        "Repeat Search Here",
                        bundle: .toolkitModule,
                        comment: """
                                  A label for button to show when the user has panned the map away
                                  from the original search location. 'Here' is in reference to the
                                  current visible extent of the map or scene.
                                  """
                    )
                }
                .esriBorder()
            }
        }
        .listStyle(.plain)
        .onReceive(viewModel.$currentQuery) { _ in
            onQueryChangedAction?(viewModel.currentQuery)
            viewModel.updateSuggestions()
        }
        .onChange(of: viewModel.selectedResult) { _ in
            searchFieldIsFocused = false
        }
        .onChange(of: viewModel.currentSuggestion) { _ in
            searchFieldIsFocused = false
        }
        .onChange(of: geoViewExtent) { _ in
            viewModel.geoViewExtent = geoViewExtent
        }
        .onChange(of: isGeoViewNavigating) { _ in
            viewModel.isGeoViewNavigating = isGeoViewNavigating
        }
        .onChange(of: queryCenter) { _ in
            viewModel.queryCenter = queryCenter
        }
        .onChange(of: queryArea) { _ in
            viewModel.queryArea = queryArea
        }
        .onAppear {
            viewModel.currentQuery = currentQuery
            viewModel.resultsOverlay = resultsOverlay
            viewModel.resultMode = resultMode
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
    
    /// Sets a closure to perform when the query changes.
    /// - Parameters:
    ///   - action: The closure to performed when the query has changed.
    ///   - query: The new query.
    public func onQueryChanged(perform action: @escaping (_ query: String) -> Void) -> Self {
        var copy = self
        copy.onQueryChangedAction = action
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
    
    /// Defines how many results to return.
    /// - Parameter newResultMode: The new value.
    /// - Returns: The `SearchView`.
    public func resultMode(_ newResultMode: SearchResultMode) -> Self {
        var copy = self
        copy.resultMode = newResultMode
        return copy
    }
    
    /// The search area to be used for the current query.
    /// - Parameter newQueryArea: The new value.
    /// - Returns: The `SearchView`.
    public func queryArea(_ newQueryArea: Binding<Geometry?>) -> Self {
        var copy = self
        copy._queryArea = newQueryArea
        return copy
    }
    
    /// Defines the center for the search.
    /// - Parameter newQueryCenter: The new value.
    /// - Returns: The `SearchView`.
    public func queryCenter(_ newQueryCenter: Binding<Point?>) -> Self {
        var copy = self
        copy._queryCenter = newQueryCenter
        return copy
    }
    
    /// The current map/scene view extent. Defaults to `nil`. Used to allow repeat searches after
    /// panning/zooming the map. Set to `nil` if repeat search behavior is not wanted.
    /// - Parameter newGeoViewExtent: The new value.
    /// - Returns: The `SearchView`.
    public func geoViewExtent(_ newGeoViewExtent: Binding<Envelope?>) -> Self {
        var copy = self
        copy._geoViewExtent = newGeoViewExtent
        return copy
    }
    
    /// Denotes whether the `GeoView` is navigating. Used for the repeat search behavior.
    /// - Parameter newIsGeoViewNavigating: The new value.
    /// - Returns: The `SearchView`.
    public func isGeoViewNavigating(_ newIsGeoViewNavigating: Binding<Bool>) -> Self {
        var copy = self
        copy._isGeoViewNavigating = newIsGeoViewNavigating
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
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
                            in: .toolkitModule,
                            with: nil
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
