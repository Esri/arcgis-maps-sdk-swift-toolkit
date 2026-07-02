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
    func openFeatureEditorToolbarTestsWithStartingFeature(_ objectID: Int, on layerName: String) {
        let app = XCUIApplication()
        let geometryEditorToolbarTestsButton = app.buttons["Feature Editor Tests"]
        
        // Adds the launch arguments that will be read in the test view.
        let arguments = ["-objectID", "\(objectID)", "-layerName", "\(layerName)"]
        app.launchArguments.append(contentsOf: arguments)
        
        // Opens the geometry editor toolbar test view.
        app.launch()
        geometryEditorToolbarTestsButton.assertExistenceAndTap()
    }
    
    /// Tests the default style for the feature editor toolbar is vertical.
    /// Verifies that the tool button is positioned above the delete button
    /// by comparing their midY values.
    func testGeometryEditorToolbarDefaultStyleIsVertical() {
        let app = XCUIApplication()
        openFeatureEditorToolbarTestsWithStartingFeature(3321, on: .electricDistributionDevice)
        
        let toolButton = app.buttons["Tool"]
        let deleteButton = app.buttons["Delete Selected Element"]
        
        toolButton.assertExistence(timeout: 1)
        deleteButton.assertExistence(timeout: 1)
        
        let toolMidY = toolButton.frame.midY
        let deleteMidY = deleteButton.frame.midY
        
        XCTAssertLessThan(
            toolMidY, deleteMidY,
            "Expected the tool button to be above the delete button when the toolbar is vertical"
        )
    }
    
    /// Tests the feature editor toolbar appears when the feature editor
    /// is started, and disappears when it is stopped.
    func testFeatureEditorToolbarAppearsWhenEditorStarts() {
        let app = XCUIApplication()
        openFeatureEditorToolbarTestsWithStartingFeature(3321, on: .electricDistributionDevice)
        
        let toolButton = app.buttons["Tool"]
        toolButton.assertExistence(timeout: 1)
        
        app.buttons["Stop"].assertExistenceAndTap()
        toolButton.assertNonExistence(timeout: 1)
    }
    
    /// Tests the feature editor tool picker shows only vertex-based
    /// tools when the feature editor is started with a point feature.
    func testPointToolPickerButtons() {
        let app = XCUIApplication()
        openFeatureEditorToolbarTestsWithStartingFeature(3321, on: .electricDistributionDevice)
        
        let toolButton = app.buttons["Tool"]
        toolButton.assertExistenceAndTap(timeout: 1)
        
        [
            "Vertex",
            "Reticle"
        ].forEach { label in
            app.buttons[label].assertExistence(timeout: 1)
        }
        
        app.buttons["Stop"].assertExistenceAndTap()
    }
    
    /// Tests all geometry editing tools are available in the tool picker
    /// when the feature editor is started with a polyline feature.
    func testPolylineToolPickerButtons() {
        let app = XCUIApplication()
        openFeatureEditorToolbarTestsWithStartingFeature(2525, on: .electricDistributionLine)
        
        let toolButton = app.buttons["Tool"]
        toolButton.assertExistenceAndTap(timeout: 1)
        
        [
            "Freehand",
            "Vertex",
            "Reticle",
            "Arrow",
            "Ellipse",
            "Rectangle",
            "Triangle"
        ].forEach { label in
            app.buttons[label].assertExistence(timeout: 1)
        }
        
        app.buttons["Stop"].assertExistenceAndTap()
    }
    
    /// Tests all geometry editing tools are available in the tool picker
    /// when the feature editor is started with a polygon feature.
    func testPolygonToolPickerButtons() {
        let app = XCUIApplication()
        openFeatureEditorToolbarTestsWithStartingFeature(1, on: .structureBoundary)
        
        let toolButton = app.buttons["Tool"]
        toolButton.assertExistenceAndTap(timeout: 1)
        
        [
            "Freehand",
            "Vertex",
            "Reticle",
            "Arrow",
            "Ellipse",
            "Rectangle",
            "Triangle"
        ].forEach { label in
            app.buttons[label].assertExistence(timeout: 1)
        }
        
        app.buttons["Stop"].assertExistenceAndTap()
    }
}


private extension String {
    static let electricDistributionDevice = "Electric Distribution Device"
    static let electricDistributionLine = "Electric Distribution Line"
    static let structureBoundary = "Structure Boundary"
}
