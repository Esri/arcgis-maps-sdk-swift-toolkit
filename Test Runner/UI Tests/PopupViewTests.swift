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
        
        // Adds the launch arguments that will be read in the test view.
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
    func testUNADefaultTitles() {
        let app = XCUIApplication()
        let associationsElement = app.staticTexts["Associations"]
        let connectivityFilterResult = app.staticTexts["Connectivity"]
        let containerFilterResult = app.staticTexts["Container"]
        let filterResults = app.buttons.matching(identifier: "Associations Filter Result")
        let popupTitle = app.navigationBars["Electric Distribution Device: Arrester"]
        let structureFilterResult = app.staticTexts["Structure"]
        
        openPopup(3216, on: .electricDistributionDevice)
        XCTExpectFailure("KNOWN ISSUE -- nautilus/issues/2625") {
            assertPopupOpened(popupTitle: popupTitle)
        }
        
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
    
    /// Verifies that custom titles and descriptions for an associations element are honored.
    func testUNACustomTitlesAndDescriptions() {
        let app = XCUIApplication()
        let connectivityDescription = app.staticTexts[
            "Associations between two network features that are not coincident."
        ]
        let connectivityTitle = app.staticTexts["Junction Connectivity"]
        let elementTitle = app.staticTexts["Connectivity and Attachment"]
        let elementDescription = app.staticTexts["Line End"]
        let filterResults = app.buttons.matching(identifier: "Associations Filter Result")
        let popupTitle = app.navigationBars["Electric Distribution Junction: Line End"]
        let structureDescription = app.staticTexts[
            "Features that have network features attached to them."
        ]
        let structureTitle = app.staticTexts["Junction Structure"]
        
        openPopup(2473, on: "Electric Distribution Junction")
        XCTExpectFailure("KNOWN ISSUE -- nautilus/issues/2625") {
            assertPopupOpened(popupTitle: popupTitle)
        }
        
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
    
    /// Verifies that "No Associations" is displayed for an associations element with no filter results.
    func testUNANoAssociations() {
        let app = XCUIApplication()
        let associationsElements = app.staticTexts.matching(identifier: "Associations Popup Element")
        let filterResults = app.buttons.matching(identifier: "Associations Filter Result")
        let noAssociationsText = app.staticTexts["No Associations"]
        let popupTitle = app.navigationBars["Electric Distribution Line: Medium Voltage"]
        
        openPopup(513, on: "Electric Distribution Line")
        XCTExpectFailure("KNOWN ISSUE -- nautilus/issues/2625") {
            assertPopupOpened(popupTitle: popupTitle)
        }
        
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
    func testMultipleUNAElements() {
        let app = XCUIApplication()
        let associationsElements = app.staticTexts.matching(identifier: "Associations Popup Element")
        let attachmentElement = app.staticTexts["Attachment"]
        let containerElement = app.staticTexts["Container"]
        let contentFilterResult = app.staticTexts["Content"]
        let popupTitle = app.navigationBars["Structure Junction: Switchgear"]
        let structureFilterResult = app.staticTexts["Structure"]
        
        openPopup(2339, on: .structureJunction)
        XCTExpectFailure("KNOWN ISSUE -- nautilus/issues/2625") {
            assertPopupOpened(popupTitle: popupTitle)
        }
        
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
    func testUNANavigation() {
        let app = XCUIApplication()
        let backButton = app.navigationBars.element(boundBy: 1).buttons.firstMatch
        let filterResultTitle = app.staticTexts["Content"]
        let fusePopupTitle = app.staticTexts["Electric Distribution Device: Fuse"]
        let groupResult = app.staticTexts["Electric Distribution Device, 3"]
        let showAllButton = app.buttons["Show all, Total: 3"]
        let switchgearPopupTitle = app.staticTexts["Structure Junction: Switchgear"]
        let searchField = app.searchFields["Title"]
        
        openPopup(1464, on: .structureJunction)
        XCTExpectFailure("KNOWN ISSUE -- nautilus/issues/2625") {
            assertPopupOpened(popupTitle: switchgearPopupTitle)
        }
        
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
            switchgearPopupTitle.exists,
            "The \"Structure Junction: Switchgear\" text doesn't exist."
        )
        
        // Expectation: A result opens new popup with the result's label as the title.
        XCTAssertTrue(
            fusePopupTitle.exists,
            "The result \"Electric Distribution Device: Fuse\" doesn't exist."
        )
        fusePopupTitle.tap()
        assertPopupOpened(popupTitle: fusePopupTitle)
        
        // Expectation: The popup back button opens the group result list again.
        XCTAssertTrue(
            backButton.exists,
            "The navigation back button doesn't exist."
        )
        backButton.tap()
        
        XCTAssertTrue(
            groupResult.waitForExistence(timeout: 3),
            "The group result \"Electric Distribution Device, 3\" failed to appear."
        )
        
        // Expectation: The "Show all" button opens the "Show all" view.
        XCTAssertTrue(
            showAllButton.exists,
            "The \"Show all, Total: 3\" button doesn't exist."
        )
        showAllButton.tap()
        
        XCTAssertTrue(
            searchField.waitForExistence(timeout: 3),
            "The \"Title\" search field failed to appear."
        )
        
        // Expectation: A result from the "Show all" view also opens a new popup.
        XCTAssertTrue(
            fusePopupTitle.exists,
            "The result \"Electric Distribution Device: Fuse\" doesn't exist."
        )
        fusePopupTitle.firstMatch.tap()
        assertPopupOpened(popupTitle: fusePopupTitle)
        
        // Expectation: The popup back button opens the "Show all" view again.
        XCTAssertTrue(
            backButton.exists,
            "The navigation back button doesn't exist."
        )
        backButton.tap()
        
        XCTAssertTrue(
            searchField.waitForExistence(timeout: 3),
            "The \"Title\" search field failed to appear."
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
        assertPopupOpened(popupTitle: switchgearPopupTitle)
    }
    
    /// Verifies that `onPopupChanged(perform:)` provides the correct popup when a new one is shown in the view.
    func testOnPopupChangedModifier() {
        let app = XCUIApplication()
        let backButton = app.navigationBars.element(boundBy: 1).buttons.firstMatch
        let filterResult = app.buttons["Structure, 1"]
        let polePopupTitle = app.staticTexts["Structure Junction: Pole"]
        let poleObjectIDText = app.staticTexts["Selected Popup Object ID, 1158"]
        let switchPopupTitle = app.navigationBars["Electric Distribution Device: Switch"]
        let switchObjectIDText = app.staticTexts["Selected Popup Object ID, 4361"]
        
        openPopup(4361, on: .electricDistributionDevice)
        XCTExpectFailure("KNOWN ISSUE -- nautilus/issues/2625") {
            assertPopupOpened(popupTitle: switchPopupTitle)
        }
        
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
            polePopupTitle.waitForExistence(timeout: 3),
            "The result \"Structure Junction: Pole\" doesn't exist."
        )
        XCTAssertTrue(
            switchObjectIDText.exists,
            "The text \"Selected Popup Object ID, 4361\" doesn't exist."
        )
        
        // Expectation: Navigating to a new popup provides that popup.
        polePopupTitle.tap()
        assertPopupOpened(popupTitle: polePopupTitle)
        
        XCTAssertTrue(
            poleObjectIDText.waitForExistence(timeout: 3),
            "The text \"Selected Popup Object ID, 1158\" doesn't exist."
        )
        
        // Expectation: Navigating back to the group results list provides the last popup.
        XCTAssertTrue(
            backButton.exists,
            "The navigation back button doesn't exist."
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
    func testUNAAssociationResultIcons() {
        let app = XCUIApplication()
        let associationResults = app.staticTexts.matching(identifier: "Association Result")
        let associationResultIcons = app.images.matching(identifier: "Association Result Icon")
        let backButton = app.navigationBars.element(boundBy: 1).buttons.firstMatch
        let connectivityFilterResult = app.buttons["Connectivity, 1"]
        let containerFilterResult = app.buttons["Container, 1"]
        let popupTitle = app.navigationBars["Electric Distribution Device: Fuse"]
        let transformerBankResult = app.staticTexts["Electric Distribution Assembly: Transformer Bank"]
        let transformerResult = app.staticTexts["Electric Distribution Device: Transformer"]
        
        openPopup(2672, on: .electricDistributionDevice)
        XCTExpectFailure("KNOWN ISSUE -- nautilus/issues/2625") {
            assertPopupOpened(popupTitle: popupTitle)
        }
        
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
            "The navigation back button doesn't exist."
        )
        backButton.tap()
        assertPopupOpened(popupTitle: popupTitle)
        
        // Opens the "Container" filter result.
        XCTAssertTrue(
            containerFilterResult.exists,
            "The filter result \"Container, 1\" doesn't exist."
        )
        containerFilterResult.tap()
        
        // Expectation: The one result has no icon.
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
    func testUNAAssociationDescriptions() async {
        let app = XCUIApplication()
        let associationResultDescription = app.staticTexts["Association Result Description"]
        let connectivityFilterResult = app.staticTexts["Connectivity"]
        let containerFilterResult = app.staticTexts["Container"]
        let contentFilterResult = app.staticTexts["Content"]
        let fusePopupTitle = app.staticTexts["Electric Distribution Device: Fuse"]
        let transformerPopupTitle = app.staticTexts["Electric Distribution Device: Transformer"]
        let transformerBankPopupTitle = app.staticTexts["Electric Distribution Assembly: Transformer Bank"]
        
        openPopup(4567, on: .electricDistributionDevice)
        XCTExpectFailure("KNOWN ISSUE -- nautilus/issues/2625") {
            assertPopupOpened(popupTitle: fusePopupTitle)
        }
        
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
            fusePopupTitle.waitForExistence(timeout: 3),
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
    func testUNADisplayCount() {
        let app = XCUIApplication()
        let associationResults = app.staticTexts.matching(identifier: "Association Result")
        let contentFilterResult = app.buttons["Content, 3"]
        let popupTitle = app.navigationBars["Electric Distribution Assembly: Switch Bank"]
        let groupResult = app.staticTexts["Electric Distribution Device, 3"]
        let groupResults = app.staticTexts.matching(identifier: "Association Group Result")
        let showAllButton = app.buttons["Show all, Total: 3"]
        let searchField = app.searchFields["Title"]
        
        openPopup(316, on: .electricDistributionAssembly)
        XCTExpectFailure("KNOWN ISSUE -- nautilus/issues/2625") {
            assertPopupOpened(popupTitle: popupTitle)
        }
        
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
            searchField.waitForExistence(timeout: 3),
            "The \"Title\" search field failed to appear."
        )
        
        // Expectation: All of the results are now shown.
        XCTAssertEqual(associationResults.count, 3)
    }
    
    /// Verifies that using the search bar filters the association results as expected.
    func testUNASearchResults() {
        let app = XCUIApplication()
        let associationResults = app.staticTexts.matching(identifier: "Association Result")
        let cancelButton = app.buttons["Cancel"]
        let filterResult = app.buttons["Content, 6"]
        let popupTitle = app.navigationBars["Electric Distribution Assembly: Fuse Bank"]
        let groupResult = app.staticTexts["Electric Distribution Device, 6"]
        let showAllButton = app.buttons["Show all, Total: 6"]
        let searchField = app.searchFields["Title"]
        
        openPopup(475, on: .electricDistributionAssembly)
        XCTExpectFailure("KNOWN ISSUE -- nautilus/issues/2625") {
            assertPopupOpened(popupTitle: popupTitle)
        }
        
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
            searchField.waitForExistence(timeout: 3),
            "The \"Title\" search field failed to appear."
        )
        
        // Expectation: There are 6 results to begin with.
        XCTAssertEqual(associationResults.count, 6)
        
        // Expectation: Searching filters the results to only those with the query in their title.
        searchField.tap()
        searchField.typeText("Arrester")
        
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
        searchField.tap()
        searchField.typeText("fuse")
        
        XCTAssertEqual(associationResults.count, 3)
        XCTAssertTrue(
            associationResults.allElementsBoundByIndex.allSatisfy {
                $0.label.localizedStandardContains("fuse")
            },
            "There are filter results that do not contain \"fuse\" in their title."
        )
        
        // Expectation: Invalid search queries have no results.
        searchField.typeText("!")
        
        XCTAssertEqual(associationResults.count, 0)
    }
}

private extension String {
    static let electricDistributionAssembly = "Electric Distribution Assembly"
    static let electricDistributionDevice = "Electric Distribution Device"
    static let structureJunction = "Structure Junction"
}
