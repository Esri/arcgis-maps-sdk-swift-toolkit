// Copyright 2021 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
@testable import ArcGISToolkit
@preconcurrency import Combine
import XCTest

class SearchViewModelTests: XCTestCase {
    @MainActor
    func testAcceptSuggestion() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        model.currentQuery = "Magers & Quinn Booksellers"
        
        model.updateSuggestions()
        
        // Get suggestion
        let suggestions = try await model.searchSuggestions()
        let suggestion = try XCTUnwrap(suggestions?.first)
        
        model.acceptSuggestion(suggestion)
        
        let results = try await model.searchResults(dropFirst: true)
        let result = try XCTUnwrap(results)
        XCTAssertEqual(result.count, 1)
        
        // With only one result, model should set `selectedResult` property.
        XCTAssertEqual(result.first, model.selectedResult)
    }
    
    @MainActor
    func testCommitSearch() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // No search - searchOutcome is nil.
        XCTAssertNil(model.searchOutcome)
        
        // Search with no results - result count is 0.
        model.currentQuery = "No results found blah blah blah blah"
        
        model.commitSearch()
        
        var results = try await model.searchResults()
        var result = try XCTUnwrap(results)
        XCTAssertEqual(result, [])
        XCTAssertNil(model.selectedResult)
        
        // Search with one result.
        model.currentQuery = "Magers & Quinn Booksellers"
        
        model.commitSearch()
        
        results = try await model.searchResults()
        result = try XCTUnwrap(results)
        XCTAssertEqual(result.count, 1)
        
        // One results automatically populates `selectedResult`.
        XCTAssertEqual(result.first, model.selectedResult)
        
        // Search with multiple results.
        model.currentQuery = "Magers & Quinn"
        
        model.commitSearch()
        
        results = try await model.searchResults()
        result = try XCTUnwrap(results)
        XCTAssertGreaterThan(result.count, 1)
        
        XCTAssertNil(model.selectedResult)
        
        model.selectedResult = result.first!
        
        model.commitSearch()
        
        results = try await model.searchResults(dropFirst: true)
        result = try XCTUnwrap(results)
        XCTAssertGreaterThan(result.count, 1)
        
        XCTAssertNil(model.selectedResult)
    }
    
    @MainActor
    func testCurrentQuery() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // Empty `currentQuery` should produce nil searchOutcome.
        model.currentQuery = ""
        XCTAssertNil(model.searchOutcome)
        
        // Valid `currentQuery` should produce non-nil results.
        model.currentQuery = "Coffee"
        
        model.commitSearch()
        
        let results = try await model.searchResults()
        XCTAssertNotNil(results)
        
        // Changing the `currentQuery` should set searchOutcome to nil.
        model.currentQuery = "Coffee in Portland"
        XCTAssertNil(model.searchOutcome)
        
        model.updateSuggestions()
        
        let suggestions = try await model.searchSuggestions()
        XCTAssertNotNil(suggestions)
        
        // Changing current query after search with 1 result
        // should set `selectedResult` to nil
        model.currentQuery = "Magers & Quinn Bookseller"
        
        model.commitSearch()
        
        _ = try await model.searchResults(dropFirst: true)
        XCTAssertNotNil(model.selectedResult)
        model.currentQuery = "Hotel"
        XCTAssertNil(model.selectedResult)
    }
    
    @MainActor
    func testIsEligibleForRequery() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // Set queryArea to Chippewa Falls
        model.queryArea = Polygon.chippewaFalls
        model.geoViewExtent = Polygon.chippewaFalls.extent
        model.currentQuery = "Coffee"
        
        // This is necessary for the model to compute `isEligibleForRequery`.
        model.isGeoViewNavigating = true
        
        model.commitSearch()
        
        _ = try await model.searchResults()
        XCTAssertFalse(model.isEligibleForRequery)
        
        // Offset extent by 10% - isEligibleForRequery should still be `false`.
        var builder = EnvelopeBuilder(envelope: model.geoViewExtent!)
        let tenPercentWidth = model.geoViewExtent!.width * 0.1
        builder.offsetBy(x: tenPercentWidth, y: 0.0)
        var newExtent = builder.toGeometry()
        
        model.geoViewExtent = newExtent
        XCTAssertFalse(model.isEligibleForRequery)
        
        // Offset extent by 50% - isEligibleForRequery should now be `true`.
        builder = EnvelopeBuilder(envelope: model.geoViewExtent!)
        let fiftyPercentWidth = model.geoViewExtent!.width * 0.5
        builder.offsetBy(x: fiftyPercentWidth, y: 0.0)
        newExtent = builder.toGeometry()
        
        model.geoViewExtent = newExtent
        XCTAssertTrue(model.isEligibleForRequery)
        
        // Set queryArea to Chippewa Falls
        model.queryArea = Polygon.chippewaFalls
        model.geoViewExtent = Polygon.chippewaFalls.extent
        
        model.commitSearch()
        
        _ = try await model.searchResults(dropFirst: true)
        XCTAssertFalse(model.isEligibleForRequery)
        
        // Expand extent by 1.1x - isEligibleForRequery should still be `false`.
        builder = EnvelopeBuilder(envelope: model.geoViewExtent!)
        builder.expand(by: 1.1)
        newExtent = builder.toGeometry()
        
        model.geoViewExtent = newExtent
        XCTAssertFalse(model.isEligibleForRequery)
        
        // Expand extent by 1.5x - isEligibleForRequery should now be `true`.
        builder = EnvelopeBuilder(envelope: model.geoViewExtent!)
        builder.expand(by: 1.5)
        newExtent = builder.toGeometry()
        
        model.geoViewExtent = newExtent
        XCTAssertTrue(model.isEligibleForRequery)
    }
    
    @MainActor
    func testQueryArea() async throws {
        let source = LocatorSearchSource()
        source.maximumResults = .max
        let model = SearchViewModel(sources: [source])
        
        // Set queryArea to Chippewa Falls
        model.queryArea = Polygon.chippewaFalls
        model.currentQuery = "Coffee"
        
        model.commitSearch()
        
        var results = try await model.searchResults()
        var result = try XCTUnwrap(results)
        XCTAssertGreaterThan(result.count, 1)
        
        let resultGeometryUnion: Geometry = try XCTUnwrap(
            GeometryEngine.union(
                of: result.compactMap { $0.geoElement?.geometry }
            )
        )
        
        XCTAssertTrue(
            GeometryEngine.doesGeometry(
                model.queryArea!,
                contain: resultGeometryUnion
            )
        )
        
        model.currentQuery = "Magers & Quinn Booksellers"
        
        model.commitSearch()
        
        results = try await model.searchResults()
        result = try XCTUnwrap(results)
        XCTAssertEqual(result, [])
        
        model.queryArea = Polygon.minneapolis
        
        model.commitSearch()
        
        // A note about the use of `.dropFirst()`:
        // Because `model.searchOutcome` is not changed between the previous call
        // to `model.commitSearch()` and the one right above, the
        // `try await model.searchOutCome...` call will return the last result
        // received (from the first `model.commitSearch()` call), which is
        // incorrect.  Calling `.dropFirst()` will remove that one
        // and will give us the next one, which is the correct one (the result
        // from the second `model.commitSearch()` call).
        results = try await model.searchResults(dropFirst: true)
        result = try XCTUnwrap(results)
        XCTAssertEqual(result.count, 1)
    }
    
    @MainActor
    func testQueryCenter() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // Set queryCenter to Portland
        model.queryCenter = .portland
        model.currentQuery = "Coffee"
        
        model.commitSearch()
        
        var results = try await model.searchResults()
        var result = try XCTUnwrap(results)
        
        var resultPoint = try XCTUnwrap(
            result.first?.geoElement?.geometry as? Point
        )
        
        var geodeticDistance = try XCTUnwrap (
            GeometryEngine.geodeticDistance(
                from: .portland,
                to: resultPoint,
                distanceUnit: .meters,
                azimuthUnit: nil,
                curveType: .geodesic
            )
        )
        
        // First result within 1500m of Portland.
        XCTAssertLessThan(geodeticDistance.distance.value,  1500)
        
        // Set queryCenter to Edinburgh
        model.queryCenter = .edinburgh
        model.currentQuery = "Restaurants"
        
        model.commitSearch()
        
        results = try await model.searchResults()
        result = try XCTUnwrap(results)
        
        resultPoint = try XCTUnwrap(
            result.first?.geoElement?.geometry as? Point
        )
        
        // Web Mercator distance between .edinburgh and first result.
        geodeticDistance = try XCTUnwrap (
            GeometryEngine.geodeticDistance(
                from: .edinburgh,
                to: resultPoint,
                distanceUnit: .meters,
                azimuthUnit: nil,
                curveType: .geodesic
            )
        )
        
        // First result within 100m of Edinburgh.
        XCTAssertLessThan(geodeticDistance.distance.value,  100)
    }
    
    @MainActor
    func testRepeatSearch() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // Set queryArea to Chippewa Falls
        model.geoViewExtent = Polygon.chippewaFalls.extent
        model.currentQuery = "Coffee"
        
        model.repeatSearch()
        
        var results = try await model.searchResults()
        var result = try XCTUnwrap(results)
        XCTAssertGreaterThan(result.count, 1)
        
        let resultGeometryUnion: Geometry = try XCTUnwrap(
            GeometryEngine.union(
                of: result.compactMap { $0.geoElement?.geometry }
            )
        )
        
        XCTAssertTrue(
            GeometryEngine.doesGeometry(
                model.geoViewExtent!,
                contain: resultGeometryUnion
            )
        )
        
        model.currentQuery = "Magers & Quinn Booksellers"
        
        model.repeatSearch()
        
        results = try await model.searchResults()
        result = try XCTUnwrap(results)
        XCTAssertEqual(result.count, 0)
        
        model.geoViewExtent = Polygon.minneapolis.extent
        
        model.repeatSearch()
        
        results = try await model.searchResults(dropFirst: true)
        result = try XCTUnwrap(results)
        XCTAssertEqual(result.count, 1)
    }
    
    @MainActor
    func testSearchResultMode() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        XCTAssertEqual(model.resultMode, .automatic)
        
        model.resultMode = .single
        model.currentQuery = "Magers & Quinn"
        
        model.commitSearch()
        
        var results = try await model.searchResults()
        var result = try XCTUnwrap(results)
        XCTAssertEqual(result.count, 1)
        
        model.resultMode = .multiple
        
        model.commitSearch()
        
        results = try await model.searchResults(dropFirst: true)
        result = try XCTUnwrap(results)
        XCTAssertGreaterThan(result.count, 1)
        
        model.currentQuery = "Coffee"
        
        model.updateSuggestions()
        
        let suggestionResults = try await model.searchSuggestions()
        let suggestions = try XCTUnwrap(suggestionResults)
        
        let collectionSuggestion = try XCTUnwrap(suggestions.filter(\.isCollection).first)
        let singleSuggestion = try XCTUnwrap(suggestions.filter { !$0.isCollection }.first)
        
        model.resultMode = .automatic
        
        model.acceptSuggestion(collectionSuggestion)
        
        results = try await model.searchResults(dropFirst: true)
        result = try XCTUnwrap(results)
        XCTAssertGreaterThan(result.count, 1)
        
        model.acceptSuggestion(singleSuggestion)
        
        results = try await model.searchResults()
        result = try XCTUnwrap(results)
        XCTAssertEqual(result.count, 1)
    }
    
    @MainActor
    func testUpdateSuggestions() async throws {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        
        // No currentQuery - suggestions are nil.
        XCTAssertNil(model.searchOutcome)
        
        // UpdateSuggestions with no results - result count is 0.
        model.currentQuery = "No results found blah blah blah blah"
        
        model.updateSuggestions()
        
        var suggestionResults = try await model.searchSuggestions()
        var suggestions = try XCTUnwrap(suggestionResults)
        XCTAssertEqual(suggestions, [])
        
        // UpdateSuggestions with results.
        model.currentQuery = "Magers & Quinn"
        
        model.updateSuggestions()
        
        suggestionResults = try await model.searchSuggestions(dropFirst: true)
        suggestions = try XCTUnwrap(suggestionResults)
        XCTAssertGreaterThanOrEqual(suggestions.count, 1)
        
        XCTAssertNil(model.selectedResult)
    }
}

