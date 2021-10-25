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
public class LocatorSearchSource: ObservableObject, SearchSource {
***REMOVED******REMOVED***/ Creates a locator search source.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - name: Name to show when presenting this source in the UI.
***REMOVED******REMOVED***/   - locatorTask: The `LocatorTask` to use for searching.
***REMOVED******REMOVED***/   - maximumResults: The maximum results to return when performing a search. Most sources default to 6.
***REMOVED******REMOVED***/   - maximumSuggestions: The maximum suggestions to return. Most sources default to 6.
***REMOVED******REMOVED***/   - searchArea: Area to be used as a constraint for searches and suggestions.
***REMOVED******REMOVED***/   - preferredSearchLocation: Point to be used as an input to searches and suggestions.
***REMOVED***public init(
***REMOVED******REMOVED***name: String = "Locator",
***REMOVED******REMOVED***locatorTask: LocatorTask = LocatorTask(
***REMOVED******REMOVED******REMOVED***url: URL(
***REMOVED******REMOVED******REMOVED******REMOVED***string: "https:***REMOVED***geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
***REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED***),
***REMOVED******REMOVED***maximumResults: Int32 = 6,
***REMOVED******REMOVED***maximumSuggestions: Int32 = 6,
***REMOVED******REMOVED***searchArea: Geometry? = nil,
***REMOVED******REMOVED***preferredSearchLocation: Point? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.name = name
***REMOVED******REMOVED***self.locatorTask = locatorTask
***REMOVED******REMOVED***self.maximumResults = maximumResults
***REMOVED******REMOVED***self.maximumSuggestions = maximumSuggestions
***REMOVED******REMOVED***self.searchArea = searchArea
***REMOVED******REMOVED***self.preferredSearchLocation = preferredSearchLocation
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.geocodeParameters.addResultAttributeName("*")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Name to show when presenting this source in the UI.
***REMOVED***public var name: String
***REMOVED***
***REMOVED******REMOVED***/ The maximum results to return when performing a search. Most sources default to 6
***REMOVED***public var maximumResults: Int32 {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***geocodeParameters.maxResults
***REMOVED***
***REMOVED******REMOVED***set {
***REMOVED******REMOVED******REMOVED***geocodeParameters.maxResults = newValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The maximum suggestions to return. Most sources default to 6.
***REMOVED***public var maximumSuggestions: Int32 {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***suggestParameters.maxResults
***REMOVED***
***REMOVED******REMOVED***set {
***REMOVED******REMOVED******REMOVED***suggestParameters.maxResults = newValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Area to be used as a constraint for searches and suggestions.
***REMOVED***public var searchArea: Geometry?
***REMOVED***
***REMOVED******REMOVED***/ Point to be used as an input to searches and suggestions.
***REMOVED***public var preferredSearchLocation: Point?
***REMOVED***
***REMOVED******REMOVED***/ The locator used by this search source.
***REMOVED***public private(set) var locatorTask: LocatorTask
***REMOVED***
***REMOVED******REMOVED***/ Parameters used for geocoding. Some properties on parameters will be updated automatically
***REMOVED******REMOVED***/ based on searches.
***REMOVED***public let geocodeParameters: GeocodeParameters = GeocodeParameters()
***REMOVED***
***REMOVED******REMOVED***/ Parameters used for getting suggestions. Some properties will be updated automatically
***REMOVED******REMOVED***/ based on searches.
***REMOVED***public let suggestParameters: SuggestParameters = SuggestParameters()
***REMOVED***
***REMOVED***public func repeatSearch(
***REMOVED******REMOVED***_ queryString: String,
***REMOVED******REMOVED***queryExtent: Envelope
***REMOVED***) async throws -> [SearchResult] {
***REMOVED******REMOVED***return try await internalSearch(queryString, queryArea: queryExtent)
***REMOVED***
***REMOVED***
***REMOVED***public func search(_ queryString: String) async throws -> [SearchResult] {
***REMOVED******REMOVED***return try await internalSearch(queryString, queryArea: searchArea)
***REMOVED***
***REMOVED***
***REMOVED***public func search(
***REMOVED******REMOVED***_ searchSuggestion: SearchSuggestion
***REMOVED***) async throws -> [SearchResult] {
***REMOVED******REMOVED***guard let suggestResult = searchSuggestion.suggestResult else { return [] ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***geocodeParameters.searchArea = searchArea
***REMOVED******REMOVED***geocodeParameters.preferredSearchLocation = preferredSearchLocation
***REMOVED******REMOVED***
***REMOVED******REMOVED***let geocodeResults = try await locatorTask.geocode(
***REMOVED******REMOVED******REMOVED***suggestResult: suggestResult,
***REMOVED******REMOVED******REMOVED***parameters: geocodeParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Convert to SearchResults and return.
***REMOVED******REMOVED***return geocodeResults.map { $0.toSearchResult(searchSource: self) ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func suggest(
***REMOVED******REMOVED***_ queryString: String
***REMOVED***) async throws -> [SearchSuggestion] {
***REMOVED******REMOVED***suggestParameters.searchArea = searchArea
***REMOVED******REMOVED***suggestParameters.preferredSearchLocation = preferredSearchLocation
***REMOVED******REMOVED***
***REMOVED******REMOVED***let geocodeResults = try await locatorTask.suggest(
***REMOVED******REMOVED******REMOVED***searchText: queryString,
***REMOVED******REMOVED******REMOVED***parameters: suggestParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** Convert to SearchSuggestions and return.
***REMOVED******REMOVED***return geocodeResults.map{ $0.toSearchSuggestion(searchSource: self) ***REMOVED***
***REMOVED***
***REMOVED***

extension LocatorSearchSource {
***REMOVED***private func internalSearch(
***REMOVED******REMOVED***_ queryString: String,
***REMOVED******REMOVED***queryArea: Geometry?
***REMOVED***) async throws -> [SearchResult] {
***REMOVED******REMOVED***geocodeParameters.searchArea = queryArea
***REMOVED******REMOVED***geocodeParameters.preferredSearchLocation = preferredSearchLocation
***REMOVED******REMOVED***
***REMOVED******REMOVED***let geocodeResults = try await locatorTask.geocode(
***REMOVED******REMOVED******REMOVED***searchText: queryString,
***REMOVED******REMOVED******REMOVED***parameters: geocodeParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Convert to SearchResults and return.
***REMOVED******REMOVED***return geocodeResults.map { $0.toSearchResult(searchSource: self) ***REMOVED***
***REMOVED***
***REMOVED***
