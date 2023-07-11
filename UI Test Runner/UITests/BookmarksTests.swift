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
***REMOVED******REMOVED******REMOVED*** Open the Bookmarks component test view.
***REMOVED******REMOVED***app.buttons["Bookmarks Tests"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the bookmark selection view.
***REMOVED******REMOVED***app.buttons["Bookmarks"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify that the directive UI label is present.
***REMOVED******REMOVED***XCTAssertTrue(app.staticTexts["Select a bookmark"].exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify that the expected bookmarks are present.
***REMOVED******REMOVED***XCTAssertTrue(app.buttons["Giant Sequoias of Willamette Blvd"].exists)
***REMOVED******REMOVED***XCTAssertTrue(app.buttons["Historic Ladd's Addition"].exists)
***REMOVED******REMOVED***XCTAssertTrue(app.buttons["Irvington neighborhood"].exists)
***REMOVED******REMOVED***XCTAssertTrue(app.buttons["Large Douglas-fir"].exists)
***REMOVED***
***REMOVED***
