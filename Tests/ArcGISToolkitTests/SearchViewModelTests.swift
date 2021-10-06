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
import Combine

class SearchViewModelTests: XCTestCase {
    @MainActor
    func testAcceptSuggestion() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        model.currentQuery = "Magers & Quinn Booksellers"

        Task {
            model.updateSuggestions()
        }
        
        // Get suggestion
        let suggestionResult = try await model.$suggestions.dropFirst().compactMap({$0}).first
        let suggestion = try XCTUnwrap(suggestionResult?.get().first)
        
        Task {
            model.acceptSuggestion(suggestion)
        }
        
        let searchResultResult = try await model.$results.dropFirst().compactMap({$0}).first
        let searchResults = try XCTUnwrap(searchResultResult?.get())
        XCTAssertEqual(searchResults.count, 1)
        try XCTAssertNil(model.suggestions?.get())
        
        // With only one results, model should set `selectedResult` property.
        let results = try XCTUnwrap(model.results?.get())
        XCTAssertEqual(results.first!, model.selectedResult)
    }
    
    
//    @MainActor
//    func testAcceptSuggestion() async throws {
//        let model = SearchViewModel(sources: [LocatorSearchSource()])
//        model.currentQuery = "Magers & Quinn Booksellers"
//
//        var subscriptions = Set<AnyCancellable>()
//
//        // Get suggestion
//        let exp = expectation(description: "UpdateSuggestions")
//        var suggestion: SearchSuggestion?
//        model.$suggestions.dropFirst().first().sink { value in
//            do {
//                print("$suggestions: \(String(describing: value))")
//                suggestion = try XCTUnwrap(value?.get().first)
//            } catch {
//                XCTFail("Valid suggestion")
//            }
//            exp.fulfill()
//        }
//        .store(in: &subscriptions)
//
//        // `model.updateSuggestions()` gets called, but the inner locatorSearchSource.suggest()
//        // is never called (it's wrapped in a Taks, which is never started.  I'm wondering if
//        // `waitForExpectations` is blocking the main thread, which is where the Task is
//        // started (maybe?) because the model is marked as `@MainActor`.???
//        model.updateSuggestions()
//        waitForExpectations(timeout: 5.0)
//
//        // Get search result
//        guard let suggestion = suggestion else { return }
//
//        let exp2 = expectation(description: "AcceptSuggestion")
//        model.$results.drop(while: { $0 == nil }).sink { value in
//            do {
//                print("$results: \(String(describing: value))")
//                let results = try XCTUnwrap(value?.get())
//                XCTAssertEqual(results.count, 1)
//
//                try XCTAssertNil(model.suggestions?.get())
//            } catch {
//                XCTFail("Valid suggestion")
//            }
//            exp2.fulfill()
//        }
//        .store(in: &subscriptions)
//
//        model.acceptSuggestion(suggestion)
//        waitForExpectations(timeout: 5.0)
//
//        // With only one results, model should set `selectedResult` property.
//        let results = try XCTUnwrap(model.results?.get())
//        XCTAssertEqual(results.first!, model.selectedResult)
//    }
/*
    func testActiveSource() async throws {
        let activeSource = LocatorSearchSource()
        activeSource.displayName = "Simple Locator"
        
        let model = SearchViewModel(
            activeSource: activeSource,
            sources: [LocatorSearchSource()]
        )
        
        model.currentQuery = "Magers & Quinn Booksellers"
        await model.commitSearch()
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
        await model.commitSearch()
        var results = try XCTUnwrap(model.results.get())
        XCTAssertEqual(results.count, 0)
        
        XCTAssertNil(model.selectedResult)
        try XCTAssertNil(model.suggestions.get())
        
        // Search with one result.
        model.currentQuery = "Magers & Quinn Booksellers"
        await model.commitSearch()
        results = try XCTUnwrap(model.results.get())
        XCTAssertEqual(results.count, 1)
        
        // One results automatically populates `selectedResult`.
        XCTAssertEqual(results.first!, model.selectedResult)
        try XCTAssertNil(model.suggestions.get())
        
        // Search with multiple results.
        model.currentQuery = "Magers & Quinn"
        await model.commitSearch()
        results = try XCTUnwrap(model.results.get())
        XCTAssertGreaterThan(results.count, 1)
        
        XCTAssertNil(model.selectedResult)
        try XCTAssertNil(model.suggestions.get())
    }
    
    func testCurrentQuery() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // Empty `currentQuery` should produce nil results value.
        model.currentQuery = ""
        await model.commitSearch()
        try XCTAssertNil(model.results.get())
        
        // Empty `currentQuery` should produce nil suggestions value.
        await model.updateSuggestions()
        try XCTAssertNil(model.suggestions.get())
        
        model.currentQuery = "Coffee"
        await model.commitSearch()
        try XCTAssertNotNil(model.results.get())
        
        // Changing the `currentQuery` should set results to nil.
        model.currentQuery = "Coffee in Portland"
        try XCTAssertNil(model.results.get())
        
        await model.updateSuggestions()
        try XCTAssertNotNil(model.suggestions.get())
        
        // Changing the `currentQuery` should set results to nil.
        model.currentQuery = "Coffee in Edinburgh"
        try XCTAssertNil(model.suggestions.get())
        
        // Changing current query after search with 1 result
        // should set `selectedResult` to nil
        model.currentQuery = "Magers & Quinn Bookseller"
        await model.commitSearch()
        XCTAssertNotNil(model.selectedResult)
        model.currentQuery = "Hotel"
        XCTAssertNil(model.selectedResult)
    }
    
    func testQueryArea() async throws {
        let source = LocatorSearchSource()
        source.maximumResults = Int32.max
        let model = SearchViewModel(sources: [source])
        
        // Set queryArea to Chippewa Falls
        model.queryArea = Polygon.chippewaFalls
        model.currentQuery = "Coffee"
        await model.commitSearch()
        
        var results = try XCTUnwrap(model.results.get())
        XCTAssertEqual(results.count, 9)
        
        let resultGeometryUnion: Geometry = try XCTUnwrap(
            GeometryEngine.union(
                geometries: results.compactMap{ $0.geoElement?.geometry }
            )
        )
        
        XCTAssertTrue(
            GeometryEngine.contains(
                geometry1: model.queryArea!,
                geometry2: resultGeometryUnion
            )
        )
        
        model.currentQuery = "Magers & Quinn Booksellers"
        await model.commitSearch()
        results = try XCTUnwrap(model.results.get())
        XCTAssertEqual(results.count, 0)
        
        model.queryArea = Polygon.minneapolis
        await model.commitSearch()
        results = try XCTUnwrap(model.results.get())
        XCTAssertEqual(results.count, 1)
    }

    func testQueryCenter() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // Set queryCenter to Portland
        model.queryCenter = .portland
        model.currentQuery = "Coffee"
        await model.commitSearch()
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
        await model.commitSearch()
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
    
    func testSearchResultMode() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        XCTAssertEqual(model.resultMode, .automatic)
        
        model.resultMode = .single
        model.currentQuery = "Magers & Quinn"
        await model.commitSearch()
        var results = try XCTUnwrap(model.results.get())
        XCTAssertEqual(results.count, 1)
        
        model.resultMode = .multiple
        await model.commitSearch()
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
 */
}

