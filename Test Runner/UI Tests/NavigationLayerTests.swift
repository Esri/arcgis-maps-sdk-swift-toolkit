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
final class NavigationLayerTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Test that titles and subtitles are shown properly.
    func testCase_1() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["NavigationLayer Tests"].tap()
        app.buttons["NavigationLayer Test Case 1"].tap()
        
        app.buttons["Present a view"].tap()
        
        XCTAssertTrue(app.staticTexts["1st Destination"].exists)
        XCTAssertTrue(app.staticTexts["Subtitle"].exists)
        
        app.buttons["Present another view"].tap()
        
        XCTAssertTrue(app.staticTexts["2nd Destination"].exists)
        
        XCTAssertFalse(app.staticTexts["1st Destination"].exists)
        XCTAssertFalse(app.staticTexts["Subtitle"].exists)
    }
    
    /// Test that back navigation is blocked correctly.
    func testCase_2() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["NavigationLayer Tests"].tap()
        app.buttons["NavigationLayer Test Case 2"].tap()
        
        app.buttons["Present a view"].tap()
        
        XCTAssertTrue(app.staticTexts["Presented view"].exists)
        
        app.buttons.matching(identifier: "Back").element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Navigation blocked!"].exists)
        
        app.buttons["Continue"].tap()
        
        XCTAssertTrue(app.staticTexts["Presented view"].exists)
    }
}
