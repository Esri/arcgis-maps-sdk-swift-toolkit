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
***REMOVED***Toolkit
***REMOVED***
import Combine

@MainActor
class BasemapGalleryItemTests: XCTestCase {
***REMOVED******REMOVED***
***REMOVED******REMOVED*** Test Design: https:***REMOVED***devtopia.esri.com/runtime/common-toolkit/blob/master/designs/BasemapGallery/BasemapGallery_Test_Design.md
***REMOVED******REMOVED***
***REMOVED***func testInit() async throws {
***REMOVED******REMOVED***let basemap = Basemap.lightGrayCanvas()
***REMOVED******REMOVED***var item = BasemapGalleryItem(basemap: basemap)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var isLoading = try await item.$isLoading.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***var loading = try XCTUnwrap(isLoading)
***REMOVED******REMOVED***XCTAssertFalse(loading, "Item is not loading.")
***REMOVED******REMOVED***XCTAssertTrue(item.basemap === basemap)
***REMOVED******REMOVED***XCTAssertEqual(item.name, "Light Gray Canvas")
***REMOVED******REMOVED***XCTAssertNil(item.description)
***REMOVED******REMOVED***XCTAssertNotNil(item.thumbnail)
***REMOVED******REMOVED***XCTAssertNil(item.loadBasemapsError)

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
***REMOVED******REMOVED***isLoading = try await item.$isLoading.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***loading = try XCTUnwrap(isLoading)
***REMOVED******REMOVED***XCTAssertFalse(loading, "Item is not loading.")
***REMOVED******REMOVED***XCTAssertEqual(item.name, "My Basemap")
***REMOVED******REMOVED***XCTAssertEqual(item.description, "Basemap description")
***REMOVED******REMOVED***XCTAssertEqual(item.thumbnail, thumbnail)
***REMOVED******REMOVED***XCTAssertNil(item.loadBasemapsError)

***REMOVED******REMOVED******REMOVED*** Test with portal item.
***REMOVED******REMOVED***item = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=46a87c20f09e4fc48fa3c38081e0cae6")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***isLoading = try await item.$isLoading.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***loading = try XCTUnwrap(isLoading)
***REMOVED******REMOVED***XCTAssertFalse(loading, "Item is not loading.")
***REMOVED******REMOVED***XCTAssertEqual(item.name, "OpenStreetMap Blueprint")
***REMOVED******REMOVED***XCTAssertEqual(item.description, "<div><div style=\'margin-bottom:3rem;\'><div><div style=\'max-width:100%; display:inherit;\'><p style=\'margin-top:0px; margin-bottom:1.5rem;\'><span style=\'font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'>This web map presents a vector basemap of OpenStreetMap (OSM) data hosted by Esri. Esri created this vector tile basemap from the </span><a href=\'https:***REMOVED***daylightmap.org/\' rel=\'nofollow ugc\' style=\'color:rgb(0, 121, 193); text-decoration-line:none; font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'>Daylight map distribution</a><span style=\'font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'> of OSM data, which is supported by </span><b><font style=\'font-family:inherit;\'><span style=\'font-family:inherit;\'>Facebook</span></font> </b><span style=\'font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'>and supplemented with additional data from </span><font style=\'font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'><b>Microsoft</b>. It presents the map in a cartographic style is like a blueprint technical drawing. The OSM Daylight map will be updated every month with the latest version of OSM Daylight data. </font></p><div style=\'font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'>OpenStreetMap is an open collaborative project to create a free editable map of the world. Volunteers gather location data using GPS, local knowledge, and other free sources of information and upload it. The resulting free map can be viewed and downloaded from the OpenStreetMap site: <a href=\'https:***REMOVED***www.openstreetmap.org/\' rel=\'nofollow ugc\' style=\'color:rgb(0, 121, 193); text-decoration-line:none; font-family:inherit;\' target=\'_blank\'>www.OpenStreetMap.org</a>. Esri is a supporter of the OSM project and is excited to make this enhanced vector basemap available to the ArcGIS user and developer communities.</div></div></div></div></div><div style=\'margin-bottom:3rem; display:inherit; font-family:&quot;Avenir Next W01&quot;, &quot;Avenir Next W00&quot;, &quot;Avenir Next&quot;, Avenir, &quot;Helvetica Neue&quot;, sans-serif; font-size:16px;\'><div style=\'display:inherit;\'></div></div>")
***REMOVED******REMOVED***XCTAssertNotNil(item.thumbnail)
***REMOVED******REMOVED***XCTAssertNil(item.loadBasemapsError)
***REMOVED***
***REMOVED***
***REMOVED***func testLoadBasemapError() async throws {
***REMOVED******REMOVED***let item = BasemapGalleryItem(
***REMOVED******REMOVED******REMOVED***basemap: Basemap(
***REMOVED******REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***runtime.maps.arcgis.com/home/item.html?id=4a3922d6d15f405d8c2b7a448a7fbad2")!
***REMOVED******REMOVED******REMOVED******REMOVED***)!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)

***REMOVED******REMOVED***let isLoading = try await item.$isLoading.compactMap({ $0 ***REMOVED***).dropFirst().first
***REMOVED******REMOVED***let loading = try XCTUnwrap(isLoading)
***REMOVED******REMOVED***XCTAssertFalse(loading, "Item is not loading.")
***REMOVED******REMOVED***XCTAssertNotNil(item.loadBasemapsError)
***REMOVED***
***REMOVED***
***REMOVED***func testSpatialReferenceStatus() async throws {
***REMOVED******REMOVED***let basemap = Basemap.lightGrayCanvas()
***REMOVED******REMOVED***let item = BasemapGalleryItem(basemap: basemap)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func testSpatialReference() async throws {
***REMOVED******REMOVED***
***REMOVED***

***REMOVED***
***REMOVED***/*

***REMOVED***
***REMOVED***
***REMOVED***func testAcceptSuggestion() async throws {
***REMOVED******REMOVED***let model = BasemapGalleryViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.updateSuggestions() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Get suggestion
***REMOVED******REMOVED***let suggestions = try await model.$suggestions.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***let suggestion = try XCTUnwrap(suggestions?.get().first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.acceptSuggestion(suggestion) ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***let result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** With only one results, model should set `selectedResult` property.
***REMOVED******REMOVED***XCTAssertEqual(result.first!, model.selectedResult)
***REMOVED***
***REMOVED***
***REMOVED***func testActiveSource() async throws {
***REMOVED******REMOVED***let activeSource = LocatorSearchSource()
***REMOVED******REMOVED***activeSource.displayName = "Simple Locator"
***REMOVED******REMOVED***let model = BasemapGalleryViewModel(
***REMOVED******REMOVED******REMOVED***activeSource: activeSource,
***REMOVED******REMOVED******REMOVED***sources: [LocatorSearchSource()]
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***let result = try XCTUnwrap(results?.get().first)
***REMOVED******REMOVED***XCTAssertEqual(result.owningSource.displayName, activeSource.displayName)
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.updateSuggestions() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let suggestions = try await model.$suggestions.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***let suggestion = try XCTUnwrap(suggestions?.get().first)
***REMOVED******REMOVED***XCTAssertEqual(suggestion.owningSource.displayName, activeSource.displayName)
***REMOVED***
***REMOVED***
***REMOVED***func testCommitSearch() async throws {
***REMOVED******REMOVED***let model = BasemapGalleryViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** No search - results are nil.
***REMOVED******REMOVED***XCTAssertNil(model.results)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with no results - result count is 0.
***REMOVED******REMOVED***model.currentQuery = "No results found blah blah blah blah"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***var result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 0)
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with one result.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** One results automatically populates `selectedResult`.
***REMOVED******REMOVED***XCTAssertEqual(result.first!, model.selectedResult)
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Search with multiple results.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.selectedResult = result.first!
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).dropFirst().first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED***
***REMOVED***
***REMOVED***func testCurrentQuery() async throws {
***REMOVED******REMOVED***let model = BasemapGalleryViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Empty `currentQuery` should produce nil results and suggestions.
***REMOVED******REMOVED***model.currentQuery = ""
***REMOVED******REMOVED***XCTAssertNil(model.results)
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Valid `currentQuery` should produce non-nil results.
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***XCTAssertNotNil(results)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Changing the `currentQuery` should set results to nil.
***REMOVED******REMOVED***model.currentQuery = "Coffee in Portland"
***REMOVED******REMOVED***XCTAssertNil(model.results)
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.updateSuggestions() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let suggestions = try await model.$suggestions.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***XCTAssertNotNil(suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Changing the `currentQuery` should set suggestions to nil.
***REMOVED******REMOVED***model.currentQuery = "Coffee in Edinburgh"
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Changing current query after search with 1 result
***REMOVED******REMOVED******REMOVED*** should set `selectedResult` to nil
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Bookseller"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***_ = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***XCTAssertNotNil(model.selectedResult)
***REMOVED******REMOVED***model.currentQuery = "Hotel"
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED***
***REMOVED***
***REMOVED***func testIsEligibleForRequery() async throws {
***REMOVED******REMOVED***let model = BasemapGalleryViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryArea to Chippewa Falls
***REMOVED******REMOVED***model.queryArea = Polygon.chippewaFalls
***REMOVED******REMOVED***model.geoViewExtent = Polygon.chippewaFalls.extent
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***_ = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***XCTAssertFalse(model.isEligibleForRequery)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Offset extent by 10% - isEligibleForRequery should still be `false`.
***REMOVED******REMOVED***var builder = EnvelopeBuilder(envelope: model.geoViewExtent)
***REMOVED******REMOVED***let tenPercentWidth = model.geoViewExtent!.width * 0.1
***REMOVED******REMOVED***builder.offsetBy(x: tenPercentWidth, y: 0.0)
***REMOVED******REMOVED***var newExtent = builder.toGeometry() as! Envelope
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.geoViewExtent = newExtent
***REMOVED******REMOVED***XCTAssertFalse(model.isEligibleForRequery)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Offset extent by 50% - isEligibleForRequery should now be `true`.
***REMOVED******REMOVED***builder = EnvelopeBuilder(envelope: model.geoViewExtent)
***REMOVED******REMOVED***let fiftyPercentWidth = model.geoViewExtent!.width * 0.5
***REMOVED******REMOVED***builder.offsetBy(x: fiftyPercentWidth, y: 0.0)
***REMOVED******REMOVED***newExtent = builder.toGeometry() as! Envelope
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.geoViewExtent = newExtent
***REMOVED******REMOVED***XCTAssertTrue(model.isEligibleForRequery)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryArea to Chippewa Falls
***REMOVED******REMOVED***model.queryArea = Polygon.chippewaFalls
***REMOVED******REMOVED***model.geoViewExtent = Polygon.chippewaFalls.extent
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***_ = try await model.$results.compactMap({$0***REMOVED***).dropFirst().first
***REMOVED******REMOVED***XCTAssertFalse(model.isEligibleForRequery)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Expand extent by 1.1x - isEligibleForRequery should still be `false`.
***REMOVED******REMOVED***builder = EnvelopeBuilder(envelope: model.geoViewExtent)
***REMOVED******REMOVED***builder.expand(factor: 1.1)
***REMOVED******REMOVED***newExtent = builder.toGeometry() as! Envelope
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.geoViewExtent = newExtent
***REMOVED******REMOVED***XCTAssertFalse(model.isEligibleForRequery)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Expand extent by 1.5x - isEligibleForRequery should now be `true`.
***REMOVED******REMOVED***builder = EnvelopeBuilder(envelope: model.geoViewExtent)
***REMOVED******REMOVED***builder.expand(factor: 1.5)
***REMOVED******REMOVED***newExtent = builder.toGeometry() as! Envelope
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.geoViewExtent = newExtent
***REMOVED******REMOVED***XCTAssertTrue(model.isEligibleForRequery)
***REMOVED***
***REMOVED***
***REMOVED***func testQueryArea() async throws {
***REMOVED******REMOVED***let source = LocatorSearchSource()
***REMOVED******REMOVED***source.maximumResults = Int32.max
***REMOVED******REMOVED***let model = BasemapGalleryViewModel(sources: [source])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryArea to Chippewa Falls
***REMOVED******REMOVED***model.queryArea = Polygon.chippewaFalls
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***var result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let resultGeometryUnion: Geometry = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***GeometryEngine.union(
***REMOVED******REMOVED******REMOVED******REMOVED***geometries: result.compactMap{ $0.geoElement?.geometry ***REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***GeometryEngine.contains(
***REMOVED******REMOVED******REMOVED******REMOVED***geometry1: model.queryArea!,
***REMOVED******REMOVED******REMOVED******REMOVED***geometry2: resultGeometryUnion
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.queryArea = Polygon.minneapolis
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** A note about the use of `.dropFirst()`:
***REMOVED******REMOVED******REMOVED*** Because `model.results` is not changed between the previous call
***REMOVED******REMOVED******REMOVED*** to `model.commitSearch()` and the one right above, the
***REMOVED******REMOVED******REMOVED*** `try await model.$results...` call will return the last result
***REMOVED******REMOVED******REMOVED*** received (from the first `model.commitSearch()` call), which is
***REMOVED******REMOVED******REMOVED*** incorrect.  Calling `.dropFirst()` will remove that one
***REMOVED******REMOVED******REMOVED*** and will give us the next one, which is the correct one (the result
***REMOVED******REMOVED******REMOVED*** from the second `model.commitSearch()` call).
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).dropFirst().first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED***
***REMOVED***
***REMOVED***func testQueryCenter() async throws {
***REMOVED******REMOVED***let model = BasemapGalleryViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryCenter to Portland
***REMOVED******REMOVED***model.queryCenter = .portland
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***var result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***
***REMOVED******REMOVED***var resultPoint = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***result.first?.geoElement?.geometry as? Point
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var geodeticDistance = try XCTUnwrap (
***REMOVED******REMOVED******REMOVED***GeometryEngine.distanceGeodetic(
***REMOVED******REMOVED******REMOVED******REMOVED***point1: .portland,
***REMOVED******REMOVED******REMOVED******REMOVED***point2: resultPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***distanceUnit: .meters,
***REMOVED******REMOVED******REMOVED******REMOVED***azimuthUnit: nil,
***REMOVED******REMOVED******REMOVED******REMOVED***curveType: .geodesic
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** First result within 1500m of Portland.
***REMOVED******REMOVED***XCTAssertLessThan(geodeticDistance.distance,  1500.0)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryCenter to Edinburgh
***REMOVED******REMOVED***model.queryCenter = .edinburgh
***REMOVED******REMOVED***model.currentQuery = "Restaurants"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***
***REMOVED******REMOVED***resultPoint = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***result.first?.geoElement?.geometry as? Point
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Web Mercator distance between .edinburgh and first result.
***REMOVED******REMOVED***geodeticDistance = try XCTUnwrap (
***REMOVED******REMOVED******REMOVED***GeometryEngine.distanceGeodetic(
***REMOVED******REMOVED******REMOVED******REMOVED***point1: .edinburgh,
***REMOVED******REMOVED******REMOVED******REMOVED***point2: resultPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***distanceUnit: .meters,
***REMOVED******REMOVED******REMOVED******REMOVED***azimuthUnit: nil,
***REMOVED******REMOVED******REMOVED******REMOVED***curveType: .geodesic
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** First result within 100m of Edinburgh.
***REMOVED******REMOVED***XCTAssertLessThan(geodeticDistance.distance,  100)
***REMOVED***
***REMOVED***
***REMOVED***func testRepeatSearch() async throws {
***REMOVED******REMOVED***let model = BasemapGalleryViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set queryArea to Chippewa Falls
***REMOVED******REMOVED***model.geoViewExtent = Polygon.chippewaFalls.extent
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.repeatSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***var result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let resultGeometryUnion: Geometry = try XCTUnwrap(
***REMOVED******REMOVED******REMOVED***GeometryEngine.union(
***REMOVED******REMOVED******REMOVED******REMOVED***geometries: result.compactMap{ $0.geoElement?.geometry ***REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***GeometryEngine.contains(
***REMOVED******REMOVED******REMOVED******REMOVED***geometry1: model.geoViewExtent!,
***REMOVED******REMOVED******REMOVED******REMOVED***geometry2: resultGeometryUnion
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn Booksellers"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.repeatSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.geoViewExtent = Polygon.minneapolis.extent
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.repeatSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).dropFirst().first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED***
***REMOVED***
***REMOVED***func testSearchResultMode() async throws {
***REMOVED******REMOVED***let model = BasemapGalleryViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***XCTAssertEqual(model.resultMode, .automatic)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.resultMode = .single
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***var result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.resultMode = .multiple
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.commitSearch() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).dropFirst().first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.currentQuery = "Coffee"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.updateSuggestions() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let suggestionResults = try await model.$suggestions.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***let suggestions = try XCTUnwrap(suggestionResults?.get())
***REMOVED******REMOVED***
***REMOVED******REMOVED***let collectionSuggestion = try XCTUnwrap(suggestions.filter { $0.isCollection ***REMOVED***.first)
***REMOVED******REMOVED***let singleSuggestion = try XCTUnwrap(suggestions.filter { !$0.isCollection ***REMOVED***.first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.resultMode = .automatic
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.acceptSuggestion(collectionSuggestion) ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertGreaterThan(result.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.acceptSuggestion(singleSuggestion) ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***results = try await model.$results.compactMap({$0***REMOVED***).dropFirst().first
***REMOVED******REMOVED***result = try XCTUnwrap(results?.get())
***REMOVED******REMOVED***XCTAssertEqual(result.count, 1)
***REMOVED***
***REMOVED***
***REMOVED***func testUpdateSuggestions() async throws {
***REMOVED******REMOVED***let model = BasemapGalleryViewModel(sources: [LocatorSearchSource()])
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** No currentQuery - suggestions are nil.
***REMOVED******REMOVED***XCTAssertNil(model.suggestions)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** UpdateSuggestions with no results - result count is 0.
***REMOVED******REMOVED***model.currentQuery = "No results found blah blah blah blah"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.updateSuggestions() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var suggestionResults = try await model.$suggestions.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***var suggestions = try XCTUnwrap(suggestionResults?.get())
***REMOVED******REMOVED***XCTAssertEqual(suggestions.count, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** UpdateSuggestions with results.
***REMOVED******REMOVED***model.currentQuery = "Magers & Quinn"
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task { model.updateSuggestions() ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***suggestionResults = try await model.$suggestions.compactMap({$0***REMOVED***).first
***REMOVED******REMOVED***suggestions = try XCTUnwrap(suggestionResults?.get())
***REMOVED******REMOVED***XCTAssertGreaterThanOrEqual(suggestions.count, 1)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(model.selectedResult)
***REMOVED******REMOVED***XCTAssertNil(model.results)
***REMOVED***
***REMOVED*** */
***REMOVED***

***REMOVED***extension Polygon {
***REMOVED******REMOVED***static var chippewaFalls: Polygon {
***REMOVED******REMOVED******REMOVED***let builder = PolygonBuilder(spatialReference: .wgs84)
***REMOVED******REMOVED******REMOVED***let _ = builder.add(point: Point(x: -91.59127653822401, y: 44.74770908213401, spatialReference: .wgs84))
***REMOVED******REMOVED******REMOVED***let _ = builder.add(point: Point(x: -91.19322516572637, y: 44.74770908213401, spatialReference: .wgs84))
***REMOVED******REMOVED******REMOVED***let _ = builder.add(point: Point(x: -91.19322516572637, y: 45.116100854348254, spatialReference: .wgs84))
***REMOVED******REMOVED******REMOVED***let _ = builder.add(point: Point(x: -91.59127653822401, y: 45.116100854348254, spatialReference: .wgs84))
***REMOVED******REMOVED******REMOVED***return builder.toGeometry() as! ArcGIS.Polygon
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***static var minneapolis: Polygon {
***REMOVED******REMOVED******REMOVED***let builder = PolygonBuilder(spatialReference: .wgs84)
***REMOVED******REMOVED******REMOVED***let _ = builder.add(point: Point(x: -94.170821328662, y: 44.13656401114444, spatialReference: .wgs84))
***REMOVED******REMOVED******REMOVED***let _ = builder.add(point: Point(x: -94.170821328662, y: 44.13656401114444, spatialReference: .wgs84))
***REMOVED******REMOVED******REMOVED***let _ = builder.add(point: Point(x: -92.34544467133114, y: 45.824325577904446, spatialReference: .wgs84))
***REMOVED******REMOVED******REMOVED***let _ = builder.add(point: Point(x: -92.34544467133114, y: 45.824325577904446, spatialReference: .wgs84))
***REMOVED******REMOVED******REMOVED***return builder.toGeometry() as! ArcGIS.Polygon
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***extension Point {
***REMOVED******REMOVED***static let edinburgh = Point(x: -3.188267, y: 55.953251, spatialReference: .wgs84)
***REMOVED******REMOVED***static let portland = Point(x: -122.658722, y: 45.512230, spatialReference: .wgs84)
***REMOVED******REMOVED***
***REMOVED***
