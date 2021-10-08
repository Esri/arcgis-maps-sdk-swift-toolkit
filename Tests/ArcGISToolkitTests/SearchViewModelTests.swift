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

import XCTest
***REMOVED***
***REMOVED***Toolkit
***REMOVED***
import Combine

@MainActor
class SearchViewModelTests: XCTestCase {
***REMOVED******REMOVED***
***REMOVED******REMOVED*** Test Design: https:***REMOVED***devtopia.esri.com/runtime/common-toolkit/blob/master/designs/Search/Search_Test_Design.md
***REMOVED******REMOVED***
***REMOVED***func testAcceptSuggestion() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"

***REMOVED******REMOVED***Task { model.updateSuggestions() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Get suggestion
***REMOVED******REMOVED***let suggestions = try await model.$suggestions.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***let suggestion = try XCTUnwrap(suggestions?.get().first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.acceptSuggestion(suggestion) ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***let result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** With only one results, model should set `selectedResult` property.
***REMOVED******REMOVED***XCTAssertEqual(result.first!, model.selectedResult)
***REMOVED***

***REMOVED***func testActiveSource() async throws {
***REMOVED******REMOVED***let activeSource = LocatorSearchSource()
***REMOVED******REMOVED***activeSource.displayName = "Simple Locator"
***REMOVED******REMOVED***let model = SearchViewModel(
***REMOVED******REMOVED******REMOVED***activeSource: activeSource,
***REMOVED******REMOVED******REMOVED***sources: [LocatorSearchSource()]
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***let result = try XCTUnwrap(results?.get().first)
***REMOVED******REMOVED***XCTAssertEqual(result.owningSource.displayName, activeSource.displayName)
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.updateSuggestions() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let suggestions = try await model.$suggestions.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***let suggestion = try XCTUnwrap(suggestions?.get().first)
***REMOVED******REMOVED***XCTAssertEqual(suggestion.owningSource.displayName, activeSource.displayName)
***REMOVED***

***REMOVED***func testCommitSearch() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** No search - results are nil.
***REMOVED******REMOVED***XCTAssertNil(model.results)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with no results - result count is 0.
***REMOVED******REMOVED***model.currentQuery = "No results found blah blah blah blah"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***var result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 0)
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with one result.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** One results automatically populates `selectedResult`.
***REMOVED******REMOVED***XCTAssertEqual(result.first!, model.selectedResult)
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with multiple results.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED***

***REMOVED***func testCurrentQuery() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Empty `currentQuery` should produce nil results and suggestions.
***REMOVED******REMOVED***model.currentQuery = ""
***REMOVED******REMOVED***XCTAssertNil(model.results)
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Valid `currentQuery` should produce non-nil results.
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***XCTAssertNotNil(results)

***REMOVED******REMOVED******REMOVED*** Changing the `currentQuery` should set results to nil.
***REMOVED******REMOVED***model.currentQuery = "Coffee in Portland"
***REMOVED******REMOVED***XCTAssertNil(model.results)
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.updateSuggestions() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let suggestions = try await model.$suggestions.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***XCTAssertNotNil(suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Changing the `currentQuery` should set suggestions to nil.
***REMOVED******REMOVED***model.currentQuery = "Coffee in Edinburgh"
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Changing current query after search with 1 result
***REMOVED******REMOVED******REMOVED*** should set `selectedResult` to nil
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Bookseller"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***_ = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***XCTAssertNotNil(model.selectedResult)
***REMOVED******REMOVED***model.currentQuery = "Hotel"
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED***

***REMOVED***func testQueryArea() async throws {
***REMOVED******REMOVED***let source = LocatorSearchSource()
***REMOVED******REMOVED***source.maximumResults = Int32.max
***REMOVED******REMOVED***let model = SearchViewModel(sources: [source])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryArea to Chippewa Falls
***REMOVED******REMOVED***model.queryArea = Polygon.chippewaFalls
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***var result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let resultGeometryUnion: Geometry = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***GeometryEngine.union(
***REMOVED******REMOVED******REMOVED******REMOVED***geometries: result.compactMap{ $0.geoElement?.geometry ***REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***GeometryEngine.contains(
***REMOVED******REMOVED******REMOVED******REMOVED***geometry1: model.queryArea!,
***REMOVED******REMOVED******REMOVED******REMOVED***geometry2: resultGeometryUnion
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.queryArea = Polygon.minneapolis

***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***

***REMOVED******REMOVED******REMOVED*** A note about the use of `.dropFirst()`:
***REMOVED******REMOVED******REMOVED*** Because `model.results` is not changed between the previous call
***REMOVED******REMOVED******REMOVED*** to `model.commitSearch()` and the one right above, the
***REMOVED******REMOVED******REMOVED*** `try await model.$results...` call will return the last result
***REMOVED******REMOVED******REMOVED*** received (from the first `model.commitSearch()` call), which is
***REMOVED******REMOVED******REMOVED*** incorrect.  Calling `.dropFirst()` will remove that one
***REMOVED******REMOVED******REMOVED*** and will give us the next one, which is the correct one (the result
***REMOVED******REMOVED******REMOVED*** from the second `model.commitSearch()` call).
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).dropFirst().first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED***

***REMOVED***func testQueryCenter() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryCenter to Portland
***REMOVED******REMOVED***model.queryCenter = .portland
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***var result = try XCTUnwrap(results?.get())

***REMOVED******REMOVED***var resultPoint = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***result.first?.geoElement?.geometry as? Point
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var geodeticDistance = try XCTUnwrap (
***REMOVED******REMOVED******REMOVED***GeometryEngine.distanceGeodetic(
***REMOVED******REMOVED******REMOVED******REMOVED***point1: .portland,
***REMOVED******REMOVED******REMOVED******REMOVED***point2: resultPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***distanceUnit: .meters,
***REMOVED******REMOVED******REMOVED******REMOVED***azimuthUnit: nil,
***REMOVED******REMOVED******REMOVED******REMOVED***curveType: .geodesic
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** First result within 1500m of Portland.
***REMOVED******REMOVED***XCTAssertLessThan(geodeticDistance.distance,  1500.0)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryCenter to Edinburgh
***REMOVED******REMOVED***model.queryCenter = .edinburgh
***REMOVED******REMOVED***model.currentQuery = "Restaurants"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())

***REMOVED******REMOVED***resultPoint = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***result.first?.geoElement?.geometry as? Point
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Web Mercator distance between .edinburgh and first result.
***REMOVED******REMOVED***geodeticDistance = try XCTUnwrap (
***REMOVED******REMOVED******REMOVED***GeometryEngine.distanceGeodetic(
***REMOVED******REMOVED******REMOVED******REMOVED***point1: .edinburgh,
***REMOVED******REMOVED******REMOVED******REMOVED***point2: resultPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***distanceUnit: .meters,
***REMOVED******REMOVED******REMOVED******REMOVED***azimuthUnit: nil,
***REMOVED******REMOVED******REMOVED******REMOVED***curveType: .geodesic
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** First result within 100m of Edinburgh.
***REMOVED******REMOVED***XCTAssertLessThan(geodeticDistance.distance,  100)
***REMOVED***

***REMOVED***func testSearchResultMode() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***XCTAssertEqual(model.resultMode, .automatic)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.resultMode = .single
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***var result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.resultMode = .multiple

***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***

***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).dropFirst().first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.updateSuggestions() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let suggestionResults = try await model.$suggestions.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***let suggestions = try XCTUnwrap(suggestionResults?.get())

***REMOVED******REMOVED***let collectionSuggestion = try XCTUnwrap(suggestions.filter { $0.isCollection ***REMOVED***.first)
***REMOVED******REMOVED***let singleSuggestion = try XCTUnwrap(suggestions.filter { !$0.isCollection ***REMOVED***.first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.resultMode = .automatic
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.acceptSuggestion(collectionSuggestion) ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.acceptSuggestion(singleSuggestion) ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).dropFirst().first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED***
***REMOVED***
***REMOVED***func testUpdateSuggestions() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** No currentQuery - suggestions are nil.
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** UpdateSuggestions with no results - result count is 0.
***REMOVED******REMOVED***model.currentQuery = "No results found blah blah blah blah"

***REMOVED******REMOVED***Task { model.updateSuggestions() ***REMOVED***

***REMOVED******REMOVED***var suggestionResults = try await model.$suggestions.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***var suggestions = try XCTUnwrap(suggestionResults?.get())
***REMOVED******REMOVED***XCTAssertEqual(suggestions.count, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** UpdateSuggestions with results.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.updateSuggestions() ***REMOVED***

***REMOVED******REMOVED***suggestionResults = try await model.$suggestions.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***suggestions = try XCTUnwrap(suggestionResults?.get())
***REMOVED******REMOVED***XCTAssertGreaterThanOrEqual(suggestions.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***XCTAssertNil(model.results)
***REMOVED***
***REMOVED***

extension Polygon {
static var chippewaFalls: Polygon {
***REMOVED***let builder = PolygonBuilder(spatialReference: .wgs84)
***REMOVED***let _ = builder.add(point: Point(x: -91.59127653822401, y: 44.74770908213401, spatialReference: .wgs84))
***REMOVED***let _ = builder.add(point: Point(x: -91.19322516572637, y: 44.74770908213401, spatialReference: .wgs84))
***REMOVED***let _ = builder.add(point: Point(x: -91.19322516572637, y: 45.116100854348254, spatialReference: .wgs84))
***REMOVED***let _ = builder.add(point: Point(x: -91.59127653822401, y: 45.116100854348254, spatialReference: .wgs84))
***REMOVED***return builder.toGeometry() as! ArcGIS.Polygon
***REMOVED***

static var minneapolis: Polygon {
***REMOVED***let builder = PolygonBuilder(spatialReference: .wgs84)
***REMOVED***let _ = builder.add(point: Point(x: -94.170821328662, y: 44.13656401114444, spatialReference: .wgs84))
***REMOVED***let _ = builder.add(point: Point(x: -94.170821328662, y: 44.13656401114444, spatialReference: .wgs84))
***REMOVED***let _ = builder.add(point: Point(x: -92.34544467133114, y: 45.824325577904446, spatialReference: .wgs84))
***REMOVED***let _ = builder.add(point: Point(x: -92.34544467133114, y: 45.824325577904446, spatialReference: .wgs84))
***REMOVED***return builder.toGeometry() as! ArcGIS.Polygon
***REMOVED***
***REMOVED***

extension Point {
***REMOVED***static let edinburgh = Point(x: -3.188267, y: 55.953251, spatialReference: .wgs84)
***REMOVED***static let portland = Point(x: -122.658722, y: 45.512230, spatialReference: .wgs84)
***REMOVED***

