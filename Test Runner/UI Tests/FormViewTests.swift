***REMOVED*** Copyright 2023 Esri
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

final class FeatureFormViewTests: XCTestCase {
***REMOVED***override func setUp() async throws {
***REMOVED******REMOVED***continueAfterFailure = false
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the map and feature based on the current test case.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - app: The current application.
***REMOVED******REMOVED***/   - id: The name of the test case.
***REMOVED***func selectTestCase(_ app: XCUIApplication, id: String = #function) {
***REMOVED******REMOVED***let testCase = String(id.dropLast(2))
***REMOVED******REMOVED***let testCaseButton = app.buttons[testCase]
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***testCaseButton.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The button doesn't exist for \(testCase)"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***testCaseButton.tap()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** - MARK: Test case 1: Text Box with no hint, no description, value not required
***REMOVED***
***REMOVED******REMOVED***/ Test case 1.1: unfocused and focused state, no value
***REMOVED***func testCase_1_1() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let characterIndicator = app.staticTexts["Single Line No Value, Placeholder or Description Character Indicator"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
***REMOVED******REMOVED***let footer = app.staticTexts["Single Line No Value, Placeholder or Description Footer"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["InputValidation"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let textField = app.textFields["Single Line No Value, Placeholder or Description Text Input"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.exists,
***REMOVED******REMOVED******REMOVED***"The field title doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
#if !targetEnvironment(macCatalyst)
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***textField.hasFocus,
***REMOVED******REMOVED******REMOVED***"The target text field has focus."
***REMOVED******REMOVED***)
#endif
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***footer.isHittable,
***REMOVED******REMOVED******REMOVED***"The footer isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Give focus to the target text field.
***REMOVED******REMOVED***textField.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.exists,
***REMOVED******REMOVED******REMOVED***"The field title doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***footer.exists,
***REMOVED******REMOVED******REMOVED***"The footer doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"Maximum 256 characters"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***characterIndicator.exists,
***REMOVED******REMOVED******REMOVED***"The character indicator doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***characterIndicator.label,
***REMOVED******REMOVED******REMOVED***"0"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 1.2: focused and unfocused state, with value (populated)
***REMOVED***func testCase_1_2() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let characterIndicator = app.staticTexts["Single Line No Value, Placeholder or Description Character Indicator"]
***REMOVED******REMOVED***let clearButton = app.buttons["Single Line No Value, Placeholder or Description Clear Button"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
***REMOVED******REMOVED***let footer = app.staticTexts["Single Line No Value, Placeholder or Description Footer"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["InputValidation"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let returnButton = app.buttons["Return"]
***REMOVED******REMOVED***let textField = app.textFields["Single Line No Value, Placeholder or Description Text Input"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***textField.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.typeText("Sample text")
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.exists,
***REMOVED******REMOVED******REMOVED***"The field title doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***footer.exists,
***REMOVED******REMOVED******REMOVED***"The footer doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"Maximum 256 characters"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***characterIndicator.exists,
***REMOVED******REMOVED******REMOVED***"The character count doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***characterIndicator.label,
***REMOVED******REMOVED******REMOVED***"11"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***clearButton.exists,
***REMOVED******REMOVED******REMOVED***"The clear button doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
#if targetEnvironment(macCatalyst)
***REMOVED******REMOVED***app.typeText("\r")
#else
***REMOVED******REMOVED***returnButton.tap()
#endif
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.isHittable,
***REMOVED******REMOVED******REMOVED***"The title isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***footer.isHittable,
***REMOVED******REMOVED******REMOVED***"The footer is hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***clearButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The clear button isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***textField.isHittable,
***REMOVED******REMOVED******REMOVED***"The text field isn't hittable."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 1.3: unfocused and focused state, with error value (> 256 chars)
***REMOVED***func testCase_1_3() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let characterIndicator = app.staticTexts["Single Line No Value, Placeholder or Description Character Indicator"]
***REMOVED******REMOVED***let clearButton = app.buttons["Single Line No Value, Placeholder or Description Clear Button"]
***REMOVED******REMOVED***let footer = app.staticTexts["Single Line No Value, Placeholder or Description Footer"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["InputValidation"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
***REMOVED******REMOVED***let returnButton = app.buttons["Return"]
***REMOVED******REMOVED***let textField = app.textFields["Single Line No Value, Placeholder or Description Text Input"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***textField.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.typeText(.loremIpsum257)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.exists,
***REMOVED******REMOVED******REMOVED***"The title doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***footer.exists,
***REMOVED******REMOVED******REMOVED***"The footer doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"Maximum 256 characters"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***characterIndicator.exists,
***REMOVED******REMOVED******REMOVED***"The character count doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***characterIndicator.label,
***REMOVED******REMOVED******REMOVED***"257"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***clearButton.exists,
***REMOVED******REMOVED******REMOVED***"The clear button doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
#if targetEnvironment(macCatalyst)
***REMOVED******REMOVED***app.typeText("\r")
#else
***REMOVED******REMOVED***returnButton.tap()
#endif
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.exists,
***REMOVED******REMOVED******REMOVED***"The title doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***footer.exists,
***REMOVED******REMOVED******REMOVED***"The footer doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"Maximum 256 characters"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***characterIndicator.exists,
***REMOVED******REMOVED******REMOVED***"The character count exists."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***clearButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The clear button isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***textField.isHittable,
***REMOVED******REMOVED******REMOVED***"The text field isn't hittable."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func testCase_1_4() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let footer = app.staticTexts["numbers Footer"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["Domain"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let textField = app.textFields["numbers Text Input"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***textField.value as? String,
***REMOVED******REMOVED******REMOVED***""
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"Range domain 2-5"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***textField.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***textField.typeText("1")
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"Enter value from 2.0 to 5.0"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Highlight/select the current value and replace it
***REMOVED******REMOVED***textField.doubleTap()
***REMOVED******REMOVED***textField.typeText("3")
***REMOVED******REMOVED***
***REMOVED******REMOVED***expectation(
***REMOVED******REMOVED******REMOVED***for: NSPredicate(format: "label == \"Range domain 2-5\""),
***REMOVED******REMOVED******REMOVED***evaluatedWith: footer
***REMOVED******REMOVED***)
***REMOVED******REMOVED***waitForExpectations(timeout: 10, handler: nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Highlight/select the current value and replace it
***REMOVED******REMOVED***textField.doubleTap()
***REMOVED******REMOVED***textField.typeText("6")
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"Enter value from 2.0 to 5.0"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** - MARK: Test case 2: DateTime picker input type
***REMOVED***
***REMOVED******REMOVED***/ Test case 2.1: Unfocused and focused state, no value, date required
***REMOVED***func testCase_2_1() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let calendarImage = app.images["Required Date Calendar Image"]
***REMOVED******REMOVED***let clearButton = app.buttons["Required Date Clear Button"]
***REMOVED******REMOVED***let datePicker = app.datePickers["Required Date Date Picker"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Required Date Value"]
***REMOVED******REMOVED***let footer = app.staticTexts["Required Date Footer"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["DateTimePoint"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let nowButton = app.buttons["Required Date Now Button"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if fieldValue.label != "No Value" {
***REMOVED******REMOVED******REMOVED***clearButton.tap()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"No Value"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***footer.exists,
***REMOVED******REMOVED******REMOVED***"The required label doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"Date Entry is Required"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***calendarImage.exists,
***REMOVED******REMOVED******REMOVED***"The calendar image doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***fieldValue.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***datePicker.exists,
***REMOVED******REMOVED******REMOVED***"The date picker doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***Date.now.formatted()
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***nowButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The now button isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"Date Entry is Required"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 2.2: Focused and unfocused state, with value (populated)
***REMOVED***func testCase_2_2() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let datePicker = app.datePickers["Launch Date and Time for Apollo 11 Date Picker"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Launch Date and Time for Apollo 11"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Launch Date and Time for Apollo 11 Value"]
***REMOVED******REMOVED***let footer = app.staticTexts["Launch Date and Time for Apollo 11 Footer"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["DateTimePoint"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let nowButton = app.buttons["Launch Date and Time for Apollo 11 Now Button"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***fieldValue.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.isHittable,
***REMOVED******REMOVED******REMOVED***"The field title isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let localDate = Calendar.current.date(
***REMOVED******REMOVED******REMOVED***from: DateComponents(
***REMOVED******REMOVED******REMOVED******REMOVED***timeZone: .gmt, year: 1969, month: 7, day: 16, hour: 13, minute: 32
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***localDate?.formatted()
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"Enter the launch date and time (July 16, 1969 13:32 UTC)"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***datePicker.exists,
***REMOVED******REMOVED******REMOVED***"The date picker doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***nowButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The now button isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***fieldValue.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldValue.isHittable,
***REMOVED******REMOVED******REMOVED***"The label isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***datePicker.isHittable,
***REMOVED******REMOVED******REMOVED***"The date picker was hittable."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 2.3: Date only, no time
***REMOVED***func testCase_2_3() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let datePicker = app.datePickers["Launch Date for Apollo 11 Date Picker"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Launch Date for Apollo 11 Value"]
***REMOVED******REMOVED***let footer = app.staticTexts["Launch Date for Apollo 11 Footer"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["DateTimePoint"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let todayButton = app.buttons["Launch Date for Apollo 11 Today Button"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***footer.isHittable,
***REMOVED******REMOVED******REMOVED***"The footer isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***fieldValue.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"Enter the Date for the Apollo 11 launch"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldValue.isHittable,
***REMOVED******REMOVED******REMOVED***"The field value isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let localDate = Calendar.current.date(
***REMOVED******REMOVED******REMOVED***from: DateComponents(
***REMOVED******REMOVED******REMOVED******REMOVED***timeZone: .gmt, year: 2023, month: 7, day: 15, hour: 3, minute: 53
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTExpectFailure("Time should not be included. Apollo #355")
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***localDate?.formatted(.dateTime.day().month().year())
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***datePicker.isHittable,
***REMOVED******REMOVED******REMOVED***"The date picker isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***todayButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The today button isn't hittable."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 2.4: Maximum date
***REMOVED***func testCase_2_4() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let clearButton = app.buttons["Launch Date Time End Clear Button"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Launch Date Time End Value"]
***REMOVED******REMOVED***let footer = app.staticTexts["Launch Date Time End Footer"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["DateTimePoint"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let nowButton = app.buttons["Launch Date Time End Now Button"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if fieldValue.label != "No Value" {
***REMOVED******REMOVED******REMOVED***clearButton.tap()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***fieldValue.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***footer.exists,
***REMOVED******REMOVED******REMOVED***"The footer doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***nowButton.waitForExistence(timeout: 2.5),
***REMOVED******REMOVED******REMOVED***"The Now button doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***nowButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The Now button wasn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***nowButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldValue.isHittable,
***REMOVED******REMOVED******REMOVED***"The field wasn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***fieldValue.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"End date and Time 7/27/1969 12:00:00 AM"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let localDate = Calendar.current.date(
***REMOVED******REMOVED******REMOVED***from: DateComponents(
***REMOVED******REMOVED******REMOVED******REMOVED***timeZone: .gmt, year: 1969, month: 7, day: 27, hour: 7
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***localDate?.formatted()
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 2.5: Minimum date
***REMOVED***func testCase_2_5() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let datePicker = app.datePickers["start and end date time Date Picker"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["start and end date time Value"]
***REMOVED******REMOVED***let footer = app.staticTexts["start and end date time Footer"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["DateTimePoint"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let nowButton = app.buttons["start and end date time Now Button"]
***REMOVED******REMOVED***let previousMonthButton = datePicker.buttons["Previous Month"]
***REMOVED******REMOVED***let julyFirstButton = datePicker.collectionViews.staticTexts["1"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***fieldValue.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***footer.exists,
***REMOVED******REMOVED******REMOVED***"The footer doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED******REMOVED***Form with Start date and End date defined
***REMOVED******REMOVED******REMOVED***Start July 1, 1969
***REMOVED******REMOVED******REMOVED***End  July 31, 1969
***REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***nowButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***julyFirstButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let localDate = Calendar.current.date(
***REMOVED******REMOVED******REMOVED***from: DateComponents(
***REMOVED******REMOVED******REMOVED******REMOVED***timeZone: .gmt, year: 1969, month: 7, day: 1, hour: 7
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***localDate?.formatted()
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***previousMonthButton.isEnabled,
***REMOVED******REMOVED******REMOVED***"The user was able to view June 1969 in the calendar."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 2.6: Clear date
***REMOVED***func testCase_2_6() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let clearButton = app.buttons["Launch Date and Time for Apollo 11 Clear Button"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Launch Date and Time for Apollo 11"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Launch Date and Time for Apollo 11 Value"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["DateTimePoint"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.isHittable,
***REMOVED******REMOVED******REMOVED***"The field title isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***clearButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The clear button isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***clearButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"No Value"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** - MARK: Test case 3: Combo Box input type
***REMOVED***
***REMOVED******REMOVED***/ Test case 3.1: Pre-existing value, description, clear button, no value label
***REMOVED***func testCase_3_1() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let clearButton = app.buttons["Combo String Clear Button"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Combo String"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Combo String Combo Box Value"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["comboBox"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let footer = app.staticTexts["Combo String Footer"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.isHittable,
***REMOVED******REMOVED******REMOVED***"The field title isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldValue.isHittable,
***REMOVED******REMOVED******REMOVED***"The field value isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"String 3"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***clearButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The clear button isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***clearButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"No value"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***footer.isHittable,
***REMOVED******REMOVED******REMOVED***"The footer isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"Combo Box of Field Type String"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 3.2: No pre-existing value, no value label, options button
***REMOVED***func testCase_3_2() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Combo Integer"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Combo Integer Combo Box Value"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["comboBox"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let optionsButton = app.images["Combo Integer Options Button"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.isHittable,
***REMOVED******REMOVED******REMOVED***"The field title isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldValue.isHittable,
***REMOVED******REMOVED******REMOVED***"The field value isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"No value"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***optionsButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The options button isn't hittable."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 3.3: Pick a value
***REMOVED***func testCase_3_3() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let doneButton = app.buttons["Done"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Combo String"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Combo String Combo Box Value"]
***REMOVED******REMOVED***let firstOptionButton = app.buttons["String 1"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["comboBox"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.isHittable,
***REMOVED******REMOVED******REMOVED***"The field title isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldValue.isHittable,
***REMOVED******REMOVED******REMOVED***"The field value isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"String 3"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***fieldValue.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***firstOptionButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The first option (String 1) isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***firstOptionButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***doneButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The done button isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***doneButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"String 1"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 3.4: Picker with a noValueLabel row
***REMOVED***func testCase_3_4() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let doneButton = app.buttons["Done"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Combo String"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Combo String Combo Box Value"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["comboBox"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let noValueButton = app.buttons["No value"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.isHittable,
***REMOVED******REMOVED******REMOVED***"The field title isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"String 3"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***fieldValue.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***noValueButton.waitForExistence(timeout: 1),
***REMOVED******REMOVED******REMOVED***"The no value button doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***noValueButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***doneButton.exists,
***REMOVED******REMOVED******REMOVED***"The done button doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***doneButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"No value"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 3.5: Required Value
***REMOVED***func testCase_3_5() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let clearButton = app.buttons["Required Combo Box Clear Button"]
***REMOVED******REMOVED***let doneButton = app.buttons["Done"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Required Combo Box *"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Required Combo Box Combo Box Value"]
***REMOVED******REMOVED***let footer = app.staticTexts["Required Combo Box Footer"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["comboBox"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let noValueButton = app.buttons["No value"]
***REMOVED******REMOVED***let oakButton = app.buttons["Oak"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.exists,
***REMOVED******REMOVED******REMOVED***"The field title doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"Pine"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***clearButton.isHittable,
***REMOVED******REMOVED******REMOVED***"The clear button is hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***footer.exists,
***REMOVED******REMOVED******REMOVED***"The footer doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***fieldValue.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***noValueButton.exists,
***REMOVED******REMOVED******REMOVED***"The no value button exists but it should not."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***oakButton.exists,
***REMOVED******REMOVED******REMOVED***"The Oak button doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***oakButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***doneButton.exists,
***REMOVED******REMOVED******REMOVED***"The done button doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***doneButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"Oak"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 3.6: noValueOption is 'Hide'
***REMOVED***func testCase_3_6() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let doneButton = app.buttons["Done"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Combo No Value False"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Combo No Value False Combo Box Value"]
***REMOVED******REMOVED***let firstOption = app.buttons["First"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["comboBox"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let noValueButton = app.buttons["No Value"]
***REMOVED******REMOVED***let optionsButton = app.images["Combo No Value False Options Button"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.exists,
***REMOVED******REMOVED******REMOVED***"The field title doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***""
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***optionsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***firstOption.waitForExistence(timeout: 1),
***REMOVED******REMOVED******REMOVED***"The First option doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***noValueButton.exists,
***REMOVED******REMOVED******REMOVED***"No Value exists as an option but it shouldn't."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***firstOption.isHittable,
***REMOVED******REMOVED******REMOVED***"The First option isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***firstOption.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***doneButton.exists,
***REMOVED******REMOVED******REMOVED***"The done button doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***doneButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"First"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** - MARK: Test case 4: Radio Buttons input type
***REMOVED***
***REMOVED******REMOVED***/ Test case 4.1: Test regular selection
***REMOVED***func testCase_4_1() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let birdOptionCheckmark = app.images["Radio Button Text bird Checkmark"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Radio Button Text *"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let dogOption = app.buttons["Radio Button Text dog Radio Button"]
***REMOVED******REMOVED***let dogOptionCheckmark = app.images["Radio Button Text dog Checkmark"]
***REMOVED******REMOVED***let noValueOption = app.buttons["Radio Button Text No Value Radio Button"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.exists,
***REMOVED******REMOVED******REMOVED***"The field title doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***birdOptionCheckmark.exists,
***REMOVED******REMOVED******REMOVED***"The bird option isn't selected."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***dogOptionCheckmark.exists,
***REMOVED******REMOVED******REMOVED***"The dog option is selected."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***dogOption.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***dogOptionCheckmark.exists,
***REMOVED******REMOVED******REMOVED***"The dog option isn't selected."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***birdOptionCheckmark.exists,
***REMOVED******REMOVED******REMOVED***"The bird option is selected."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***noValueOption.exists,
***REMOVED******REMOVED******REMOVED***"The no value option doesn't exist."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 4.2: Test radio button fallback to combo box
***REMOVED***func testCase_4_2() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let field1 = app.staticTexts["Fallback 1 Combo Box Value"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let noValueDisabledRadioButton = app.buttons["No Value Disabled One Radio Button"]
***REMOVED******REMOVED***let noValueEnabledRadioButton = app.buttons["No Value Enabled N/A Radio Button"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify the Radio Button fallback to Combo Box was successful.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***field1.exists,
***REMOVED******REMOVED******REMOVED***"The combo box doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify the radio buttons are shown even when the value option is enabled.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***noValueEnabledRadioButton.exists,
***REMOVED******REMOVED******REMOVED***"The radio button doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify the radio buttons are still shown even when the value option is disabled.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***noValueDisabledRadioButton.exists,
***REMOVED******REMOVED******REMOVED***"The radio button doesn't exist."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** - MARK: Test case 5: Switch input type
***REMOVED***
***REMOVED******REMOVED***/ Test case 5.1: Test switch on
***REMOVED***func testCase_5_1() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["switch integer"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let switchLabel = app.staticTexts["switch integer Switch Label"]
***REMOVED******REMOVED***let switchView = app.switches["switch integer Switch"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.exists,
***REMOVED******REMOVED******REMOVED***"The field title isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***switchLabel.label,
***REMOVED******REMOVED******REMOVED***"2"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***switchView.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***switchLabel.label,
***REMOVED******REMOVED******REMOVED***"1"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 5.2: Test switch off
***REMOVED***func testCase_5_2() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["switch string"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let switchLabel = app.staticTexts["switch string Switch Label"]
***REMOVED******REMOVED***let switchView = app.switches["switch string Switch"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.isHittable,
***REMOVED******REMOVED******REMOVED***"The field title isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***switchLabel.label,
***REMOVED******REMOVED******REMOVED***"1"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***switchView.isHittable,
***REMOVED******REMOVED******REMOVED***"The switch isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***switchView.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***switchLabel.label,
***REMOVED******REMOVED******REMOVED***"2"
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 5.3: Test switch with no value
***REMOVED***func testCase_5_3() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["switch double"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["switch double Combo Box Value"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.exists,
***REMOVED******REMOVED******REMOVED***"The field title doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldValue.exists,
***REMOVED******REMOVED******REMOVED***"The combo box doesn't exist."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 6.1: Test initially expanded and collapsed
***REMOVED***func testCase_6_1() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let collapsedGroupFirstElement = app.staticTexts["Single Line Text"]
***REMOVED******REMOVED***let expandedGroupFirstElement = app.staticTexts["MultiLine Text"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["group_formelement_UI_not_editable"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***
#if targetEnvironment(macCatalyst)
***REMOVED******REMOVED***let collapsedGroup = app.disclosureTriangles["Group with Multiple Form Elements 2"]
***REMOVED******REMOVED***let expandedGroup = app.disclosureTriangles["Group with Multiple Form Elements"]
***REMOVED******REMOVED***let expandedGroupDescription = app.disclosureTriangles["Group with Multiple Form Elements Description"]
#else
***REMOVED******REMOVED***let collapsedGroup = app.staticTexts["Group with Multiple Form Elements 2"]
***REMOVED******REMOVED***let expandedGroup = app.staticTexts["Group with Multiple Form Elements"]
***REMOVED******REMOVED***let expandedGroupDescription = app.staticTexts["Group with Multiple Form Elements Description"]
#endif
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***expandedGroup.exists,
***REMOVED******REMOVED******REMOVED***"The first group header doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***expandedGroupDescription.exists,
***REMOVED******REMOVED******REMOVED***"The expanded group's description doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***expandedGroupDescription.label,
***REMOVED******REMOVED******REMOVED***"This Group is 'Expand initial state'\nThis group is Visible"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Confirm the first element of the expanded group exists.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***expandedGroupFirstElement.exists,
***REMOVED******REMOVED******REMOVED***"The first group element doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***collapsedGroup.exists,
***REMOVED******REMOVED******REMOVED***"The collapsed group header doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Confirm the first element of the collapsed group doesn't exist.
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***collapsedGroupFirstElement.exists,
***REMOVED******REMOVED******REMOVED***"The first group element exists but should be hidden."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 6.2: Test visibility of empty group
***REMOVED***func testCase_6_2() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let formTitle = app.staticTexts["group_formelement_UI_not_editable"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let groupElement = app.staticTexts["single line text 3"]
***REMOVED******REMOVED***let showElementsButton = app.buttons["show invisible form element"]
***REMOVED******REMOVED***
#if targetEnvironment(macCatalyst)
***REMOVED******REMOVED***let hiddenElementsGroup = app.disclosureTriangles["Group with children that are visible dependent"]
***REMOVED******REMOVED***let hiddenElementsGroupDescription = app.disclosureTriangles["Group with children that are visible dependent Description"]
#else
***REMOVED******REMOVED***let hiddenElementsGroup = app.staticTexts["Group with children that are visible dependent"]
***REMOVED******REMOVED***let hiddenElementsGroupDescription = app.staticTexts["Group with children that are visible dependent Description"]
#endif
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***hiddenElementsGroup.exists,
***REMOVED******REMOVED******REMOVED***"The group header doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***hiddenElementsGroupDescription.exists,
***REMOVED******REMOVED******REMOVED***"The expanded group's description doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***hiddenElementsGroupDescription.label,
***REMOVED******REMOVED******REMOVED***"The Form Elements in this group need the Radio button \"show invisible form elements\" to be selected, if you want to see them"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Confirm the first element of the conditional group doesn't exist.
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***groupElement.exists,
***REMOVED******REMOVED******REMOVED***"The first group element exists but should be hidden."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Confirm the option to show the elements exists.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***showElementsButton.exists,
***REMOVED******REMOVED******REMOVED***"The show group elements button doesn't exist."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***showElementsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Confirm the first element of the conditional group doesn't exist.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***groupElement.exists,
***REMOVED******REMOVED******REMOVED***"The first group element doesn't exist."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 7.1: Test read only elements
***REMOVED***func testCase_7_1() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let formTitle = app.staticTexts["Test Case 7.1 - Read only elements"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let elementsAreEditableSwitch = app.switches["Elements are editable Switch"]
***REMOVED******REMOVED***let elementInTheGroupIsEditableReadOnlyInput = app.staticTexts["Element in the group is editable Read Only Input"]
***REMOVED******REMOVED***let elementInTheGroupIsEditableSwitch = app.switches["Element in the group is editable Switch"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***let comboBoxReadOnlyInput = app.staticTexts["Combo box Read Only Input"]
***REMOVED******REMOVED***let comboBox = app.staticTexts["Combo box Combo Box Value"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***let radioButtonsReadOnlyInput = app.staticTexts["Radio buttons Read Only Input"]
***REMOVED******REMOVED***let radioButtonsInput = app.images["Radio buttons 0 Checkmark"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***let dateReadOnlyInput = app.staticTexts["Date Read Only Input"]
***REMOVED******REMOVED***let dateInput = app.staticTexts["Date Value"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***let shortTextReadOnlyInput = app.staticTexts["Short text Read Only Input"]
***REMOVED******REMOVED***let shortTextTextInput = app.textFields["Short text Text Input"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***let longTextReadOnlyInput = app.staticTexts["Long text Read Only Input"]
***REMOVED******REMOVED***let longTextTextInputPreview = app.staticTexts["Long text Text Input Preview"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(elementInTheGroupIsEditableReadOnlyInput.exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(comboBoxReadOnlyInput.exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(radioButtonsReadOnlyInput.exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(dateReadOnlyInput.exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(shortTextReadOnlyInput.exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(longTextReadOnlyInput.exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***elementsAreEditableSwitch.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(elementInTheGroupIsEditableSwitch.exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***elementInTheGroupIsEditableSwitch.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(comboBox.exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(radioButtonsInput.exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(dateInput.exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(shortTextTextInput.exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(longTextTextInputPreview.exists)
***REMOVED***
***REMOVED***
***REMOVED***func testCase_8_1() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let attachmentElementTitle = app.staticTexts["Attachments"]
***REMOVED******REMOVED***let attachmentName = app.staticTexts["EsriHQ.jpeg"]
***REMOVED******REMOVED***let downloadIcon = app.images["Download"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["Esri Location"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let placeholderImage = app.images["Photo"]
***REMOVED******REMOVED***let sizeLabel = app.staticTexts["154 kB"]
***REMOVED******REMOVED***let thumbnailImage = app.images["EsriHQ.jpeg Thumbnail"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(attachmentElementTitle.exists)
***REMOVED******REMOVED***XCTAssertTrue(placeholderImage.exists)
***REMOVED******REMOVED***XCTAssertTrue(attachmentName.exists)
***REMOVED******REMOVED***XCTAssertTrue(sizeLabel.exists)
***REMOVED******REMOVED***XCTAssertTrue(downloadIcon.exists)
***REMOVED******REMOVED***
***REMOVED******REMOVED***placeholderImage.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(thumbnailImage.waitForExistence(timeout: 10))
***REMOVED******REMOVED***XCTAssertFalse(placeholderImage.exists)
***REMOVED******REMOVED***XCTAssertFalse(downloadIcon.exists)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test value backed read only elements
***REMOVED***func testCase_9_1() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let formTitle = app.staticTexts["Test Case 9 Form"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["Feature Form Tests"]
***REMOVED******REMOVED***let singleCharacterString = app.staticTexts["singleCharacterString Footer"]
***REMOVED******REMOVED***let lengthRangeString = app.staticTexts["lengthRangeString Footer"]
***REMOVED******REMOVED***let maxExceededString = app.staticTexts["maxExceededString Footer"]
***REMOVED******REMOVED***let numericalRange = app.staticTexts["numericalRange Footer"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FeatureFormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***selectTestCase(app)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 10),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 10 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(singleCharacterString.label, "Value must be 1 character")
***REMOVED******REMOVED***XCTAssertEqual(lengthRangeString.label, "Value must be 2 to 5 characters")
***REMOVED******REMOVED***XCTAssertEqual(maxExceededString.label, "Maximum 5 characters")
***REMOVED******REMOVED***XCTAssertEqual(numericalRange.label, "Value must be from 2 to 5")
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
