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

final class FloorFilterTests: XCTestCase {
***REMOVED***override func setUpWithError() throws {
***REMOVED******REMOVED***continueAfterFailure = false
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test general usage of the Floor Filter component.
***REMOVED***func testFloorFilter() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Floor Filter component test view.
***REMOVED******REMOVED***app.buttons["Floor Filter Tests"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for floor aware data to load and then open the filter.
***REMOVED******REMOVED***let filterButton = app.buttons["Business"]
***REMOVED******REMOVED***_ = filterButton.waitForExistence(timeout: 5)
***REMOVED******REMOVED***filterButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Select the site named "Research Annex".
***REMOVED******REMOVED***app.buttons["Research Annex"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Select the facility named "Lattice".
***REMOVED******REMOVED***app.staticTexts["Lattice"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Select the level labeled "8".
***REMOVED******REMOVED***app.scrollViews.otherElements.staticTexts["8"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let levelOneButton = app.scrollViews.otherElements.staticTexts["1"]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify that the level selector is not collapsed
***REMOVED******REMOVED******REMOVED*** and other levels are available for selection.
***REMOVED******REMOVED***XCTAssertTrue(levelOneButton.exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Collapse the level selector.
***REMOVED******REMOVED***app.buttons["Go Down"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify that the level selector is collapsed.
***REMOVED******REMOVED***XCTAssertFalse(levelOneButton.exists)
***REMOVED***
***REMOVED***
