# Search

`SearchView` enables searching using one or more locators, with support for suggestions, automatic zooming, and custom search sources.

|iPhone|iPad|
|:--:|:--:|
|![image](https:***REMOVED***user-images.githubusercontent.com/3998072/203608897-5f3bf34a-0931-4d11-b3fc-18a5dd07131a.png)|![image](https:***REMOVED***user-images.githubusercontent.com/3998072/203608708-45a0096c-a8d6-457c-9ee1-8cdb9e5bb15a.png)|

## Features

- Updates search suggestions as you type.
- Supports using the Esri world geocoder or any other ArcGIS locators.
- Supports searching using custom search sources.
- Allows for customization of the display of search results.
- Allows you to repeat a search within a defined area, and displays a button to enable that search when the view's viewpoint changes.

## Key properties

`SearchView` has the following initializer:

```swift
***REMOVED******REMOVED***/ Creates a `SearchView`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - sources: A collection of search sources to be used.
***REMOVED******REMOVED***/   - viewpoint: The `Viewpoint` used to pan/zoom to results. If `nil`, there will be
***REMOVED******REMOVED***/   no zooming to results.
***REMOVED***public init(
***REMOVED******REMOVED***sources: [SearchSource] = [],
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>? = nil
***REMOVED***)
```

`SearchView` uses search sources which implement the `SearchSource` protocol:

```swift
***REMOVED***/ Defines the contract for a search result provider.
public protocol SearchSource {

***REMOVED******REMOVED***/ Name to show when presenting this source in the UI.
***REMOVED***var name: String { get set ***REMOVED***

***REMOVED******REMOVED***/ The maximum results to return when performing a search. Most sources default to `6`.
***REMOVED***var maximumResults: Int32 { get set ***REMOVED***

***REMOVED******REMOVED***/ The maximum suggestions to return. Most sources default to `6`.
***REMOVED***var maximumSuggestions: Int32 { get set ***REMOVED***

***REMOVED******REMOVED***/ Returns the search suggestions for the specified query.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - query: The query for which to provide search suggestions.
***REMOVED******REMOVED***/   - searchArea: The area used to limit results.
***REMOVED******REMOVED***/   - preferredSearchLocation: The location used as a starting point for searches.
***REMOVED******REMOVED***/ - Returns: An array of search suggestions.
***REMOVED***func suggest(_ query: String, searchArea: Geometry?, preferredSearchLocation: Point?) async throws -> [SearchSuggestion]

***REMOVED******REMOVED***/ Gets search results.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - query: Text to be used for query.
***REMOVED******REMOVED***/   - searchArea: The area used to limit results.
***REMOVED******REMOVED***/   - preferredSearchLocation: The location used as a starting point for searches.
***REMOVED******REMOVED***/ - Returns: An array of search results.
***REMOVED***func search(_ query: String, searchArea: Geometry?, preferredSearchLocation: Point?) async throws -> [SearchResult]

***REMOVED******REMOVED***/ Returns the search results for the specified search suggestion.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - searchSuggestion: The search suggestion for which to provide search results.
***REMOVED******REMOVED***/   - searchArea: The area used to limit results.
***REMOVED******REMOVED***/   - preferredSearchLocation: The location used as a starting point for searches.
***REMOVED******REMOVED***/ - Returns: An array of search results.
***REMOVED***func search(_ searchSuggestion: SearchSuggestion, searchArea: Geometry?, preferredSearchLocation: Point?) async throws -> [SearchResult]

***REMOVED******REMOVED***/ Repeats the last search.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - query: Text to be used for query.
***REMOVED******REMOVED***/   - searchExtent: Extent used to limit the results.
***REMOVED******REMOVED***/ - Returns: An array of search results.
***REMOVED***func repeatSearch(_ query: String, searchExtent: Envelope) async throws -> [SearchResult]
***REMOVED***
```

`SearchView` provides the following search sources:

```swift
***REMOVED***/ Uses a Locator to provide search and suggest results. Most configuration should be done on the
***REMOVED***/ `GeocodeParameters` directly.
public class LocatorSearchSource : ObservableObject, SearchSource
```

```swift
***REMOVED***/ Extends `LocatorSearchSource` with intelligent search behaviors; adds support for features like
***REMOVED***/ type-specific placemarks, repeated search, and more on the world geocode service.
public class SmartLocatorSearchSource: LocatorSearchSource
```

`SearchView` provides several instance methods, allowing customization and additional search behaviors (such as displaying a "Repeat search here" button):

