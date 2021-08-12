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

class SearchViewModelTests: XCTestCase {
    func testAcceptSuggestion() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])

        model.currentQuery = "Magers & Quinn Booksellers"
        await model.updateSuggestions()
        let suggestionionResults = try XCTUnwrap(model.suggestions.get())
        let suggestion = try XCTUnwrap(suggestionionResults.first)
        
        await model.acceptSuggestion(suggestion)
        let results = try XCTUnwrap(model.results.get())
        XCTAssertEqual(results.count, 1)
        
        // With only one results, model should set `selectedResult` property.
        XCTAssertEqual(results.first!, model.selectedResult)
        
        try XCTAssertNil(model.suggestions.get())
    }
    
    func testActiveSource() async throws {
        let activeSource = LocatorSearchSource()
        activeSource.displayName = "Simple Locator"
        
        let model = SearchViewModel(
            activeSource: activeSource,
            sources: [LocatorSearchSource()]
        )
        
        model.currentQuery = "Magers & Quinn Booksellers"
        await model.commitSearch(false)
        let result = try XCTUnwrap(model.results.get()?.first)
        XCTAssertEqual(result.owningSource.displayName, activeSource.displayName)

        await model.updateSuggestions()
        let suggestResult = try XCTUnwrap(model.suggestions.get()?.first)
        XCTAssertEqual(suggestResult.owningSource.displayName, activeSource.displayName)
    }

    func testCommitSearch() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // No search - results are nil.
        try XCTAssertNil(model.results.get())

        // Search with no results - result count is 0.
        model.currentQuery = "No results found blah blah blah blah"
        await model.commitSearch(false)
        var results = try XCTUnwrap(model.results.get())
        XCTAssertEqual(results.count, 0)

        XCTAssertNil(model.selectedResult)
        try XCTAssertNil(model.suggestions.get())
        
        // Search with one result.
        model.currentQuery = "Magers & Quinn Booksellers"
        await model.commitSearch(false)
        results = try XCTUnwrap(model.results.get())
        XCTAssertEqual(results.count, 1)

        // One results automatically populates `selectedResult`.
        XCTAssertNotNil(model.selectedResult)
        try XCTAssertNil(model.suggestions.get())
        
        // Search with multiple results.
        model.currentQuery = "Magers & Quinn"
        await model.commitSearch(false)
        results = try XCTUnwrap(model.results.get())
        XCTAssertGreaterThan(results.count, 1)

        XCTAssertNil(model.selectedResult)
        try XCTAssertNil(model.suggestions.get())
    }
    
    func testCurrentQuery() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])

        // Empty `currentQuery` should produce nil results value.
        model.currentQuery = ""
        await model.commitSearch(false)
        try XCTAssertNil(model.results.get())

        // Empty `currentQuery` should produce nil suggestions value.
        await model.updateSuggestions()
        try XCTAssertNil(model.suggestions.get())
        
        model.currentQuery = "Coffee"
        await model.commitSearch(false)
        try XCTAssertNotNil(model.results.get())

        // Changing the `currentQuery` should set results to nil.
        model.currentQuery = "Coffee in Portland"
        try XCTAssertNil(model.results.get())
    }

    func testIsEligibleForRequery() async {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // isEligibleForRequery defaults to `false`.
        XCTAssertFalse(model.isEligibleForRequery)
        
        // There are no results, so setting `queryArea` has
        // no effect on `isEligibleForRequery`.
        model.queryArea = createPolygon()
        XCTAssertFalse(model.isEligibleForRequery)
        
        // We have results and a new polygon, `isEligibleForRequery` is true.
        model.currentQuery = "Magers & Quinn Booksellers"
        await model.commitSearch(false)
        XCTAssertFalse(model.isEligibleForRequery)

        model.queryArea = createPolygon()
        XCTAssertTrue(model.isEligibleForRequery)
    }
    
    func testQueryCenter() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])

        // Set queryCenter to Portland
        model.queryCenter = .portland
        model.currentQuery = "Coffee"
        await model.commitSearch(false)
        var resultPoint = try XCTUnwrap(
            model.results.get()?.first?.geoElement?.geometry as? Point
        )
        
        var geodeticDistance = try XCTUnwrap (
            GeometryEngine.distanceGeodetic(
                point1: .portland,
                point2: resultPoint,
                distanceUnit: .meters,
                azimuthUnit: nil,
                curveType: .geodesic
            )
        )
        
        // First result within 1500m of Portland.
        XCTAssertLessThan(geodeticDistance.distance,  1500.0)

        // Set queryCenter to Edinburgh
        model.queryCenter = .edinburgh
        model.currentQuery = "Restaurants"
        await model.commitSearch(false)
        resultPoint = try XCTUnwrap(
            model.results.get()?.first?.geoElement?.geometry as? Point
        )
        
        // Web Mercator distance between .edinburgh and first result.
        geodeticDistance = try XCTUnwrap (
            GeometryEngine.distanceGeodetic(
                point1: .edinburgh,
                point2: resultPoint,
                distanceUnit: .meters,
                azimuthUnit: nil,
                curveType: .geodesic
            )
        )

        // First result within 100m of Edinburgh.
        XCTAssertLessThan(geodeticDistance.distance,  100)
    }
    
    func testQueryArea() async throws {
        // Coming soon, once the implementation details are
        // finalized between .Net/Qt/iOS.
    }

    func testSearchResultMode() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        XCTAssertEqual(model.resultMode, .automatic)

        model.resultMode = .single
        model.currentQuery = "Magers & Quinn"
        await model.commitSearch(false)
        var results = try XCTUnwrap(model.results.get())
        XCTAssertEqual(results.count, 1)
        
        model.resultMode = .multiple
        await model.commitSearch(false)
        results = try XCTUnwrap(model.results.get())
        XCTAssertGreaterThan(results.count, 1)
        
        model.currentQuery = "Coffee"
        await model.updateSuggestions()
        let suggestResults = try XCTUnwrap(model.suggestions.get())
        let collectionSuggestion = try XCTUnwrap(suggestResults.filter { $0.isCollection }.first)
        let singleSuggestion = try XCTUnwrap(suggestResults.filter { !$0.isCollection }.first)

        model.resultMode = .automatic
        await model.acceptSuggestion(collectionSuggestion)
        results = try XCTUnwrap(model.results.get())
        XCTAssertGreaterThan(results.count, 1)

        await model.acceptSuggestion(singleSuggestion)
        results = try XCTUnwrap(model.results.get())
        XCTAssertEqual(results.count, 1)
    }

    func testUpdateSuggestions() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // No currentQuery - suggestions are nil.
        try XCTAssertNil(model.suggestions.get())
        
        // UpdateSuggestions with no results - result count is 0.
        model.currentQuery = "No results found blah blah blah blah"
        await model.updateSuggestions()
        var results = try XCTUnwrap(model.suggestions.get())
        XCTAssertEqual(results.count, 0)
        
        // UpdateSuggestions with results.
        model.currentQuery = "Magers & Quinn"
        await model.updateSuggestions()
        results = try XCTUnwrap(model.suggestions.get())
        XCTAssertGreaterThanOrEqual(results.count, 1)

        XCTAssertNil(model.selectedResult)
        try XCTAssertNil(model.results.get())
    }
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
    static let edinburgh = Point(x: -3.188267, y: 55.953251, spatialReference: .wgs84)
    static let london = Point(x: -0.1278, y: 51.5074, spatialReference: .wgs84)
    static let minneapolis = Point(x: -93.25813, y: 44.98665, spatialReference: .wgs84)
    static let paris = Point(x: 2.23522, y: 48.8566, spatialReference: .wgs84)
    static let portland = Point(x: -122.658722, y: 45.512230, spatialReference: .wgs84)
    static let rome = Point(x: 12.4964, y: 41.9028, spatialReference: .wgs84)
}
