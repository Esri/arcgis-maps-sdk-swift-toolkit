// Copyright 2026 Esri
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
final class FeatureEditorToolbarTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Adds launch arguments specifying the feature to use and opens the feature editor test view.
    /// - Parameters:
    ///   - objectID: The object ID of the feature that will be used by the test setup.
    ///   - layerName: The name of the `FeatureLayer` containing the feature.
    func openFeatureEditorTestViewWithStartingFeature(_ objectID: Int, on layerName: String) {
        let app = XCUIApplication()
        let featureEditorTestsButton = app.buttons["Feature Editor Tests"]
        
        // Adds the launch arguments that will be read in the test view.
        let arguments = ["-objectID", "\(objectID)", "-layerName", layerName]
        app.launchArguments.append(contentsOf: arguments)
        
        // Opens the feature editor test view.
        app.launch()
        featureEditorTestsButton.assertExistenceAndTap()
    }
    
    /// Tests the default style for the feature editor toolbar is vertical.
    /// Verifies that the tool button is positioned above the delete button
    /// by comparing their midY values.
    func testToolbarDefaultStyleIsVertical() {
        let app = XCUIApplication()
        openFeatureEditorTestViewWithStartingFeature(3321, on: .electricDistributionDevice)
        
        let toolButton = app.toolButton
        let deleteButton = app.buttons["Delete Selected Element"]
        
        toolButton.assertExistence(timeout: 30)
        deleteButton.assertExistence()
        
        let toolMidY = toolButton.frame.midY
        let deleteMidY = deleteButton.frame.midY
        
        XCTAssertLessThan(
            toolMidY, deleteMidY,
            "Expected the tool button to be above the delete button when the toolbar is vertical"
        )
    }
    
    /// Tests the feature editor toolbar appears when the feature editor
    /// is started, and disappears when it is stopped.
    func testToolbarAppearsWhenEditorStarts() {
        let app = XCUIApplication()
        openFeatureEditorTestViewWithStartingFeature(3321, on: .electricDistributionDevice)
        
        let toolButton = app.toolButton
        toolButton.assertExistence(timeout: 30)
        
        app.buttons["Cancel"].assertExistenceAndTap()
        toolButton.assertNonExistence(timeout: 1)
    }
    
    /// Tests the feature editor tool picker shows only vertex-based
    /// tools when the feature editor is started with a point feature.
    func testPointToolPickerButtons() {
        let app = XCUIApplication()
        openFeatureEditorTestViewWithStartingFeature(3321, on: .electricDistributionDevice)
        
        let toolButton = app.toolButton
        toolButton.assertExistenceAndTap(timeout: 30)
        
        [
            "Vertex",
            "Reticle"
        ].forEach { label in
            app.menuButton(named: label).assertExistence()
        }
        
        // Dismiss the tool picker and close the feature editor.
        toolButton.tap()
        app.buttons["Cancel"].assertExistenceAndTap()
        toolButton.assertNonExistence(timeout: 1)
    }
    
    /// Tests all geometry editing tools are available in the tool picker
    /// when the feature editor is started with a polyline feature.
    func testPolylineToolPickerButtons() {
        let app = XCUIApplication()
        openFeatureEditorTestViewWithStartingFeature(2525, on: .electricDistributionLine)
        
        let toolButton = app.toolButton
        toolButton.assertExistenceAndTap(timeout: 30)
        
        [
            "Freehand",
            "Vertex",
            "Reticle",
            "Arrow",
            "Ellipse",
            "Rectangle",
            "Triangle"
        ].forEach { label in
            app.menuButton(named: label).assertExistence()
        }
        
        // Dismiss the tool picker and close the feature editor.
        toolButton.tap()
        app.buttons["Cancel"].assertExistenceAndTap()
        toolButton.assertNonExistence(timeout: 1)
    }
    
    /// Tests all geometry editing tools are available in the tool picker
    /// when the feature editor is started with a polygon feature.
    func testPolygonToolPickerButtons() {
        let app = XCUIApplication()
        openFeatureEditorTestViewWithStartingFeature(1, on: .structureBoundary)
        
        let toolButton = app.toolButton
        toolButton.assertExistenceAndTap(timeout: 30)
        
        [
            "Freehand",
            "Vertex",
            "Reticle",
            "Arrow",
            "Ellipse",
            "Rectangle",
            "Triangle"
        ].forEach { label in
            app.menuButton(named: label).assertExistence()
        }
        
        // Dismiss the tool picker and close the feature editor.
        toolButton.tap()
        app.buttons["Cancel"].assertExistenceAndTap()
        toolButton.assertNonExistence(timeout: 1)
    }
    
    /// Verifies the snap settings toggles states when a feature is selected
    /// for editing.
    func testDefaultToggleStatesAndPreservation() {
        let app = XCUIApplication()
        
        openFeatureEditorTestViewWithStartingFeature(3321, on: .electricDistributionDevice)
        app.buttons["Settings"].assertExistenceAndTap(timeout: 30)
        
        let geometryGuidesToggle = app.snapToggle(named: "Snap to Geometry Guides")
        let featuresToggle = app.snapToggle(named: "Snap to Features")
        geometryGuidesToggle.assertExistence()
        featuresToggle.assertExistence()
        
        // By default, the geometry guides toggle should be off, and the
        // snap to features toggle should be on.
        XCTAssertEqual(geometryGuidesToggle.boolValue, false)
        XCTAssertEqual(featuresToggle.boolValue, true)
        
        // Snap sources should have been synced with snap rules and source
        // toggles with "Rules prevent snapping" should be disabled.
        let structureLineToggle = app.snapToggle(named: "Structure Line, Rules prevent snapping.")
        structureLineToggle.assertExistence()
        XCTAssertFalse(structureLineToggle.isEnabled)
        
        // Use one snap source toggle to verify that snapping to snap sources
        // are disabled by default.
        let dirtyAreasToggle = app.snapToggle(named: "NapervilleElectricV5 - Dirty Areas")
        dirtyAreasToggle.assertExistence()
        XCTAssertEqual(dirtyAreasToggle.boolValue, false)
        
        // Turn on some toggles and verify their states are preserved when the
        // settings view is reopened.
        geometryGuidesToggle.tapResolvedToggleControl()
        dirtyAreasToggle.tapResolvedToggleControl()
        // Close the settings view.
        app.buttons["Close"].assertExistenceAndTap()
        // Reopen the settings view and verify the toggles states are preserved.
        app.buttons["Settings"].assertExistenceAndTap()
        XCTAssertEqual(geometryGuidesToggle.boolValue, true)
        XCTAssertEqual(dirtyAreasToggle.boolValue, true)
    }
}

private extension String {
    static let electricDistributionDevice = "Electric Distribution Device"
    static let electricDistributionLine = "Electric Distribution Line"
    static let structureBoundary = "Structure Boundary"
}

private extension XCUIElement {
    /// The tool button in the feature editor toolbar.
    var toolButton: XCUIElement {
#if targetEnvironment(macCatalyst)
        popUpButtons["Tool"]
#else
        buttons["Tool"]
#endif
    }
    
    /// The menu button with the given name in the feature editor tool picker.
    func menuButton(named name: String) -> XCUIElement {
#if targetEnvironment(macCatalyst)
        menuItems[name]
#else
        buttons[name]
#endif
    }
    
    /// The snap toggle with the given name in the snap settings view.
    func snapToggle(named name: String) -> XCUIElement {
#if targetEnvironment(macCatalyst)
        checkBoxes[name]
#else
        switches[name]
#endif
    }
    
    /// Taps the snap toggle with the correct tapping behavior based on the platform.
    func tapResolvedToggleControl() {
#if targetEnvironment(macCatalyst)
        tap()
#else
        switches.firstMatch.tap()
#endif
    }
}
