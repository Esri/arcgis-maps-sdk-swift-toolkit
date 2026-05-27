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
final class GeometryEditorToolbarTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Tests the default style for the geometry editor toolbar is vertical.
    /// Verifies that the tool button is positioned above the delete button
    /// by comparing their midY values.
    func testGeometryEditorToolbarDefaultStyleIsVertical() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Geometry Editor Toolbar Tests"].assertExistenceAndTap()
        app.buttons["Point"].assertExistenceAndTap()
        
        let toolButton = app.buttons["Tool"]
        let deleteButton = app.buttons["Delete Selected Element"]
        
        toolButton.assertExistence(timeout: 1)
        deleteButton.assertExistence(timeout: 1)
        
        let toolMinY = toolButton.frame.midY
        let deleteMinY = deleteButton.frame.midY
        
        XCTAssertLessThan(toolMinY, deleteMinY, "Expected the tool button to be above the delete button when the toolbar is vertical")
    }
    
    /// Tests the geometry editor toolbar appears when a geometry editor
    /// is started, and disappears when it is stopped.
    func testGeometryEditorToolbarAppearsWhenEditorStarts() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Geometry Editor Toolbar Tests"].assertExistenceAndTap()
        
        let toolButton = app.buttons["Tool"]
        toolButton.assertNonExistence(timeout: 1)
        
        app.buttons["Point"].assertExistenceAndTap()
        toolButton.assertExistence(timeout: 1)
        
        app.buttons["Stop"].assertExistenceAndTap()
        toolButton.assertNonExistence(timeout: 1)
    }
    
    /// Tests the geometry editor tool picker shows only vertex-based
    /// tools when the geometry editor is started with point type.
    func testPointToolPickerButtons() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Geometry Editor Toolbar Tests"].assertExistenceAndTap()
        app.buttons["Point"].assertExistenceAndTap()
        
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
    /// when the geometry editor is started with polyline type.
    func testPolylineToolPickerButtons() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Geometry Editor Toolbar Tests"].assertExistenceAndTap()
        app.buttons["Polyline"].assertExistenceAndTap()
        
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
