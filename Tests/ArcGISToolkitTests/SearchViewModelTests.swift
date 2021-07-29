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

class SearchViewModelTests: XCTestCase {
    func testIsEligibleForRequery() {
        let model = SearchViewModel()
        XCTAssertFalse(model.isEligibleForRequery)

        model.queryArea = createPolygon()
        XCTAssertFalse(model.isEligibleForRequery)

        model.results = .success([])
        model.queryArea = createPolygon()
        XCTAssertTrue(model.isEligibleForRequery)
    }
    
    func testCommitSearch() {
        let model = SearchViewModel(sources: [LocatorSearchSource()])
        XCTAssertEqual(model.sources.count, 1)
        
        model.currentQuery = "London"
        let result = await model.commitSearch(false)

        model.queryArea = createPolygon()
        XCTAssertFalse(model.isEligibleForRequery)

        model.results = .success([])
        model.queryArea = createPolygon()
        XCTAssertTrue(model.isEligibleForRequery)
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
    static let paris = Point(x: 2.23522, y: 48.8566, spatialReference: .wgs84)
    static let rome = Point(x: 12.4964, y: 41.9028, spatialReference: .wgs84)
    static let london = Point(x: -0.1278, y: 51.5074, spatialReference: .wgs84)
}
