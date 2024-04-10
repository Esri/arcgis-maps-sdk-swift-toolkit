// Copyright 2023 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest

final class BookmarksTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Test general usage of the Bookmarks component.
    func testCase1() throws {
        let app = XCUIApplication()
        app.launch()
        
        let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
        let bookmarksButton = app.buttons["Bookmarks"].firstMatch
        let selectABookmarkText = app.staticTexts["Select a bookmark"]
        let giantSequoiasButton = app.buttons["Giant Sequoias of Willamette Blvd"].firstMatch
        let giantSequoiasLabel = app.staticTexts["Giant Sequoias of Willamette Blvd"].firstMatch
        let historicLaddsButton = app.buttons["Historic Ladd's Addition"].firstMatch
        let historicLaddsLabel = app.staticTexts["Historic Ladd's Addition"]
        let bookmarksTestCase1Button = app.buttons["Bookmarks Test Case 1"]
        
        // Open the Bookmarks component test views.
        XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
        bookmarksTestsButton.tap()
        
        // Open the Bookmarks component test view.
        XCTAssertTrue(bookmarksTestCase1Button.exists, "The Bookmarks Test Case 1 button wasn't found.")
        bookmarksTestCase1Button.tap()
        
        // Open the bookmark selection view.
        XCTAssertTrue(bookmarksButton.exists, "The Bookmarks button wasn't found.")
        bookmarksButton.tap()
        
        // Verify that the directive UI label is present.
        XCTAssertTrue(selectABookmarkText.waitForExistence(timeout: 1.0), "The Select a bookmark text wasn't found.")
        
        // Select a bookmark and confirm the component notified the test view of the selection.
        XCTAssertTrue(giantSequoiasButton.waitForExistence(timeout: 1.0), "The Giant Sequoias button wasn't found.")
        giantSequoiasButton.tap()
        
        // Confirm the selection was made.
        XCTAssertTrue(
            giantSequoiasLabel.exists,
            "The Giant Sequoias label confirming the bookmark selection wasn't found."
        )
        
        // Verify that the bookmarks selection view is no longer present.
        XCTAssertFalse(
            selectABookmarkText.exists,
            "The Select a bookmark text was unexpectedly found."
        )
        
        // Re-open the bookmark selection view.
        XCTAssertTrue(bookmarksButton.exists, "The Bookmarks button wasn't found.")
        bookmarksButton.tap()
        
        // Select a bookmark and confirm the component notified the test view of the new selection.
        XCTAssertTrue(historicLaddsButton.waitForExistence(timeout: 1.0), "The Historic Ladd's button wasn't found.")
        historicLaddsButton.tap()
        
        // Confirm the selection was made.
        XCTAssertTrue(
            historicLaddsLabel.exists,
            "The Historic Ladd's label confirming the bookmark selection wasn't found."
        )
    }
    
    /// Test using the Bookmarks component with a map with no bookmarks defined.
    func testCase2() throws {
        let app = XCUIApplication()
        app.launch()
        
        let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
        let bookmarksTestCase2Button = app.buttons["Bookmarks Test Case 2"]
        let noBookmarks = app.staticTexts["No bookmarks"]
        
        // Open the Bookmarks component test views.
        XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
        bookmarksTestsButton.tap()
        
        // Open the Bookmarks component test view.
        XCTAssertTrue(bookmarksTestCase2Button.exists, "The Bookmarks Test Case 2 button wasn't found.")
        bookmarksTestCase2Button.tap()
        
        XCTAssertTrue(noBookmarks.waitForExistence(timeout: 5.0), "The \"No Bookmarks\" text wasn't found.")
    }
    
    /// Test using the Bookmarks component no bookmarks defined.
    func testCase3() throws {
        let app = XCUIApplication()
        app.launch()
        
        let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
        let bookmarksTestCase3Button = app.buttons["Bookmarks Test Case 3"]
        let noBookmarks = app.staticTexts["No bookmarks"]
        
        // Open the Bookmarks component test views.
        XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
        bookmarksTestsButton.tap()
        
        // Open the Bookmarks component test view.
        XCTAssertTrue(bookmarksTestCase3Button.exists, "The Bookmarks Test Case 3 button wasn't found.")
        bookmarksTestCase3Button.tap()
        
        XCTAssertTrue(noBookmarks.exists, "The \"No Bookmarks\" text wasn't found.")
    }
    
    /// Test using the Bookmarks component with bookmarks provided directly.
    func testCase4() throws {
        let app = XCUIApplication()
        app.launch()
        
        let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
        let bookmarksTestCase4Button = app.buttons["Bookmarks Test Case 4"]
        let redlandsButton = app.buttons["Redlands"].firstMatch
        
        // Open the Bookmarks component test views.
        XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
        bookmarksTestsButton.tap()
        
        // Open the Bookmarks component test view.
        XCTAssertTrue(bookmarksTestCase4Button.exists, "The Bookmarks Test Case 4 button wasn't found.")
        bookmarksTestCase4Button.tap()
        
        XCTAssertTrue(redlandsButton.exists, "The Redlands button wasn't found.")
    }
    
    /// Test using the Bookmarks component with bookmarks provided directly, creating new bookmarks
    /// while the component is displayed.
    func testCase5() throws {
        let app = XCUIApplication()
        app.launch()
        
        let addNewButton = app.buttons["Add New"].firstMatch
        let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
        let bookmarksTestCase5Button = app.buttons["Bookmarks Test Case 5"]
        let firstBookmark = app.buttons["Bookmark 1"].firstMatch
        let secondBookmark = app.buttons["Bookmark 2"].firstMatch
        
        // Open the Bookmarks component test views.
        XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
        bookmarksTestsButton.tap()
        
        // Open the Bookmarks component test view.
        XCTAssertTrue(bookmarksTestCase5Button.exists, "The Bookmarks Test Case 5 button wasn't found.")
        bookmarksTestCase5Button.tap()
        
        XCTAssertTrue(firstBookmark.exists, "The first bookmark wasn't found.")
        
        XCTAssertFalse(secondBookmark.exists, "The second bookmark was present before it should've been.")
        
        addNewButton.tap()
        
        XCTAssertTrue(secondBookmark.exists, "The second bookmark wasn't found.")
    }
    
    /// Test automatic pan and zoom to the selected bookmark.
    func testCase6() {
        let app = XCUIApplication()
        app.launch()
        
        let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
        let bookmarksTestCase6Button = app.buttons["Bookmarks Test Case 6"]
        let firstBookmark = app.buttons["San Diego Convention Center"].firstMatch
        let expectedCoordinatesLabel = app.staticTexts["32.7N 117.2W"]
        
        // Open the Bookmarks component test views.
        XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
        bookmarksTestsButton.tap()
        
        // Open the Bookmarks component test view.
        XCTAssertTrue(bookmarksTestCase6Button.exists, "The Bookmarks Test Case 6 button wasn't found.")
        bookmarksTestCase6Button.tap()
        
        XCTAssertTrue(firstBookmark.exists, "The first bookmark wasn't found.")
        
        firstBookmark.tap()
        
        XCTAssertTrue(
            expectedCoordinatesLabel.waitForExistence(timeout: 5.0),
            "The expected coordinate label doesn't exist."
        )
    }
}
