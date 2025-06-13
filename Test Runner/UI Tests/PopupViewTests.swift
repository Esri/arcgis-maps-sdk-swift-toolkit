// Copyright 2025 Esri
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

@MainActor
final class PopupViewTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Opens a popup in the `PopupTestView`.
    /// - Parameters:
    ///   - objectID: The object ID of the feature that will be used to create the `Popup`.
    ///   - layerName: The name of the `FeatureLayer` containing the feature.
    func openPopup(_ objectID: Int, on layerName: String) {
        let app = XCUIApplication()
        let popupTestsButton = app.buttons["Popup Tests"]
        
        // Adds the launch arguments that will be read in the popup test view.
        let openPopupArguments = ["-objectID", "\(objectID)", "-layerName", "\(layerName)"]
        app.launchArguments.append(contentsOf: openPopupArguments)
        
        // Opens the popup test view.
        app.launch()
        popupTestsButton.tap()
    }
    
    // MARK: - UtilityAssociationsPopupElement Tests
    
    /// Asserts that a `PopupView` with a given title has opened and its elements have loaded.
    /// - Parameters:
    ///   - popupTitle: The title element of the popup view.
    func assertPopupOpened(
        popupTitle: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let app = XCUIApplication()
        let evaluatingExpressionsText = app.staticTexts["Evaluating popup expressions"]
        let fetchingFilterResultsIndicator = app.activityIndicators["Fetching filter results"]
        
        XCTAssertTrue(
            popupTitle.waitForExistence(timeout: 30),
            "The popup view failed to open after 30 seconds.",
            file: file,
            line: line
        )
        XCTAssertTrue(
            evaluatingExpressionsText.waitForNonExistence(timeout: 15),
            "The popup expressions didn't finish evaluating after 15 seconds.",
            file: file,
            line: line
        )
        XCTAssertTrue(
            fetchingFilterResultsIndicator.waitForNonExistence(timeout: 15),
            "The associations filer results didn't finish fetching after 15 seconds.",
            file: file,
            line: line
        )
    }
    
    /// Verifies that the correct default titles are shown for an associations
    /// element with no titles specified in the web definition.
    func testDefaultTitles() {
        let app = XCUIApplication()
        let associationsElement = app.staticTexts["Associations"]
        let connectivityFilterResult = app.staticTexts["Connectivity"]
        let containerFilterResult = app.staticTexts["Container"]
        let filterResults = app.buttons.matching(identifier: "Associations Filter Result")
        let popupTitle = app.staticTexts["Electric Distribution Device: Arrester"]
        let structureFilterResult = app.staticTexts["Structure"]
        
        openPopup(3216, on: "Electric Distribution Device")
        assertPopupOpened(popupTitle: popupTitle)
        
        XCTAssertTrue(
            associationsElement.exists,
            "The element \"Associations\" doesn't exist."
        )
        
        XCTAssertEqual(filterResults.count, 3)
        XCTAssertTrue(
            connectivityFilterResult.exists,
            "The filter result \"Connectivity\" doesn't exist."
        )
        XCTAssertTrue(
            containerFilterResult.exists,
            "The filter result \"Container\" doesn't exist."
        )
        XCTAssertTrue(
            structureFilterResult.exists,
            "The filter result \"Structure\" doesn't exist."
        )
    }
    
    /// Verifies that "No Associations" is displayed for an element with no filter results.
    func testNoAssociations() {
        let app = XCUIApplication()
        let associationsElements = app.buttons.matching(identifier: "Associations Popup Element")
        let filterResults = app.buttons.matching(identifier: "Associations Filter Result")
        let noAssociationsText = app.staticTexts["No Associations"]
        let popupTitle = app.staticTexts["Electric Distribution Line: Medium Voltage"]
        
        openPopup(513, on: "Electric Distribution Line")
        assertPopupOpened(popupTitle: popupTitle)
        
        // Expectation: There is only one associations element with no filter results.
        XCTAssertEqual(associationsElements.count, 1)
        XCTAssertEqual(filterResults.count, 0)
        
        // Expectation: "No Associations" is shown.
        XCTAssertTrue(
            noAssociationsText.waitForExistence(timeout: 5),
            "The \"No Associations\" text doesn't exist."
        )
    }
    
    /// Verifies that navigating through associations results works as expected.
    func testNavigation() {
        let app = XCUIApplication()
        let backButton = app.buttons.matching(identifier: "Back").element(boundBy: 1)
        let filterResult = app.buttons["Content, 3"]
        let fuseText = app.staticTexts["Electric Distribution Device: Fuse"]
        let groupResult = app.buttons["Electric Distribution Device, 3"]
        let showAllButton = app.buttons["Show all, Total: 3"]
        let switchgearText = app.staticTexts["Structure Junction: Switchgear"]
        let titleField = app.textFields["Title"]
        
        openPopup(1464, on: "Structure Junction")
        assertPopupOpened(popupTitle: switchgearText)
        
        // Expectation: A filter result opens the group result list.
        XCTAssertTrue(
            filterResult.exists,
            "The filter result \"Content, 3\" doesn't exist."
        )
        filterResult.tap()
        
        XCTAssertTrue(
            groupResult.waitForExistence(timeout: 3),
            "The group result \"Electric Distribution Device, 3\" failed to appear."
        )
        
        // Expectation: A result opens new popup with the result's label as the title.
        XCTAssertTrue(
            fuseText.exists,
            "The result \"Electric Distribution Device: Fuse\" doesn't exist."
        )
        fuseText.tap()
        
        assertPopupOpened(popupTitle: fuseText)
        
        // Expectation: The popup back button opens the group result list again.
        XCTAssertTrue(
            backButton.exists,
            "The \"Back\" button doesn't exist."
        )
        backButton.tap()
        
        XCTAssertTrue(
            groupResult.waitForExistence(timeout: 3),
            "The group result \"Electric Distribution Device, 3\" failed to appear."
        )
        
        // Expectation: The show all button opens the "Show all" view.
        XCTAssertTrue(
            showAllButton.exists,
            "The \"Show all, Total: 3\" button doesn't exist."
        )
        showAllButton.tap()
        
        XCTAssertTrue(
            titleField.waitForExistence(timeout: 3),
            "The \"Title\" field failed to appear."
        )
        
        // Expectation: A result from the "Show all" view also opens a new popup.
        XCTAssertTrue(
            fuseText.exists,
            "The result \"Electric Distribution Device: Fuse\" doesn't exist."
        )
        fuseText.firstMatch.tap()
        
        assertPopupOpened(popupTitle: fuseText)
        
        // Expectation: The popup back button opens the "Show all" view again.
        XCTAssertTrue(
            backButton.exists,
            "The \"Back\" button doesn't exist."
        )
        backButton.tap()
        
        XCTAssertTrue(
            titleField.waitForExistence(timeout: 3),
            "The \"Title\" field failed to appear."
        )
        
        // Expectation: The "Show all" back button opens the group result list again.
        XCTAssertTrue(
            backButton.exists,
            "The \"Back\" button doesn't exist."
        )
        backButton.tap()
        
        XCTAssertTrue(
            groupResult.waitForExistence(timeout: 3),
            "The group result \"Electric Distribution Device, 3\" failed to appear."
        )
        
        // Expectation: The group result list back button opens the original popup.
        backButton.tap()
        
        assertPopupOpened(popupTitle: switchgearText)
        
        XCTAssertFalse(
            backButton.exists,
            "The \"Back\" has not disappeared."
        )
    }
    
    /// Verifies that the `UtilityAssociationsPopupElement.displayCount` is respected.
    func testDisplayCount() {
        let app = XCUIApplication()
        let associationResults = app.buttons.matching(identifier: "Association Result")
        let contentFilterResult = app.buttons["Content, 3"]
        let popupTitle = app.staticTexts["Electric Distribution Assembly: Switch Bank"]
        let groupResult = app.buttons["Electric Distribution Device, 3"]
        let groupResults = app.buttons.matching(identifier: "Association Group Result")
        let showAllButton = app.buttons["Show all, Total: 3"]
        let titleField = app.textFields["Title"]
        
        openPopup(316, on: "Electric Distribution Assembly")
        assertPopupOpened(popupTitle: popupTitle)
        
        // Opens the filter result.
        XCTAssertTrue(
            contentFilterResult.exists,
            "The filter result \"Content, 3\" doesn't exist."
        )
        contentFilterResult.tap()
        
        XCTAssertTrue(
            groupResult.waitForExistence(timeout: 3),
            "The group result \"Electric Distribution Device, 3\" failed to appear."
        )
        
        // Expectation: The group result has only 1 result, same as the `displayCount`.
        XCTAssertEqual(groupResults.count, 1)
        XCTAssertEqual(associationResults.count, 1)
        
        // Opens the "Show all" view.
        XCTAssertTrue(
            showAllButton.exists,
            "The \"Show all, Total: 3\" button doesn't exist."
        )
        showAllButton.tap()
        
        XCTAssertTrue(
            titleField.waitForExistence(timeout: 3),
            "The \"Title\" field failed to appear."
        )
        
        // Expectation: All of the results are now shown.
        XCTAssertEqual(associationResults.count, 3)
    }
    
    /// Verifies that the searching filters the association results as expected.
    func testSearchResults() {
        let app = XCUIApplication()
        let associationResults = app.buttons.matching(identifier: "Association Result")
        let cancelButton = app.buttons["Cancel"]
        let filterResult = app.buttons["Content, 6"]
        let popupTitle = app.staticTexts["Electric Distribution Assembly: Fuse Bank"]
        let groupResult = app.buttons["Electric Distribution Device, 6"]
        let showAllButton = app.buttons["Show all, Total: 6"]
        let titleField = app.textFields["Title"]
        
        openPopup(475, on: "Electric Distribution Assembly")
        assertPopupOpened(popupTitle: popupTitle)
        
        // Opens the filter result.
        XCTAssertTrue(
            filterResult.exists,
            "The filter result \"Content, 6\" doesn't exist."
        )
        filterResult.tap()
        
        XCTAssertTrue(
            groupResult.waitForExistence(timeout: 3),
            "The group result \"Electric Distribution Device, 6\" failed to appear."
        )
        
        // Opens the "Show all" view.
        XCTAssertTrue(
            showAllButton.exists,
            "The \"Show all, Total: 6\" button doesn't exist."
        )
        showAllButton.tap()
        
        XCTAssertTrue(
            titleField.waitForExistence(timeout: 3),
            "The \"Title\" field failed to appear."
        )
        
        // Expectation: There are 6 results to begin with.
        XCTAssertEqual(associationResults.count, 6)
        
        // Expectation: Searching filters the results to only those with the query in their title.
        titleField.tap()
        titleField.typeText("Arrester")
        
        XCTAssertEqual(associationResults.count, 3)
        XCTAssertTrue(
            associationResults.allElementsBoundByIndex.allSatisfy {
                $0.label.contains("Arrester")
            },
            "There are filter results that do not contain \"Arrester\" in their title."
        )
        
        // Expectation: The cancel button brings back all the results.
        XCTAssertTrue(
            cancelButton.exists,
            "The \"Cancel\" button doesn't exist."
        )
        cancelButton.tap()
        
        XCTAssertTrue(
            app.wait(for: \.keyboards.count, toEqual: 0, timeout: 3),
            "The keyboard failed to disappear."
        )
        
        XCTAssertEqual(associationResults.count, 6)
        
        // Expectation: The search is case insensitive.
        titleField.tap()
        titleField.typeText("fuse")
        
        XCTAssertEqual(associationResults.count, 3)
        XCTAssertTrue(
            associationResults.allElementsBoundByIndex.allSatisfy {
                $0.label.localizedStandardContains("fuse")
            },
            "There are filter results that do not contain \"fuse\" in their title."
        )
        
        // Expectation: Invalid search queries have no results.
        titleField.typeText("!")
        
        XCTAssertEqual(associationResults.count, 0)
    }
}
