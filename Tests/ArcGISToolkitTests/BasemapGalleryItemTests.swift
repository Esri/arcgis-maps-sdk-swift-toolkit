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
import Foundation
***REMOVED***
import XCTest

***REMOVED*** Note:  the iOS implementation uses the MVVM approach and SwiftUI. This
***REMOVED*** required a bit more properties/logic in the 'BasemapGalleryItem' (such
***REMOVED*** as the 'loadBasemapError' and 'spatialReferenceStatus' properties than
***REMOVED*** the 'BasemapGallery' design specifies. Tests not present in the
***REMOVED*** test design have been added to accommodate those differences.
final class BasemapGalleryItemTests: XCTestCase {
***REMOVED***override func setUp() async throws {
***REMOVED******REMOVED***ArcGISEnvironment.apiKey = .default
***REMOVED***
***REMOVED***
***REMOVED***override func tearDown() {
***REMOVED******REMOVED***ArcGISEnvironment.apiKey = nil
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testInit() async throws {
***REMOVED******REMOVED***let basemap = Basemap(style: .arcGISLightGray)
***REMOVED******REMOVED***let item = BasemapGalleryItem(basemap: basemap, is3D: false)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let isBasemapLoading = try await item.$isBasemapLoading.dropFirst().first
***REMOVED******REMOVED***let loading = try XCTUnwrap(isBasemapLoading)
***REMOVED******REMOVED***XCTAssertFalse(loading, "Item is not loading.")
***REMOVED******REMOVED***XCTAssertIdentical(item.basemap, basemap)
***REMOVED******REMOVED***XCTAssertEqual(item.name, "ArcGIS Light Gray")
***REMOVED******REMOVED***XCTAssertNil(item.description)
***REMOVED******REMOVED***XCTAssertNotNil(item.thumbnail)
***REMOVED******REMOVED***XCTAssertNil(item.loadBasemapError)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test with overrides.
***REMOVED******REMOVED***let thumbnail = UIImage(systemName: "magnifyingglass")!
***REMOVED******REMOVED***let basemap2 = Basemap(style: .arcGISLightGray)
***REMOVED******REMOVED***let item2 = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: basemap2,
***REMOVED******REMOVED******REMOVED***name: "My Basemap",
***REMOVED******REMOVED******REMOVED***description: "Basemap description",
***REMOVED******REMOVED******REMOVED***thumbnail: thumbnail,
***REMOVED******REMOVED******REMOVED***is3D: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let isBasemapLoading2 = try await item2.$isBasemapLoading.dropFirst().first
***REMOVED******REMOVED***let loading2 = try XCTUnwrap(isBasemapLoading2)
***REMOVED******REMOVED***XCTAssertFalse(loading2, "Item is not loading.")
***REMOVED******REMOVED***XCTAssertEqual(item2.name, "My Basemap")
***REMOVED******REMOVED***XCTAssertEqual(item2.description, "Basemap description")
***REMOVED******REMOVED***XCTAssertEqual(item2.thumbnail, thumbnail)
***REMOVED******REMOVED***XCTAssertNil(item2.loadBasemapError)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test with portal item.
***REMOVED******REMOVED***let item3 = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***is3D: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let isBasemapLoading3 = try await item3.$isBasemapLoading.dropFirst().first
***REMOVED******REMOVED***let loading3 = try XCTUnwrap(isBasemapLoading3)
***REMOVED******REMOVED***XCTAssertFalse(loading3, "Item is not loading.")
***REMOVED******REMOVED***XCTAssertEqual(item3.name, "OpenStreetMap (Blueprint)")
***REMOVED******REMOVED***XCTAssertNotNil(item3.description)
***REMOVED******REMOVED***XCTAssertNotNil(item3.thumbnail)
***REMOVED******REMOVED***XCTAssertNil(item3.loadBasemapError)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testLoadBasemapError() async throws {
***REMOVED******REMOVED******REMOVED*** Create item with bad portal item URL.
***REMOVED******REMOVED***let item = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***arcgis.com/home/item.html?id=4a3922d6d15f405d8c2b7a448a7fbad2")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***is3D: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let isBasemapLoading = try await item.$isBasemapLoading.dropFirst().first
***REMOVED******REMOVED***let loading = try XCTUnwrap(isBasemapLoading)
***REMOVED******REMOVED***XCTAssertFalse(loading, "Item is not loading.")
***REMOVED******REMOVED***XCTAssertNotNil(item.loadBasemapError)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testSpatialReferenceAndStatus() async throws {
***REMOVED******REMOVED***let basemap = Basemap(style: .arcGISLightGray)
***REMOVED******REMOVED***let item = BasemapGalleryItem(basemap: basemap, is3D: false)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let isBasemapLoading = try await item.$isBasemapLoading.dropFirst().first
***REMOVED******REMOVED***let loading = try XCTUnwrap(isBasemapLoading)
***REMOVED******REMOVED***XCTAssertFalse(loading, "Item is not loading.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(item.spatialReferenceStatus, .unknown)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test if basemap matches. Use a Task here so we can catch and test
***REMOVED******REMOVED******REMOVED*** the change to `item.isBasemapLoading` during the loading of the base layers.
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***try await item.updateSpatialReferenceStatus(SpatialReference.webMercator)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Check if `isBasemapLoading` is set to true during first call
***REMOVED******REMOVED******REMOVED*** to `updateSpatialReferenceStatus`.
***REMOVED******REMOVED***let isBasemapLoading2 = try await item.$isBasemapLoading.dropFirst().first
***REMOVED******REMOVED***let loading2 = try XCTUnwrap(isBasemapLoading2)
***REMOVED******REMOVED***XCTAssertTrue(loading2, "Item base layers are loading.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***let srStatus = try await item.$spatialReferenceStatus.dropFirst().first
***REMOVED******REMOVED***let status = try XCTUnwrap(srStatus)
***REMOVED******REMOVED***XCTAssertEqual(status, .match)
***REMOVED******REMOVED***XCTAssertEqual(item.spatialReference, SpatialReference.webMercator)
***REMOVED******REMOVED***XCTAssertFalse(item.isBasemapLoading)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test if basemap doesn't match.
***REMOVED******REMOVED***try await item.updateSpatialReferenceStatus(.wgs84)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Since we've already called `updateSpatialReferenceStatus` once,
***REMOVED******REMOVED******REMOVED*** we should no longer internally need to load the base layers.
***REMOVED******REMOVED***let isBasemapLoading3 = try await item.$isBasemapLoading.first
***REMOVED******REMOVED***let loading3 = try XCTUnwrap(isBasemapLoading3)
***REMOVED******REMOVED***XCTAssertFalse(loading3, "Item base layers are not loading.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***let srStatus2 = try await item.$spatialReferenceStatus.first
***REMOVED******REMOVED***let status2 = try XCTUnwrap(srStatus2)
***REMOVED******REMOVED***XCTAssertEqual(status2, .noMatch)
***REMOVED******REMOVED***XCTAssertEqual(item.spatialReference, .webMercator)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test WGS84 basemap.
***REMOVED******REMOVED***let otherItem = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***is3D: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***_ = try await otherItem.$isBasemapLoading.dropFirst().first
***REMOVED******REMOVED***
***REMOVED******REMOVED***try await otherItem.updateSpatialReferenceStatus(.wgs84)
***REMOVED******REMOVED***let srStatus3 = try await otherItem.$spatialReferenceStatus.first
***REMOVED******REMOVED***let status3 = try XCTUnwrap(srStatus3)
***REMOVED******REMOVED***XCTAssertEqual(status3, .match)
***REMOVED******REMOVED***XCTAssertEqual(otherItem.spatialReference, .wgs84)
***REMOVED***
***REMOVED***
