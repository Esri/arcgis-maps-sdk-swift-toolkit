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
// Note:  the iOS implementation uses the MVVM approach and SwiftUI. This
// required a bit more properties/logic in the `BasemapGalleryViewModel` (such
// as `geoModel.actualSpatialReference`) than the `BasemapGallery` design
// specifies. Tests not present in the test design have been added to
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
    
    /// Test the various constructor methods.
    func testInit() async throws {
        // Note:  this is a good candidate for mocking portal data.
        // This would allow the test to check for a specific number of items.
        
        //
        // GeoModel.
        //
        var geoModel = Map(basemap: Basemap.lightGrayCanvas())
        let geoModelViewModel = BasemapGalleryViewModel(geoModel)
        XCTAssertTrue(geoModel === geoModelViewModel.geoModel)
        
        // With no portal, `basemapGalleryItems` are fetched from AGOL's
        // list of developer basemaps.
        var items = try await geoModelViewModel.$basemapGalleryItems.compactMap({ $0 }).dropFirst().first
        var basemapGalleryItems = try XCTUnwrap(items)
        XCTAssertFalse(basemapGalleryItems.isEmpty)
        
        // GeoModel should be loaded.
        XCTAssertEqual(geoModel.loadStatus, .loaded)
        XCTAssertTrue(geoModel.basemap === geoModelViewModel.currentBasemapGalleryItem?.basemap)

        // Save the array of developer basemap items from AGOL.
        let developerBasemapItems = basemapGalleryItems
        
        //
        // Portal.
        //
        geoModel = Map(basemap: Basemap.lightGrayCanvas())
        let portal = Portal.arcGISOnline(isLoginRequired: false)
        let portalViewModel = BasemapGalleryViewModel(geoModel, portal: portal)
        
        XCTAssertTrue(geoModel === portalViewModel.geoModel)
        XCTAssertTrue(portal === portalViewModel.portal)

        // With a portal, `basemapGalleryItems` are fetched from either the
        // portal's vector basemaps or regular basemaps.
        items = try await portalViewModel.$basemapGalleryItems.compactMap({ $0 }).dropFirst().first
        basemapGalleryItems = try XCTUnwrap(items)
        XCTAssertFalse(basemapGalleryItems.isEmpty)

        XCTAssertEqual(geoModel.loadStatus, .loaded)
        XCTAssertTrue(geoModel.basemap === portalViewModel.currentBasemapGalleryItem?.basemap)

        // Sort the developer items from the "GeoModel" test above and the
        // items from the portal and make sure they are not equal.
        let sortedItems = basemapGalleryItems.sorted { $0.name < $1.name }
        let sortedDeveloperItems = developerBasemapItems.sorted { $0.name < $1.name }
        XCTAssertNotEqual(sortedItems, sortedDeveloperItems)

        //
        // BasemapGalleryItems. No basemaps are fetched from a portal.
        //
        geoModel = Map(basemap: Basemap.lightGrayCanvas())
        let itemsViewModel = BasemapGalleryViewModel(
            geoModel,
            basemapGalleryItems: defaultBasemapGalleryItems
        )

        // The item counts should match.
        XCTAssertEqual(
            itemsViewModel.basemapGalleryItems.count,
            defaultBasemapGalleryItems.count
        )
    }
    
    /// Test the `GeoModel.actualSpatialReference` extension property.
    func testGeoModelActualSpatialReference() async throws {
        // Map with .webMercator basemap.
        let geoModel = Map(basemap: Basemap.lightGrayCanvas())
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
        
        // Test with Scene that has a tiling scheme of .wgs84
        let geoModel4 = Scene(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
                )!
            )
        )
        try await geoModel4.load()
        XCTAssertEqual(geoModel4.actualSpatialReference, .wgs84)
    }
    
    /// Test the `currentBasemapGalleryItem` property including valid and invalid basemaps.
    func testCurrentBasemapGalleryItem() async throws {
        let basemap = Basemap.streets()
        let geoModel = Map(basemap: basemap)

        let viewModel = BasemapGalleryViewModel(geoModel)
        
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

        // Update the item on the model.
        viewModel.updateCurrentBasemapGalleryItem(validItem)
        
        // Wait until the `currentBasemapGalleryItem` is updated.
        item = try await viewModel.$currentBasemapGalleryItem.compactMap({ $0 }).dropFirst().first
        currentItem = try XCTUnwrap(item)
        
        // Items should equal, meaning the `validItem` was set properly.
        XCTAssertEqual(currentItem, validItem)
    
        // Test WGS84 basemap item (Imagery (WGS84)).  This item is in a
        // different spatial reference than the geoModel, so it should
        // not be set as the current item.
        let invalidItem = BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://runtime.maps.arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
                )!
            )
        )
        
        // Wait until it loads.
        _ = try await invalidItem.$isLoading.compactMap({ $0 }).dropFirst().first

        // Update the item on the model.
        viewModel.updateCurrentBasemapGalleryItem(invalidItem)

        // The update will fail, so wait until the
        // `$spatialReferenceMismatchError` is updated.
        let error = try await viewModel.$spatialReferenceMismatchError.compactMap({ $0 }).first
        XCTAssertNotNil(error, "Error is not nil.")
        
        // Make sure the current item is still equal to the valid item.
        XCTAssertEqual(currentItem, validItem)
    }
    
    /// Test setting the portal after the model has been created.
    func testUpdatePortal() async throws {
        // Create a model with a default list of items.
        let viewModel = BasemapGalleryViewModel(
            basemapGalleryItems: defaultBasemapGalleryItems
        )

        var items = try await viewModel.$basemapGalleryItems.compactMap({ $0 }).first
        var basemapGalleryItems = try XCTUnwrap(items)
        
        // There are exactly two default items.
        XCTAssertEqual(basemapGalleryItems.count, 2)

        // Set a portal on the model.  This should clear out the existing
        // array of items and load basemaps from the portal.
        viewModel.portal = Portal.arcGISOnline(isLoginRequired: false)
        
        // The items should be cleared prior to loading those from the portal.
        items = try await viewModel.$basemapGalleryItems.compactMap({ $0 }).first
        basemapGalleryItems = try XCTUnwrap(items)
        XCTAssertTrue(basemapGalleryItems.isEmpty)

        // Wait for the portal basemaps to load.
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
