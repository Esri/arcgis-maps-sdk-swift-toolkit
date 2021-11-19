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
@testable import ArcGISToolkit
import SwiftUI
import Combine

@MainActor
class BasemapGalleryViewModelTests: XCTestCase {
    let basemapGalleryItems: [BasemapGalleryItem] = [
        BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
                )!
            )
        ),
        BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=f33a34de3a294590ab48f246e99958c9")!
                )!
            )
        )
    ]
    
    //
    // Test Design: https://devtopia.esri.com/runtime/common-toolkit/blob/master/designs/BasemapGallery/BasemapGallery_Test_Design.md
    //
    func testInit() async throws {
        // Note:  this is a good candidate for mocking portal data.
        // This would allow the test to check for a specific number of items
        // in both the "Portal" and "Both" sections.

        // Portal.
        let portalViewModel = BasemapGalleryViewModel(
            portal: Portal.arcGISOnline(isLoginRequired: false)
        )

        var bgItems = try await portalViewModel.$basemapGalleryItems.compactMap({ $0 }).dropFirst().first
        var items = try XCTUnwrap(bgItems)
        
        // There will be greater than 10 basemaps in the portal.
        XCTAssertGreaterThan(items.count, 10)

        // BasemapGalleryItems.
        let itemsViewModel = BasemapGalleryViewModel(
            basemapGalleryItems: basemapGalleryItems
        )
        
        // The item counts should match.
        XCTAssertEqual(
            itemsViewModel.basemapGalleryItems.count,
            basemapGalleryItems.count
        )
        
        // Both Portal and BasemapGalleryItems.
        let viewModel = BasemapGalleryViewModel(
            portal: Portal.arcGISOnline(isLoginRequired: false),
            basemapGalleryItems: basemapGalleryItems
        )

        bgItems  = try await viewModel.$basemapGalleryItems.compactMap({ $0 }).dropFirst().first
        items = try XCTUnwrap(bgItems)
        
        // Count will be greater than the number of hardcoded items.
        XCTAssertGreaterThan(items.count, basemapGalleryItems.count)
    }
    
    func testGeoModelActualSpatialReference() async throws {
        // Map with .webMercator basemap.
        let geoModel = Map(basemap: Basemap.streets())
        try await geoModel.load()
        XCTAssertEqual(geoModel.actualSpatialReference, .webMercator)
        
        // Map with .wgs84 basemap.
        let geoModel2 = Map(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
                )!
            )
        )

        try await geoModel2.load()
        XCTAssertEqual(geoModel2.actualSpatialReference, .wgs84)

        // Test with Scene that has a tiling scheme of .webMercator
        // but a different spatial reference...
    }
    
    func testCurrentBasemapItem() async throws {
        let geoModel = Map(basemap: Basemap.streets())

        let viewModel = BasemapGalleryViewModel(geoModel: geoModel)
        
        // Test valid basemap item (OpenStreetMap Vector Basemap (Blueprint)).
        let validItem = BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
                )!
            )
        )
        
        // Wait until it loads.
        _ = try await validItem.$isLoading.compactMap({ $0 }).dropFirst().first

        viewModel.updateCurrentBasemapGalleryItem(validItem)
        
        // Wait until the `currentBasemapGalleryItem` is updated.
        let tmpItem = try await viewModel.$currentBasemapGalleryItem.compactMap({ $0 }).dropFirst().first
        let currentItem = try XCTUnwrap(tmpItem)
        XCTAssertEqual(currentItem, validItem)
    
        // Test WGS84 basemap item (Imagery (WGS84)).
        let invalidItem = BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
                )!
            )
        )
        
        // Wait until it loads.
        _ = try await invalidItem.$isLoading.compactMap({ $0 }).dropFirst().first

        viewModel.updateCurrentBasemapGalleryItem(invalidItem)

        // The update will fail, so wait until the
        // `$spatialReferenceMismatchError` is updated.
        let error = try await viewModel.$spatialReferenceMismatchError.compactMap({ $0 }).first
        XCTAssertNotNil(error, "Error is not nil.")
        
        // Make sure the current item is still equal to the valid item.
        XCTAssertEqual(currentItem, validItem)
    }
}
