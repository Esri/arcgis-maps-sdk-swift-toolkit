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

import Foundation
***REMOVED***

***REMOVED***/ Uses a Locator to provide search and suggest results. Most configuration should be done on the
***REMOVED***/ `GeocodeParameters` directly.
public class LocatorSearchSource: ObservableObject, SearchSourceProtocol {
***REMOVED***public init(displayName: String = "Search",
***REMOVED******REMOVED******REMOVED******REMOVED***maximumResults: Int = 6,
***REMOVED******REMOVED******REMOVED******REMOVED***maximumSuggestions: Int = 6,
***REMOVED******REMOVED******REMOVED******REMOVED***searchArea: Geometry? = nil,
***REMOVED******REMOVED******REMOVED******REMOVED***preferredSearchLocation: Point? = nil) {
***REMOVED******REMOVED***self.displayName = displayName
***REMOVED******REMOVED***self.maximumResults = maximumResults
***REMOVED******REMOVED***self.maximumSuggestions = maximumSuggestions
***REMOVED******REMOVED***self.searchArea = searchArea
***REMOVED******REMOVED***self.preferredSearchLocation = preferredSearchLocation
***REMOVED******REMOVED***
***REMOVED******REMOVED***geocodeParameters.maxResults = Int32(maximumResults)
***REMOVED******REMOVED***suggestParameters.maxResults = Int32(maximumSuggestions)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The locator used by this search source.
***REMOVED***private(set) var locator: LocatorTask = LocatorTask(url: URL(string: "https:***REMOVED***geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
***REMOVED***
***REMOVED******REMOVED***/ Parameters used for geocoding. Some properties on parameters will be updated automatically
***REMOVED******REMOVED***/ based on searches.
***REMOVED***private(set) var geocodeParameters: GeocodeParameters = GeocodeParameters()
***REMOVED***
***REMOVED******REMOVED***/ Parameters used for getting suggestions. Some properties will be updated automatically
***REMOVED******REMOVED***/ based on searches.
***REMOVED***private(set) var suggestParameters: SuggestParameters = SuggestParameters()
***REMOVED***
***REMOVED***public var displayName: String = "Search"
***REMOVED***
***REMOVED***public var maximumResults: Int {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***geocodeParameters.maxResults = Int32(maximumResults)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var maximumSuggestions: Int {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***suggestParameters.maxResults = Int32(maximumResults)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var searchArea: Geometry?
***REMOVED***
***REMOVED***public var preferredSearchLocation: Point?
***REMOVED***
***REMOVED***public func search(_ queryString: String, area: Geometry? = nil) async throws -> [SearchResult] {
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** This differs from the .NET approach; .NET only uses the
***REMOVED******REMOVED******REMOVED*** center of `searchArea` for the `geocodeParameters.preferredSearchLocation`
***REMOVED******REMOVED******REMOVED*** and only sets `geocodeParameters.searchArea` from the `area` argument.
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***geocodeParameters.searchArea = (area != nil) ? area : searchArea
***REMOVED******REMOVED***geocodeParameters.preferredSearchLocation = preferredSearchLocation
***REMOVED******REMOVED***
***REMOVED******REMOVED***let geocodeResults = try await locator.geocode(searchText: queryString,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   parameters: geocodeParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Convert to SearchResults and return.
***REMOVED******REMOVED***return geocodeResults.map{ $0.toSearchResult(searchSource: self) ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func search(_ searchSuggestion: SearchSuggestion) async throws -> [SearchResult] {
***REMOVED******REMOVED***guard let suggestResult = searchSuggestion.suggestResult else { return [] ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***geocodeParameters.searchArea = nil
***REMOVED******REMOVED***geocodeParameters.preferredSearchLocation = nil
***REMOVED******REMOVED***if preferredSearchLocation == nil,
***REMOVED******REMOVED***   let area = searchArea {
***REMOVED******REMOVED******REMOVED***if let point = searchArea as? Point {
***REMOVED******REMOVED******REMOVED******REMOVED***geocodeParameters.preferredSearchLocation = point
***REMOVED******REMOVED******REMOVED******REMOVED***geocodeParameters.searchArea = nil
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***else if !area.extent.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***geocodeParameters.preferredSearchLocation = area.extent.center
***REMOVED******REMOVED******REMOVED******REMOVED***geocodeParameters.searchArea = nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***else if preferredSearchLocation != nil {
***REMOVED******REMOVED******REMOVED***geocodeParameters.preferredSearchLocation = preferredSearchLocation
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let geocodeResults = try await locator.geocode(suggestResult: suggestResult,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   parameters: geocodeParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Convert to SearchResults and return.
***REMOVED******REMOVED***return geocodeResults.map{ $0.toSearchResult(searchSource: self) ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func suggest(_ queryString: String) async throws -> [SearchSuggestion] {
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** This differs from the .NET approach; .NET only uses the
***REMOVED******REMOVED******REMOVED*** center of `searchArea` for the `geocodeParameters.preferredSearchLocation`.
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***suggestParameters.searchArea = searchArea
***REMOVED******REMOVED***suggestParameters.preferredSearchLocation = preferredSearchLocation
***REMOVED******REMOVED***
***REMOVED******REMOVED***let geocodeResults = try await locator.suggest(
***REMOVED******REMOVED******REMOVED***searchText: queryString,
***REMOVED******REMOVED******REMOVED***parameters: suggestParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** Convert to SearchSuggestions and return.
***REMOVED******REMOVED***return geocodeResults.map{ $0.toSearchSuggestion(searchSource: self) ***REMOVED***
***REMOVED***
***REMOVED***
