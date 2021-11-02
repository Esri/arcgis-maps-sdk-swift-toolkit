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

@MainActor
class SearchViewModelTests: XCTestCase {
    //
    // Test Design: https://devtopia.esri.com/runtime/common-toolkit/blob/master/designs/Search/Search_Test_Design.md
    //
    func testAcceptSuggestion() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        model.currentQuery = "Magers & Quinn Booksellers"
        
        model.updateSuggestions()
        
        // Get suggestion
        let suggestions = try await model.$suggestions.compactMap({ $0 }).first
        let suggestion = try XCTUnwrap(suggestions?.get().first)
        
        model.acceptSuggestion(suggestion)
        
        let results = try await model.$results.compactMap({ $0 }).first
        let result = try XCTUnwrap(results?.get())
        XCTAssertEqual(result.count, 1)
        XCTAssertNil(model.suggestions)
        
        // With only one results, model should set `selectedResult` property.
        XCTAssertEqual(result.first, model.selectedResult)
    }
    
    func testActiveSource() async throws {
        let activeSource = LocatorSearchSource()
        activeSource.name = "Simple Locator"
        let model = SearchViewModel(
            activeSource: activeSource,
            sources: [LocatorSearchSource()]
        )
        
        model.currentQuery = "Magers & Quinn Booksellers"
        
        model.commitSearch()
        
        let results = try await model.$results.compactMap({ $0 }).first
        let result = try XCTUnwrap(results?.get().first)
        XCTAssertEqual(result.owningSource.name, activeSource.name)
        
        model.updateSuggestions()
        
        let suggestions = try await model.$suggestions.compactMap({ $0 }).first
        let suggestion = try XCTUnwrap(suggestions?.get().first)
        XCTAssertEqual(suggestion.owningSource.name, activeSource.name)
    }
    
    func testCommitSearch() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // No search - results are nil.
        XCTAssertNil(model.results)
        
        // Search with no results - result count is 0.
        model.currentQuery = "No results found blah blah blah blah"
        
        model.commitSearch()
        
        var results = try await model.$results.compactMap({ $0 }).first
        var result = try XCTUnwrap(results?.get())
        XCTAssert(result.count, [])
        XCTAssertNil(model.selectedResult)
        XCTAssertNil(model.suggestions)
        
        // Search with one result.
        model.currentQuery = "Magers & Quinn Booksellers"
        
        model.commitSearch()
        
        results = try await model.$results.compactMap({ $0 }).first
        result = try XCTUnwrap(results?.get())
        XCTAssertEqual(result.count, 1)
        
        // One results automatically populates `selectedResult`.
        XCTAssertEqual(result.first, model.selectedResult)
        XCTAssertNil(model.suggestions)
        
        // Search with multiple results.
        model.currentQuery = "Magers & Quinn"
        
        model.commitSearch()
        
        results = try await model.$results.compactMap({ $ 0}).first
        result = try XCTUnwrap(results?.get())
        XCTAssertGreaterThan(result.count, 1)
        
        XCTAssertNil(model.selectedResult)
        XCTAssertNil(model.suggestions)
        
        model.selectedResult = result.first!
        
        model.commitSearch()
        
        results = try await model.$results.compactMap({ $0 }).dropFirst().first
        result = try XCTUnwrap(results?.get())
        XCTAssertGreaterThan(result.count, 1)
        
        XCTAssertNil(model.selectedResult)
    }
    
    func testCurrentQuery() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // Empty `currentQuery` should produce nil results and suggestions.
        model.currentQuery = ""
        XCTAssertNil(model.results)
        XCTAssertNil(model.suggestions)
        
        // Valid `currentQuery` should produce non-nil results.
        model.currentQuery = "Coffee"
        
        model.commitSearch()
        
        let results = try await model.$results.compactMap({ $0 }).first
        XCTAssertNotNil(results)
        
        // Changing the `currentQuery` should set results to nil.
        model.currentQuery = "Coffee in Portland"
        XCTAssertNil(model.results)
        
        model.updateSuggestions()
        
        let suggestions = try await model.$suggestions.compactMap({ $0 }).first
        XCTAssertNotNil(suggestions)
        
        // Changing the `currentQuery` should set suggestions to nil.
        model.currentQuery = "Coffee in Edinburgh"
        XCTAssertNil(model.suggestions)
        
        // Changing current query after search with 1 result
        // should set `selectedResult` to nil
        model.currentQuery = "Magers & Quinn Bookseller"
        
        model.commitSearch()
        
        _ = try await model.$results.compactMap({ $0 }).first
        XCTAssertNotNil(model.selectedResult)
        model.currentQuery = "Hotel"
        XCTAssertNil(model.selectedResult)
    }
    
    func testIsEligibleForRequery() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // Set queryArea to Chippewa Falls
        model.queryArea = Polygon.chippewaFalls
        model.geoViewExtent = Polygon.chippewaFalls.extent
        model.currentQuery = "Coffee"
        
        model.commitSearch()
        
        _ = try await model.$results.compactMap({ $0 }).first
        XCTAssertFalse(model.isEligibleForRequery)
        
        // Offset extent by 10% - isEligibleForRequery should still be `false`.
        var builder = EnvelopeBuilder(envelope: model.geoViewExtent)
        let tenPercentWidth = model.geoViewExtent!.width * 0.1
        builder.offsetBy(x: tenPercentWidth, y: 0.0)
        var newExtent = builder.toGeometry() as! Envelope
        
        model.geoViewExtent = newExtent
        XCTAssertFalse(model.isEligibleForRequery)
        
        // Offset extent by 50% - isEligibleForRequery should now be `true`.
        builder = EnvelopeBuilder(envelope: model.geoViewExtent)
        let fiftyPercentWidth = model.geoViewExtent!.width * 0.5
        builder.offsetBy(x: fiftyPercentWidth, y: 0.0)
        newExtent = builder.toGeometry() as! Envelope
        
        model.geoViewExtent = newExtent
        XCTAssertTrue(model.isEligibleForRequery)
        
        // Set queryArea to Chippewa Falls
        model.queryArea = Polygon.chippewaFalls
        model.geoViewExtent = Polygon.chippewaFalls.extent
        
        model.commitSearch()
        
        _ = try await model.$results.compactMap({ $0 }).dropFirst().first
        XCTAssertFalse(model.isEligibleForRequery)
        
        // Expand extent by 1.1x - isEligibleForRequery should still be `false`.
        builder = EnvelopeBuilder(envelope: model.geoViewExtent)
        builder.expand(factor: 1.1)
        newExtent = builder.toGeometry() as! Envelope
        
        model.geoViewExtent = newExtent
        XCTAssertFalse(model.isEligibleForRequery)
        
        // Expand extent by 1.5x - isEligibleForRequery should now be `true`.
        builder = EnvelopeBuilder(envelope: model.geoViewExtent)
        builder.expand(factor: 1.5)
        newExtent = builder.toGeometry() as! Envelope
        
        model.geoViewExtent = newExtent
        XCTAssertTrue(model.isEligibleForRequery)
    }
    
    func testQueryArea() async throws {
        let source = LocatorSearchSource()
        source.maximumResults = .max
        let model = SearchViewModel(sources: [source])
        
        // Set queryArea to Chippewa Falls
        model.queryArea = Polygon.chippewaFalls
        model.currentQuery = "Coffee"
        
        model.commitSearch()
        
        var results = try await model.$results.compactMap({ $0 }).first
        var result = try XCTUnwrap(results?.get())
        XCTAssertGreaterThan(result.count, 1)
        
        let resultGeometryUnion: Geometry = try XCTUnwrap(
            GeometryEngine.union(
                geometries: result.compactMap { $0.geoElement?.geometry }
            )
        )
        
        XCTAssertTrue(
            GeometryEngine.contains(
                geometry1: model.queryArea!,
                geometry2: resultGeometryUnion
            )
        )
        
        model.currentQuery = "Magers & Quinn Booksellers"
        
        model.commitSearch()
        
        results = try await model.$results.compactMap({ $0 }).first
        result = try XCTUnwrap(results?.get())
        XCTAssertEqual(result.count, 0)
        
        model.queryArea = Polygon.minneapolis
        
        model.commitSearch()
        
        // A note about the use of `.dropFirst()`:
        // Because `model.results` is not changed between the previous call
        // to `model.commitSearch()` and the one right above, the
        // `try await model.$results...` call will return the last result
        // received (from the first `model.commitSearch()` call), which is
        // incorrect.  Calling `.dropFirst()` will remove that one
        // and will give us the next one, which is the correct one (the result
        // from the second `model.commitSearch()` call).
        results = try await model.$results.compactMap({ $0 }).dropFirst().first
        result = try XCTUnwrap(results?.get())
        XCTAssertEqual(result.count, 1)
    }
    
    func testQueryCenter() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // Set queryCenter to Portland
        model.queryCenter = .portland
        model.currentQuery = "Coffee"
        
        model.commitSearch()
        
        var results = try await model.$results.compactMap({ $0 }).first
        var result = try XCTUnwrap(results?.get())
        
        var resultPoint = try XCTUnwrap(
            result.first?.geoElement?.geometry as? Point
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
        XCTAssertLessThan(geodeticDistance.distance,  1500)
        
        // Set queryCenter to Edinburgh
        model.queryCenter = .edinburgh
        model.currentQuery = "Restaurants"
        
        model.commitSearch()
        
        results = try await model.$results.compactMap({ $0 }).first
        result = try XCTUnwrap(results?.get())
        
        resultPoint = try XCTUnwrap(
            result.first?.geoElement?.geometry as? Point
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
    
    func testRepeatSearch() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // Set queryArea to Chippewa Falls
        model.geoViewExtent = Polygon.chippewaFalls.extent
        model.currentQuery = "Coffee"
        
        model.repeatSearch()
        
        var results = try await model.$results.compactMap({ $0 }).first
        var result = try XCTUnwrap(results?.get())
        XCTAssertGreaterThan(result.count, 1)
        
        let resultGeometryUnion: Geometry = try XCTUnwrap(
            GeometryEngine.union(
                geometries: result.compactMap { $0.geoElement?.geometry }
            )
        )
        
        XCTAssertTrue(
            GeometryEngine.contains(
                geometry1: model.geoViewExtent!,
                geometry2: resultGeometryUnion
            )
        )
        
        model.currentQuery = "Magers & Quinn Booksellers"
        
        model.repeatSearch()
        
        results = try await model.$results.compactMap({ $0 }).first
        result = try XCTUnwrap(results?.get())
        XCTAssertEqual(result.count, 0)
        
        model.geoViewExtent = Polygon.minneapolis.extent
        
        model.repeatSearch()
        
        results = try await model.$results.compactMap({ $0 }).dropFirst().first
        result = try XCTUnwrap(results?.get())
        XCTAssertEqual(result.count, 1)
    }
    
    func testSearchResultMode() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        XCTAssertEqual(model.resultMode, .automatic)
        
        model.resultMode = .single
        model.currentQuery = "Magers & Quinn"
        
        model.commitSearch()
        
        var results = try await model.$results.compactMap({ $0 }).first
        var result = try XCTUnwrap(results?.get())
        XCTAssertEqual(result.count, 1)
        
        model.resultMode = .multiple
        
        model.commitSearch()
        
        results = try await model.$results.compactMap({ $0 }).dropFirst().first
        result = try XCTUnwrap(results?.get())
        XCTAssertGreaterThan(result.count, 1)
        
        model.currentQuery = "Coffee"
        
        model.updateSuggestions()
        
        let suggestionResults = try await model.$suggestions.compactMap({ $0 }).first
        let suggestions = try XCTUnwrap(suggestionResults?.get())
        
        let collectionSuggestion = try XCTUnwrap(suggestions.filter(\.isCollection).first)
        let singleSuggestion = try XCTUnwrap(suggestions.filter(!\.isCollection).first)
        
        model.resultMode = .automatic
        
        model.acceptSuggestion(collectionSuggestion)
        
        results = try await model.$results.compactMap({ $0 }).first
        result = try XCTUnwrap(results?.get())
        XCTAssertGreaterThan(result.count, 1)
        
        Task { model.acceptSuggestion(singleSuggestion) }
        
        results = try await model.$results.compactMap({ $0 }).dropFirst().first
        result = try XCTUnwrap(results?.get())
        XCTAssertEqual(result.count, 1)
    }
    
    func testUpdateSuggestions() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // No currentQuery - suggestions are nil.
        XCTAssertNil(model.suggestions)
        
        // UpdateSuggestions with no results - result count is 0.
        model.currentQuery = "No results found blah blah blah blah"
        
        model.updateSuggestions()
        
        var suggestionResults = try await model.$suggestions.compactMap({ $0 }).first
        var suggestions = try XCTUnwrap(suggestionResults?.get())
        XCTAssertEqual(suggestions, [])
        
        // UpdateSuggestions with results.
        model.currentQuery = "Magers & Quinn"
        
        model.updateSuggestions()
        
        suggestionResults = try await model.$suggestions.compactMap({ $0 }).first
        suggestions = try XCTUnwrap(suggestionResults?.get())
        XCTAssertGreaterThanOrEqual(suggestions.count, 1)
        
        XCTAssertNil(model.selectedResult)
        XCTAssertNil(model.results)
    }
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

