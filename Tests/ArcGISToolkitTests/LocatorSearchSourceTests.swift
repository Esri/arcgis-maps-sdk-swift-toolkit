// Copyright 2021 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

import XCTest
import ArcGIS
import ArcGISToolkit
import SwiftUI

class LocatorSearchSourceTests: XCTestCase {
    // Modify GeocodeParameters and SuggestParameters from example view
    // Pass in custom locator (maybe from MMPK?)
    // Set searchArea and/or preferredSearchLocation once (instead of every pan)
    //
}

//class SearchViewModelTests: XCTestCase {
//    func testAcceptSuggestion() async throws {
//        let model = SearchViewModel(sources: [LocatorSearchSource()])
//
//        model.currentQuery = "Magers & Quinn Bookseller"
//        await model.updateSuggestions()
//        let suggestionionResults = try XCTUnwrap(model.suggestions.get())
//        let suggestion = try XCTUnwrap(suggestionionResults.first)
//
//        await model.acceptSuggestion(suggestion)
//        let results = try XCTUnwrap(model.results.get())
//        XCTAssertEqual(results.count, 1)
//
//        // TODO:  look into setting model.selectedResults in didSet of `results`.
//        XCTAssertNotNil(model.selectedResult)
//        try XCTAssertNil(model.suggestions.get())
//    }
//
//    func testCommitSearch() async throws {
//        let model = SearchViewModel(sources: [LocatorSearchSource()])
//
//        // No search - results are nil.
//        try XCTAssertNil(model.results.get())
//
//        // Search with no results - result count is 0.
//        model.currentQuery = "No results found blah blah blah blah"
//        await model.commitSearch(false)
//        var results = try XCTUnwrap(model.results.get())
//        XCTAssertEqual(results.count, 0)
//
//        XCTAssertNil(model.selectedResult)
//        try XCTAssertNil(model.suggestions.get())
//
//        // Search with one result.
//        model.currentQuery = "Magers & Quinn Bookseller"
//        await model.commitSearch(false)
//        results = try XCTUnwrap(model.results.get())
//        XCTAssertEqual(results.count, 1)
//
//        // One results automatically populates `selectedResult`.
//        XCTAssertNotNil(model.selectedResult)
//        try XCTAssertNil(model.suggestions.get())
//
//        // Search with multiple results.
//        model.currentQuery = "Magers & Quinn"
//        await model.commitSearch(false)
//        results = try XCTUnwrap(model.results.get())
//        XCTAssertGreaterThanOrEqual(results.count, 1)
//
//        XCTAssertNil(model.selectedResult)
//        try XCTAssertNil(model.suggestions.get())
//    }
//
//    func testIsEligibleForRequery() async {
//        let model = SearchViewModel(sources: [LocatorSearchSource()])
//
//        // isEligibleForRequery defaults to `false`.
//        XCTAssertFalse(model.isEligibleForRequery)
//
//        // There are no results, so setting `queryArea` has
//        // no effect on `isEligibleForRequery`.
//        model.queryArea = createPolygon()
//        XCTAssertFalse(model.isEligibleForRequery)
//
//        // We have results and a new polygon, `isEligibleForRequery` is true.
//        model.currentQuery = "Magers & Quinn Bookseller"
//        await model.commitSearch(false)
//        model.queryArea = createPolygon()
//        XCTAssertTrue(model.isEligibleForRequery)
//    }
//
//    func testUpdateSuggestions() async throws {
//        let model = SearchViewModel(sources: [LocatorSearchSource()])
//
//        // No currentQuery - suggestions are nil.
//        try XCTAssertNil(model.suggestions.get())
//
//        // UpdateSuggestions with no results - result count is 0.
//        model.currentQuery = "No results found blah blah blah blah"
//        await model.updateSuggestions()
//        var results = try XCTUnwrap(model.suggestions.get())
//        XCTAssertEqual(results.count, 0)
//
//        XCTAssertNil(model.selectedResult)
//        try XCTAssertNil(model.results.get())
//
//        // UpdateSuggestions with results.
//        model.currentQuery = "Magers & Quinn"
//        await model.updateSuggestions()
//        results = try XCTUnwrap(model.suggestions.get())
//        XCTAssertGreaterThanOrEqual(results.count, 1)
//
//        XCTAssertNil(model.selectedResult)
//        try XCTAssertNil(model.results.get())
//    }
//
//}

// Move to new file
class SmartLocatorSearchSourceTests: XCTestCase {
    //
}

extension SearchViewModelTests {
    func createPolygon() -> Polygon {
        let builder = PolygonBuilder(spatialReference: .wgs84)
        let _ = builder.add(point: .london)
        let _ = builder.add(point: .paris)
        let _ = builder.add(point: .rome)
        return builder.toGeometry() as! ArcGIS.Polygon
    }
}

extension Point {
    static let paris = Point(x: 2.23522, y: 48.8566, spatialReference: .wgs84)
    static let rome = Point(x: 12.4964, y: 41.9028, spatialReference: .wgs84)
    static let london = Point(x: -0.1278, y: 51.5074, spatialReference: .wgs84)
}
