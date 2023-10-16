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
    
    /// Sets the map and feature based on the current test case.
    /// - Parameters:
    ///   - app: The current application.
    ///   - id: The name of the test case.
    func selectTestCase(_ app: XCUIApplication, id: String = #function) {
        let testCase = String(id.dropLast(2))
        let testCaseButton = app.buttons[testCase]
        XCTAssertTrue(
            testCaseButton.waitForExistence(timeout: 5),
            "The button doesn't exist for \(testCase)"
        )
        testCaseButton.tap()
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
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The field title doesn't exist."
        )
        
#if !targetEnvironment(macCatalyst)
        XCTAssertFalse(
            textField.hasFocus,
            "The target text field has focus."
        )
#endif
        
        XCTAssertFalse(
            footer.isHittable,
            "The footer isn't hittable."
        )
        
        // Give focus to the target text field.
        textField.tap()
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The field title doesn't exist."
        )
        
        XCTAssertTrue(
            footer.exists,
            "The footer doesn't exist."
        )
        
        XCTAssertEqual(
            footer.label,
            "Maximum 256 characters"
        )
    
        XCTAssertTrue(
            characterIndicator.exists,
            "The character indicator doesn't exist."
        )
        
        XCTAssertEqual(
            characterIndicator.label,
            "0"
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
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        textField.tap()
        
        app.typeText("Sample text")
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The field title doesn't exist."
        )
        
        XCTAssertTrue(
            footer.exists,
            "The footer doesn't exist."
        )
        
        XCTAssertEqual(
            footer.label,
            "Maximum 256 characters"
        )
        
        XCTAssertTrue(
            characterIndicator.isHittable,
            "The character count isn't hittable."
        )
        
        XCTAssertEqual(
            characterIndicator.label,
            "11"
        )
        
        XCTAssertTrue(
            clearButton.exists,
            "The clear button doesn't exist."
        )
        
#if targetEnvironment(macCatalyst)
        app.typeText("\r")
#else
        returnButton.tap()
