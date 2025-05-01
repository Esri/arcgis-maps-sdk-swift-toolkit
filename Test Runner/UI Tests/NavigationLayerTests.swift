***REMOVED*** Copyright 2025 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import XCTest

@MainActor
final class NavigationLayerTests: XCTestCase {
***REMOVED***override func setUpWithError() throws {
***REMOVED******REMOVED***continueAfterFailure = false
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test that titles and subtitles are shown properly.
***REMOVED***func testCase_1() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.buttons["NavigationLayer Tests"].tap()
***REMOVED******REMOVED***app.buttons["NavigationLayer Test Case 1"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.buttons["Present a view"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(app.staticTexts["1st Destination"].exists)
***REMOVED******REMOVED***XCTAssertTrue(app.staticTexts["Subtitle"].exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.buttons["Present another view"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(app.staticTexts["2nd Destination"].exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(app.staticTexts["1st Destination"].exists)
***REMOVED******REMOVED***XCTAssertFalse(app.staticTexts["Subtitle"].exists)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test that back navigation is blocked correctly.
***REMOVED***func testCase_2() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.buttons["NavigationLayer Tests"].tap()
***REMOVED******REMOVED***app.buttons["NavigationLayer Test Case 2"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.buttons["Present a view"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(app.staticTexts["Presented view"].exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.buttons.matching(identifier: "Back").element(boundBy: 1).tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(app.staticTexts["Navigation blocked!"].exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.buttons["Continue"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(app.staticTexts["Presented view"].exists)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test that `onNavigationPathChanged(perform:)` works as expected.
***REMOVED***func testCase_3() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.buttons["NavigationLayer Tests"].tap()
***REMOVED******REMOVED***app.buttons["NavigationLayer Test Case 3"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(app.staticTexts["Root view"].exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.buttons["Present a view"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(app.staticTexts["DemoView"].exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.buttons.matching(identifier: "Back").element(boundBy: 1).tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(app.staticTexts["Root view"].exists)
***REMOVED***
***REMOVED***