extension Polygon {
static var chippewaFalls: Polygon {
    let builder = PolygonBuilder(spatialReference: .wgs84)
    let _ = builder.add(point: Point(x: -91.59127653822401, y: 44.74770908213401, spatialReference: .wgs84))
    let _ = builder.add(point: Point(x: -91.19322516572637, y: 44.74770908213401, spatialReference: .wgs84))
    let _ = builder.add(point: Point(x: -91.19322516572637, y: 45.116100854348254, spatialReference: .wgs84))
    let _ = builder.add(point: Point(x: -91.59127653822401, y: 45.116100854348254, spatialReference: .wgs84))
    return builder.toGeometry() as! ArcGIS.Polygon
}

static var minneapolis: Polygon {
    let builder = PolygonBuilder(spatialReference: .wgs84)
    let _ = builder.add(point: Point(x: -94.170821328662, y: 44.13656401114444, spatialReference: .wgs84))
    let _ = builder.add(point: Point(x: -94.170821328662, y: 44.13656401114444, spatialReference: .wgs84))
    let _ = builder.add(point: Point(x: -92.34544467133114, y: 45.824325577904446, spatialReference: .wgs84))
    let _ = builder.add(point: Point(x: -92.34544467133114, y: 45.824325577904446, spatialReference: .wgs84))
    return builder.toGeometry() as! ArcGIS.Polygon
}
}

extension Point {
    static let edinburgh = Point(x: -3.188267, y: 55.953251, spatialReference: .wgs84)
    static let portland = Point(x: -122.658722, y: 45.512230, spatialReference: .wgs84)
}

