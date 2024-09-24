***REMOVED***
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import Combine
import Foundation

***REMOVED***/ Uses a Locator to provide search and suggest results. Most configuration should be done on the
***REMOVED***/ `GeocodeParameters` directly.
public class LocatorSearchSource: ObservableObject, SearchSource, @unchecked Sendable {
***REMOVED******REMOVED***/ Creates a locator search source.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - name: The name to show when presenting this source in the UI.
***REMOVED******REMOVED***/   - locatorTask: The `LocatorTask` to use for searching.
***REMOVED******REMOVED***/   - maximumResults: The maximum results to return when performing a search. Most sources default to `6`.
***REMOVED******REMOVED***/   - maximumSuggestions: The maximum suggestions to return. Most sources default to `6`.
***REMOVED***public init(
***REMOVED******REMOVED***name: String = "Locator",
***REMOVED******REMOVED***locatorTask: LocatorTask = LocatorTask(
***REMOVED******REMOVED******REMOVED***url: URL(
***REMOVED******REMOVED******REMOVED******REMOVED***string: "https:***REMOVED***geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
***REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED***),
***REMOVED******REMOVED***maximumResults: Int = 6,
***REMOVED******REMOVED***maximumSuggestions: Int = 6
***REMOVED***) {
***REMOVED******REMOVED***self.name = name
***REMOVED******REMOVED***self.locatorTask = locatorTask
***REMOVED******REMOVED***self.maximumResults = maximumResults
***REMOVED******REMOVED***self.maximumSuggestions = maximumSuggestions
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.geocodeParameters.addResultAttributeName("*")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The name to show when presenting this source in the UI.
***REMOVED***public var name: String
***REMOVED***
***REMOVED******REMOVED***/ The maximum results to return when performing a search. Most sources default to `6`.
***REMOVED***public var maximumResults: Int {
***REMOVED******REMOVED***get { geocodeParameters.maxResults ***REMOVED***
***REMOVED******REMOVED***set { geocodeParameters.maxResults = newValue ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The maximum suggestions to return. Most sources default to `6`.
***REMOVED***public var maximumSuggestions: Int {
***REMOVED******REMOVED***get { suggestParameters.maxResults ***REMOVED***
***REMOVED******REMOVED***set { suggestParameters.maxResults = newValue ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The locator used by this search source.
***REMOVED***public let locatorTask: LocatorTask
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
***REMOVED******REMOVED***_ query: String,
***REMOVED******REMOVED***searchExtent: Envelope
***REMOVED***) async throws -> [SearchResult] {
***REMOVED******REMOVED***try await internalSearch(
***REMOVED******REMOVED******REMOVED***query,
***REMOVED******REMOVED******REMOVED***searchArea: searchExtent
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***public func search(
***REMOVED******REMOVED***_ query: String,
***REMOVED******REMOVED***searchArea: Geometry? = nil,
***REMOVED******REMOVED***preferredSearchLocation: Point? = nil
***REMOVED***) async throws -> [SearchResult] {
***REMOVED******REMOVED***try await internalSearch(
***REMOVED******REMOVED******REMOVED***query,
***REMOVED******REMOVED******REMOVED***searchArea: searchArea,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: preferredSearchLocation
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***public func search(
***REMOVED******REMOVED***_ searchSuggestion: SearchSuggestion,
***REMOVED******REMOVED***searchArea: Geometry? = nil,
***REMOVED******REMOVED***preferredSearchLocation: Point? = nil
***REMOVED***) async throws -> [SearchResult] {
***REMOVED******REMOVED***guard let suggestResult = searchSuggestion.suggestResult else { return [] ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***geocodeParameters.searchArea = searchArea
***REMOVED******REMOVED***geocodeParameters.preferredSearchLocation = preferredSearchLocation
***REMOVED******REMOVED***
***REMOVED******REMOVED***let geocodeResults = try await locatorTask.geocode(
***REMOVED******REMOVED******REMOVED***forSuggestResult: suggestResult,
***REMOVED******REMOVED******REMOVED***using: geocodeParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Convert to an array of `SearchResult` objects and return.
***REMOVED******REMOVED***return geocodeResults.map {
***REMOVED******REMOVED******REMOVED***SearchResult(geocodeResult: $0, searchSource: self)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public func suggest(
***REMOVED******REMOVED***_ query: String,
***REMOVED******REMOVED***searchArea: Geometry? = nil,
***REMOVED******REMOVED***preferredSearchLocation: Point? = nil
***REMOVED***) async throws -> [SearchSuggestion] {
***REMOVED******REMOVED***suggestParameters.searchArea = searchArea
***REMOVED******REMOVED***suggestParameters.preferredSearchLocation = preferredSearchLocation
***REMOVED******REMOVED***
***REMOVED******REMOVED***let geocodeResults = try await locatorTask.suggest(
***REMOVED******REMOVED******REMOVED***forSearchText: query,
***REMOVED******REMOVED******REMOVED***parameters: suggestParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** Convert to an array of `SearchSuggestion` objects and return.
***REMOVED******REMOVED***return geocodeResults.map {
***REMOVED******REMOVED******REMOVED***SearchSuggestion(suggestResult: $0, searchSource: self)
***REMOVED***
***REMOVED***
***REMOVED***

private extension LocatorSearchSource {
***REMOVED***func internalSearch(
***REMOVED******REMOVED***_ query: String,
***REMOVED******REMOVED***searchArea: Geometry?,
***REMOVED******REMOVED***preferredSearchLocation: Point? = nil
***REMOVED***) async throws -> [SearchResult] {
***REMOVED******REMOVED***geocodeParameters.searchArea = searchArea
***REMOVED******REMOVED***geocodeParameters.preferredSearchLocation = preferredSearchLocation
***REMOVED******REMOVED***
***REMOVED******REMOVED***let geocodeResults = try await locatorTask.geocode(
***REMOVED******REMOVED******REMOVED***forSearchText: query,
***REMOVED******REMOVED******REMOVED***using: geocodeParameters
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Convert to SearchResults and return.
***REMOVED******REMOVED***return geocodeResults.map {
***REMOVED******REMOVED******REMOVED***SearchResult(geocodeResult: $0, searchSource: self)
***REMOVED***
***REMOVED***
***REMOVED***
