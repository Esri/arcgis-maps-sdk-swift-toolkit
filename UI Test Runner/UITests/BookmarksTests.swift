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
        
        // Open the Bookmarks component test view.
        app.buttons["Bookmarks Tests"].tap()
        
        // Open the bookmark selection view.
        app.buttons["Bookmarks"].tap()
        
        // Verify that the directive UI label is present.
        XCTAssertTrue(app.staticTexts["Select a bookmark"].exists)
        
        // Select a bookmark and confirm the component notified the test view of the selection.
        app.buttons["Giant Sequoias of Willamette Blvd"].tap()
        XCTAssertTrue(app.staticTexts["Giant Sequoias of Willamette Blvd"].exists)
        
        // Verify that the bookmarks selection view is no longer present.
        XCTAssertFalse(app.staticTexts["Select a bookmark"].exists)
        
        // Re-open the bookmark selection view.
        app.buttons["Bookmarks"].tap()
        
        // Select a bookmark and confirm the component notified the test view of the new selection.
        app.buttons["Historic Ladd's Addition"].tap()
        XCTAssertTrue(app.staticTexts["Historic Ladd's Addition"].exists)
    }
}
