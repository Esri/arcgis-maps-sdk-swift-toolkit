***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import XCTest

final class FormViewTests: XCTestCase {
***REMOVED******REMOVED***/ Text Box with no hint, no description, value not required.
***REMOVED***func testCase_1_1() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Form View Tests"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["InputValidation"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
***REMOVED******REMOVED***let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
***REMOVED******REMOVED***let helperText = app.staticTexts["Maximum 256 characters"]
***REMOVED******REMOVED***let characterCount = app.staticTexts["0"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Form View component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Scroll to the target form element.
***REMOVED******REMOVED***while !(fieldTitle.isHittable) {
***REMOVED******REMOVED******REMOVED***app.scrollViews.firstMatch.swipeUp(velocity: 750)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***textField.isHittable,
***REMOVED******REMOVED******REMOVED***"The target text field wasn't found."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***helperText.exists,
***REMOVED******REMOVED******REMOVED***"The helper text was visible before it should've been."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***characterCount.exists,
***REMOVED******REMOVED******REMOVED***"The character count was visible before it should've been."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Give focus to the target text field.
***REMOVED******REMOVED***textField.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***characterCount.exists,
***REMOVED******REMOVED******REMOVED***"The character count wasn't visible when it should've been."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Tests focused and unfocused state, with value (populated).
***REMOVED***func testCase_1_2() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Form View Tests"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["InputValidation"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
***REMOVED******REMOVED***let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
***REMOVED******REMOVED***let helperText = app.staticTexts["Maximum 256 characters"]
***REMOVED******REMOVED***let characterCount = app.staticTexts["11"]
***REMOVED******REMOVED***let clearButton = app.buttons["Single Line No Value, Placeholder or Description Clear Button"]
***REMOVED******REMOVED***let returnButton = app.buttons["Return"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Form View component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Scroll to the target form element.
***REMOVED******REMOVED***while !(fieldTitle.isHittable) {
***REMOVED******REMOVED******REMOVED***app.scrollViews.firstMatch.swipeUp(velocity: 750)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***textField.isHittable,
***REMOVED******REMOVED******REMOVED***"The text field wasn't found within 30 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***textField.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.typeText("Sample text")
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***helperText.exists,
***REMOVED******REMOVED******REMOVED***"The helper text wasn't visible when it should've been."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***characterCount.exists,
***REMOVED******REMOVED******REMOVED***"The character count wasn't visible when it should've been."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***clearButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The clear button wasn't present when it should've been."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***returnButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.isHittable,
***REMOVED******REMOVED******REMOVED***"The title wasn't found within 30 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***helperText.exists,
***REMOVED******REMOVED******REMOVED***"The helper text was visible when it should've been hidden."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***clearButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The clear button wasn't present when it should've been."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***textField.isHittable,
***REMOVED******REMOVED******REMOVED***"The text field wasn't found within 30 seconds."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func testCase_1_3() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Form View Tests"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["InputValidation"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
***REMOVED******REMOVED***let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
***REMOVED******REMOVED***let helperText = app.staticTexts["Maximum 256 characters"]
***REMOVED******REMOVED***let characterCount = app.staticTexts["257"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Form View component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Scroll to the target form element.
***REMOVED******REMOVED***while !(fieldTitle.isHittable) {
***REMOVED******REMOVED******REMOVED***app.scrollViews.firstMatch.swipeUp(velocity: 750)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***textField.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.typeText(.loremIpsum257)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.isHittable,
***REMOVED******REMOVED******REMOVED***"The title wasn't found within 30 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***helperText.exists,
***REMOVED******REMOVED******REMOVED***"The helper text was visible when it should've been hidden."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***characterCount.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The character count wasn't visible when it should've been."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private extension String {
***REMOVED******REMOVED***/ 257 characters of Lorem ipsum text
***REMOVED***static var loremIpsum257: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED******REMOVED***Lorem ipsum dolor sit amet, consecteur adipiscing elit, sed do eiusmod tempor \
***REMOVED******REMOVED******REMOVED***incididunt ut labore et dolore magna aliqua. Semper eget at tellus. Sed cras ornare \
***REMOVED******REMOVED******REMOVED***arcu dui vivamus arcu. In a metus dictum at. Cras at vivamus at adipiscing \
***REMOVED******REMOVED******REMOVED***tellus et ut dolore.
***REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