```swift
***REMOVED***/ Specifies whether a built-in result view will be shown. If `false`, the result display/selection
***REMOVED***/ list is not shown. Set to `false` if you want to define a custom result list. You might use a
***REMOVED***/ custom result list to show results in a separate list, disconnected from the rest of the search view.
***REMOVED***/ Defaults to `true`.
***REMOVED***/ - Parameter newEnableResultListView: The new value.
***REMOVED***/ - Returns: A new `SearchView`.
public func enableResultListView(_ newEnableResultListView: Bool) -> Self

***REMOVED***/ The string shown in the search view when no user query is entered.
***REMOVED***/ Defaults to "Find a place or address".
***REMOVED***/ - Parameter newPrompt: The new value.
***REMOVED***/ - Returns: A new `SearchView`.
public func prompt(_ newPrompt: String) -> Self

***REMOVED***/ Sets the message to show when there are no results or suggestions.
***REMOVED***/
***REMOVED***/ The default message is "No results found".
***REMOVED***/ - Parameter newNoResultsMessage: The new value.
***REMOVED***/ - Returns: A new `SearchView`.
public func noResultsMessage(_ newNoResultsMessage: String) -> Self

***REMOVED***/ Sets the current query.
***REMOVED***/ - Parameter newQueryString: The new value.
***REMOVED***/ - Returns: The `SearchView`.
public func currentQuery(_ newQuery: String) -> Self

***REMOVED***/ Sets a closure to perform when the query changes.
***REMOVED***/ - Parameters:
***REMOVED***/   - action: The closure to performed when the query has changed.
***REMOVED***/   - query: The new query.
public func onQueryChanged(perform action: @escaping (_ query: String) -> Void) -> Self

***REMOVED***/ The `GraphicsOverlay` used to display results. If `nil`, no results will be displayed.
***REMOVED***/ - Parameter newResultsOverlay: The new value.
***REMOVED***/ - Returns: The `SearchView`.
public func resultsOverlay(_ newResultsOverlay: GraphicsOverlay?) -> Self

***REMOVED***/ Defines how many results to return.
***REMOVED***/ - Parameter newResultMode: The new value.
***REMOVED***/ - Returns: The `SearchView`.
public func resultMode(_ newResultMode: SearchResultMode) -> Self

***REMOVED***/ The search area to be used for the current query.
***REMOVED***/ - Parameter newQueryArea: The new value.
***REMOVED***/ - Returns: The `SearchView`.
public func queryArea(_ newQueryArea: Binding<Geometry?>) -> Self

***REMOVED***/ Defines the center for the search.
***REMOVED***/ - Parameter newQueryCenter: The new value.
***REMOVED***/ - Returns: The `SearchView`.
public func queryCenter(_ newQueryCenter: Binding<Point?>) -> Self

***REMOVED***/ The current map/scene view extent. Defaults to `nil`. Used to allow repeat searches after
***REMOVED***/ panning/zooming the map. Set to `nil` if repeat search behavior is not wanted.
***REMOVED***/ - Parameter newGeoViewExtent: The new value.
***REMOVED***/ - Returns: The `SearchView`.
public func geoViewExtent(_ newGeoViewExtent: Binding<Envelope?>) -> Self

***REMOVED***/ Denotes whether the `GeoView` is navigating. Used for the repeat search behavior.
***REMOVED***/ - Parameter newIsGeoViewNavigating: The new value.
***REMOVED***/ - Returns: The `SearchView`.
public func isGeoViewNavigating(_ newIsGeoViewNavigating: Binding<Bool>) -> Self
```

## Behavior:

The `SearchView` will display the results list view at half height, exposing a portion of the underlying map below the list, on an iPhone in portrait orientation (and certain iPad multitasking configurations).  The user can hide or show the result list after searching by clicking on the up/down chevron symbol on the right of the search bar.

## Usage

### Basic usage for displaying a `SearchView`.

```swift
SearchView(
***REMOVED***sources: [locatorDataSource],
***REMOVED***viewpoint: $searchResultViewpoint
)
.resultsOverlay(searchResultsOverlay)
.queryCenter($queryCenter)
.geoViewExtent($geoViewExtent)
.isGeoViewNavigating($isGeoViewNavigating)
.padding()
```

To see the `SearchView` in action, and for examples of `Search` customization, check out the [Examples](../../Examples) and refer to [SearchExampleView.swift](../../Examples/Examples/SearchExampleView.swift) in the project.
