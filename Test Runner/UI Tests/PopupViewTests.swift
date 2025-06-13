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
    
    /// Asserts that any `UtilityAssociationsPopupElement`s in an opened
    /// `PopupView` have finished fetching their associations filer results.
    /// - Parameters:
    ///   - popupTitle: The title element of the `PopupView` used to assert the
    ///   view has opened.
    func assertAssociationsElementsLoad(
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
        assertAssociationsElementsLoad(popupTitle: popupTitle)
        
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
        assertAssociationsElementsLoad(popupTitle: popupTitle)
        
        // Expectation: There is only one associations element with no filter results.
        XCTAssertEqual(associationsElements.count, 1)
        XCTAssertEqual(filterResults.count, 0)
        
        // Expectation: "No Associations" is shown.
        XCTAssertTrue(
            noAssociationsText.waitForExistence(timeout: 5),
            "The \"No Associations\" text doesn't exist."
        )
    }
}