private extension ArcGIS.Polygon {
    class var chippewaFalls: ArcGIS.Polygon {
        let points = [
            Point(x: -91.59127653822401, y: 44.74770908213401),
            Point(x: -91.19322516572637, y: 44.74770908213401),
            Point(x: -91.19322516572637, y: 45.116100854348254),
            Point(x: -91.59127653822401, y: 45.116100854348254)
        ]
        return .init(points: points, spatialReference: .wgs84)
    }
    
    class var minneapolis: ArcGIS.Polygon {
        let points = [
            Point(x: -94.170821328662, y: 44.13656401114444),
            Point(x: -94.170821328662, y: 44.13656401114444),
            Point(x: -92.34544467133114, y: 45.824325577904446),
            Point(x: -92.34544467133114, y: 45.824325577904446)
        ]
        return .init(points: points, spatialReference: .wgs84)
    }
}

private extension Point {
    class var edinburgh: Point {
        .init(x: -3.188267, y: 55.953251, spatialReference: .wgs84)
    }
    class var portland: Point {
        .init(x: -122.658722, y: 45.512230, spatialReference: .wgs84)
    }
}

private extension SearchViewModel {
    func searchResults(dropFirst: Bool = false) async throws -> [SearchResult]? {
        let searchOutcome = try await $searchOutcome
            .compactMap { $0 }
            .dropFirst(dropFirst ? 1 : 0)
            .first
        
        switch searchOutcome {
        case .results(let results):
            return results
        default:
            return nil
        }
    }
    
    func searchSuggestions(dropFirst: Bool = false) async throws -> [SearchSuggestion]? {
        let searchOutcome = try await $searchOutcome
            .compactMap { $0 }
            .dropFirst(dropFirst ? 1 : 0)
            .first
        
        switch searchOutcome {
        case .suggestions(let suggestions):
            return suggestions
        default:
            return nil
        }
    }
}
