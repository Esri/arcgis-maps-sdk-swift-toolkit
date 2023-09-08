// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest

final class FormViewTests: XCTestCase {
    override func setUp() async throws {
        continueAfterFailure = false
    }
    
    // - MARK: Test case 1: Text Box with no hint, no description, value not required
    
    /// Test case 1.1: unfocused and focused state, no value
    func testCase_1_1() throws {
        let app = XCUIApplication()
        let characterIndicator = app.staticTexts["Single Line No Value, Placeholder or Description Character Indicator"]
        let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
        let footer = app.staticTexts["Single Line No Value, Placeholder or Description Footer"]
        let formTitle = app.staticTexts["InputValidation"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
        
        app.launch()
        
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertTrue(
            textField.isHittable,
            "The target text field wasn't visible."
        )
        
        XCTAssertFalse(
            helperText.isHittable,
            "The helper text wasn't hidden."
        )
        
        XCTAssertFalse(
            characterCount.isHittable,
            "The character count wasn't hidden."
        )
        
        // Give focus to the target text field.
        textField.tap()
        
        XCTAssertTrue(
            characterCount.isHittable,
            "The character count wasn't visible."
        )
    }
    
    /// Test case 1.2: focused and unfocused state, with value (populated)
    func testCase_1_2() throws {
        let app = XCUIApplication()
        let characterIndicator = app.staticTexts["Single Line No Value, Placeholder or Description Character Indicator"]
        let clearButton = app.buttons["Single Line No Value, Placeholder or Description Clear Button"]
        let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
        let footer = app.staticTexts["Single Line No Value, Placeholder or Description Footer"]
        let formTitle = app.staticTexts["InputValidation"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let returnButton = app.buttons["Return"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
        
        app.launch()
        
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        // Scroll to the target form element.
        while !(fieldTitle.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        XCTAssertTrue(
            textField.isHittable,
            "The text field wasn't visible."
        )
        
        textField.tap()
        
        app.typeText("Sample text")
        
        XCTAssertTrue(
            helperText.isHittable,
            "The helper text wasn't visible."
        )
        
        XCTAssertTrue(
            characterCount.isHittable,
            "The character count wasn't visible."
        )
        
        XCTAssertTrue(
            clearButton.isHittable,
            "The clear button wasn't visible."
        )
        
        #if targetEnvironment(macCatalyst)
            app.typeText("\r")
        #else
            returnButton.tap()
        #endif
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The title wasn't visible."
        )
        
        XCTAssertFalse(
            helperText.isHittable,
            "The helper text wasn't hidden."
        )
        
        XCTAssertTrue(
            clearButton.isHittable,
            "The clear button wasn't visible."
        )
        
        XCTAssertTrue(
            textField.isHittable,
            "The text field wasn't visible."
        )
    }
    
    /// Test case 1.3: unfocused and focused state, with error value (> 256 chars)
    func testCase_1_3() throws {
        let app = XCUIApplication()
        let formViewTestsButton = app.buttons["FormView Tests"]
        let formTitle = app.staticTexts["InputValidation"]
        let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
        let helperText = app.staticTexts["Maximum 256 characters"]
        let characterCount = app.staticTexts["257"]
        
        app.launch()
        
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        // Scroll to the target form element.
        while !(fieldTitle.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        textField.tap()
        
        app.typeText(.loremIpsum257)
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The title wasn't visible."
        )
        
        XCTAssertTrue(
            helperText.isHittable,
            "The helper text wasn't visible."
        )
        
        XCTAssertTrue(
            characterCount.isHittable,
            "The character count wasn't visible."
        )
    }
    
    // - MARK: Test case 2: Test case 2: DateTime picker input type
    
    /// Test case 2.1: Unfocused and focused state, no value, date required
    func testCase_2_1() throws {
        let app = XCUIApplication()
        let calendarImage = app.images["Required Date Calendar Image"]
        let clearButton = app.buttons["Required Date Clear Button"]
        let datePicker = app.datePickers["Required Date Date Picker"]
        let fieldTitle = app.staticTexts["Required Date"]
        let fieldValue = app.staticTexts["Required Date Value"]
        let footer = app.staticTexts["Required Date Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let nowButton = app.buttons["Required Date Now Button"]
        
        app.launch()
        
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        // Scroll to the target form element.
        while !(fieldTitle.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        if fieldValue.label != "No Value" {
            clearButton.tap()
        }
        
        XCTAssertEqual(
            fieldValue.label,
            "No Value"
        )
        
        XCTAssertTrue(
            footer.isHittable,
            "The required label wasn't visible."
        )
        
        XCTAssertEqual(
            footer.label,
            "Required"
        )
        
        XCTAssertTrue(
            calendarImage.isHittable,
            "The calendar image wasn't visible."
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            datePicker.isHittable,
            "The date picker wasn't visible."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            Date.now.formatted(.dateTime.day().month().year().hour().minute())
        )
        
        XCTAssertTrue(
            nowButton.isHittable,
            "The now button wasn't visible."
        )
        
        // Scroll to the target form element.
        while !(footer.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        XCTAssertEqual(
            footer.label,
            "Date Entry is Required"
        )
    }
    
    /// Test case 2.2: Focused and unfocused state, with value (populated)
    func testCase_2_2() {
        let app = XCUIApplication()
        let datePicker = app.datePickers["Launch Date and Time for Apollo 11 Date Picker"]
        let fieldTitle = app.staticTexts["Launch Date and Time for Apollo 11"]
        let fieldValue = app.staticTexts["Launch Date and Time for Apollo 11 Value"]
        let footer = app.staticTexts["Launch Date and Time for Apollo 11 Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let nowButton = app.buttons["Launch Date and Time for Apollo 11 Now Button"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The field title wasn't visible."
        )
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let localDate = formatter.date(from: "1969-07-07T20:17:00.000Z")
        
        XCTAssertEqual(
            fieldValue.label,
            localDate?.formatted(.dateTime.day().month().year().hour().minute())
        )
        
        XCTAssertEqual(
            footer.label,
            "Enter the launch date and time (July 7, 1969 20:17 UTC)"
        )
        
        XCTAssertTrue(
            datePicker.isHittable,
            "The date picker wasn't visible."
        )
        
        XCTAssertTrue(
            nowButton.isHittable,
            "The now button wasn't visible."
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            fieldValue.isHittable,
            "The label wasn't visible."
        )
        
        XCTAssertFalse(
            datePicker.isHittable,
            "The date picker was visible."
        )
    }
    
    /// Test case 2.3: Date only, no time
    func testCase_2_3() {
        let app = XCUIApplication()
        let datePicker = app.datePickers["Launch Date for Apollo 11 Date Picker"]
        let fieldTitle = app.staticTexts["Launch Date for Apollo 11"]
        let fieldValue = app.staticTexts["Launch Date for Apollo 11 Value"]
        let footer = app.staticTexts["Launch Date for Apollo 11 Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let todayButton = app.buttons["Launch Date for Apollo 11 Today Button"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        // Scroll to the target form element.
        while !(fieldTitle.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        XCTAssertTrue(
            footer.isHittable,
            "The footer wasn't visible."
        )
        
        fieldValue.tap()
        
        XCTAssertEqual(
            footer.label,
            "Enter the Date for the Apollo 11 launch"
        )
        
        XCTAssertTrue(
            fieldValue.isHittable,
            "The field value wasn't visible."
        )
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let localDate = formatter.date(from: "2023-07-14")
        
        XCTAssertEqual(
            fieldValue.label,
            localDate?.formatted(.dateTime.day().month().year())
        )
        
        XCTAssertTrue(
            datePicker.isHittable,
            "The date picker wasn't visible."
        )
        
        XCTAssertTrue(
            todayButton.isHittable,
            "The today button wasn't visible."
        )
    }
    
    /// Test case 2.4: Maximum date
    func testCase_2_4() {
        let app = XCUIApplication()
        let clearButton = app.buttons["Launch Date Time End Clear Button"]
        let fieldTitle = app.staticTexts["Launch Date Time End"]
        let fieldValue = app.staticTexts["Launch Date Time End Value"]
        let footer = app.staticTexts["Launch Date Time End Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let nowButton = app.buttons["Launch Date Time End Now Button"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        // Scroll to the target form element.
        while !(fieldTitle.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        if fieldValue.label != "No Value" {
            clearButton.tap()
        }
        
        fieldValue.tap()
        
        // Scroll to the target form element.
        while !(footer.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 250)
        }
        
        XCTAssertTrue(
            footer.isHittable,
            "The footer wasn't visible."
        )
        
        nowButton.tap()
        
        fieldValue.tap()
        
        XCTAssertEqual(
            footer.label,
            "End date and Time 7/27/1969 12:00:00 AM"
        )
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let localDate = formatter.date(from: "1969-07-27T07:00:00.000Z")
        
        XCTAssertEqual(
            fieldValue.label,
            localDate?.formatted(.dateTime.day().month().year().hour().minute())
        )
    }
    
    /// Test case 2.5: Minimum date
    func testCase_2_5() {
        let app = XCUIApplication()
        let datePicker = app.datePickers["start and end date time Date Picker"]
        let fieldTitle = app.staticTexts["start and end date time"]
        let fieldValue = app.staticTexts["start and end date time Value"]
        let footer = app.staticTexts["start and end date time Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let nowButton = app.buttons["start and end date time Now Button"]
        let previousMonthButton = datePicker.buttons["Previous Month"]
        let julyFirstButton = datePicker.collectionViews.staticTexts["1"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        // Scroll to the target form element.
        while !(fieldTitle.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        fieldValue.tap()
        
        // Scroll to the target form element.
        while !(footer.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 250)
        }
        
        XCTAssertTrue(
            footer.isHittable,
            "The footer wasn't visible."
        )
        
        XCTAssertEqual(
            footer.label,
            """
            Form with Start date and End date defined
            Start July 1, 1969
            End  July 31, 1969
            """
        )
        
        nowButton.tap()
        
        julyFirstButton.tap()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let localDate = formatter.date(from: "1969-07-01T07:00:00.000Z")
        
        XCTAssertEqual(
            fieldValue.label,
            localDate?.formatted(.dateTime.day().month().year().hour().minute())
        )
        
        XCTAssertFalse(
            previousMonthButton.isEnabled,
            "The user was able to view June 1969 in the calendar."
        )
    }
    
    /// Test case 2.6: Clear date
    func testCase_2_6() {
        let app = XCUIApplication()
        let clearButton = app.buttons["Launch Date and Time for Apollo 11 Clear Button"]
        let fieldTitle = app.staticTexts["Launch Date and Time for Apollo 11"]
        let fieldValue = app.staticTexts["Launch Date and Time for Apollo 11 Value"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The field title wasn't visible."
        )
        
        XCTAssertTrue(
            clearButton.isHittable,
            "The clear button wasn't visible."
        )
        
        clearButton.tap()
        
        XCTAssertEqual(
            fieldValue.label,
            "No Value"
        )
    }
}

private extension String {
    /// 257 characters of Lorem ipsum text
    static var loremIpsum257: Self {
        .init(
            """
            Lorem ipsum dolor sit amet, consecteur adipiscing elit, sed do eiusmod tempor \
            incididunt ut labore et dolore magna aliqua. Semper eget at tellus. Sed cras ornare \
            arcu dui vivamus arcu. In a metus dictum at. Cras at vivamus at adipiscing \
            tellus et ut dolore.
            """
        )
    }
}
