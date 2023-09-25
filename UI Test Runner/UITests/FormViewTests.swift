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
***REMOVED***override func setUp() async throws {
***REMOVED******REMOVED***continueAfterFailure = false
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
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
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
***REMOVED***
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
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***let returnButton = app.buttons["Return"]
***REMOVED******REMOVED***let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
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
***REMOVED******REMOVED******REMOVED***characterIndicator.isHittable,
***REMOVED******REMOVED******REMOVED***"The character count isn't hittable."
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
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["InputValidation"]
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
***REMOVED******REMOVED***let returnButton = app.buttons["Return"]
***REMOVED******REMOVED***let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
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
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***let nowButton = app.buttons["Required Date Now Button"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
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
***REMOVED******REMOVED******REMOVED***Date.now.formatted(.dateTime.day().month().year().hour().minute())
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
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***let nowButton = app.buttons["Launch Date and Time for Apollo 11 Now Button"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
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
***REMOVED******REMOVED******REMOVED******REMOVED***timeZone: .gmt, year: 1969, month: 7, day: 8, hour: 3, minute: 17
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***localDate?.formatted(.dateTime.day().month().year().hour().minute())
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***footer.label,
***REMOVED******REMOVED******REMOVED***"Enter the launch date and time (July 7, 1969 20:17 UTC)"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***datePicker.isHittable,
***REMOVED******REMOVED******REMOVED***"The date picker isn't hittable."
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
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***let todayButton = app.buttons["Launch Date for Apollo 11 Today Button"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
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
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***let nowButton = app.buttons["Launch Date Time End Now Button"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
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
***REMOVED******REMOVED***nowButton.tap()
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
***REMOVED******REMOVED******REMOVED***localDate?.formatted(.dateTime.day().month().year().hour().minute())
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
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***let nowButton = app.buttons["start and end date time Now Button"]
***REMOVED******REMOVED***let previousMonthButton = datePicker.buttons["Previous Month"]
***REMOVED******REMOVED***let julyFirstButton = datePicker.collectionViews.staticTexts["1"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
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
***REMOVED******REMOVED******REMOVED***localDate?.formatted(.dateTime.day().month().year().hour().minute())
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
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
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
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Combo String Value"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["comboBox"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***let footer = app.staticTexts["Combo String Footer"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
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
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Combo Integer Value"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["comboBox"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***let optionsButton = app.images["Combo Integer Options Button"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
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
***REMOVED******REMOVED***let fieldValue = app.staticTexts["Combo String Value"]
***REMOVED******REMOVED***let firstOptionButton = app.buttons["String 1"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["comboBox"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
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
***REMOVED******REMOVED*** - MARK: Test case 5: Switch input type
***REMOVED***
***REMOVED******REMOVED***/ Test case 5.1: Test switch on
***REMOVED***func testCase_5_1() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["switch integer"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["switch integer Value"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.isHittable,
***REMOVED******REMOVED******REMOVED***"The field title isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"On"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***...
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 5.2: Test switch off
***REMOVED***func testCase_5_2() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["switch string"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["switch string Value"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.isHittable,
***REMOVED******REMOVED******REMOVED***"The field title isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***"Off"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***...
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test case 5.3: Test switch with no value
***REMOVED***func testCase_5_3() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let fieldTitle = app.staticTexts["switch double"]
***REMOVED******REMOVED***let fieldValue = app.staticTexts["switch double Value"]
***REMOVED******REMOVED***let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
***REMOVED******REMOVED***let formViewTestsButton = app.buttons["FormView Tests"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the FormView component test view.
***REMOVED******REMOVED***formViewTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait and verify that the form is opened.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***formTitle.waitForExistence(timeout: 5),
***REMOVED******REMOVED******REMOVED***"The form failed to open after 5 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***fieldTitle.isHittable,
***REMOVED******REMOVED******REMOVED***"The field title isn't hittable."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***fieldValue.label,
***REMOVED******REMOVED******REMOVED***""
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***...
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
