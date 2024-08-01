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
***REMOVED***
import XCTest
@testable ***REMOVED***Toolkit

final class BookmarksTests: XCTestCase {
***REMOVED***@MainActor
***REMOVED***func testBookmarksWithGeoModel() async throws {
***REMOVED******REMOVED***var _isPresented = true
***REMOVED******REMOVED***var _selection: Bookmark?
***REMOVED******REMOVED***
***REMOVED******REMOVED***let map = Map.portlandTreeSurvey
***REMOVED******REMOVED***let bookmarks = Bookmarks(
***REMOVED******REMOVED******REMOVED***isPresented: Binding(get: { _isPresented ***REMOVED***, set: { _isPresented = $0 ***REMOVED***),
***REMOVED******REMOVED******REMOVED***geoModel: map,
***REMOVED******REMOVED******REMOVED***selection: Binding(get: { _selection ***REMOVED***, set: { _selection = $0 ***REMOVED***),
***REMOVED******REMOVED******REMOVED***geoViewProxy: nil
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***XCTFail("Web map failed to load \(error.localizedDescription)")
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***bookmarks.selectBookmark(map.bookmarks.first!)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(_isPresented)
***REMOVED******REMOVED***XCTAssertEqual(_selection, map.bookmarks.first)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testBookmarksWithList() {
***REMOVED******REMOVED***var _isPresented = true
***REMOVED******REMOVED***var _selection: Bookmark?
***REMOVED******REMOVED***
***REMOVED******REMOVED***let bookmarks = Bookmarks(
***REMOVED******REMOVED******REMOVED***isPresented: Binding(get: { _isPresented ***REMOVED***, set: { _isPresented = $0 ***REMOVED***),
***REMOVED******REMOVED******REMOVED***bookmarks: sampleBookmarks,
***REMOVED******REMOVED******REMOVED***selection: Binding(get: { _selection ***REMOVED***, set: { _selection = $0 ***REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***bookmarks.selectBookmark(sampleBookmarks.first!)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(_isPresented)
***REMOVED******REMOVED***XCTAssertEqual(_selection, sampleBookmarks.first)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Asserts that the list properly handles a selection when provided a modifier.
***REMOVED***@available(*, deprecated)
***REMOVED***@MainActor
***REMOVED***func testSelectBookmarkWithModifier() {
***REMOVED******REMOVED***let expectation = XCTestExpectation(
***REMOVED******REMOVED******REMOVED***description: "Modifier action was performed"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let sampleBookmarks = sampleBookmarks
***REMOVED******REMOVED***var _isPresented = true
***REMOVED******REMOVED***let action: ((Bookmark) -> Void) = {
***REMOVED******REMOVED******REMOVED***expectation.fulfill()
***REMOVED******REMOVED******REMOVED***XCTAssertEqual($0.viewpoint, sampleBookmarks.first?.viewpoint)
***REMOVED***
***REMOVED******REMOVED***let isPresented = Binding(
***REMOVED******REMOVED******REMOVED***get: { _isPresented ***REMOVED***,
***REMOVED******REMOVED******REMOVED***set: { _isPresented = $0 ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***var bookmarks = Bookmarks(
***REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED***bookmarks: sampleBookmarks
***REMOVED******REMOVED***)
***REMOVED******REMOVED***bookmarks.selectionChangedAction = action
***REMOVED******REMOVED***XCTAssertTrue(_isPresented)
***REMOVED******REMOVED***bookmarks.selectBookmark(sampleBookmarks.first!)
***REMOVED******REMOVED***XCTAssertFalse(_isPresented)
***REMOVED******REMOVED***wait(for: [expectation], timeout: 1.0)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Asserts that the list properly handles a selection when provided a modifier and web map.
***REMOVED***@available(*, deprecated)
***REMOVED***@MainActor
***REMOVED***func testSelectBookmarkWithModifierAndMap() async throws {
***REMOVED******REMOVED***let map = Map.portlandTreeSurvey
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***XCTFail("Web map failed to load \(error.localizedDescription)")
***REMOVED***
***REMOVED******REMOVED***var _isPresented = true
***REMOVED******REMOVED***let isPresented = Binding(
***REMOVED******REMOVED******REMOVED***get: { _isPresented ***REMOVED***,
***REMOVED******REMOVED******REMOVED***set: { _isPresented = $0 ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var selectedBookmark: Bookmark?
***REMOVED******REMOVED***let bookmarks = Bookmarks(isPresented: isPresented,geoModel: map)
***REMOVED******REMOVED******REMOVED***.onSelectionChanged { selectedBookmark = $0 ***REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(_isPresented)
***REMOVED******REMOVED***let firstBookmark = try XCTUnwrap(map.bookmarks.first)
***REMOVED******REMOVED***bookmarks.selectBookmark(firstBookmark)
***REMOVED******REMOVED***XCTAssertFalse(_isPresented)
***REMOVED******REMOVED***XCTAssertEqual(selectedBookmark, map.bookmarks.first)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Asserts that the list properly handles a selection when provided a viewpoint.
***REMOVED***@available(*, deprecated)
***REMOVED***@MainActor
***REMOVED***func testSelectBookmarkWithViewpoint() {
***REMOVED******REMOVED***let sampleBookmarks = sampleBookmarks
***REMOVED******REMOVED***var _isPresented = true
***REMOVED******REMOVED***let isPresented = Binding(
***REMOVED******REMOVED******REMOVED***get: { _isPresented ***REMOVED***,
***REMOVED******REMOVED******REMOVED***set: { _isPresented = $0 ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = Viewpoint.esriRedlandsCampus
***REMOVED******REMOVED***let viewpoint = Binding(
***REMOVED******REMOVED******REMOVED***get: { _viewpoint ***REMOVED***,
***REMOVED******REMOVED******REMOVED***set: { _viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let bookmarks = Bookmarks(
***REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED***bookmarks: sampleBookmarks,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertTrue(_isPresented)
***REMOVED******REMOVED***XCTAssertNotEqual(_viewpoint, sampleBookmarks.first?.viewpoint)
***REMOVED******REMOVED***bookmarks.selectBookmark(sampleBookmarks.first!)
***REMOVED******REMOVED***XCTAssertFalse(_isPresented)
***REMOVED******REMOVED***XCTAssertEqual(_viewpoint, sampleBookmarks.first?.viewpoint)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Asserts that the list properly handles a selection when provided a viewpoint and web map.
***REMOVED***@available(*, deprecated)
***REMOVED***@MainActor
***REMOVED***func testSelectBookmarkWithViewpointAndMap() async throws {
***REMOVED******REMOVED***let map = Map.portlandTreeSurvey
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***XCTFail("Web map failed to load \(error.localizedDescription)")
***REMOVED***
***REMOVED******REMOVED***var _isPresented = true
***REMOVED******REMOVED***let isPresented = Binding(
***REMOVED******REMOVED******REMOVED***get: { _isPresented ***REMOVED***,
***REMOVED******REMOVED******REMOVED***set: { _isPresented = $0 ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = Viewpoint.esriRedlandsCampus
***REMOVED******REMOVED***let viewpoint = Binding(
***REMOVED******REMOVED******REMOVED***get: { _viewpoint ***REMOVED***,
***REMOVED******REMOVED******REMOVED***set: { _viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let bookmarks = Bookmarks(
***REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED***geoModel: map,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertTrue(_isPresented)
***REMOVED******REMOVED***XCTAssertNotEqual(_viewpoint, map.bookmarks.first?.viewpoint)
***REMOVED******REMOVED***let firstBookmark = try XCTUnwrap(map.bookmarks.first)
***REMOVED******REMOVED***bookmarks.selectBookmark(firstBookmark)
***REMOVED******REMOVED***XCTAssertFalse(_isPresented)
***REMOVED******REMOVED***XCTAssertEqual(_viewpoint, map.bookmarks.first?.viewpoint)
***REMOVED***
***REMOVED***

private extension BookmarksTests {
***REMOVED******REMOVED***/ A list of sample bookmarks for testing.
***REMOVED***var sampleBookmarks: [Bookmark] {[
***REMOVED******REMOVED***Bookmark(
***REMOVED******REMOVED******REMOVED***name: "Yosemite National Park",
***REMOVED******REMOVED******REMOVED***viewpoint: Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: -119.538330,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: 37.865101,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***scale: 250_000
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***),
***REMOVED******REMOVED***Bookmark(
***REMOVED******REMOVED******REMOVED***name: "Zion National Park",
***REMOVED******REMOVED******REMOVED***viewpoint: Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: -113.028770,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: 37.297817,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***scale: 250_000
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***),
***REMOVED******REMOVED***Bookmark(
***REMOVED******REMOVED******REMOVED***name: "Yellowstone National Park",
***REMOVED******REMOVED******REMOVED***viewpoint: Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: -110.584663,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: 44.429764,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***scale: 375_000
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***),
***REMOVED******REMOVED***Bookmark(
***REMOVED******REMOVED******REMOVED***name: "Grand Canyon National Park",
***REMOVED******REMOVED******REMOVED***viewpoint: Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: -112.1129,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: 36.1069,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***scale: 375_000
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***),
***REMOVED***]***REMOVED***
***REMOVED***

private extension Map {
***REMOVED******REMOVED***/ A web map authored with bookmarks for testing.
***REMOVED***static let portlandTreeSurvey = Map(url: URL(string: "https:***REMOVED***www.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!
***REMOVED***

private extension Viewpoint {
***REMOVED***static let esriRedlandsCampus = Viewpoint(
***REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED***x: -117.19494,
***REMOVED******REMOVED******REMOVED***y: 34.05723,
***REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED***),
***REMOVED******REMOVED***scale: 10_000.00,
***REMOVED******REMOVED***rotation: .zero
***REMOVED***)
***REMOVED***
