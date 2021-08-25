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

class SearchViewModelTests: XCTestCase {
***REMOVED***func testAcceptSuggestion() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***await model.updateSuggestions()
***REMOVED******REMOVED***let suggestionionResults = try XCTUnwrap(model.suggestions.get())
***REMOVED******REMOVED***let suggestion = try XCTUnwrap(suggestionionResults.first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await model.acceptSuggestion(suggestion)
***REMOVED******REMOVED***let results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertEqual(results.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** With only one results, model should set `selectedResult` property.
***REMOVED******REMOVED***XCTAssertEqual(results.first!, model.selectedResult)
***REMOVED******REMOVED***
***REMOVED******REMOVED***try XCTAssertNil(model.suggestions.get())
***REMOVED***
***REMOVED***
***REMOVED***func testActiveSource() async throws {
***REMOVED******REMOVED***let activeSource = LocatorSearchSource()
***REMOVED******REMOVED***activeSource.displayName = "Simple Locator"
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = SearchViewModel(
***REMOVED******REMOVED******REMOVED***activeSource: activeSource,
***REMOVED******REMOVED******REMOVED***sources: [LocatorSearchSource()]
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***await model.commitSearch()
***REMOVED******REMOVED***let result = try XCTUnwrap(model.results.get()?.first)
***REMOVED******REMOVED***XCTAssertEqual(result.owningSource.displayName, activeSource.displayName)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await model.updateSuggestions()
***REMOVED******REMOVED***let suggestResult = try XCTUnwrap(model.suggestions.get()?.first)
***REMOVED******REMOVED***XCTAssertEqual(suggestResult.owningSource.displayName, activeSource.displayName)
***REMOVED***
***REMOVED***
***REMOVED***func testCommitSearch() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** No search - results are nil.
***REMOVED******REMOVED***try XCTAssertNil(model.results.get())
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with no results - result count is 0.
***REMOVED******REMOVED***model.currentQuery = "No results found blah blah blah blah"
***REMOVED******REMOVED***await model.commitSearch()
***REMOVED******REMOVED***var results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertEqual(results.count, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***try XCTAssertNil(model.suggestions.get())
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with one result.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***await model.commitSearch()
***REMOVED******REMOVED***results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertEqual(results.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** One results automatically populates `selectedResult`.
***REMOVED******REMOVED***XCTAssertNotNil(model.selectedResult)
***REMOVED******REMOVED***try XCTAssertNil(model.suggestions.get())
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with multiple results.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***await model.commitSearch()
***REMOVED******REMOVED***results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertGreaterThan(results.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***try XCTAssertNil(model.suggestions.get())
***REMOVED***
***REMOVED***
***REMOVED***func testCurrentQuery() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Empty `currentQuery` should produce nil results value.
***REMOVED******REMOVED***model.currentQuery = ""
***REMOVED******REMOVED***await model.commitSearch()
***REMOVED******REMOVED***try XCTAssertNil(model.results.get())
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Empty `currentQuery` should produce nil suggestions value.
***REMOVED******REMOVED***await model.updateSuggestions()
***REMOVED******REMOVED***try XCTAssertNil(model.suggestions.get())
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***await model.commitSearch()
***REMOVED******REMOVED***try XCTAssertNotNil(model.results.get())
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Changing the `currentQuery` should set results to nil.
***REMOVED******REMOVED***model.currentQuery = "Coffee in Portland"
***REMOVED******REMOVED***try XCTAssertNil(model.results.get())
***REMOVED***
***REMOVED***
***REMOVED***func testQueryCenter() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryCenter to Portland
***REMOVED******REMOVED***model.queryCenter = .portland
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***await model.commitSearch()
***REMOVED******REMOVED***var resultPoint = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***model.results.get()?.first?.geoElement?.geometry as? Point
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
***REMOVED******REMOVED***await model.commitSearch()
***REMOVED******REMOVED***resultPoint = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***model.results.get()?.first?.geoElement?.geometry as? Point
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
***REMOVED***
***REMOVED***func testQueryArea() async throws {
***REMOVED******REMOVED***let source = LocatorSearchSource()
***REMOVED******REMOVED***source.maximumResults = Int32.max
***REMOVED******REMOVED***let model = SearchViewModel(sources: [source])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryArea to Chippewa Falls
***REMOVED******REMOVED***model.queryArea = Polygon.chippewaFalls
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***await model.commitSearch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertEqual(results.count, 9)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let resultGeometryUnion: Geometry = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***GeometryEngine.union(
***REMOVED******REMOVED******REMOVED******REMOVED***geometries: results.compactMap{ $0.geoElement?.geometry ***REMOVED***
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
***REMOVED******REMOVED***await model.commitSearch()
***REMOVED******REMOVED***results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertEqual(results.count, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.queryArea = Polygon.minneapolis
***REMOVED******REMOVED***await model.commitSearch()
***REMOVED******REMOVED***results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertEqual(results.count, 1)
***REMOVED***
***REMOVED***
***REMOVED***func testSearchResultMode() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***XCTAssertEqual(model.resultMode, .automatic)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.resultMode = .single
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***await model.commitSearch()
***REMOVED******REMOVED***var results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertEqual(results.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.resultMode = .multiple
***REMOVED******REMOVED***await model.commitSearch()
***REMOVED******REMOVED***results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertGreaterThan(results.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***await model.updateSuggestions()
***REMOVED******REMOVED***let suggestResults = try XCTUnwrap(model.suggestions.get())
***REMOVED******REMOVED***let collectionSuggestion = try XCTUnwrap(suggestResults.filter { $0.isCollection ***REMOVED***.first)
***REMOVED******REMOVED***let singleSuggestion = try XCTUnwrap(suggestResults.filter { !$0.isCollection ***REMOVED***.first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.resultMode = .automatic
***REMOVED******REMOVED***await model.acceptSuggestion(collectionSuggestion)
***REMOVED******REMOVED***results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertGreaterThan(results.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await model.acceptSuggestion(singleSuggestion)
***REMOVED******REMOVED***results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertEqual(results.count, 1)
***REMOVED***
***REMOVED***
***REMOVED***func testUpdateSuggestions() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** No currentQuery - suggestions are nil.
***REMOVED******REMOVED***try XCTAssertNil(model.suggestions.get())
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** UpdateSuggestions with no results - result count is 0.
***REMOVED******REMOVED***model.currentQuery = "No results found blah blah blah blah"
***REMOVED******REMOVED***await model.updateSuggestions()
***REMOVED******REMOVED***var results = try XCTUnwrap(model.suggestions.get())
***REMOVED******REMOVED***XCTAssertEqual(results.count, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** UpdateSuggestions with results.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***await model.updateSuggestions()
***REMOVED******REMOVED***results = try XCTUnwrap(model.suggestions.get())
***REMOVED******REMOVED***XCTAssertGreaterThanOrEqual(results.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***try XCTAssertNil(model.results.get())
***REMOVED***
***REMOVED***

extension Polygon {
***REMOVED***static var chippewaFalls: Polygon {
***REMOVED******REMOVED***let builder = PolygonBuilder(spatialReference: .wgs84)
***REMOVED******REMOVED***let _ = builder.add(point: Point(x: -91.59127653822401, y: 44.74770908213401, spatialReference: .wgs84))
***REMOVED******REMOVED***let _ = builder.add(point: Point(x: -91.19322516572637, y: 44.74770908213401, spatialReference: .wgs84))
***REMOVED******REMOVED***let _ = builder.add(point: Point(x: -91.19322516572637, y: 45.116100854348254, spatialReference: .wgs84))
***REMOVED******REMOVED***let _ = builder.add(point: Point(x: -91.59127653822401, y: 45.116100854348254, spatialReference: .wgs84))
***REMOVED******REMOVED***return builder.toGeometry() as! ArcGIS.Polygon
***REMOVED***
***REMOVED***
***REMOVED***static var minneapolis: Polygon {
***REMOVED******REMOVED***let builder = PolygonBuilder(spatialReference: .wgs84)
***REMOVED******REMOVED***let _ = builder.add(point: Point(x: -94.170821328662, y: 44.13656401114444, spatialReference: .wgs84))
***REMOVED******REMOVED***let _ = builder.add(point: Point(x: -94.170821328662, y: 44.13656401114444, spatialReference: .wgs84))
***REMOVED******REMOVED***let _ = builder.add(point: Point(x: -92.34544467133114, y: 45.824325577904446, spatialReference: .wgs84))
***REMOVED******REMOVED***let _ = builder.add(point: Point(x: -92.34544467133114, y: 45.824325577904446, spatialReference: .wgs84))
***REMOVED******REMOVED***return builder.toGeometry() as! ArcGIS.Polygon
***REMOVED***
***REMOVED***

extension Point {
***REMOVED***static let edinburgh = Point(x: -3.188267, y: 55.953251, spatialReference: .wgs84)
***REMOVED***static let minneapolis = Point(x: -93.25813, y: 44.98665, spatialReference: .wgs84)
***REMOVED***static let portland = Point(x: -122.658722, y: 45.512230, spatialReference: .wgs84)
***REMOVED***
