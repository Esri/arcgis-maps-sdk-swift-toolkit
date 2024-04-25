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

final class FloorFilterTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Test general usage of the Floor Filter component.
    func testFloorFilter() throws {
        let app = XCUIApplication()
        app.launch()
        
        let filterButton = app.buttons["Business"]
        let researchAnnexButton = app.buttons["Research Annex"]
        let latticeText = app.staticTexts["Lattice"]
        let levelEightText = app.scrollViews.otherElements.staticTexts["8"]
        let levelOneText = app.staticTexts["1"]
        let collapseButton = app.buttons["Go Down"]
        
        // Open the Floor Filter component test view.
        app.buttons["Floor Filter Tests"].tap()
        
        // Wait for floor aware data to load and then open the filter.
        XCTAssertTrue(
            filterButton.waitForExistence(timeout: 5),
            "The filter button wasn't found within 5 seconds."
        )
        filterButton.tap()
        
        // Select the site named "Research Annex".
        XCTAssertTrue(
            researchAnnexButton.waitForExistence(timeout: 2),
            "The Research Annex button wasn't found within 2 seconds."
        )
        researchAnnexButton.tap()
        
        // Select the facility named "Lattice".
        XCTAssertTrue(
            latticeText.waitForExistence(timeout: 10),
            "The Lattice text wasn't found."
        )
        latticeText.tap()
        
        // Select the level labeled "8".
        XCTAssertTrue(levelEightText.exists, "The level eight text wasn't found.")
        levelEightText.tap()
        
        // Verify that the level selector is not collapsed
        // and other levels are available for selection.
        XCTAssertTrue(levelOneText.exists, "The level one text wasn't found.")
        
        // Collapse the level selector.
        XCTAssertTrue(collapseButton.exists, "The collapse button wasn't found.")
        collapseButton.tap()
        
        // Verify that the level selector is collapsed.
        XCTAssertFalse(levelOneText.exists, "The collapse button was unexpectedly still present.")
    }
}
