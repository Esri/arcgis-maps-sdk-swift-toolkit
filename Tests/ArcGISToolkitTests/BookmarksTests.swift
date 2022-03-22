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

***REMOVED***
***REMOVED***
import XCTest
@testable ***REMOVED***Toolkit

class BookmarksTests: XCTestCase {
***REMOVED******REMOVED***/ Assert that the list properly handles a selction when provided a modifier.
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
***REMOVED******REMOVED******REMOVED***set: {_isPresented = $0 ***REMOVED***
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

***REMOVED******REMOVED***/ Assert that the list properly handles a selction when provided a modifier and web map.
***REMOVED***func testSelectBookmarkWithModifierAndWebMap() async {
***REMOVED******REMOVED***let expectation = XCTestExpectation(
***REMOVED******REMOVED******REMOVED***description: "Modifier action was performed"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let webMap = webMap
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await webMap.load()
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***XCTFail("Web map failed to load \(error.localizedDescription)")
***REMOVED***
***REMOVED******REMOVED***var _isPresented = true
***REMOVED******REMOVED***let isPresented = Binding(
***REMOVED******REMOVED******REMOVED***get: { _isPresented ***REMOVED***,
***REMOVED******REMOVED******REMOVED***set: {_isPresented = $0 ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let action: ((Bookmark) -> Void) = {
***REMOVED******REMOVED******REMOVED***expectation.fulfill()
***REMOVED******REMOVED******REMOVED***XCTAssertEqual($0.viewpoint, webMap.bookmarks.first?.viewpoint)
***REMOVED***
***REMOVED******REMOVED***var bookmarks = Bookmarks(
***REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED***mapOrScene: webMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***bookmarks.selectionChangedAction = action
***REMOVED******REMOVED***XCTAssertTrue(_isPresented)
***REMOVED******REMOVED***bookmarks.selectBookmark(webMap.bookmarks.first!)
***REMOVED******REMOVED***XCTAssertFalse(_isPresented)
***REMOVED******REMOVED***wait(for: [expectation], timeout: 1.0)
***REMOVED***

***REMOVED******REMOVED***/ Assert that the list properly handles a selction when provided a viewpoint.
***REMOVED***func testSelectBookmarkWithViewpoint() {
***REMOVED******REMOVED***let sampleBookmarks = sampleBookmarks
***REMOVED******REMOVED***var _isPresented = true
***REMOVED******REMOVED***let isPresented = Binding(
***REMOVED******REMOVED******REMOVED***get: { _isPresented ***REMOVED***,
***REMOVED******REMOVED******REMOVED***set: {_isPresented = $0 ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = getViewpoint(0)
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

***REMOVED******REMOVED***/ Assert that the list properly handles a selction when provided a viewpoint and web map.
***REMOVED***func testSelectBookmarkWithViewpointAndWebMap() async {
***REMOVED******REMOVED***let webMap = webMap
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await webMap.load()
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***XCTFail("Web map failed to load \(error.localizedDescription)")
***REMOVED***
***REMOVED******REMOVED***var _isPresented = true
***REMOVED******REMOVED***let isPresented = Binding(
***REMOVED******REMOVED******REMOVED***get: { _isPresented ***REMOVED***,
***REMOVED******REMOVED******REMOVED***set: {_isPresented = $0 ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = getViewpoint(0)
***REMOVED******REMOVED***let viewpoint = Binding(
***REMOVED******REMOVED******REMOVED***get: { _viewpoint ***REMOVED***,
***REMOVED******REMOVED******REMOVED***set: { _viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let bookmarks = Bookmarks(
***REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED***mapOrScene: webMap,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertTrue(_isPresented)
***REMOVED******REMOVED***XCTAssertNotEqual(_viewpoint, webMap.bookmarks.first?.viewpoint)
***REMOVED******REMOVED***bookmarks.selectBookmark(webMap.bookmarks.first!)
***REMOVED******REMOVED***XCTAssertFalse(_isPresented)
***REMOVED******REMOVED***XCTAssertEqual(_viewpoint, webMap.bookmarks.first?.viewpoint)
***REMOVED***
***REMOVED***

extension BookmarksTests {
***REMOVED******REMOVED***/ An arbitrary point to use for testing.
***REMOVED***var point: Point {
***REMOVED******REMOVED***Point(x: -117.19494, y: 34.05723, spatialReference: .wgs84)
***REMOVED***

***REMOVED******REMOVED***/ A list of sample bookmarks for testing
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

***REMOVED******REMOVED***/ An arbitrary scale to use for testing.
***REMOVED***var scale: Double {
***REMOVED******REMOVED***10_000.00
***REMOVED***

***REMOVED******REMOVED***/ A web map authored with bookmarks for testing.
***REMOVED***var webMap: Map {
***REMOVED******REMOVED***return Map(url: URL(string: "https:***REMOVED***www.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!
***REMOVED***

***REMOVED******REMOVED***/ Builds viewpoints to use for tests.
***REMOVED******REMOVED***/ - Parameter rotation: The rotation to use for the resulting viewpoint.
***REMOVED******REMOVED***/ - Returns: A viewpoint object for tests.
***REMOVED***func getViewpoint(_ rotation: Double) -> Viewpoint {
***REMOVED******REMOVED***return Viewpoint(center: point, scale: scale, rotation: rotation)
***REMOVED***
***REMOVED***
