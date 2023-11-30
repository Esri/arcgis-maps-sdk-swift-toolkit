// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

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
    func testBookmarks() throws {
        let app = XCUIApplication()
        app.launch()
        
        let bookmarksTestsButton = app.buttons["Bookmarks Tests"]
        let bookmarksButton = app.buttons["Bookmarks"].firstMatch
        let selectABookmarkText = app.staticTexts["Select a bookmark"]
        let giantSequoiasButton = app.buttons["Giant Sequoias of Willamette Blvd"].firstMatch
        let giantSequoiasLabel = app.staticTexts["Giant Sequoias of Willamette Blvd"]
        let historicLaddsButton = app.buttons["Historic Ladd's Addition"].firstMatch
        let historicLaddsLabel = app.staticTexts["Historic Ladd's Addition"]
        
        // Open the Bookmarks component test view.
        XCTAssertTrue(bookmarksTestsButton.exists, "The Bookmarks Tests button wasn't found.")
        bookmarksTestsButton.tap()
        
        // Open the bookmark selection view.
        XCTAssertTrue(bookmarksButton.exists, "The Bookmarks button wasn't found.")
        bookmarksButton.tap()
        
        // Verify that the directive UI label is present.
        XCTAssertTrue(selectABookmarkText.exists, "The Select a bookmark text wasn't found.")
        
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
}
