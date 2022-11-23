# Search

`SearchView` enables searching using one or more locators, with support for suggestions, automatic zooming, and custom search sources.

## Features

- Updates search suggestions as you type.
- Supports using the Esri world geocoder or any other ArcGIS locators.
- Supports searching using custom search sources.
- Allows for customization of the display of search results.
- Allows you to repeat a search within a defined area, and displays a button to enable that search when the view's viewpoint changes.

|iPhone|iPad|
|:--:|:--:|
|![image](https://user-images.githubusercontent.com/3998072/203608897-5f3bf34a-0931-4d11-b3fc-18a5dd07131a.png)|![image](https://user-images.githubusercontent.com/3998072/203608708-45a0096c-a8d6-457c-9ee1-8cdb9e5bb15a.png)|

## Key properties

`SearchView` has the following initializer:

```swift
    /// Creates a `SearchView`.
    /// - Parameters:
    ///   - sources: A collection of search sources to be used.
    ///   - viewpoint: The `Viewpoint` used to pan/zoom to results. If `nil`, there will be
    ///   no zooming to results.
    public init(
        sources: [SearchSource] = [],
        viewpoint: Binding<Viewpoint?>? = nil
    )
```

`SearchView` uses search sources which implement the `SearchSource` protocol:

```swift
/// Defines the contract for a search result provider.
public protocol SearchSource {

    /// Name to show when presenting this source in the UI.
    var name: String { get set }

    /// The maximum results to return when performing a search. Most sources default to `6`.
    var maximumResults: Int32 { get set }

    /// The maximum suggestions to return. Most sources default to `6`.
    var maximumSuggestions: Int32 { get set }

    /// Returns the search suggestions for the specified query.
    /// - Parameters:
    ///   - query: The query for which to provide search suggestions.
    ///   - searchArea: The area used to limit results.
    ///   - preferredSearchLocation: The location used as a starting point for searches.
    /// - Returns: An array of search suggestions.
    func suggest(_ query: String, searchArea: Geometry?, preferredSearchLocation: Point?) async throws -> [SearchSuggestion]

    /// Gets search results.
    /// - Parameters:
    ///   - query: Text to be used for query.
    ///   - searchArea: The area used to limit results.
    ///   - preferredSearchLocation: The location used as a starting point for searches.
    /// - Returns: An array of search results.
    func search(_ query: String, searchArea: Geometry?, preferredSearchLocation: Point?) async throws -> [SearchResult]

    /// Returns the search results for the specified search suggestion.
    /// - Parameters:
    ///   - searchSuggestion: The search suggestion for which to provide search results.
    ///   - searchArea: The area used to limit results.
    ///   - preferredSearchLocation: The location used as a starting point for searches.
    /// - Returns: An array of search results.
    func search(_ searchSuggestion: SearchSuggestion, searchArea: Geometry?, preferredSearchLocation: Point?) async throws -> [SearchResult]

    /// Repeats the last search.
    /// - Parameters:
    ///   - query: Text to be used for query.
    ///   - searchExtent: Extent used to limit the results.
    /// - Returns: An array of search results.
    func repeatSearch(_ query: String, searchExtent: Envelope) async throws -> [SearchResult]
}
```

`SearchView` provides the following search sources:

```swift
/// Uses a Locator to provide search and suggest results. Most configuration should be done on the
/// `GeocodeParameters` directly.
public class LocatorSearchSource : ObservableObject, SearchSource
```

```swift
/// Extends `LocatorSearchSource` with intelligent search behaviors; adds support for features like
/// type-specific placemarks, repeated search, and more on the world geocode service.
public class SmartLocatorSearchSource: LocatorSearchSource {
```

`SearchView` provides several instance methods, allowing customization and additional search behaviors (such as displaying a "Repeat search here" button):

```swift
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
```

## Behavior:

The `SearchView` will display the results list view at half height, exposing a portion of the underlying map below the list, on an iPhone in portrait orientation (and certain iPad multitasking configurations).  The user can hide or show the result list after searching by clicking on the up/down chevron symbol on the right of the search bar.

## Usage

### Basic usage for displaying a `SearchView`.

```swift
/// Provides search behavior customization.
let locatorDataSource = SmartLocatorSearchSource(
    name: "My locator",
    maximumResults: 16,
    maximumSuggestions: 16
)

@StateObject private var map = Map(basemapStyle: .arcGISImagery)

/// The `GraphicsOverlay` used by the `SearchView` to display search results on the map.
private let searchResultsOverlay = GraphicsOverlay()

/// The map viewpoint used by the `SearchView` to pan/zoom the map
/// to the extent of the search results.
@State private var searchResultViewpoint: Viewpoint? = Viewpoint(
    center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
    scale: 1000000
)

/// Denotes whether the geoview is navigating. Used for the repeat search behavior.
@State private var isGeoViewNavigating = false

/// The current map/scene view extent. Used to allow repeat searches after panning/zooming the map.
@State private var geoViewExtent: Envelope?

/// The search area to be used for the current query.
@State private var queryArea: Geometry?

/// Defines the center for the search.
@State private var queryCenter: Point?

var body: some View {
    MapView(
        map: map,
        viewpoint: searchResultViewpoint,
        graphicsOverlays: [searchResultsOverlay]
    )
    .onNavigatingChanged { isGeoViewNavigating = $0 }
    .onViewpointChanged(kind: .centerAndScale) {
        queryCenter = $0.targetGeometry as? Point
    }
    .onVisibleAreaChanged { newValue in
        // For "Repeat Search Here" behavior, use the `geoViewExtent` and
        // `isGeoViewNavigating` modifiers on the `SearchView`.
        geoViewExtent = newValue.extent
    }
    .overlay {
        SearchView(
            sources: [locatorDataSource],
            viewpoint: $searchResultViewpoint
        )
        .resultsOverlay(searchResultsOverlay)
        .queryCenter($queryCenter)
        .geoViewExtent($geoViewExtent)
        .isGeoViewNavigating($isGeoViewNavigating)
        .padding()
    }
}
```

To see the `SearchView` in action, and for examples of `Search` customization, check out the [Examples](../../Examples) and refer to [SearchExampleView.swift](../../Examples/Examples/SearchExampleView.swift) in the project.
