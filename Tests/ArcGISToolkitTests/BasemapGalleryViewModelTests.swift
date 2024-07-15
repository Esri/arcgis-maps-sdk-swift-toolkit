***REMOVED*** Copyright 2022 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
@testable ***REMOVED***Toolkit
@preconcurrency import Combine
import XCTest

***REMOVED*** Note:  the iOS implementation uses the MVVM approach and SwiftUI. This
***REMOVED*** required a bit more properties/logic in the 'BasemapGalleryViewModel' (such
***REMOVED*** as 'geoModel.actualSpatialReference') than the 'BasemapGallery' design
***REMOVED*** specifies. Tests not present in the test design have been added to
***REMOVED*** accommodate those differences.
class BasemapGalleryViewModelTests: XCTestCase {
***REMOVED***override func setUp() async throws {
***REMOVED******REMOVED***ArcGISEnvironment.apiKey = .default
***REMOVED***
***REMOVED***
***REMOVED***override func tearDown() {
***REMOVED******REMOVED***ArcGISEnvironment.apiKey = nil
***REMOVED***
***REMOVED***
***REMOVED***let defaultBasemapGalleryItems: [BasemapGalleryItem] = [
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***arcgis.com/home/item.html?id=f33a34de3a294590ab48f246e99958c9")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***]
***REMOVED***
***REMOVED******REMOVED***/ Test the various constructor methods.
***REMOVED***@MainActor
***REMOVED***func testInit() async throws {
***REMOVED******REMOVED******REMOVED*** Note:  this is a good candidate for mocking portal data.
***REMOVED******REMOVED******REMOVED*** This would allow the test to check for a specific number of items.
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** GeoModel.
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***let geoModel = Map(basemapStyle: .arcGISLightGray)
***REMOVED******REMOVED***let geoModelViewModel = BasemapGalleryViewModel(geoModel: geoModel)
***REMOVED******REMOVED***XCTAssertIdentical(geoModelViewModel.geoModel, geoModel)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** With no portal, `basemapGalleryItems` are fetched from AGOL's
***REMOVED******REMOVED******REMOVED*** list of developer basemaps.
***REMOVED******REMOVED***let items = try await geoModelViewModel.$items.dropFirst().first
***REMOVED******REMOVED***let basemapGalleryItems = try XCTUnwrap(items)
***REMOVED******REMOVED***XCTAssertFalse(basemapGalleryItems.isEmpty)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** GeoModel should be loaded.
***REMOVED******REMOVED***XCTAssertEqual(geoModel.loadStatus, .loaded)
***REMOVED******REMOVED***XCTAssertEqual(geoModelViewModel.currentItem?.basemap.name, geoModel.basemap?.name)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Save the array of developer basemap items from AGOL.
***REMOVED******REMOVED***let developerBasemapItems = basemapGalleryItems
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Portal.
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***let geoModel2 = Map(basemapStyle: .arcGISLightGray)
***REMOVED******REMOVED***let portal = Portal.arcGISOnline(connection: .anonymous)
***REMOVED******REMOVED***let portalViewModel = BasemapGalleryViewModel(geoModel2, portal: portal)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertIdentical(portalViewModel.geoModel, geoModel2)
***REMOVED******REMOVED***XCTAssertIdentical(portalViewModel.portal, portal)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** With a portal, `basemapGalleryItems` are fetched from either the
***REMOVED******REMOVED******REMOVED*** portal's vector basemaps or regular basemaps.
***REMOVED******REMOVED***let items2 = try await portalViewModel.$items.dropFirst().first
***REMOVED******REMOVED***let basemapGalleryItems2 = try XCTUnwrap(items2)
***REMOVED******REMOVED***XCTAssertFalse(basemapGalleryItems2.isEmpty)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(geoModel2.loadStatus, .loaded)
***REMOVED******REMOVED***XCTAssertIdentical(portalViewModel.currentItem?.basemap, geoModel2.basemap)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Sort the developer items from the "GeoModel" test above and the
***REMOVED******REMOVED******REMOVED*** items from the portal and make sure they are not equal.
***REMOVED******REMOVED***let sortedItems = basemapGalleryItems2.sorted {
***REMOVED******REMOVED******REMOVED***guard let name0 = $0.name, let name1 = $1.name else { return false ***REMOVED***
***REMOVED******REMOVED******REMOVED***return name0 < name1
***REMOVED***
***REMOVED******REMOVED***let sortedDeveloperItems = developerBasemapItems.sorted {
***REMOVED******REMOVED******REMOVED***guard let name0 = $0.name, let name1 = $1.name else { return false ***REMOVED***
***REMOVED******REMOVED******REMOVED***return name0 < name1
***REMOVED***
***REMOVED******REMOVED***XCTAssertNotEqual(sortedItems, sortedDeveloperItems)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** BasemapGalleryItems. No basemaps are fetched from a portal.
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***let geoModel3 = Map(basemapStyle: .arcGISLightGray)
***REMOVED******REMOVED***let itemsViewModel = BasemapGalleryViewModel(
***REMOVED******REMOVED******REMOVED***geoModel: geoModel3,
***REMOVED******REMOVED******REMOVED***items: defaultBasemapGalleryItems
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** The item counts should match.
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***itemsViewModel.items.count,
***REMOVED******REMOVED******REMOVED***defaultBasemapGalleryItems.count
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test the `GeoModel.actualSpatialReference` extension property.
***REMOVED***func testGeoModelActualSpatialReference() async throws {
***REMOVED******REMOVED******REMOVED*** Map with Web Mercator basemap.
***REMOVED******REMOVED***let geoModel = Map(basemapStyle: .arcGISLightGray)
***REMOVED******REMOVED***try await geoModel.load()
***REMOVED******REMOVED***XCTAssertEqual(geoModel.actualSpatialReference, .webMercator)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Map with WGS 84 basemap.
***REMOVED******REMOVED***let geoModel2 = Map(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***try await geoModel2.load()
***REMOVED******REMOVED***XCTAssertEqual(geoModel2.actualSpatialReference, .wgs84)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test with Scene that has a tiling scheme of Web Mercator.
***REMOVED******REMOVED***let geoModel3 = Scene(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***try await geoModel3.load()
***REMOVED******REMOVED***XCTAssertEqual(geoModel3.actualSpatialReference, .webMercator)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test with Scene that has a tiling scheme of WGS 84.
***REMOVED******REMOVED***let geoModel4 = Scene(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***try await geoModel4.load()
***REMOVED******REMOVED***XCTAssertEqual(geoModel4.actualSpatialReference, .wgs84)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test the `currentItem` property including valid and invalid basemaps.
***REMOVED***@MainActor
***REMOVED***func testCurrentItem() async throws {
***REMOVED******REMOVED***let basemap = Basemap(style: .arcGISStreets)
***REMOVED******REMOVED***let geoModel = Map(basemap: basemap)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let viewModel = BasemapGalleryViewModel(geoModel: geoModel)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify current item is equal to map's basemap.
***REMOVED******REMOVED***let item = try await viewModel.$currentItem.dropFirst().first
***REMOVED******REMOVED***let currentItem = try XCTUnwrap(item)
***REMOVED******REMOVED***XCTAssertIdentical(currentItem?.basemap, basemap)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test valid basemap item (OpenStreetMap Vector Basemap (Blueprint)).
***REMOVED******REMOVED***let validItem = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait until it loads.
***REMOVED******REMOVED***_ = try await validItem.$isBasemapLoading.dropFirst().first
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Update the item on the model.
***REMOVED******REMOVED***viewModel.setCurrentItem(validItem)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait until the `currentItem` is updated.
***REMOVED******REMOVED***let item2 = try await viewModel.$currentItem.dropFirst().first
***REMOVED******REMOVED***let currentItem2 = try XCTUnwrap(item2)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Items should equal, meaning the `validItem` was set properly.
***REMOVED******REMOVED***XCTAssertEqual(currentItem2, validItem)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test WGS84 basemap item (Imagery (WGS84)).  This item is in a
***REMOVED******REMOVED******REMOVED*** different spatial reference than the geoModel, so it should
***REMOVED******REMOVED******REMOVED*** not be set as the current item.
***REMOVED******REMOVED***let invalidItem = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait until it loads.
***REMOVED******REMOVED***_ = try await invalidItem.$isBasemapLoading.dropFirst().first
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Update the item on the model.
***REMOVED******REMOVED***viewModel.setCurrentItem(invalidItem)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** The update will fail, so wait until the
***REMOVED******REMOVED******REMOVED*** `spatialReferenceMismatchError` is updated.
***REMOVED******REMOVED***let error = try await viewModel.$spatialReferenceMismatchError.dropFirst().first
***REMOVED******REMOVED***let unwrappedError = try XCTUnwrap(error)
***REMOVED******REMOVED***XCTAssertNotNil(unwrappedError, "Error is not nil.")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Make sure the current item is still equal to the valid item.
***REMOVED******REMOVED***XCTAssertEqual(currentItem2, validItem)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test setting the portal after the model has been created.
***REMOVED***@MainActor
***REMOVED***func testUpdatePortal() async throws {
***REMOVED******REMOVED******REMOVED*** Create a model with a default list of items.
***REMOVED******REMOVED***let viewModel = BasemapGalleryViewModel(
***REMOVED******REMOVED******REMOVED***items: defaultBasemapGalleryItems
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let items = try await viewModel.$items.first
***REMOVED******REMOVED***let basemapGalleryItems = try XCTUnwrap(items)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** There are exactly two default items.
***REMOVED******REMOVED***XCTAssertEqual(basemapGalleryItems.count, 2)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set a portal on the model. This should clear out the existing
***REMOVED******REMOVED******REMOVED*** array of items and load basemaps from the portal.
***REMOVED******REMOVED***viewModel.portal = Portal.arcGISOnline(connection: .anonymous)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** The items should be cleared prior to loading those from the portal.
***REMOVED******REMOVED***let items2 = try await viewModel.$items.first
***REMOVED******REMOVED***let basemapGalleryItems2 = try XCTUnwrap(items2)
***REMOVED******REMOVED***XCTAssertTrue(basemapGalleryItems2.isEmpty)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for the portal basemaps to load.
***REMOVED******REMOVED***let items3 = try await viewModel.$items.dropFirst().first
***REMOVED******REMOVED***let basemapGalleryItems3 = try XCTUnwrap(items3)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** There should be no default items in the basemap gallery.
***REMOVED******REMOVED***XCTAssertFalse(basemapGalleryItems3.contains(where: { item in
***REMOVED******REMOVED******REMOVED***defaultBasemapGalleryItems.contains(item)
***REMOVED***))
***REMOVED***
***REMOVED***
