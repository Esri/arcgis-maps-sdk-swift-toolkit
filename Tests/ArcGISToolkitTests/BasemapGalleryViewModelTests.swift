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

//
// Test Design: https://devtopia.esri.com/runtime/common-toolkit/blob/master/designs/BasemapGallery/BasemapGallery_Test_Design.md
//
// Note:  the iOS implementation uses the MVVM approach and SwiftUI.  This
// required a bit more properties/logic in the `BasemapGalleryViewModel` (such
// as `geoModel.actualSpatialReference`) than the `BasemapGallery` design
// specifies.  Tests not present in the test design have been added to
// accomodate those differences.
@MainActor
class BasemapGalleryViewModelTests: XCTestCase {
    let defaultBasemapGalleryItems: [BasemapGalleryItem] = [
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

    func testInit() async throws {
        // Note:  this is a good candidate for mocking portal data.
        // This would allow the test to check for a specific number of items.
        
        // GeoModel.
        let geoModel = Map(basemap: Basemap.streets())
        let geoModelViewModel = BasemapGalleryViewModel(geoModel: geoModel)
        
        // With no portal, `basemapGalleryItems` are fetched from AGOL's
        // list of developer basemaps.
        var items = try await geoModelViewModel.$basemapGalleryItems.compactMap({ $0 }).dropFirst().first
        var basemapGalleryItems = try XCTUnwrap(items)
        XCTAssertFalse(basemapGalleryItems.isEmpty)
        
        let developerBasemapItems = basemapGalleryItems
        
        // Portal.
        let portalViewModel = BasemapGalleryViewModel(
            portal: Portal.arcGISOnline(isLoginRequired: false)
        )

        // With a portal, `basemapGalleryItems` are fetched from either the
        // portal's vector basemaps or regular basemaps.
        items = try await portalViewModel.$basemapGalleryItems.compactMap({ $0 }).dropFirst().first
        basemapGalleryItems = try XCTUnwrap(items)
        XCTAssertFalse(basemapGalleryItems.isEmpty)

        // Sort the developer items from the "GeoModel" test above and the
        // items from the portal and make sure they are not equal.
        let sortedItems = basemapGalleryItems.sorted { $0.name < $1.name }
        let sortedDeveloperItems = developerBasemapItems.sorted { $0.name < $1.name }
        XCTAssertNotEqual(sortedItems, sortedDeveloperItems)

        // BasemapGalleryItems.  No basemaps are fetched from a portal.
        let itemsViewModel = BasemapGalleryViewModel(
            basemapGalleryItems: defaultBasemapGalleryItems
        )
        
        // The item counts should match.
        XCTAssertEqual(
            itemsViewModel.basemapGalleryItems.count,
            defaultBasemapGalleryItems.count
        )
        
        // Both Portal and BasemapGalleryItems.  Basemaps are fetched from
        // the portal and appended to the list of basemapGalleryItems.
        let viewModel = BasemapGalleryViewModel(
            portal: Portal.arcGISOnline(isLoginRequired: false),
            basemapGalleryItems: defaultBasemapGalleryItems
        )

        items  = try await viewModel.$basemapGalleryItems.compactMap({ $0 }).dropFirst().first
        basemapGalleryItems = try XCTUnwrap(items)
        
        // Count will be greater than the number of hardcoded items.
        XCTAssertGreaterThan(basemapGalleryItems.count, defaultBasemapGalleryItems.count)
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
        let geoModel3 = Scene(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
                )!
            )
        )

        try await geoModel3.load()
        XCTAssertEqual(geoModel3.actualSpatialReference, .webMercator)
    }
    
    func testCurrentBasemapGalleryItem() async throws {
        let basemap = Basemap.streets()
        let geoModel = Map(basemap: basemap)

        let viewModel = BasemapGalleryViewModel(geoModel: geoModel)
        
        // Verify current item is equal to map's basemap.
        var item = try await viewModel.$currentBasemapGalleryItem.compactMap({ $0 }).first
        var currentItem = try XCTUnwrap(item)
        XCTAssertTrue(currentItem.basemap === basemap)

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
        item = try await viewModel.$currentBasemapGalleryItem.compactMap({ $0 }).dropFirst().first
        currentItem = try XCTUnwrap(item)
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
    
    func testUpdatePortal() async throws {
        // Note:  this is a good candidate for mocking portal data.
        // This would allow the test to check for a specific number of items.

        let viewModel = BasemapGalleryViewModel(
            basemapGalleryItems: defaultBasemapGalleryItems
        )

        var items = try await viewModel.$basemapGalleryItems.compactMap({ $0 }).first
        var basemapGalleryItems = try XCTUnwrap(items)
        
        // There are exactly two default items.
        XCTAssertEqual(basemapGalleryItems.count, 2)

        viewModel.portal = Portal.arcGISOnline(isLoginRequired: false)
        
        items = try await viewModel.$basemapGalleryItems.compactMap({ $0 }).dropFirst().first
        basemapGalleryItems = try XCTUnwrap(items)

        // There should be no default items in the basemap gallery.
        let foundDefaultItem = basemapGalleryItems.first(where: {
            $0 == defaultBasemapGalleryItems[0] ||
            $0 == defaultBasemapGalleryItems[1]
        })
        XCTAssertNil(foundDefaultItem)
    }
}
