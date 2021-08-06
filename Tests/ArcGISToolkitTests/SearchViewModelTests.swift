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
***REMOVED***func testIsEligibleForRequery() async {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** isEligibleForRequery defaults to `false`.
***REMOVED******REMOVED***XCTAssertFalse(model.isEligibleForRequery)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** There are no results, so setting `queryArea` has
***REMOVED******REMOVED******REMOVED*** no effect on `isEligibleForRequery`.
***REMOVED******REMOVED***model.queryArea = createPolygon()
***REMOVED******REMOVED***XCTAssertFalse(model.isEligibleForRequery)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** We have results and a new polygon, `isEligibleForRequery` is true.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Bookseller"
***REMOVED******REMOVED***await model.commitSearch(false)
***REMOVED******REMOVED***model.queryArea = createPolygon()
***REMOVED******REMOVED***XCTAssertTrue(model.isEligibleForRequery)
***REMOVED***
***REMOVED***
***REMOVED***func testCommitSearch() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** No search - results are nil.
***REMOVED******REMOVED***try XCTAssertNil(model.results.get())

***REMOVED******REMOVED******REMOVED*** Search with no results - result count is 0.
***REMOVED******REMOVED***model.currentQuery = "No results found blah blah blah blah"
***REMOVED******REMOVED***await model.commitSearch(false)
***REMOVED******REMOVED***var results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertEqual(results.count, 0)

***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***try XCTAssertNil(model.suggestions.get())
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with one result.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Bookseller"
***REMOVED******REMOVED***await model.commitSearch(false)
***REMOVED******REMOVED***results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertEqual(results.count, 1)

***REMOVED******REMOVED******REMOVED*** One results automatically populates `selectedResult`.
***REMOVED******REMOVED***XCTAssertNotNil(model.selectedResult)
***REMOVED******REMOVED***try XCTAssertNil(model.suggestions.get())
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with multiple results.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***await model.commitSearch(false)
***REMOVED******REMOVED***results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertGreaterThanOrEqual(results.count, 1)

***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***try XCTAssertNil(model.suggestions.get())
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
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***try XCTAssertNil(model.results.get())
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** UpdateSuggestions with results.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***await model.updateSuggestions()
***REMOVED******REMOVED***results = try XCTUnwrap(model.suggestions.get())
***REMOVED******REMOVED***XCTAssertGreaterThanOrEqual(results.count, 1)

***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***try XCTAssertNil(model.results.get())
***REMOVED***
***REMOVED***
***REMOVED***func testAcceptSuggestion() async throws {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])

***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Bookseller"
***REMOVED******REMOVED***await model.updateSuggestions()
***REMOVED******REMOVED***let suggestionionResults = try XCTUnwrap(model.suggestions.get())
***REMOVED******REMOVED***let suggestion = try XCTUnwrap(suggestionionResults.first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***await model.acceptSuggestion(suggestion)
***REMOVED******REMOVED***let results = try XCTUnwrap(model.results.get())
***REMOVED******REMOVED***XCTAssertEqual(results.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** TODO:  look into setting model.selectedResults in didSet of `results`.
***REMOVED******REMOVED***XCTAssertNotNil(model.selectedResult)
***REMOVED******REMOVED***try XCTAssertNil(model.suggestions.get())
***REMOVED***
***REMOVED***

***REMOVED*** Move to new file
class LocatorSearchSourceTests: XCTestCase {
***REMOVED******REMOVED*** Modify GeocodeParameters and SuggestParameters from example view
***REMOVED******REMOVED*** Pass in custom locator (maybe from MMPK?)
***REMOVED******REMOVED*** Set searchArea and/or preferredSearchLocation once (instead of every pan)
***REMOVED******REMOVED***
***REMOVED***

***REMOVED*** Move to new file
class SmartLocatorSearchSourceTests: XCTestCase {
***REMOVED******REMOVED***
***REMOVED***

extension SearchViewModelTests {
***REMOVED***func createPolygon() -> Polygon {
***REMOVED******REMOVED***let builder = PolygonBuilder(spatialReference: .wgs84)
***REMOVED******REMOVED***let _ = builder.add(point: .london)
***REMOVED******REMOVED***let _ = builder.add(point: .paris)
***REMOVED******REMOVED***let _ = builder.add(point: .rome)
***REMOVED******REMOVED***return builder.toGeometry() as! ArcGIS.Polygon
***REMOVED***
***REMOVED***

extension Point {
***REMOVED***static let paris = Point(x: 2.23522, y: 48.8566, spatialReference: .wgs84)
***REMOVED***static let rome = Point(x: 12.4964, y: 41.9028, spatialReference: .wgs84)
***REMOVED***static let london = Point(x: -0.1278, y: 51.5074, spatialReference: .wgs84)
***REMOVED***
