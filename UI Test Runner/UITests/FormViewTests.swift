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
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Form View Tests"]
***REMOVED******REMOVED***let inputValidationLabel = app.staticTexts["InputValidation"]
***REMOVED******REMOVED***let singleLineNoValueNoPlaceholderNoDescriptionTitle = app.staticTexts[
***REMOVED******REMOVED******REMOVED***"Single Line No Value, Placeholder or Description"
***REMOVED******REMOVED***]
***REMOVED******REMOVED***let singleLineNoValueNoPlaceholderNoDescriptionTextField =
***REMOVED******REMOVED******REMOVED***app.scrollViews.otherElements.containing(.staticText, identifier:"InputValidation")
***REMOVED******REMOVED******REMOVED***.children(matching: .textField).element(boundBy: 1)
***REMOVED******REMOVED***let helperText = app.staticTexts["Maximum 256 characters"]
***REMOVED******REMOVED***let characterCount = app.staticTexts["0"]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Form View component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***inputValidationLabel.waitForExistence(timeout: 30),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 30 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Scroll to the target form element.
***REMOVED******REMOVED***while !(singleLineNoValueNoPlaceholderNoDescriptionTitle.isHittable) {
***REMOVED******REMOVED******REMOVED***app.scrollViews.firstMatch.swipeUp(velocity: 750)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***singleLineNoValueNoPlaceholderNoDescriptionTextField.isHittable,
***REMOVED******REMOVED******REMOVED***"The target text field wasn't found within 30 seconds."
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
***REMOVED******REMOVED***singleLineNoValueNoPlaceholderNoDescriptionTextField.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***characterCount.exists,
***REMOVED******REMOVED******REMOVED***"The character count wasn't visible when it should've been."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
