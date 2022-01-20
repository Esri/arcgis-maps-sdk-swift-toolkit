***REMOVED*** Copyright 2022 Esri.

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
***REMOVED*** Note:  the iOS implementation uses the MVVM approach and SwiftUI. This
***REMOVED*** required a bit more properties/logic in the `BasemapGalleryItem` (such
***REMOVED*** as the `loadBasemapError` and `spatialReferenceStatus` properties than
***REMOVED*** the `BasemapGallery` design specifies. Tests not present in the
***REMOVED*** test design have been added to accomodate those differences.
@MainActor
class BasemapGalleryItemTests: XCTestCase {
***REMOVED***func testInit() async throws {
***REMOVED******REMOVED***let basemap = Basemap.lightGrayCanvas()
***REMOVED******REMOVED***var item = BasemapGalleryItem(basemap: basemap)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var isBasemapLoading = try await item.$isBasemapLoading.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***var loading = try XCTUnwrap(isBasemapLoading)
***REMOVED******REMOVED***XCTAssertFalse(loading, "Item is not loading.")
***REMOVED******REMOVED***XCTAssertTrue(item.basemap === basemap)
***REMOVED******REMOVED***XCTAssertEqual(item.name, "Light Gray Canvas")
***REMOVED******REMOVED***XCTAssertNil(item.description)
***REMOVED******REMOVED***XCTAssertNotNil(item.thumbnail)
***REMOVED******REMOVED***XCTAssertNil(item.loadBasemapError)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test with overrides.
***REMOVED******REMOVED***let thumbnail = UIImage(systemName: "magnifyingglass")
***REMOVED******REMOVED***XCTAssertNotNil(thumbnail)
***REMOVED******REMOVED***item = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: basemap,
***REMOVED******REMOVED******REMOVED***name: "My Basemap",
***REMOVED******REMOVED******REMOVED***description: "Basemap description",
***REMOVED******REMOVED******REMOVED***thumbnail: thumbnail
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***isBasemapLoading = try await item.$isBasemapLoading.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***loading = try XCTUnwrap(isBasemapLoading)
***REMOVED******REMOVED***XCTAssertFalse(loading, "Item is not loading.")
***REMOVED******REMOVED***XCTAssertEqual(item.name, "My Basemap")
***REMOVED******REMOVED***XCTAssertEqual(item.description, "Basemap description")
***REMOVED******REMOVED***XCTAssertEqual(item.thumbnail, thumbnail)
***REMOVED******REMOVED***XCTAssertNil(item.loadBasemapError)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test with portal item.
***REMOVED******REMOVED***item = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***isBasemapLoading = try await item.$isBasemapLoading.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***loading = try XCTUnwrap(isBasemapLoading)
***REMOVED******REMOVED***XCTAssertFalse(loading, "Item is not loading.")
***REMOVED******REMOVED***XCTAssertEqual(item.name, "OpenStreetMap Blueprint")
***REMOVED******REMOVED***XCTAssertEqual(item.description, "<div><div style=\'margin-bottom:3rem;\'><div><div style=\'max-width:100%; display:inherit;\'><p style=\'margin-top:0px; margin-bottom:1.5rem;\'><span style=\'font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'>This web map presents a vector basemap of OpenStreetMap (OSM) data hosted by Esri. Esri created this vector tile basemap from the </span><a href=\'https:***REMOVED***daylightmap.org/\' rel=\'nofollow ugc\' style=\'color:rgb(0, 121, 193); text-decoration-line:none; font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'>Daylight map distribution</a><span style=\'font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'> of OSM data, which is supported by </span><b><font style=\'font-family:inherit;\'><span style=\'font-family:inherit;\'>Facebook</span></font> </b><span style=\'font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'>and supplemented with additional data from </span><font style=\'font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'><b>Microsoft</b>. It presents the map in a cartographic style is like a blueprint technical drawing. The OSM Daylight map will be updated every month with the latest version of OSM Daylight data. </font></p><div style=\'font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'>OpenStreetMap is an open collaborative project to create a free editable map of the world. Volunteers gather location data using GPS, local knowledge, and other free sources of information and upload it. The resulting free map can be viewed and downloaded from the OpenStreetMap site: <a href=\'https:***REMOVED***www.openstreetmap.org/\' rel=\'nofollow ugc\' style=\'color:rgb(0, 121, 193); text-decoration-line:none; font-family:inherit;\' target=\'_blank\'>www.OpenStreetMap.org</a>. Esri is a supporter of the OSM project and is excited to make this enhanced vector basemap available to the ArcGIS user and developer communities.</div></div></div></div></div><div style=\'margin-bottom:3rem; display:inherit; font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'><div style=\'display:inherit;\'></div></div>")
***REMOVED******REMOVED***XCTAssertNotNil(item.thumbnail)
***REMOVED******REMOVED***XCTAssertNil(item.loadBasemapError)
***REMOVED***
***REMOVED***
***REMOVED***func testLoadBasemapError() async throws {
***REMOVED******REMOVED******REMOVED*** Create item with bad portal item URL.
***REMOVED******REMOVED***let item = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=4a3922d6d15f405d8c2b7a448a7fbad2")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let isBasemapLoading = try await item.$isBasemapLoading.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***let loading = try XCTUnwrap(isBasemapLoading)
***REMOVED******REMOVED***XCTAssertFalse(loading, "Item is not loading.")
***REMOVED******REMOVED***XCTAssertNotNil(item.loadBasemapError)
***REMOVED***
***REMOVED***
***REMOVED***func testSpatialReferenceAndStatus() async throws {
***REMOVED******REMOVED***let basemap = Basemap.lightGrayCanvas()
***REMOVED******REMOVED***let item = BasemapGalleryItem(basemap: basemap)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var isBasemapLoading = try await item.$isBasemapLoading.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***var loading = try XCTUnwrap(isBasemapLoading)
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
***REMOVED******REMOVED******REMOVED*** to updateSpatialReferenceStatus.
***REMOVED******REMOVED***isBasemapLoading = try await item.$isBasemapLoading.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***loading = try XCTUnwrap(isBasemapLoading)
***REMOVED******REMOVED***XCTAssertTrue(loading, "Item base layers are loading.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***var srStatus = try await item.$spatialReferenceStatus.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***var status = try XCTUnwrap(srStatus)
***REMOVED******REMOVED***XCTAssertEqual(status, .match)
***REMOVED******REMOVED***XCTAssertEqual(item.spatialReference, SpatialReference.webMercator)
***REMOVED******REMOVED***XCTAssertFalse(item.isBasemapLoading)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test if basemap doesn't match.
***REMOVED******REMOVED***try await item.updateSpatialReferenceStatus(SpatialReference.wgs84)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Since we've already called `updateSpatialReferenceStatus` once,
***REMOVED******REMOVED******REMOVED*** we should no longer internally need to load the baselayers.
***REMOVED******REMOVED***isBasemapLoading = try await item.$isBasemapLoading.compactMap({ $0 ***REMOVED***).first
***REMOVED******REMOVED***loading = try XCTUnwrap(isBasemapLoading)
***REMOVED******REMOVED***XCTAssertFalse(loading, "Item base layers are not loading.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***srStatus = try await item.$spatialReferenceStatus.compactMap({ $0 ***REMOVED***).first
***REMOVED******REMOVED***status = try XCTUnwrap(srStatus)
***REMOVED******REMOVED***XCTAssertEqual(status, .noMatch)
***REMOVED******REMOVED***XCTAssertEqual(item.spatialReference, SpatialReference.webMercator)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test WGS84 basemap.
***REMOVED******REMOVED***let otherItem = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=52bdc7ab7fb044d98add148764eaa30a")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***_ = try await otherItem.$isBasemapLoading.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***
***REMOVED******REMOVED***try await otherItem.updateSpatialReferenceStatus(SpatialReference.wgs84)
***REMOVED******REMOVED***srStatus = try await otherItem.$spatialReferenceStatus.compactMap({ $0 ***REMOVED***).first
***REMOVED******REMOVED***status = try XCTUnwrap(srStatus)
***REMOVED******REMOVED***XCTAssertEqual(status, .match)
***REMOVED******REMOVED***XCTAssertEqual(otherItem.spatialReference, SpatialReference.wgs84)
***REMOVED***
***REMOVED***
