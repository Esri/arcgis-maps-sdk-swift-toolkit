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

import XCTest
***REMOVED***
@testable ***REMOVED***Toolkit

class SearchViewModelTests: XCTestCase {
***REMOVED***@MainActor
***REMOVED***func testAcceptSuggestion() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.updateSuggestions()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Get suggestion
***REMOVED******REMOVED***let suggestions = try await searchSuggestions(model)
***REMOVED******REMOVED***let suggestion = try XCTUnwrap(suggestions?.first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.acceptSuggestion(suggestion)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let results = try await searchResults(model, dropFirst: true)
***REMOVED******REMOVED***let result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** With only one result, model should set `selectedResult` property.
***REMOVED******REMOVED***XCTAssertEqual(result.first, model.selectedResult)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testCommitSearch() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** No search - searchOutcome is nil.
***REMOVED******REMOVED***XCTAssertNil(model.searchOutcome)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with no results - result count is 0.
***REMOVED******REMOVED***model.currentQuery = "No results found blah blah blah blah"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await searchResults(model)
***REMOVED******REMOVED***var result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertEqual(result, [])
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with one result.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await searchResults(model)
***REMOVED******REMOVED***result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** One results automatically populates `selectedResult`.
***REMOVED******REMOVED***XCTAssertEqual(result.first, model.selectedResult)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with multiple results.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await searchResults(model)
***REMOVED******REMOVED***result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.selectedResult = result.first!
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await searchResults(model, dropFirst: true)
***REMOVED******REMOVED***result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testCurrentQuery() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Empty `currentQuery` should produce nil searchOutcome.
***REMOVED******REMOVED***model.currentQuery = ""
***REMOVED******REMOVED***XCTAssertNil(model.searchOutcome)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Valid `currentQuery` should produce non-nil results.
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let results = try await searchResults(model)
***REMOVED******REMOVED***XCTAssertNotNil(results)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Changing the `currentQuery` should set searchOutcome to nil.
***REMOVED******REMOVED***model.currentQuery = "Coffee in Portland"
***REMOVED******REMOVED***XCTAssertNil(model.searchOutcome)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.updateSuggestions()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let suggestions = try await searchSuggestions(model)
***REMOVED******REMOVED***XCTAssertNotNil(suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Changing current query after search with 1 result
***REMOVED******REMOVED******REMOVED*** should set `selectedResult` to nil
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Bookseller"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***_ = try await searchResults(model, dropFirst: true)
***REMOVED******REMOVED***XCTAssertNotNil(model.selectedResult)
***REMOVED******REMOVED***model.currentQuery = "Hotel"
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testIsEligibleForRequery() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryArea to Chippewa Falls
***REMOVED******REMOVED***model.queryArea = Polygon.chippewaFalls
***REMOVED******REMOVED***model.geoViewExtent = Polygon.chippewaFalls.extent
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** This is necessary for the model to compute `isEligibleForRequery`.
***REMOVED******REMOVED***model.isGeoViewNavigating = true
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***_ = try await searchResults(model)
***REMOVED******REMOVED***XCTAssertFalse(model.isEligibleForRequery)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Offset extent by 10% - isEligibleForRequery should still be `false`.
***REMOVED******REMOVED***var builder = EnvelopeBuilder(envelope: model.geoViewExtent!)
***REMOVED******REMOVED***let tenPercentWidth = model.geoViewExtent!.width * 0.1
***REMOVED******REMOVED***builder.offsetBy(x: tenPercentWidth, y: 0.0)
***REMOVED******REMOVED***var newExtent = builder.toGeometry()
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.geoViewExtent = newExtent
***REMOVED******REMOVED***XCTAssertFalse(model.isEligibleForRequery)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Offset extent by 50% - isEligibleForRequery should now be `true`.
***REMOVED******REMOVED***builder = EnvelopeBuilder(envelope: model.geoViewExtent!)
***REMOVED******REMOVED***let fiftyPercentWidth = model.geoViewExtent!.width * 0.5
***REMOVED******REMOVED***builder.offsetBy(x: fiftyPercentWidth, y: 0.0)
***REMOVED******REMOVED***newExtent = builder.toGeometry()
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.geoViewExtent = newExtent
***REMOVED******REMOVED***XCTAssertTrue(model.isEligibleForRequery)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryArea to Chippewa Falls
***REMOVED******REMOVED***model.queryArea = Polygon.chippewaFalls
***REMOVED******REMOVED***model.geoViewExtent = Polygon.chippewaFalls.extent
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***_ = try await searchResults(model, dropFirst: true)
***REMOVED******REMOVED***XCTAssertFalse(model.isEligibleForRequery)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Expand extent by 1.1x - isEligibleForRequery should still be `false`.
***REMOVED******REMOVED***builder = EnvelopeBuilder(envelope: model.geoViewExtent!)
***REMOVED******REMOVED***builder.expand(by: 1.1)
***REMOVED******REMOVED***newExtent = builder.toGeometry()
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.geoViewExtent = newExtent
***REMOVED******REMOVED***XCTAssertFalse(model.isEligibleForRequery)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Expand extent by 1.5x - isEligibleForRequery should now be `true`.
***REMOVED******REMOVED***builder = EnvelopeBuilder(envelope: model.geoViewExtent!)
***REMOVED******REMOVED***builder.expand(by: 1.5)
***REMOVED******REMOVED***newExtent = builder.toGeometry()
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.geoViewExtent = newExtent
***REMOVED******REMOVED***XCTAssertTrue(model.isEligibleForRequery)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testQueryArea() async throws {
***REMOVED******REMOVED***let source = LocatorSearchSource()
***REMOVED******REMOVED***source.maximumResults = .max
***REMOVED******REMOVED***let model = SearchViewModel(sources: [source])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryArea to Chippewa Falls
***REMOVED******REMOVED***model.queryArea = Polygon.chippewaFalls
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await searchResults(model)
***REMOVED******REMOVED***var result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let resultGeometryUnion: Geometry = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***GeometryEngine.union(
***REMOVED******REMOVED******REMOVED******REMOVED***of: result.compactMap { $0.geoElement?.geometry ***REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***GeometryEngine.doesGeometry(
***REMOVED******REMOVED******REMOVED******REMOVED***model.queryArea!,
***REMOVED******REMOVED******REMOVED******REMOVED***contain: resultGeometryUnion
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await searchResults(model)
***REMOVED******REMOVED***result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertEqual(result, [])
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.queryArea = Polygon.minneapolis
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** A note about the use of `.dropFirst()`:
***REMOVED******REMOVED******REMOVED*** Because `model.searchOutcome` is not changed between the previous call
***REMOVED******REMOVED******REMOVED*** to `model.commitSearch()` and the one right above, the
***REMOVED******REMOVED******REMOVED*** `try await model.searchOutCome...` call will return the last result
***REMOVED******REMOVED******REMOVED*** received (from the first `model.commitSearch()` call), which is
***REMOVED******REMOVED******REMOVED*** incorrect.  Calling `.dropFirst()` will remove that one
***REMOVED******REMOVED******REMOVED*** and will give us the next one, which is the correct one (the result
***REMOVED******REMOVED******REMOVED*** from the second `model.commitSearch()` call).
***REMOVED******REMOVED***results = try await searchResults(model, dropFirst: true)
***REMOVED******REMOVED***result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testQueryCenter() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryCenter to Portland
***REMOVED******REMOVED***model.queryCenter = .portland
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await searchResults(model)
***REMOVED******REMOVED***var result = try XCTUnwrap(results)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var resultPoint = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***result.first?.geoElement?.geometry as? Point
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var geodeticDistance = try XCTUnwrap (
***REMOVED******REMOVED******REMOVED***GeometryEngine.geodeticDistance(
***REMOVED******REMOVED******REMOVED******REMOVED***from: .portland,
***REMOVED******REMOVED******REMOVED******REMOVED***to: resultPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***distanceUnit: .meters,
***REMOVED******REMOVED******REMOVED******REMOVED***azimuthUnit: nil,
***REMOVED******REMOVED******REMOVED******REMOVED***curveType: .geodesic
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** First result within 1500m of Portland.
***REMOVED******REMOVED***XCTAssertLessThan(geodeticDistance.distance.value,  1500)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryCenter to Edinburgh
***REMOVED******REMOVED***model.queryCenter = .edinburgh
***REMOVED******REMOVED***model.currentQuery = "Restaurants"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await searchResults(model)
***REMOVED******REMOVED***result = try XCTUnwrap(results)
***REMOVED******REMOVED***
***REMOVED******REMOVED***resultPoint = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***result.first?.geoElement?.geometry as? Point
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Web Mercator distance between .edinburgh and first result.
***REMOVED******REMOVED***geodeticDistance = try XCTUnwrap (
***REMOVED******REMOVED******REMOVED***GeometryEngine.geodeticDistance(
***REMOVED******REMOVED******REMOVED******REMOVED***from: .edinburgh,
***REMOVED******REMOVED******REMOVED******REMOVED***to: resultPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***distanceUnit: .meters,
***REMOVED******REMOVED******REMOVED******REMOVED***azimuthUnit: nil,
***REMOVED******REMOVED******REMOVED******REMOVED***curveType: .geodesic
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** First result within 100m of Edinburgh.
***REMOVED******REMOVED***XCTAssertLessThan(geodeticDistance.distance.value,  100)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testRepeatSearch() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryArea to Chippewa Falls
***REMOVED******REMOVED***model.geoViewExtent = Polygon.chippewaFalls.extent
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.repeatSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await searchResults(model)
***REMOVED******REMOVED***var result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let resultGeometryUnion: Geometry = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***GeometryEngine.union(
***REMOVED******REMOVED******REMOVED******REMOVED***of: result.compactMap { $0.geoElement?.geometry ***REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***GeometryEngine.doesGeometry(
***REMOVED******REMOVED******REMOVED******REMOVED***model.geoViewExtent!,
***REMOVED******REMOVED******REMOVED******REMOVED***contain: resultGeometryUnion
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.repeatSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await searchResults(model)
***REMOVED******REMOVED***result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertEqual(result.count, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.geoViewExtent = Polygon.minneapolis.extent
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.repeatSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await searchResults(model, dropFirst: true)
***REMOVED******REMOVED***result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testSearchResultMode() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***XCTAssertEqual(model.resultMode, .automatic)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.resultMode = .single
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await searchResults(model)
***REMOVED******REMOVED***var result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.resultMode = .multiple
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await searchResults(model, dropFirst: true)
***REMOVED******REMOVED***result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.updateSuggestions()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let suggestionResults = try await searchSuggestions(model)
***REMOVED******REMOVED***let suggestions = try XCTUnwrap(suggestionResults)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let collectionSuggestion = try XCTUnwrap(suggestions.filter(\.isCollection).first)
***REMOVED******REMOVED***let singleSuggestion = try XCTUnwrap(suggestions.filter { !$0.isCollection ***REMOVED***.first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.resultMode = .automatic
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.acceptSuggestion(collectionSuggestion)
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await searchResults(model, dropFirst: true)
***REMOVED******REMOVED***result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.acceptSuggestion(singleSuggestion)
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await searchResults(model)
***REMOVED******REMOVED***result = try XCTUnwrap(results)
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testUpdateSuggestions() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** No currentQuery - suggestions are nil.
***REMOVED******REMOVED***XCTAssertNil(model.searchOutcome)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** UpdateSuggestions with no results - result count is 0.
***REMOVED******REMOVED***model.currentQuery = "No results found blah blah blah blah"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.updateSuggestions()
***REMOVED******REMOVED***
***REMOVED******REMOVED***var suggestionResults = try await searchSuggestions(model)
***REMOVED******REMOVED***var suggestions = try XCTUnwrap(suggestionResults)
***REMOVED******REMOVED***XCTAssertEqual(suggestions, [])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** UpdateSuggestions with results.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.updateSuggestions()
***REMOVED******REMOVED***
***REMOVED******REMOVED***suggestionResults = try await searchSuggestions(model, dropFirst: true)
***REMOVED******REMOVED***suggestions = try XCTUnwrap(suggestionResults)
***REMOVED******REMOVED***XCTAssertGreaterThanOrEqual(suggestions.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED***
***REMOVED***

extension SearchViewModelTests {
***REMOVED***@MainActor
***REMOVED***func searchResults(
***REMOVED******REMOVED***_ model: SearchViewModel,
***REMOVED******REMOVED***dropFirst: Bool = false
***REMOVED***) async throws -> [SearchResult]? {
***REMOVED******REMOVED***let searchOutcome = try await model.$searchOutcome
***REMOVED******REMOVED******REMOVED***.compactMap { $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.dropFirst(dropFirst ? 1 : 0)
***REMOVED******REMOVED******REMOVED***.first
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch searchOutcome {
***REMOVED******REMOVED***case .results(let results):
***REMOVED******REMOVED******REMOVED***return results
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func searchSuggestions(
***REMOVED******REMOVED***_ model: SearchViewModel,
***REMOVED******REMOVED***dropFirst: Bool = false
***REMOVED***) async throws -> [SearchSuggestion]? {
***REMOVED******REMOVED***let searchOutcome = try await model.$searchOutcome
***REMOVED******REMOVED******REMOVED***.compactMap { $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.dropFirst(dropFirst ? 1 : 0)
***REMOVED******REMOVED******REMOVED***.first
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch searchOutcome {
***REMOVED******REMOVED***case .suggestions(let suggestions):
***REMOVED******REMOVED******REMOVED***return suggestions
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***

extension ArcGIS.Polygon {
***REMOVED***class var chippewaFalls: ArcGIS.Polygon {
***REMOVED******REMOVED***let points = [
***REMOVED******REMOVED******REMOVED***Point(x: -91.59127653822401, y: 44.74770908213401),
***REMOVED******REMOVED******REMOVED***Point(x: -91.19322516572637, y: 44.74770908213401),
***REMOVED******REMOVED******REMOVED***Point(x: -91.19322516572637, y: 45.116100854348254),
***REMOVED******REMOVED******REMOVED***Point(x: -91.59127653822401, y: 45.116100854348254)
***REMOVED******REMOVED***]
***REMOVED******REMOVED***return .init(points: points, spatialReference: .wgs84)
***REMOVED***
***REMOVED***
***REMOVED***class var minneapolis: ArcGIS.Polygon {
***REMOVED******REMOVED***let points = [
***REMOVED******REMOVED******REMOVED***Point(x: -94.170821328662, y: 44.13656401114444),
***REMOVED******REMOVED******REMOVED***Point(x: -94.170821328662, y: 44.13656401114444),
***REMOVED******REMOVED******REMOVED***Point(x: -92.34544467133114, y: 45.824325577904446),
***REMOVED******REMOVED******REMOVED***Point(x: -92.34544467133114, y: 45.824325577904446)
***REMOVED******REMOVED***]
***REMOVED******REMOVED***return .init(points: points, spatialReference: .wgs84)
***REMOVED***
***REMOVED***

extension Point {
***REMOVED***class var edinburgh: Point {
***REMOVED******REMOVED***.init(x: -3.188267, y: 55.953251, spatialReference: .wgs84)
***REMOVED***
***REMOVED***class var portland: Point {
***REMOVED******REMOVED***.init(x: -122.658722, y: 45.512230, spatialReference: .wgs84)
***REMOVED***
***REMOVED***
