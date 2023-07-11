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
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    /// Test general usage of the Bookmarks component.
    func testBookmarks() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Open the GeoView examples category.
        app.buttons["GeoView"].tap()
        
        // Open the Bookmarks component example view.
        app.buttons["Bookmarks"].tap()
        
        // Open the bookmark selection view.
        app.buttons["Show Bookmarks"].tap()
        
        // Verify that the directive UI label is present.
        XCTAssertTrue(app.staticTexts["Select a bookmark"].exists)
        
        // Verify that the expected bookmarks are present.
        XCTAssertTrue(app.buttons["Giant Sequoias of Willamette Blvd"].exists)
        XCTAssertTrue(app.buttons["Historic Ladd's Addition"].exists)
        XCTAssertTrue(app.buttons["Irvington neighborhood"].exists)
        XCTAssertTrue(app.buttons["Large Douglas-fir"].exists)
    }
}
