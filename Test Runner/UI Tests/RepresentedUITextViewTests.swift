// Copyright 2024 Esri
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

@testable import ArcGISToolkit
import SwiftUI
import XCTest

final class RepresentedUITextViewTests: XCTestCase {
    func testInit() {
        let app = XCUIApplication()
        let boundValue = app.staticTexts["Bound Value"]
        let textView = app.textViews["Text View"]
        
        app.launch()
        app.buttons["RepresentedUITextView Tests"].tap()
        app.buttons["TestInit"].tap()
        
        XCTAssertEqual(boundValue.label, "World!")
        
        textView.tap()
        textView.typeText("Hello, ")
        
        XCTAssertEqual(boundValue.label, "Hello, World!")
    }
    
    func testInitWithActions() {
        let app = XCUIApplication()
        let boundValue = app.staticTexts["Bound Value"]
        let endValue = app.staticTexts["End Value"]
        let textView = app.textViews["Text View"]
        
        app.launch()
        app.buttons["RepresentedUITextView Tests"].tap()
        app.buttons["TestInitWithActions"].tap()
        
        XCTAssertEqual(boundValue.label, "World!")
        
        textView.tap()
        textView.typeText("Hello, ")
        
        XCTAssertEqual(boundValue.label, "Hello, World!")
        XCTAssertEqual(endValue.label, "")
        
        app.buttons["End Editing"].tap()
        
        XCTAssertEqual(endValue.label, "Hello, World!")
    }
}
