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

class SearchViewModelTests: XCTestCase {
***REMOVED***func testIsEligibleForRequery() {
***REMOVED******REMOVED***let model = SearchViewModel()
***REMOVED******REMOVED***XCTAssertFalse(model.isEligibleForRequery)

***REMOVED******REMOVED***model.queryArea = createPolygon()
***REMOVED******REMOVED***XCTAssertFalse(model.isEligibleForRequery)

***REMOVED******REMOVED***model.results = .success([])
***REMOVED******REMOVED***model.queryArea = createPolygon()
***REMOVED******REMOVED***XCTAssertTrue(model.isEligibleForRequery)
***REMOVED***
***REMOVED***
***REMOVED***func testCommitSearch() {
***REMOVED******REMOVED***let model = SearchViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***XCTAssertEqual(model.sources.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "London"
***REMOVED******REMOVED***let result = await model.commitSearch(false)

***REMOVED******REMOVED***model.queryArea = createPolygon()
***REMOVED******REMOVED***XCTAssertFalse(model.isEligibleForRequery)

***REMOVED******REMOVED***model.results = .success([])
***REMOVED******REMOVED***model.queryArea = createPolygon()
***REMOVED******REMOVED***XCTAssertTrue(model.isEligibleForRequery)
***REMOVED***
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
