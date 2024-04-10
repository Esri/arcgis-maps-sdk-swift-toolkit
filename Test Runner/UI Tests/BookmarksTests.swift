***REMOVED*** Copyright 2023 Esri
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

import XCTest

final class BookmarksTests: XCTestCase {
***REMOVED***override func setUpWithError() throws {
***REMOVED******REMOVED***continueAfterFailure = false
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test general usage of the Bookmarks component.
***REMOVED***func testCase1() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
***REMOVED******REMOVED***let bookmarksButton = app.buttons["Bookmarks"].firstMatch
***REMOVED******REMOVED***let selectABookmarkText = app.staticTexts["Select a bookmark"]
***REMOVED******REMOVED***let giantSequoiasButton = app.buttons["Giant Sequoias of Willamette Blvd"].firstMatch
***REMOVED******REMOVED***let giantSequoiasLabel = app.staticTexts["Giant Sequoias of Willamette Blvd"].firstMatch
***REMOVED******REMOVED***let historicLaddsButton = app.buttons["Historic Ladd's Addition"].firstMatch
***REMOVED******REMOVED***let historicLaddsLabel = app.staticTexts["Historic Ladd's Addition"]
***REMOVED******REMOVED***let bookmarksTestCase1Button = app.buttons["Bookmarks Test Case 1"]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test views.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
***REMOVED******REMOVED***bookmarksTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test view.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksTestCase1Button.exists, "The Bookmarks Test Case 1 button wasn't found.")
***REMOVED******REMOVED***bookmarksTestCase1Button.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the bookmark selection view.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksButton.exists, "The Bookmarks button wasn't found.")
***REMOVED******REMOVED***bookmarksButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify that the directive UI label is present.
***REMOVED******REMOVED***XCTAssertTrue(selectABookmarkText.waitForExistence(timeout: 1.0), "The Select a bookmark text wasn't found.")
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
***REMOVED******REMOVED***/ Test using the Bookmarks component with a map with no bookmarks defined.
***REMOVED***func testCase2() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
***REMOVED******REMOVED***let bookmarksTestCase2Button = app.buttons["Bookmarks Test Case 2"]
***REMOVED******REMOVED***let noBookmarks = app.staticTexts["No bookmarks"]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test views.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
***REMOVED******REMOVED***bookmarksTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test view.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksTestCase2Button.exists, "The Bookmarks Test Case 2 button wasn't found.")
***REMOVED******REMOVED***bookmarksTestCase2Button.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(noBookmarks.waitForExistence(timeout: 5.0), "The \"No Bookmarks\" text wasn't found.")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test using the Bookmarks component no bookmarks defined.
***REMOVED***func testCase3() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
***REMOVED******REMOVED***let bookmarksTestCase3Button = app.buttons["Bookmarks Test Case 3"]
***REMOVED******REMOVED***let noBookmarks = app.staticTexts["No bookmarks"]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test views.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
***REMOVED******REMOVED***bookmarksTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test view.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksTestCase3Button.exists, "The Bookmarks Test Case 3 button wasn't found.")
***REMOVED******REMOVED***bookmarksTestCase3Button.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(noBookmarks.exists, "The \"No Bookmarks\" text wasn't found.")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test using the Bookmarks component with bookmarks provided directly.
***REMOVED***func testCase4() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
***REMOVED******REMOVED***let bookmarksTestCase4Button = app.buttons["Bookmarks Test Case 4"]
***REMOVED******REMOVED***let redlandsButton = app.buttons["Redlands"].firstMatch
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test views.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
***REMOVED******REMOVED***bookmarksTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test view.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksTestCase4Button.exists, "The Bookmarks Test Case 4 button wasn't found.")
***REMOVED******REMOVED***bookmarksTestCase4Button.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(redlandsButton.exists, "The Redlands button wasn't found.")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test using the Bookmarks component with bookmarks provided directly, creating new bookmarks
***REMOVED******REMOVED***/ while the component is displayed.
***REMOVED***func testCase5() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let addNewButton = app.buttons["Add New"].firstMatch
***REMOVED******REMOVED***let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
***REMOVED******REMOVED***let bookmarksTestCase5Button = app.buttons["Bookmarks Test Case 5"]
***REMOVED******REMOVED***let firstBookmark = app.buttons["Bookmark 1"].firstMatch
***REMOVED******REMOVED***let secondBookmark = app.buttons["Bookmark 2"].firstMatch
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test views.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
***REMOVED******REMOVED***bookmarksTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test view.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksTestCase5Button.exists, "The Bookmarks Test Case 5 button wasn't found.")
***REMOVED******REMOVED***bookmarksTestCase5Button.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(firstBookmark.exists, "The first bookmark wasn't found.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(secondBookmark.exists, "The second bookmark was present before it should've been.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***addNewButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(secondBookmark.exists, "The second bookmark wasn't found.")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test automatic pan and zoom to the selected bookmark.
***REMOVED***func testCase6() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
***REMOVED******REMOVED***let bookmarksTestCase6Button = app.buttons["Bookmarks Test Case 6"]
***REMOVED******REMOVED***let firstBookmark = app.buttons["San Diego Convention Center"].firstMatch
***REMOVED******REMOVED***let expectedCoordinatesLabel = app.staticTexts["32.7N 117.2W"]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test views.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
***REMOVED******REMOVED***bookmarksTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test view.
***REMOVED******REMOVED***XCTAssertTrue(bookmarksTestCase6Button.exists, "The Bookmarks Test Case 6 button wasn't found.")
***REMOVED******REMOVED***bookmarksTestCase6Button.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(firstBookmark.exists, "The first bookmark wasn't found.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***firstBookmark.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***expectedCoordinatesLabel.waitForExistence(timeout: 5.0),
***REMOVED******REMOVED******REMOVED***"The expected coordinate label doesn't exist."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
