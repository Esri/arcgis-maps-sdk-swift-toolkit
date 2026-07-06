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
final class SnapSettingsViewTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Adds launch arguments specifying the feature to edit and opens the feature editor test view.
    /// - Parameters:
    ///   - objectID: The object ID of the feature that will be edited.
    ///   - layerName: The name of the `FeatureLayer` containing the feature.
    func openFeatureEditorWithStartingPoint(_ objectID: Int, on layerName: String) {
        let app = XCUIApplication()
        let featureEditorTestsButton = app.buttons["Feature Editor Tests"]
        
        // Adds the launch arguments that will be read in the test view.
        let arguments = ["-objectID", "\(objectID)", "-layerName", "\(layerName)"]
        app.launchArguments.append(contentsOf: arguments)
        
        // Opens the feature editor test view.
        app.launch()
        featureEditorTestsButton.tap()
    }
    
    /// Verifies the snap settings toggles states when a feature is selected
    /// for editing.
    func testDefaultToggleStatesAndPreservation() throws {
        let app = XCUIApplication()
        
        openFeatureEditorWithStartingPoint(3321, on: .electricDistributionDevice)
        app.buttons["Settings"].assertExistenceAndTap()
        
        let geometryGuidesToggle = app.snapToggle(named: "Snap to Geometry Guides")
        let featuresToggle = app.snapToggle(named: "Snap to Features")
        geometryGuidesToggle.assertExistence()
        featuresToggle.assertExistence()
        
        // By default, the geometry guides toggle should be off, and the
        // snap to features toggle should be on.
        XCTAssertEqual(geometryGuidesToggle.boolValue, false)
        XCTAssertEqual(featuresToggle.boolValue, true)
        
        // Use one snap source toggle to verify that snapping to snap sources
        // are disabled by default.
        let structureLineToggle = app.snapToggle(named: "Structure Line")
        structureLineToggle.assertExistence()
        XCTAssertEqual(structureLineToggle.boolValue, false)
        
        // Turn on some toggles and verify their states are preserved when the
        // settings view is reopened.
        geometryGuidesToggle.tapResolvedToggleControl()
        structureLineToggle.tapResolvedToggleControl()
        // Close the settings view.
        app.buttons["Close"].assertExistenceAndTap()
        // Reopen the settings view and verify the toggles states are preserved.
        app.buttons["Settings"].assertExistenceAndTap()
        XCTAssertEqual(geometryGuidesToggle.boolValue, true)
        XCTAssertEqual(structureLineToggle.boolValue, true)
    }
}

private extension XCUIElement {
    func snapToggle(named name: String) -> XCUIElement {
#if targetEnvironment(macCatalyst)
        checkBoxes[name]
#else
        switches[name]
#endif
    }
    
    func tapResolvedToggleControl() {
#if targetEnvironment(macCatalyst)
        tap()
#else
        switches.firstMatch.tap()
#endif
    }
}

private extension String {
    static let electricDistributionDevice = "Electric Distribution Device"
}
