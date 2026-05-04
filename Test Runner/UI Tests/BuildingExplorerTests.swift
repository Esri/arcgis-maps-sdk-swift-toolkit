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
final class BuildingExplorerTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Tests the visible toggle.
    func testCase1() {
        let app = XCUIApplication()
        app.launch()
        
        // Tap building explorer button.
        app.buttons["Building Explorer Tests"].assertExistenceAndTap()
        
        // Tap test case one button.
        app.buttons["Test Case 1"].assertExistenceAndTap()
        
        // Tap the visible toggle.
        
        let visibleToggle = app.switches["Visible"].switches.firstMatch
        visibleToggle.assertExistenceAndTap()
        
        // Verify the layer is not visible anymore by checking
        // the updated text in the banner.
        app.staticTexts["Layer is visible: false"].assertExistence()
        
        // Tap the visible toggle.
        visibleToggle.assertExistenceAndTap()
        
        // Verify the layer is visible by checking
        // the updated text in the banner.
        app.staticTexts["Layer is visible: true"].assertExistence()
    }
    
    /// Tests the full model toggle.
    func testCase2() {
        let app = XCUIApplication()
        app.launch()
        
        // Tap building explorer button.
        app.buttons["Building Explorer Tests"].assertExistenceAndTap()
        
        // Tap test case two button.
        app.buttons["Test Case 2"].assertExistenceAndTap()
        
        // Tap the full model toggle.
        
        let fullModelToggle = app.switches["Show Full Model"].switches.firstMatch
        fullModelToggle.assertExistenceAndTap()
        
        // Close the explorer so the view code knows to check
        // the visibility of the full model sublayer.
        let closeButton = app.buttons["Close"]
        closeButton.assertExistenceAndTap()
        
        // Verify the layer is not visible anymore by checking
        // the updated text in the banner.
        app.staticTexts["Full model is visible: false"].assertExistence()
        
        // Tap "Show Explorer" button.
        app.buttons["Show Explorer"].assertExistenceAndTap()
        
        // Tap the full model toggle.
        fullModelToggle.assertExistenceAndTap()
        
        // Close the explorer so the view code knows to check
        // the visibility of the full model sublayer.
        closeButton.assertExistenceAndTap()
        
        // Verify the layer is not visible anymore by checking
        // the updated text in the banner.
        app.staticTexts["Full model is visible: true"].assertExistence()
    }
    
    /// Tests the default level and level change.
    func testCase3() {
        let app = XCUIApplication()
        app.launch()
        
        // Tap building explorer button.
        app.buttons["Building Explorer Tests"].assertExistenceAndTap()
        
        // Tap test case three button.
        app.buttons["Test Case 3"].assertExistenceAndTap()
        
        // Verify the default is selected.
        app.staticTexts["Selected level: All"].assertExistence()
        
        // Tap the level picker.
        app.buttons["Level, All"].assertExistenceAndTap()
        
        // Tap level three from the picker.
        app.buttons["3"].assertExistenceAndTap()
        
        // Verify level three is selected.
        app.staticTexts["Selected level: 3"].assertExistence()
    }
    
    /// Tests the default phase and phase change.
    func testCase4() {
        let app = XCUIApplication()
        app.launch()
        
        // Tap building explorer button.
        app.buttons["Building Explorer Tests"].assertExistenceAndTap()
        
        // Tap test case four button.
        app.buttons["Test Case 4"].assertExistenceAndTap()
        
        // Verify the default which should be the last phase.
        app.staticTexts["Selected phase: 7"].assertExistence()
        
        // Tap the phase picker.
        app.buttons["Construction Phase, 7"].assertExistenceAndTap()
        
        // Tap phase three from the phase picker.
        app.buttons["3"].assertExistenceAndTap()
        
        // Verify phase 3 is selected.
        app.staticTexts["Selected phase: 3"].assertExistence()
    }
}
