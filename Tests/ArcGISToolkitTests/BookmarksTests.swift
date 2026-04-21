// Copyright 2022 Esri
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
import SwiftUI
import XCTest
@testable import ArcGISToolkit

final class BookmarksTests: XCTestCase {
    @MainActor
    func testBookmarksWithGeoModel() async throws {
        var _isPresented = true
        var _selection: Bookmark?
        
        let map = Map.portlandTreeSurvey
        let bookmarks = Bookmarks(
            isPresented: Binding(get: { _isPresented }, set: { _isPresented = $0 }),
            geoModel: map,
            selection: Binding(get: { _selection }, set: { _selection = $0 }),
            geoViewProxy: nil
        )
        
        do {
            try await map.load()
        } catch {
            XCTFail("Web map failed to load \(error.localizedDescription)")
        }
        
        bookmarks.selectBookmark(map.bookmarks.first!)
        
        XCTAssertFalse(_isPresented)
        XCTAssertEqual(_selection, map.bookmarks.first)
    }
    
    @MainActor
    func testBookmarksWithList() {
        var _isPresented = true
        var _selection: Bookmark?
        
        let bookmarks = Bookmarks(
            isPresented: Binding(get: { _isPresented }, set: { _isPresented = $0 }),
            bookmarks: sampleBookmarks,
            selection: Binding(get: { _selection }, set: { _selection = $0 })
        )
        
        bookmarks.selectBookmark(sampleBookmarks.first!)
        
        XCTAssertFalse(_isPresented)
        XCTAssertEqual(_selection, sampleBookmarks.first)
    }
}

private extension BookmarksTests {
    /// A list of sample bookmarks for testing.
    var sampleBookmarks: [Bookmark] {[
        Bookmark(
            name: "Yosemite National Park",
            viewpoint: Viewpoint(
                center: Point(
                    x: -119.538330,
                    y: 37.865101,
                    spatialReference: .wgs84
                ),
                scale: 250_000
            )
        ),
        Bookmark(
            name: "Zion National Park",
            viewpoint: Viewpoint(
                center: Point(
                    x: -113.028770,
                    y: 37.297817,
                    spatialReference: .wgs84
                ),
                scale: 250_000
            )
        ),
        Bookmark(
            name: "Yellowstone National Park",
            viewpoint: Viewpoint(
                center: Point(
                    x: -110.584663,
                    y: 44.429764,
                    spatialReference: .wgs84
                ),
                scale: 375_000
            )
        ),
        Bookmark(
            name: "Grand Canyon National Park",
            viewpoint: Viewpoint(
                center: Point(
                    x: -112.1129,
                    y: 36.1069,
                    spatialReference: .wgs84
                ),
                scale: 375_000
            )
        ),
    ]}
}

private extension Map {
    /// A web map authored with bookmarks for testing.
    static let portlandTreeSurvey = Map(url: URL(string: "https://www.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!
}

private extension Viewpoint {
    static let esriRedlandsCampus = Viewpoint(
        center: Point(
            x: -117.19494,
            y: 34.05723,
            spatialReference: .wgs84
        ),
        scale: 10_000.00,
        rotation: .zero
    )
}
