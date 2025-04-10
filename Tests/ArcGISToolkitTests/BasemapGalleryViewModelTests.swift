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
@testable import ArcGISToolkit
@preconcurrency import Combine
import XCTest

// Note:  the iOS implementation uses the MVVM approach and SwiftUI. This
// required a bit more properties/logic in the 'BasemapGalleryViewModel' (such
// as 'geoModel.actualSpatialReference') than the 'BasemapGallery' design
// specifies. Tests not present in the test design have been added to
// accommodate those differences.
class BasemapGalleryViewModelTests: XCTestCase {
    override func setUp() async throws {
        ArcGISEnvironment.apiKey = .default
    }
    
    override func tearDown() {
        ArcGISEnvironment.apiKey = nil
    }
    
    @MainActor
    let defaultBasemapGalleryItems: [BasemapGalleryItem] = [
        BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
                )!
            )
        ),
        BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://arcgis.com/home/item.html?id=f33a34de3a294590ab48f246e99958c9")!
                )!
            )
        )
    ]
    
    /// Test the various constructor methods.
    @MainActor
    func testInit() async throws {
        // Note:  this is a good candidate for mocking portal data.
        // This would allow the test to check for a specific number of items.
        
        //
        // GeoModel.
        //
        let geoModel = Map(basemapStyle: .arcGISLightGray)
        let geoModelViewModel = BasemapGalleryViewModel(geoModel: geoModel)
        XCTAssertIdentical(geoModelViewModel.geoModel, geoModel)
        
        // With no portal, `basemapGalleryItems` are fetched from AGOL's
        // list of developer basemaps.
        let items = try await geoModelViewModel.$items.dropFirst().first
        let basemapGalleryItems = try XCTUnwrap(items)
        XCTAssertFalse(basemapGalleryItems.isEmpty)
        
        // GeoModel should be loaded.
        XCTAssertEqual(geoModel.loadStatus, .loaded)
        XCTAssertEqual(geoModelViewModel.currentItem?.basemap.name, geoModel.basemap?.name)
        
        // Save the array of developer basemap items from AGOL.
        let developerBasemapItems = basemapGalleryItems
        
        //
        // Portal.
        //
        let geoModel2 = Map(basemapStyle: .arcGISLightGray)
        let portal = Portal.arcGISOnline(connection: .anonymous)
        let portalViewModel = BasemapGalleryViewModel(geoModel2, portal: portal)
        
        XCTAssertIdentical(portalViewModel.geoModel, geoModel2)
        XCTAssertIdentical(portalViewModel.portal, portal)
        
        // With a portal, `basemapGalleryItems` are fetched from either the
        // portal's vector basemaps or regular basemaps.
        let items2 = try await portalViewModel.$items.dropFirst().first
        let basemapGalleryItems2 = try XCTUnwrap(items2)
        XCTAssertFalse(basemapGalleryItems2.isEmpty)
        
        XCTAssertEqual(geoModel2.loadStatus, .loaded)
        XCTAssertIdentical(portalViewModel.currentItem?.basemap, geoModel2.basemap)
        
        // Sort the developer items from the "GeoModel" test above and the
        // items from the portal and make sure they are not equal.
        let sortedItems = basemapGalleryItems2.sorted {
            guard let name0 = $0.name, let name1 = $1.name else { return false }
            return name0 < name1
        }
        let sortedDeveloperItems = developerBasemapItems.sorted {
            guard let name0 = $0.name, let name1 = $1.name else { return false }
            return name0 < name1
        }
        XCTAssertNotEqual(sortedItems, sortedDeveloperItems)
        
        //
        // BasemapGalleryItems. No basemaps are fetched from a portal.
        //
        let geoModel3 = Map(basemapStyle: .arcGISLightGray)
        let itemsViewModel = BasemapGalleryViewModel(
            geoModel: geoModel3,
            items: defaultBasemapGalleryItems
        )
        
        // The item counts should match.
        XCTAssertEqual(
            itemsViewModel.items.count,
            defaultBasemapGalleryItems.count
        )
    }
    
    /// Test the `GeoModel.actualSpatialReference` extension property.
    func testGeoModelActualSpatialReference() async throws {
        // Map with Web Mercator basemap.
        let geoModel = Map(basemapStyle: .arcGISLightGray)
        try await geoModel.load()
        XCTAssertEqual(geoModel.actualSpatialReference, .webMercator)
        
        // Map with WGS 84 basemap.
        let geoModel2 = Map(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
                )!
            )
        )
        
        try await geoModel2.load()
        XCTAssertEqual(geoModel2.actualSpatialReference, .wgs84)
        
        // Test with Scene that has a tiling scheme of Web Mercator.
        let geoModel3 = Scene(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
                )!
            )
        )
        
        try await geoModel3.load()
        XCTAssertEqual(geoModel3.actualSpatialReference, .webMercator)
        
        // Test with Scene that has a tiling scheme of WGS 84.
        let geoModel4 = Scene(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
                )!
            )
        )
        try await geoModel4.load()
        XCTAssertEqual(geoModel4.actualSpatialReference, .wgs84)
    }
    
    /// Test the `currentItem` property including valid and invalid basemaps.
    @MainActor
    func testCurrentItem() async throws {
        let basemap = Basemap(style: .arcGISStreets)
        let geoModel = Map(basemap: basemap)
        
        let viewModel = BasemapGalleryViewModel(geoModel: geoModel)
        
        // Verify current item is equal to map's basemap.
        let item = try await viewModel.$currentItem.dropFirst().first
        let currentItem = try XCTUnwrap(item)
        XCTAssertIdentical(currentItem?.basemap, basemap)
        
        // Test valid basemap item (OpenStreetMap Vector Basemap (Blueprint)).
        let validItem = BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
                )!
            )
        )
        
        // Wait until it loads.
        _ = try await validItem.$isBasemapLoading.dropFirst().first
        
        // Update the item on the model.
        viewModel.setCurrentItem(validItem)
        
        // Wait until the `currentItem` is updated.
        let item2 = try await viewModel.$currentItem.dropFirst().first
        let currentItem2 = try XCTUnwrap(item2)
        
        // Items should equal, meaning the `validItem` was set properly.
        XCTAssertEqual(currentItem2, validItem)
        
        // Test WGS84 basemap item (Imagery (WGS84)).  This item is in a
        // different spatial reference than the geoModel, so it should
        // not be set as the current item.
        let invalidItem = BasemapGalleryItem(
            basemap: Basemap(
                item: PortalItem(
                    url: URL(string: "https://arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
                )!
            )
        )
        
        // Wait until it loads.
        _ = try await invalidItem.$isBasemapLoading.dropFirst().first
        
        // Update the item on the model.
        viewModel.setCurrentItem(invalidItem)
        
        // The update will fail, so wait until the
        // `spatialReferenceMismatchError` is updated.
        let error = try await viewModel.$spatialReferenceMismatchError.dropFirst().first
        let unwrappedError = try XCTUnwrap(error)
        XCTAssertNotNil(unwrappedError, "Error is not nil.")
        
        // Make sure the current item is still equal to the valid item.
        XCTAssertEqual(currentItem2, validItem)
    }
    
    /// Test setting the portal after the model has been created.
    @MainActor
    func testUpdatePortal() async throws {
        // Create a model with a default list of items.
        let viewModel = BasemapGalleryViewModel(
            items: defaultBasemapGalleryItems
        )
        
        let items = try await viewModel.$items.first
        let basemapGalleryItems = try XCTUnwrap(items)
        
        // There are exactly two default items.
        XCTAssertEqual(basemapGalleryItems.count, 2)
        
        // Set a portal on the model. This should clear out the existing
        // array of items and load basemaps from the portal.
        viewModel.portal = Portal.arcGISOnline(connection: .anonymous)
        
        // The items should be cleared prior to loading those from the portal.
        let items2 = try await viewModel.$items.first
        let basemapGalleryItems2 = try XCTUnwrap(items2)
        XCTAssertTrue(basemapGalleryItems2.isEmpty)
        
        // Wait for the portal basemaps to load.
        let items3 = try await viewModel.$items.dropFirst().first
        let basemapGalleryItems3 = try XCTUnwrap(items3)
        
        // There should be no default items in the basemap gallery.
        XCTAssertFalse(basemapGalleryItems3.contains(where: { item in
            defaultBasemapGalleryItems.contains(item)
        }))
    }
    
    @MainActor
    func testCase_2_4() async throws {
        let basemap = Basemap(style: .arcGISLightGray)
        let scene = Scene(basemap: basemap)
        let viewModel = BasemapGalleryViewModel(geoModel: scene)
        XCTAssertIdentical(scene, viewModel.geoModel)
        
        let item = try await viewModel.$currentItem.dropFirst().first
        let currentItem = try XCTUnwrap(item)
        XCTAssertIdentical(currentItem?.basemap, basemap)
        
        let items = try await viewModel.$items.dropFirst().first
        let basemapGalleryItems = try XCTUnwrap(items)
        XCTAssertFalse(basemapGalleryItems.isEmpty)
        XCTAssertEqual(basemapGalleryItems.count, 37)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in basemapGalleryItems.indices {
                group.addTask {
                    let item = basemapGalleryItems[index]
                    try await item.basemap.load()
                    // With a Scene, only the first 8 basemaps should be 3D.
                    if index <= 7 {
                        XCTAssertTrue(item.basemap.is3D)
                    } else {
                        XCTAssertFalse(item.basemap.is3D)
                    }
                }
            }
            try await group.waitForAll()
        }
        
        XCTAssertEqual(scene.loadStatus, .loaded)
    }
}
