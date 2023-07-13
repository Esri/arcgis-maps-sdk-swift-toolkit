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
***REMOVED******REMOVED***let filterButton = app.buttons["Business"]
***REMOVED******REMOVED***let researchAnnexButton = app.buttons["Research Annex"]
***REMOVED******REMOVED***let latticeText = app.staticTexts["Lattice"]
***REMOVED******REMOVED***let levelEightText = app.scrollViews.otherElements.staticTexts["8"]
***REMOVED******REMOVED***let levelOneText = app.staticTexts["1"]
***REMOVED******REMOVED***let collapseButton = app.buttons["Go Down"]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Floor Filter component test view.
***REMOVED******REMOVED***app.buttons["Floor Filter Tests"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for floor aware data to load and then open the filter.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***filterButton.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The filter button wasn't found within 5 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***filterButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Select the site named "Research Annex".
***REMOVED******REMOVED***XCTAssertTrue(researchAnnexButton.exists, "The Research Annex button wasn't found.")
***REMOVED******REMOVED***researchAnnexButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Select the facility named "Lattice".
***REMOVED******REMOVED***XCTAssertTrue(latticeText.exists, "The Lattice text wasn't found.")
***REMOVED******REMOVED***latticeText.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Select the level labeled "8".
***REMOVED******REMOVED***XCTAssertTrue(levelEightText.exists, "The level eight text wasn't found.")
***REMOVED******REMOVED***levelEightText.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify that the level selector is not collapsed
***REMOVED******REMOVED******REMOVED*** and other levels are available for selection.
***REMOVED******REMOVED***XCTAssertTrue(levelOneText.exists, "The level one text wasn't found.")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Collapse the level selector.
***REMOVED******REMOVED***XCTAssertTrue(collapseButton.exists, "The collapse button wasn't found.")
***REMOVED******REMOVED***collapseButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify that the level selector is collapsed.
***REMOVED******REMOVED***XCTAssertFalse(levelOneText.exists, "The collapse button was unexpectedly still present.")
***REMOVED***
***REMOVED***
