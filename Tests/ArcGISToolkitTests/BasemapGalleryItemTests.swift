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

import Foundation

import XCTest
import ArcGIS
@testable import ArcGISToolkit
import SwiftUI
import Combine

// Note:  the iOS implementation uses the MVVM approach and SwiftUI. This
// required a bit more properties/logic in the 'BasemapGalleryItem' (such
// as the 'loadBasemapError' and 'spatialReferenceStatus' properties than
// the 'BasemapGallery' design specifies. Tests not present in the
// test design have been added to accommodate those differences.
final class BasemapGalleryItemTests: XCTestCase {
    override func setUp() async throws {
        ArcGISEnvironment.apiKey = .default
    }
    
    override func tearDown() {
        ArcGISEnvironment.apiKey = nil
    }
    
    func testInit() async throws {
        let basemap = Basemap(style: .arcGISLightGray)
        let item = BasemapGalleryItem(basemap: basemap)
        
        let isBasemapLoading = try await item.$isBasemapLoading.dropFirst().first
        let loading = try XCTUnwrap(isBasemapLoading)
        XCTAssertFalse(loading, "Item is not loading.")
        XCTAssertIdentical(item.basemap, basemap)
        XCTAssertEqual(item.name, "ArcGIS Light Gray")
        XCTAssertNil(item.description)
        XCTAssertNotNil(item.thumbnail)
        XCTAssertNil(item.loadBasemapError)
        
        // Test with overrides.
        let thumbnail = UIImage(systemName: "magnifyingglass")!
        let basemap2 = Basemap(style: .arcGISLightGray)
        let item2 = BasemapGalleryItem(
            basemap: basemap2,
            name: "My Basemap",
            description: "Basemap description",
            thumbnail: thumbnail
        )
        
        let isBasemapLoading2 = try await item2.$isBasemapLoading.dropFirst().first
        let loading2 = try XCTUnwrap(isBasemapLoading2)
        XCTAssertFalse(loading2, "Item is not loading.")
        XCTAssertEqual(item2.name, "My Basemap")
        XCTAssertEqual(item2.description, "Basemap description")
        XCTAssertEqual(item2.thumbnail, thumbnail)
        XCTAssertNil(item2.loadBasemapError)
        
        // Test with portal item.
        let item3 = BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
                )!
            )
        )
        
        let isBasemapLoading3 = try await item3.$isBasemapLoading.dropFirst().first
        let loading3 = try XCTUnwrap(isBasemapLoading3)
        XCTAssertFalse(loading3, "Item is not loading.")
        XCTAssertEqual(item3.name, "OpenStreetMap (Blueprint)")
        XCTAssertNotNil(item3.description)
        XCTAssertNotNil(item3.thumbnail)
        XCTAssertNil(item3.loadBasemapError)
    }
    
    func testLoadBasemapError() async throws {
        // Create item with bad portal item URL.
        let item = BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://arcgis.com/home/item.html?id=4a3922d6d15f405d8c2b7a448a7fbad2")!
                )!
            )
        )
        
        let isBasemapLoading = try await item.$isBasemapLoading.dropFirst().first
        let loading = try XCTUnwrap(isBasemapLoading)
        XCTAssertFalse(loading, "Item is not loading.")
        XCTAssertNotNil(item.loadBasemapError)
    }
    
    func testSpatialReferenceAndStatus() async throws {
        let basemap = Basemap(style: .arcGISLightGray)
        let item = BasemapGalleryItem(basemap: basemap)
        
        let isBasemapLoading = try await item.$isBasemapLoading.dropFirst().first
        let loading = try XCTUnwrap(isBasemapLoading)
        XCTAssertFalse(loading, "Item is not loading.")
        
        XCTAssertEqual(item.spatialReferenceStatus, .unknown)
        
        // Test if basemap matches. Use a Task here so we can catch and test
        // the change to `item.isBasemapLoading` during the loading of the base layers.
        Task {
            try await item.updateSpatialReferenceStatus(SpatialReference.webMercator)
        }
        
        // Check if `isBasemapLoading` is set to true during first call
        // to `updateSpatialReferenceStatus`.
        let isBasemapLoading2 = try await item.$isBasemapLoading.dropFirst().first
        let loading2 = try XCTUnwrap(isBasemapLoading2)
        XCTAssertTrue(loading2, "Item base layers are loading.")
        
        let srStatus = try await item.$spatialReferenceStatus.dropFirst().first
        let status = try XCTUnwrap(srStatus)
        XCTAssertEqual(status, .match)
        XCTAssertEqual(item.spatialReference, SpatialReference.webMercator)
        XCTAssertFalse(item.isBasemapLoading)
        
        // Test if basemap doesn't match.
        try await item.updateSpatialReferenceStatus(.wgs84)
        
        // Since we've already called `updateSpatialReferenceStatus` once,
        // we should no longer internally need to load the base layers.
        let isBasemapLoading3 = try await item.$isBasemapLoading.first
        let loading3 = try XCTUnwrap(isBasemapLoading3)
        XCTAssertFalse(loading3, "Item base layers are not loading.")
        
        let srStatus2 = try await item.$spatialReferenceStatus.first
        let status2 = try XCTUnwrap(srStatus2)
        XCTAssertEqual(status2, .noMatch)
        XCTAssertEqual(item.spatialReference, .webMercator)
        
        // Test WGS84 basemap.
        let otherItem = BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
                )!
            )
        )
        
        _ = try await otherItem.$isBasemapLoading.dropFirst().first
        
        try await otherItem.updateSpatialReferenceStatus(.wgs84)
        let srStatus3 = try await otherItem.$spatialReferenceStatus.first
        let status3 = try XCTUnwrap(srStatus3)
        XCTAssertEqual(status3, .match)
        XCTAssertEqual(otherItem.spatialReference, .wgs84)
    }
}
