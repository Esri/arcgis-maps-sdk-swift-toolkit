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
@testable ***REMOVED***Toolkit
***REMOVED***
import Combine

***REMOVED***
***REMOVED*** Test Design: https:***REMOVED***devtopia.esri.com/runtime/common-toolkit/blob/master/designs/BasemapGallery/BasemapGallery_Test_Design.md
***REMOVED***
***REMOVED*** Note:  the iOS implementation uses the MVVM approach and SwiftUI.  This
***REMOVED*** required a bit more properties/logic in the `BasemapGalleryViewModel` (such
***REMOVED*** as `geoModel.actualSpatialReference`) than the `BasemapGallery` design
***REMOVED*** specifies.  Tests not present in the test design have been added to
***REMOVED*** accomodate those differences.
@MainActor
class BasemapGalleryViewModelTests: XCTestCase {
***REMOVED***let defaultBasemapGalleryItems: [BasemapGalleryItem] = [
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***),
***REMOVED******REMOVED***BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=f33a34de3a294590ab48f246e99958c9")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***]

***REMOVED***func testInit() async throws {
***REMOVED******REMOVED******REMOVED*** Note:  this is a good candidate for mocking portal data.
***REMOVED******REMOVED******REMOVED*** This would allow the test to check for a specific number of items.
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** GeoModel.
***REMOVED******REMOVED***let geoModel = Map(basemap: Basemap.streets())
***REMOVED******REMOVED***let geoModelViewModel = BasemapGalleryViewModel(geoModel: geoModel)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** With no portal, `basemapGalleryItems` are fetched from AGOL's
***REMOVED******REMOVED******REMOVED*** list of developer basemaps.
***REMOVED******REMOVED***var items = try await geoModelViewModel.$basemapGalleryItems.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***var basemapGalleryItems = try XCTUnwrap(items)
***REMOVED******REMOVED***XCTAssertFalse(basemapGalleryItems.isEmpty)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let developerBasemapItems = basemapGalleryItems
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Portal.
***REMOVED******REMOVED***let portalViewModel = BasemapGalleryViewModel(
***REMOVED******REMOVED******REMOVED***portal: Portal.arcGISOnline(isLoginRequired: false)
***REMOVED******REMOVED***)

***REMOVED******REMOVED******REMOVED*** With a portal, `basemapGalleryItems` are fetched from either the
***REMOVED******REMOVED******REMOVED*** portal's vector basemaps or regular basemaps.
***REMOVED******REMOVED***items = try await portalViewModel.$basemapGalleryItems.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***basemapGalleryItems = try XCTUnwrap(items)
***REMOVED******REMOVED***XCTAssertFalse(basemapGalleryItems.isEmpty)

***REMOVED******REMOVED******REMOVED*** Sort the developer items from the "GeoModel" test above and the
***REMOVED******REMOVED******REMOVED*** items from the portal and make sure they are not equal.
***REMOVED******REMOVED***let sortedItems = basemapGalleryItems.sorted { $0.name < $1.name ***REMOVED***
***REMOVED******REMOVED***let sortedDeveloperItems = developerBasemapItems.sorted { $0.name < $1.name ***REMOVED***
***REMOVED******REMOVED***XCTAssertNotEqual(sortedItems, sortedDeveloperItems)

***REMOVED******REMOVED******REMOVED*** BasemapGalleryItems.  No basemaps are fetched from a portal.
***REMOVED******REMOVED***let itemsViewModel = BasemapGalleryViewModel(
***REMOVED******REMOVED******REMOVED***basemapGalleryItems: defaultBasemapGalleryItems
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** The item counts should match.
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***itemsViewModel.basemapGalleryItems.count,
***REMOVED******REMOVED******REMOVED***defaultBasemapGalleryItems.count
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Both Portal and BasemapGalleryItems.  Basemaps are fetched from
***REMOVED******REMOVED******REMOVED*** the portal and appended to the list of basemapGalleryItems.
***REMOVED******REMOVED***let viewModel = BasemapGalleryViewModel(
***REMOVED******REMOVED******REMOVED***portal: Portal.arcGISOnline(isLoginRequired: false),
***REMOVED******REMOVED******REMOVED***basemapGalleryItems: defaultBasemapGalleryItems
***REMOVED******REMOVED***)

***REMOVED******REMOVED***items  = try await viewModel.$basemapGalleryItems.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***basemapGalleryItems = try XCTUnwrap(items)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Count will be greater than the number of hardcoded items.
***REMOVED******REMOVED***XCTAssertGreaterThan(basemapGalleryItems.count, defaultBasemapGalleryItems.count)
***REMOVED***
***REMOVED***
***REMOVED***func testGeoModelActualSpatialReference() async throws {
***REMOVED******REMOVED******REMOVED*** Map with .webMercator basemap.
***REMOVED******REMOVED***let geoModel = Map(basemap: Basemap.streets())
***REMOVED******REMOVED***try await geoModel.load()
***REMOVED******REMOVED***XCTAssertEqual(geoModel.actualSpatialReference, .webMercator)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Map with .wgs84 basemap.
***REMOVED******REMOVED***let geoModel2 = Map(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)

***REMOVED******REMOVED***try await geoModel2.load()
***REMOVED******REMOVED***XCTAssertEqual(geoModel2.actualSpatialReference, .wgs84)

***REMOVED******REMOVED******REMOVED*** Test with Scene that has a tiling scheme of .webMercator
***REMOVED******REMOVED***let geoModel3 = Scene(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)

***REMOVED******REMOVED***try await geoModel3.load()
***REMOVED******REMOVED***XCTAssertEqual(geoModel3.actualSpatialReference, .webMercator)
***REMOVED***
***REMOVED***
***REMOVED***func testCurrentBasemapGalleryItem() async throws {
***REMOVED******REMOVED***let basemap = Basemap.streets()
***REMOVED******REMOVED***let geoModel = Map(basemap: basemap)

***REMOVED******REMOVED***let viewModel = BasemapGalleryViewModel(geoModel: geoModel)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify current item is equal to map's basemap.
***REMOVED******REMOVED***var item = try await viewModel.$currentBasemapGalleryItem.compactMap({ $0 ***REMOVED***).first
***REMOVED******REMOVED***var currentItem = try XCTUnwrap(item)
***REMOVED******REMOVED***XCTAssertTrue(currentItem.basemap === basemap)

***REMOVED******REMOVED******REMOVED*** Test valid basemap item (OpenStreetMap Vector Basemap (Blueprint)).
***REMOVED******REMOVED***let validItem = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait until it loads.
***REMOVED******REMOVED***_ = try await validItem.$isLoading.compactMap({ $0 ***REMOVED***).dropFirst().first

***REMOVED******REMOVED***viewModel.updateCurrentBasemapGalleryItem(validItem)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait until the `currentBasemapGalleryItem` is updated.
***REMOVED******REMOVED***item = try await viewModel.$currentBasemapGalleryItem.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***currentItem = try XCTUnwrap(item)
***REMOVED******REMOVED***XCTAssertEqual(currentItem, validItem)
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Test WGS84 basemap item (Imagery (WGS84)).
***REMOVED******REMOVED***let invalidItem = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait until it loads.
***REMOVED******REMOVED***_ = try await invalidItem.$isLoading.compactMap({ $0 ***REMOVED***).dropFirst().first

***REMOVED******REMOVED***viewModel.updateCurrentBasemapGalleryItem(invalidItem)

***REMOVED******REMOVED******REMOVED*** The update will fail, so wait until the
***REMOVED******REMOVED******REMOVED*** `$spatialReferenceMismatchError` is updated.
***REMOVED******REMOVED***let error = try await viewModel.$spatialReferenceMismatchError.compactMap({ $0 ***REMOVED***).first
***REMOVED******REMOVED***XCTAssertNotNil(error, "Error is not nil.")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Make sure the current item is still equal to the valid item.
***REMOVED******REMOVED***XCTAssertEqual(currentItem, validItem)
***REMOVED***
***REMOVED***
***REMOVED***func testUpdatePortal() async throws {
***REMOVED******REMOVED******REMOVED*** Note:  this is a good candidate for mocking portal data.
***REMOVED******REMOVED******REMOVED*** This would allow the test to check for a specific number of items.

***REMOVED******REMOVED***let viewModel = BasemapGalleryViewModel(
***REMOVED******REMOVED******REMOVED***basemapGalleryItems: defaultBasemapGalleryItems
***REMOVED******REMOVED***)

***REMOVED******REMOVED***var items = try await viewModel.$basemapGalleryItems.compactMap({ $0 ***REMOVED***).first
***REMOVED******REMOVED***var basemapGalleryItems = try XCTUnwrap(items)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** There are exactly two default items.
***REMOVED******REMOVED***XCTAssertEqual(basemapGalleryItems.count, 2)

***REMOVED******REMOVED***viewModel.portal = Portal.arcGISOnline(isLoginRequired: false)
***REMOVED******REMOVED***
***REMOVED******REMOVED***items = try await viewModel.$basemapGalleryItems.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***basemapGalleryItems = try XCTUnwrap(items)

***REMOVED******REMOVED******REMOVED*** There should be no default items in the basemap gallery.
***REMOVED******REMOVED***let foundDefaultItem = basemapGalleryItems.first(where: {
***REMOVED******REMOVED******REMOVED***$0 == defaultBasemapGalleryItems[0] ||
***REMOVED******REMOVED******REMOVED***$0 == defaultBasemapGalleryItems[1]
***REMOVED***)
***REMOVED******REMOVED***XCTAssertNil(foundDefaultItem)
***REMOVED***
***REMOVED***