#endif
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The title isn't hittable."
        )
        
        XCTAssertFalse(
            footer.isHittable,
            "The footer is hittable."
        )
        
        XCTAssertTrue(
            clearButton.isHittable,
            "The clear button isn't hittable."
        )
        
        XCTAssertTrue(
            textField.isHittable,
            "The text field isn't hittable."
        )
    }
    
    /// Test case 1.3: unfocused and focused state, with error value (> 256 chars)
    func testCase_1_3() throws {
        let app = XCUIApplication()
        let characterIndicator = app.staticTexts["Single Line No Value, Placeholder or Description Character Indicator"]
        let clearButton = app.buttons["Single Line No Value, Placeholder or Description Clear Button"]
        let footer = app.staticTexts["Single Line No Value, Placeholder or Description Footer"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let formTitle = app.staticTexts["InputValidation"]
        let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
        let returnButton = app.buttons["Return"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
        
        app.launch()
        
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        textField.tap()
        
        app.typeText(.loremIpsum257)
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The title doesn't exist."
        )
        
        XCTAssertTrue(
            footer.exists,
            "The footer doesn't exist."
        )
        
        XCTAssertEqual(
            footer.label,
            "Maximum 256 characters"
        )
        
        XCTAssertTrue(
            characterIndicator.exists,
            "The character count doesn't exist."
        )
        
        XCTAssertEqual(
            characterIndicator.label,
            "257"
        )
        
        XCTAssertTrue(
            clearButton.exists,
            "The clear button doesn't exist."
        )
        
#if targetEnvironment(macCatalyst)
        app.typeText("\r")
#else
        returnButton.tap()
#endif
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The title doesn't exist."
        )
        
        XCTAssertTrue(
            footer.exists,
            "The footer doesn't exist."
        )
        
        XCTAssertEqual(
            footer.label,
            "Maximum 256 characters"
        )
        
        XCTAssertFalse(
            characterIndicator.exists,
            "The character count exists."
        )
        
        XCTAssertTrue(
            clearButton.isHittable,
            "The clear button isn't hittable."
        )
        
        XCTAssertTrue(
            textField.isHittable,
            "The text field isn't hittable."
        )
    }
    
    func testCase_1_4() {
        let app = XCUIApplication()
        let footer = app.staticTexts["numbers Footer"]
        let formTitle = app.staticTexts["Domain"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let textField = app.textFields["numbers Text Field"]
        
        app.launch()
        
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertEqual(
            footer.label,
            "Range domain  2-5"
        )
        
        textField.tap()
        
        textField.typeText("1")
        
        XCTAssertEqual(
            footer.label,
            "Enter value from 2.0 to 5.0"
        )
        
        // Highlight/select the current value and replace it
        textField.doubleTap()
        textField.typeText("2.1")
        
        XCTAssertEqual(
            footer.label,
            "Range domain  2-5"
        )
        
        // Highlight/select the current value and replace it
        textField.doubleTap()
        textField.typeText("5.1")
        
        XCTAssertEqual(
            footer.label,
            "Enter value from 2.0 to 5.0"
        )
    }
    
    // - MARK: Test case 2: DateTime picker input type
    
    /// Test case 2.1: Unfocused and focused state, no value, date required
    func testCase_2_1() throws {
        let app = XCUIApplication()
        let calendarImage = app.images["Required Date Calendar Image"]
        let clearButton = app.buttons["Required Date Clear Button"]
        let datePicker = app.datePickers["Required Date Date Picker"]
        let fieldValue = app.staticTexts["Required Date Value"]
        let footer = app.staticTexts["Required Date Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let nowButton = app.buttons["Required Date Now Button"]
        
        app.launch()
        
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        if fieldValue.label != "No Value" {
            clearButton.tap()
        }
        
        XCTAssertEqual(
            fieldValue.label,
            "No Value"
        )
        
        XCTAssertTrue(
            footer.exists,
            "The required label doesn't exist."
        )
        
        XCTAssertEqual(
            footer.label,
            "Date Entry is Required"
        )
        
        XCTAssertTrue(
            calendarImage.exists,
            "The calendar image doesn't exist."
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            datePicker.exists,
            "The date picker doesn't exist."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            Date.now.formatted(.dateTime.day().month().year().hour().minute())
        )
        
        XCTAssertTrue(
            nowButton.isHittable,
            "The now button isn't hittable."
        )
        
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
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The field title isn't hittable."
        )
        
        let localDate = Calendar.current.date(
            from: DateComponents(
                timeZone: .gmt, year: 1969, month: 7, day: 8, hour: 3, minute: 17
            )
        )
        
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
            "The date picker isn't hittable."
        )
        
        XCTAssertTrue(
            nowButton.isHittable,
            "The now button isn't hittable."
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            fieldValue.isHittable,
            "The label isn't hittable."
        )
        
        XCTAssertFalse(
            datePicker.isHittable,
            "The date picker was hittable."
        )
    }
    
    /// Test case 2.3: Date only, no time
    func testCase_2_3() {
        let app = XCUIApplication()
        let datePicker = app.datePickers["Launch Date for Apollo 11 Date Picker"]
        let fieldValue = app.staticTexts["Launch Date for Apollo 11 Value"]
        let footer = app.staticTexts["Launch Date for Apollo 11 Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let todayButton = app.buttons["Launch Date for Apollo 11 Today Button"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertTrue(
            footer.isHittable,
            "The footer isn't hittable."
        )
        
        fieldValue.tap()
        
        XCTAssertEqual(
            footer.label,
            "Enter the Date for the Apollo 11 launch"
        )
        
        XCTAssertTrue(
            fieldValue.isHittable,
            "The field value isn't hittable."
        )
        
        let localDate = Calendar.current.date(
            from: DateComponents(
                timeZone: .gmt, year: 2023, month: 7, day: 15, hour: 3, minute: 53
            )
        )
        
        XCTAssertEqual(
            fieldValue.label,
            localDate?.formatted(.dateTime.day().month().year())
        )
        
        XCTAssertTrue(
            datePicker.isHittable,
            "The date picker isn't hittable."
        )
        
        XCTAssertTrue(
            todayButton.isHittable,
            "The today button isn't hittable."
        )
    }
    
    /// Test case 2.4: Maximum date
    func testCase_2_4() {
        let app = XCUIApplication()
        let clearButton = app.buttons["Launch Date Time End Clear Button"]
        let fieldValue = app.staticTexts["Launch Date Time End Value"]
        let footer = app.staticTexts["Launch Date Time End Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let nowButton = app.buttons["Launch Date Time End Now Button"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        selectTestCase( app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        if fieldValue.label != "No Value" {
            clearButton.tap()
        }
        
        fieldValue.tap()
        
        XCTAssertTrue(
            footer.exists,
            "The footer doesn't exist."
        )
        
        nowButton.tap()
        
        fieldValue.tap()
        
        XCTAssertEqual(
            footer.label,
            "End date and Time 7/27/1969 12:00:00 AM"
        )
        
        let localDate = Calendar.current.date(
            from: DateComponents(
                timeZone: .gmt, year: 1969, month: 7, day: 27, hour: 7
            )
        )
        
        XCTAssertEqual(
            fieldValue.label,
            localDate?.formatted(.dateTime.day().month().year().hour().minute())
        )
    }
    
    /// Test case 2.5: Minimum date
    func testCase_2_5() {
        let app = XCUIApplication()
        let datePicker = app.datePickers["start and end date time Date Picker"]
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
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            footer.exists,
            "The footer doesn't exist."
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
        
        let localDate = Calendar.current.date(
            from: DateComponents(
                timeZone: .gmt, year: 1969, month: 7, day: 1, hour: 7
            )
        )
        
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
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The field title isn't hittable."
        )
        
        XCTAssertTrue(
            clearButton.isHittable,
            "The clear button isn't hittable."
        )
        
        clearButton.tap()
        
        XCTAssertEqual(
            fieldValue.label,
            "No Value"
        )
    }
    
    // - MARK: Test case 3: Combo Box input type
    
    /// Test case 3.1: Pre-existing value, description, clear button, no value label
    func testCase_3_1() {
        let app = XCUIApplication()
        let clearButton = app.buttons["Combo String Clear Button"]
        let fieldTitle = app.staticTexts["Combo String"]
        let fieldValue = app.staticTexts["Combo String Value"]
        let formTitle = app.staticTexts["comboBox"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let footer = app.staticTexts["Combo String Footer"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The field title isn't hittable."
        )
        
        XCTAssertTrue(
            fieldValue.isHittable,
            "The field value isn't hittable."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            "String 3"
        )
        
        XCTAssertTrue(
            clearButton.isHittable,
            "The clear button isn't hittable."
        )
        
        clearButton.tap()
        
        XCTAssertEqual(
            fieldValue.label,
            "No value"
        )
        
        XCTAssertTrue(
            footer.isHittable,
            "The footer isn't hittable."
        )
        
        XCTAssertEqual(
            footer.label,
            "Combo Box of Field Type String"
        )
    }
    
    /// Test case 3.2: No pre-existing value, no value label, options button
    func testCase_3_2() {
        let app = XCUIApplication()
        let fieldTitle = app.staticTexts["Combo Integer"]
        let fieldValue = app.staticTexts["Combo Integer Value"]
        let formTitle = app.staticTexts["comboBox"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let optionsButton = app.images["Combo Integer Options Button"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The field title isn't hittable."
        )
        
        XCTAssertTrue(
            fieldValue.isHittable,
            "The field value isn't hittable."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            "No value"
        )
        
        XCTAssertTrue(
            optionsButton.isHittable,
            "The options button isn't hittable."
        )
    }
    
    /// Test case 3.3: Pick a value
    func testCase_3_3() {
        let app = XCUIApplication()
        let doneButton = app.buttons["Done"]
        let fieldTitle = app.staticTexts["Combo String"]
        let fieldValue = app.staticTexts["Combo String Value"]
        let firstOptionButton = app.buttons["String 1"]
        let formTitle = app.staticTexts["comboBox"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The field title isn't hittable."
        )
        
        XCTAssertTrue(
            fieldValue.isHittable,
            "The field value isn't hittable."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            "String 3"
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            firstOptionButton.isHittable,
            "The first option (String 1) isn't hittable."
        )
        
        firstOptionButton.tap()
        
        XCTAssertTrue(
            doneButton.isHittable,
            "The done button isn't hittable."
        )
        
        doneButton.tap()
        
        XCTAssertEqual(
            fieldValue.label,
            "String 1"
        )
    }
    
    /// Test case 3.4: Picker with a noValueLabel row
    func testCase_3_4() {
        let app = XCUIApplication()
        let doneButton = app.buttons["Done"]
        let fieldTitle = app.staticTexts["Combo String"]
        let fieldValue = app.staticTexts["Combo String Value"]
        let formTitle = app.staticTexts["comboBox"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let noValueButton = app.buttons["No value"]
        
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
            "The field title isn't hittable."
        )
        
        XCTExpectFailure(
            "The design specifies the value should be String 3 but the actual current value may differ."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            "String 3"
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            noValueButton.exists,
            "The no value button doesn't exist."
        )
        
        noValueButton.tap()
        
        XCTAssertTrue(
            doneButton.exists,
            "The done button doesn't exist."
        )
        
        doneButton.tap()
        
        XCTAssertEqual(
            fieldValue.label,
            "No value"
        )
    }
    
    /// Test case 3.5: Required Value
    func testCase_3_5() {
        let app = XCUIApplication()
        let clearButton = app.buttons["Required Combo Box Clear Button"]
        let doneButton = app.buttons["Done"]
        let fieldTitle = app.staticTexts["Required Combo Box *"]
        let fieldValue = app.staticTexts["Required Combo Box Value"]
        let footer = app.staticTexts["Required Combo Box Footer"]
        let formTitle = app.staticTexts["comboBox"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let noValueButton = app.buttons["No value"]
        let oakButton = app.buttons["Oak"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The field title doesn't exist."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            "Pine"
        )
        
        XCTAssertTrue(
            clearButton.isHittable,
            "The clear button isn't hittable."
        )
        
        clearButton.tap()
        
        XCTAssertEqual(
            fieldValue.label,
            "Enter Value"
        )
        
        XCTAssertTrue(
            footer.exists,
            "The footer doesn't exist."
        )
        
        XCTAssertEqual(
            footer.label,
            "Required"
        )
        
        fieldValue.tap()
        
        XCTAssertFalse(
            noValueButton.exists,
            "The no value button exists but it should not."
        )
        
        XCTAssertTrue(
            oakButton.exists,
            "The Oak button doesn't exist."
        )
        
        oakButton.tap()
        
        XCTAssertTrue(
            doneButton.exists,
            "The done button doesn't exist."
        )
        
        doneButton.tap()
        
        XCTAssertEqual(
            fieldValue.label,
            "Oak"
        )
    }
    
    /// Test case 3.6: noValueOption is 'Hide'
    func testCase_3_6() {
        let app = XCUIApplication()
        let doneButton = app.buttons["Done"]
        let fieldTitle = app.staticTexts["Combo No Value False"]
        let fieldValue = app.staticTexts["Combo No Value False Value"]
        let firstOption = app.buttons["First"]
        let formTitle = app.staticTexts["comboBox"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let noValueButton = app.buttons["No Value"]
        let optionsButton = app.images["Combo No Value False Options Button"]
        
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
            "The field title isn't hittable."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            ""
        )
        
        optionsButton.tap()
        
        XCTAssertFalse(
            noValueButton.exists,
            "No Value exists as an option but it shouldn't."
        )
        
        firstOption.tap()
        
        XCTAssertTrue(
            doneButton.exists,
            "The done button doesn't exist."
        )
        
        doneButton.tap()
        
        XCTAssertEqual(
            fieldValue.label,
            "First"
        )
    }
    
    // - MARK: Test case 4: Radio Buttons input type
    
    /// Test case 4.1: Test regular selection
    func testCase_4_1() {
        let app = XCUIApplication()
        let birdOptionCheckmark = app.images["Radio Button Text bird Checkmark"]
        let fieldTitle = app.staticTexts["Radio Button Text"]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let dogOption = app.buttons["Radio Button Text dog"]
        let dogOptionCheckmark = app.images["Radio Button Text dog Checkmark"]
        let noValueOption = app.buttons["Radio Button Text No value"]
        
        app.launch()
        
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The field title doesn't exist."
        )
        
        XCTAssertTrue(
            birdOptionCheckmark.exists,
            "The bird option isn't selected."
        )
        
        XCTAssertFalse(
            dogOptionCheckmark.exists,
            "The dog option is selected."
        )
        
        dogOption.tap()
        
        XCTAssertTrue(
            dogOptionCheckmark.exists,
            "The dog option isn't selected."
        )
        
        XCTAssertFalse(
            birdOptionCheckmark.exists,
            "The bird option is selected."
        )
        
        XCTAssertTrue(
            noValueOption.exists,
            "The no value option doesn't exist."
        )
    }
    
    // - MARK: Test case 5: Switch input type
    
    /// Test case 5.1: Test switch on
    func testCase_5_1() {
        let app = XCUIApplication()
        let fieldTitle = app.staticTexts["switch integer"]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let switchView = app.switches["switch integer Switch"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The field title isn't hittable."
        )
        
        XCTAssertEqual(
            switchView.label,
            "2"
        )
        
        switchView.tap()
        
        XCTAssertEqual(
            switchView.label,
            "1"
        )
    }
    
    /// Test case 5.2: Test switch off
    func testCase_5_2() {
        let app = XCUIApplication()
        let fieldTitle = app.staticTexts["switch string"]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        let switchView = app.switches["switch string Switch"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The field title isn't hittable."
        )
        
        XCTAssertEqual(
            switchView.label,
            "1"
        )
        
        switchView.tap()
        
        
        XCTAssertEqual(
            switchView.label,
            "2"
        )
    }
    
    /// Test case 5.3: Test switch with no value
    func testCase_5_3() {
        let app = XCUIApplication()
        let fieldTitle = app.staticTexts["switch double"]
        let fieldValue = app.staticTexts["switch double Value"]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        let formViewTestsButton = app.buttons["FormView Tests"]
        
        app.launch()
            
        // Open the FormView component test view.
        formViewTestsButton.tap()
        
        selectTestCase(app)
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The field title doesn't exist."
        )
        
        XCTAssertTrue(
            fieldValue.exists,
            "The combo box doesn't exist."
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
