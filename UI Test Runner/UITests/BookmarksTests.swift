***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import XCTest

final class BookmarksTests: XCTestCase {
***REMOVED***override func setUpWithError() throws {
***REMOVED******REMOVED***continueAfterFailure = false
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test general usage of the Bookmarks component.
***REMOVED***func testBookmarks() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
***REMOVED******REMOVED***let bookmarksButton = app.buttons["Bookmarks"].firstMatch
***REMOVED******REMOVED***let selectABookmarkText = app.staticTexts["Select a bookmark"]
***REMOVED******REMOVED***let giantSequoiasButton = app.buttons["Giant Sequoias of Willamette Blvd"].firstMatch
***REMOVED******REMOVED***let giantSequoiasLabel = app.staticTexts["Giant Sequoias of Willamette Blvd"]
***REMOVED******REMOVED***let historicLaddsButton = app.buttons["Historic Ladd's Addition"].firstMatch
***REMOVED******REMOVED***let historicLaddsLabel = app.staticTexts["Historic Ladd's Addition"]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test view.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
***REMOVED******REMOVED***bookmarksTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the bookmark selection view.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksButton.exists, "The Bookmarks button wasn't found.")
***REMOVED******REMOVED***bookmarksButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify that the directive UI label is present.
***REMOVED******REMOVED***XCTAssertTrue(selectABookmarkText.exists, "The Select a bookmark text wasn't found.")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Select a bookmark and confirm the component notified the test view of the selection.
***REMOVED******REMOVED***XCTAssertTrue(giantSequoiasButton.waitForExistence(timeout: 1.0), "The Giant Sequoias button wasn't found.")
***REMOVED******REMOVED***giantSequoiasButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Confirm the selection was made.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***giantSequoiasLabel.exists,
***REMOVED******REMOVED******REMOVED***"The Giant Sequoias label confirming the bookmark selection wasn't found."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify that the bookmarks selection view is no longer present.
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***selectABookmarkText.exists,
***REMOVED******REMOVED******REMOVED***"The Select a bookmark text was unexpectedly found."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Re-open the bookmark selection view.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksButton.exists, "The Bookmarks button wasn't found.")
***REMOVED******REMOVED***bookmarksButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Select a bookmark and confirm the component notified the test view of the new selection.
***REMOVED******REMOVED***XCTAssertTrue(historicLaddsButton.waitForExistence(timeout: 1.0), "The Historic Ladd's button wasn't found.")
***REMOVED******REMOVED***historicLaddsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Confirm the selection was made.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***historicLaddsLabel.exists,
***REMOVED******REMOVED******REMOVED***"The Historic Ladd's label confirming the bookmark selection wasn't found."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
