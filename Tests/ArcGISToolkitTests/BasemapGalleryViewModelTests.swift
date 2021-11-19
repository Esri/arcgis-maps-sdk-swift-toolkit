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

@MainActor
class BasemapGalleryViewModelTests: XCTestCase {
***REMOVED***let basemapGalleryItems: [BasemapGalleryItem] = [
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
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED*** Test Design: https:***REMOVED***devtopia.esri.com/runtime/common-toolkit/blob/master/designs/BasemapGallery/BasemapGallery_Test_Design.md
***REMOVED******REMOVED***
***REMOVED***func testInit() async throws {
***REMOVED******REMOVED******REMOVED*** Note:  this is a good candidate for mocking portal data.
***REMOVED******REMOVED******REMOVED*** This would allow the test to check for a specific number of items
***REMOVED******REMOVED******REMOVED*** in both the "Portal" and "Both" sections.

***REMOVED******REMOVED******REMOVED*** Portal.
***REMOVED******REMOVED***let portalViewModel = BasemapGalleryViewModel(
***REMOVED******REMOVED******REMOVED***portal: Portal.arcGISOnline(isLoginRequired: false)
***REMOVED******REMOVED***)

***REMOVED******REMOVED***var bgItems = try await portalViewModel.$basemapGalleryItems.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***var items = try XCTUnwrap(bgItems)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** There will be greater than 10 basemaps in the portal.
***REMOVED******REMOVED***XCTAssertGreaterThan(items.count, 10)

***REMOVED******REMOVED******REMOVED*** BasemapGalleryItems.
***REMOVED******REMOVED***let itemsViewModel = BasemapGalleryViewModel(
***REMOVED******REMOVED******REMOVED***basemapGalleryItems: basemapGalleryItems
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** The item counts should match.
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***itemsViewModel.basemapGalleryItems.count,
***REMOVED******REMOVED******REMOVED***basemapGalleryItems.count
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Both Portal and BasemapGalleryItems.
***REMOVED******REMOVED***let viewModel = BasemapGalleryViewModel(
***REMOVED******REMOVED******REMOVED***portal: Portal.arcGISOnline(isLoginRequired: false),
***REMOVED******REMOVED******REMOVED***basemapGalleryItems: basemapGalleryItems
***REMOVED******REMOVED***)

***REMOVED******REMOVED***bgItems  = try await viewModel.$basemapGalleryItems.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***items = try XCTUnwrap(bgItems)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Count will be greater than the number of hardcoded items.
***REMOVED******REMOVED***XCTAssertGreaterThan(items.count, basemapGalleryItems.count)
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
***REMOVED******REMOVED******REMOVED*** but a different spatial reference...
***REMOVED***
***REMOVED***
***REMOVED***func testCurrentBasemapItem() async throws {
***REMOVED******REMOVED***let geoModel = Map(basemap: Basemap.streets())

***REMOVED******REMOVED***let viewModel = BasemapGalleryViewModel(geoModel: geoModel)
***REMOVED******REMOVED***
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
***REMOVED******REMOVED***let tmpItem = try await viewModel.$currentBasemapGalleryItem.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***let currentItem = try XCTUnwrap(tmpItem)
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
