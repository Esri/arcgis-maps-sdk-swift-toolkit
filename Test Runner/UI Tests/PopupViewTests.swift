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
    
    /// Verifies that the correct default titles are shown for an associations element with no titles specified.
    func testDefaultTitles() {
        let app = XCUIApplication()
        let associationsElement = app.staticTexts["Associations"]
        let connectivityFilterResult = app.staticTexts["Connectivity"]
        let containerFilterResult = app.staticTexts["Container"]
        let filterResults = app.buttons.matching(identifier: "Associations Filter Result")
        let popupTitle = app.staticTexts["Electric Distribution Device: Arrester"]
        let structureFilterResult = app.staticTexts["Structure"]
        
        openPopup(3216, on: .electricDistributionDevice)
        assertPopupOpened(popupTitle: popupTitle)
        
        // Expectation: The default title is "Associations".
        XCTAssertTrue(
            associationsElement.exists,
            "The element \"Associations\" doesn't exist."
        )
        
        // Expectation: Filter elements use their type name as their default title.
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
    
    /// Verifies that custom titles and descriptions are honored.
    func testCustomTitlesAndDescriptions() {
        let app = XCUIApplication()
        let connectivityDescription = app.staticTexts[
            "Associations between two network features that are not coincident."
        ]
        let connectivityTitle = app.staticTexts["Junction Connectivity"]
        let elementTitle = app.staticTexts["Connectivity and Attachment"]
        let elementDescription = app.staticTexts["Line End"]
        let filterResults = app.buttons.matching(identifier: "Associations Filter Result")
        let popupTitle = app.staticTexts["Electric Distribution Junction: Line End"]
        let structureDescription = app.staticTexts[
            "Features that have network features attached to them."
        ]
        let structureTitle = app.staticTexts["Junction Structure"]
        
        openPopup(2473, on: "Electric Distribution Junction")
        assertPopupOpened(popupTitle: popupTitle)
        
        // Expectation: The custom popup element title and description are displayed.
        XCTAssertTrue(
            elementTitle.exists,
            "The element \"Connectivity and Attachment\" doesn't exist."
        )
        XCTAssertTrue(
            elementDescription.exists,
            "The element description \"Line End\" doesn't exist."
        )
        
        // Expectation: The custom filter result titles are displayed.
        XCTAssertEqual(filterResults.count, 2)
        XCTAssertTrue(
            connectivityTitle.exists,
            "The filter result \"Junction Connectivity\" doesn't exist."
        )
        XCTAssertTrue(
            structureTitle.exists,
            "The filter result \"Junction Structure\" doesn't exist."
        )
        
        // Expectation: The custom filer result descriptions are displayed.
        XCTAssertTrue(
            connectivityDescription.exists,
            "The filter result description doesn't exist."
        )
        XCTAssertTrue(
            structureDescription.exists,
            "The filter result description doesn't exist."
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
    
    /// Verifies that `PopupView` supports definitions with multiple associations elements.
    func testMultipleElements() {
        let app = XCUIApplication()
        let associationsElements = app.staticTexts.matching(identifier: "Associations Popup Element")
        let attachmentElement = app.staticTexts["Attachment"]
        let containerElement = app.staticTexts["Container"]
        let contentFilterResult = app.staticTexts["Content"]
        let popupTitle = app.staticTexts["Structure Junction: Switchgear"]
        let structureFilterResult = app.staticTexts["Structure"]
        
        openPopup(2339, on: .structureJunction)
        assertPopupOpened(popupTitle: popupTitle)
        
        // Expectation: There are 2 associations popup elements.
        XCTAssertEqual(associationsElements.count, 2)
        
        // Expectation: There is an "Attachment" element with a "Structure" filter result.
        XCTAssertTrue(
            attachmentElement.exists,
            "The element \"Attachment\" doesn't exist."
        )
        XCTAssertTrue(
            structureFilterResult.exists,
            "The filter result \"Structure\" doesn't exist."
        )
        
        // Expectation: There is an "Container" element with a "Content" filter result.
        XCTAssertTrue(
            containerElement.exists,
            "The element \"Container\" doesn't exist."
        )
        XCTAssertTrue(
            contentFilterResult.exists,
            "The filter result \"Content\" doesn't exist."
        )
    }
    
    /// Verifies that navigating through associations results works as expected.
    func testNavigation() {
        let app = XCUIApplication()
        let backButton = app.buttons.matching(identifier: "Back").element(boundBy: 1)
        let filterResultTitle = app.staticTexts["Content"]
        let fuseText = app.staticTexts["Electric Distribution Device: Fuse"]
        let groupResult = app.buttons["Electric Distribution Device, 3"]
        let showAllButton = app.buttons["Show all, Total: 3"]
        let switchgearText = app.staticTexts["Structure Junction: Switchgear"]
        let titleField = app.textFields["Title"]
        
        assertPopupOpened(popupTitle: switchgearText)
        openPopup(1464, on: .structureJunction)
        
        // Expectation: A filter result opens the group result list.
        XCTAssertTrue(
            filterResultTitle.exists,
            "The filter result \"Content\" doesn't exist."
        )
        filterResultTitle.tap()
        
        XCTAssertTrue(
            groupResult.waitForExistence(timeout: 3),
            "The group result \"Electric Distribution Device, 3\" failed to appear."
        )
        
        // Expectation: The filter result's title is displayed as the navigation title
        // and parent popup's title is displayed as the navigation description.
        XCTAssertTrue(
            filterResultTitle.exists,
            "The \"Content\" text doesn't exist."
        )
        XCTAssertTrue(
            switchgearText.exists,
            "The \"Structure Junction: Switchgear\" text doesn't exist."
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
    
    /// Verifies that `onPopupChanged(perform:)` provides the correct popup when a new one is shown in the view.
    func testOnPopupChangedModifier() {
        let app = XCUIApplication()
        let backButton = app.buttons.matching(identifier: "Back").element(boundBy: 1)
        let filterResult = app.buttons["Structure, 1"]
        let polePopupText = app.staticTexts["Structure Junction: Pole"]
        let poleObjectIDText = app.staticTexts["Selected Popup Object ID, 1158"]
        let switchPopupText = app.staticTexts["Electric Distribution Device: Switch"]
        let switchObjectIDText = app.staticTexts["Selected Popup Object ID, 4361"]
        
        openPopup(4361, on: .electricDistributionDevice)
        assertPopupOpened(popupTitle: switchPopupText)
        
        // Expectation: The first provided popup's object ID matches the opened popup's.
        XCTAssertTrue(
            switchObjectIDText.waitForExistence(timeout: 3),
            "The text \"Selected Popup Object ID, 4361\" doesn't exist."
        )
        
        // Expectation: Opening a filter result does not provide a new popup.
        XCTAssertTrue(
            filterResult.exists,
            "The filter result \"Structure, 1\" doesn't exist."
        )
        filterResult.tap()
        
        XCTAssertTrue(
            polePopupText.waitForExistence(timeout: 3),
            "The result \"Structure Junction: Pole\" doesn't exist."
        )
        XCTAssertTrue(
            switchObjectIDText.exists,
            "The text \"Selected Popup Object ID, 4361\" doesn't exist."
        )
        
        // Expectation: Navigating to a new popup provides that popup.
        polePopupText.tap()
        assertPopupOpened(popupTitle: polePopupText)
        
        XCTAssertTrue(
            poleObjectIDText.waitForExistence(timeout: 3),
            "The text \"Selected Popup Object ID, 1158\" doesn't exist."
        )
        
        // Expectation: Navigating back to the group results list provides the last popup.
        XCTAssertTrue(
            backButton.exists,
            "The \"Back\" button doesn't exist."
        )
        backButton.tap()
        
        XCTAssertTrue(
            switchObjectIDText.waitForExistence(timeout: 3),
            "The text \"Selected Popup Object ID, 4361\" doesn't exist."
        )
    }
    
    /// Verifies that association results display the correct icon when applicable.
    /// - Note: Only the "connection-to-connection" is tested since the data
    /// doesn't contain any junction-edge-object-connectivity associations.
    func testAssociationResultIcons() {
        let app = XCUIApplication()
        let associationResults = app.buttons.matching(identifier: "Association Result")
        let associationResultIcons = app.images.matching(identifier: "Association Result Icon")
        let backButton = app.buttons.matching(identifier: "Back").element(boundBy: 1)
        let connectivityFilterResult = app.buttons["Connectivity, 1"]
        let containerFilterResult = app.buttons["Container, 1"]
        let popupTitle = app.staticTexts["Electric Distribution Device: Fuse"]
        let transformerBankResult = app.staticTexts["Electric Distribution Assembly: Transformer Bank"]
        let transformerResult = app.staticTexts["Electric Distribution Device: Transformer"]
        
        openPopup(2672, on: .electricDistributionDevice)
        assertPopupOpened(popupTitle: popupTitle)
        
        // Opens the "Connectivity" filter result.
        XCTAssertTrue(
            connectivityFilterResult.exists,
            "The filter result \"Connectivity, 1\" doesn't exist."
        )
        connectivityFilterResult.tap()
        
        // Expectation: The one result has a "connection-to-connection" icon.
        XCTAssertTrue(
            transformerResult.waitForExistence(timeout: 3),
            "The result \"Electric Distribution Device: Transformer\" failed to appear."
        )
        XCTAssertEqual(associationResults.count, 1)
        
        XCTAssertEqual(associationResultIcons.count, 1)
        XCTAssertEqual(associationResultIcons.firstMatch.label, "connection-to-connection")
        
        // Navigates back to the parent popup.
        XCTAssertTrue(
            backButton.exists,
            "The \"Back\" button doesn't exist."
        )
        backButton.tap()
        
        assertPopupOpened(popupTitle: popupTitle)
        
        // Opens the "Container" filter result.
        XCTAssertTrue(
            containerFilterResult.exists,
            "The filter result \"Container, 1\" doesn't exist."
        )
        containerFilterResult.tap()
        
        // Expectation: The one result has a no icon.
        XCTAssertTrue(
            transformerBankResult.waitForExistence(timeout: 3),
            "The result \"Electric Distribution Assembly: Transformer Bank\" failed to appear."
        )
        XCTAssertEqual(associationResults.count, 1)
        
        XCTAssertEqual(associationResultIcons.count, 0)
    }
    
    /// Verifies that association results display the correct description when applicable.
    /// - Note: The fraction-along-edge description is not tested as the data does not have any
    /// `junctionEdgeObjectConnectivityMidspan` associations.
    func testAssociationDescription() async {
        let app = XCUIApplication()
        let associationResultDescription = app.staticTexts["Association Result Description"]
        let connectivityFilterResult = app.staticTexts["Connectivity"]
        let containerFilterResult = app.staticTexts["Container"]
        let contentFilterResult = app.staticTexts["Content"]
        let fusePopupTitle = app.staticTexts["Electric Distribution Device: Fuse"]
        let transformerPopupTitle = app.staticTexts["Electric Distribution Device: Transformer"]
        let transformerBankPopupTitle = app.staticTexts["Electric Distribution Assembly: Transformer Bank"]
        
        openPopup(4567, on: .electricDistributionDevice)
        assertPopupOpened(popupTitle: fusePopupTitle)
        
        // Opens the "Connectivity" filter result.
        XCTAssertTrue(
            connectivityFilterResult.exists,
            "The filter result \"Connectivity\" doesn't exist."
        )
        connectivityFilterResult.tap()
        
        // Expectations: The transformer result has a "High" description.
        XCTAssertTrue(
            transformerPopupTitle.waitForExistence(timeout: 3),
            "The result \"Electric Distribution Device: Transformer\" doesn't exist."
        )
        XCTAssertTrue(
            associationResultDescription.exists,
            "The result description doesn't exist."
        )
        XCTAssertEqual(associationResultDescription.label, "High")
        
        // Opens the transformer popup and "Connectivity" filter result.
        transformerPopupTitle.tap()
        assertPopupOpened(popupTitle: transformerPopupTitle)
        
        XCTAssertTrue(
            connectivityFilterResult.exists,
            "The filter result \"Connectivity\" doesn't exist."
        )
        connectivityFilterResult.tap()
        
        // Expectation: The fuse results have a "Single Terminal" description.
        XCTAssertTrue(
            fusePopupTitle.exists,
            "The result \"Electric Distribution Device: Fuse\" doesn't exist."
        )
        XCTAssertTrue(
            associationResultDescription.exists,
            "The result description doesn't exist."
        )
        XCTAssertEqual(associationResultDescription.firstMatch.label, "Single Terminal")
        
        // Opens the first fuse popup and the "Container" filter result.
        fusePopupTitle.firstMatch.tap()
        assertPopupOpened(popupTitle: fusePopupTitle)
        
        XCTAssertTrue(
            containerFilterResult.exists,
            "The filter result \"Container\" doesn't exist."
        )
        containerFilterResult.tap()
        
        // Expectation: The transformer bank result does not have a description.
        XCTAssertTrue(
            transformerBankPopupTitle.waitForExistence(timeout: 3),
            "The result \"Electric Distribution Assembly: Transformer Bank\" doesn't exist."
        )
        XCTAssertFalse(
            associationResultDescription.exists,
            "The result description exists."
        )
        
        // Opens the transformer bank popup and the "Content" filter result.
        transformerBankPopupTitle.tap()
        assertPopupOpened(popupTitle: transformerBankPopupTitle)
        
        XCTAssertTrue(
            contentFilterResult.exists,
            "The filter result \"Content\" doesn't exist."
        )
        contentFilterResult.tap()
        
        // Expectation: The results have a "Containment Visible: False" description.
        XCTAssertTrue(
            associationResultDescription.exists,
            "The result description doesn't exist."
        )
        XCTAssertEqual(associationResultDescription.firstMatch.label, "Containment Visible: False")
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
        
        openPopup(316, on: .electricDistributionAssembly)
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
        
        openPopup(475, on: .electricDistributionAssembly)
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

private extension String {
    static let electricDistributionAssembly = "Electric Distribution Assembly"
    static let electricDistributionDevice = "Electric Distribution Device"
    static let structureJunction = "Structure Junction"
}
}
