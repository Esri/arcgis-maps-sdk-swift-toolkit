// Copyright 2023 Esri
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
final class FeatureFormViewTests: XCTestCase {
    override func setUp() async throws {
        continueAfterFailure = false
    }
    
    func assertFormOpened(titleElement: XCUIElement) {
        XCTAssertTrue(
            titleElement.waitForExistence(timeout: 30),
            "The form failed to open after 30 seconds."
        )
    }
    
    func openTestCase(id: String = #function) {
        let app = XCUIApplication()
        let formViewTestsButton = app.buttons["Feature Form Tests"]
        // Open tests
        app.launch()
        formViewTestsButton.tap()
        
        // Select test case
        let testCase = String(id.dropLast(2))
        let textField = app.textFields["Search"]
        textField.tap()
        textField.typeText(testCase)
        let testCaseButton = app.buttons[testCase]
        XCTAssertTrue(
            testCaseButton.waitForExistence(timeout: 5),
            "The button doesn't exist for \(testCase)"
        )
        testCaseButton.tap()
    }
    
    func testAttachmentRenaming() {
        let app = XCUIApplication()
        let activityIndicator = app.activityIndicators.firstMatch
        let attachmentLabel = app.staticTexts["EsriHQ.jpeg"]
        let formTitle = app.staticTexts["Esri Location"]
        let nameField = app.textFields["New name"]
        let okButton = app.buttons["OK"]
#if targetEnvironment(macCatalyst)
        let rename = app.menuItems["Rename"]
        let renamedAttachmentLabel = app.staticTexts["EsriHQ\(#function).jpeg"]
#else
        let rename = app.buttons["Rename"]
        let renamedAttachmentLabel = app.staticTexts["\(#function).jpeg"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertTrue(
            activityIndicator.waitForNonExistence(timeout: 5.0),
            "Attachment loading took longer than 5 seconds."
        )
        
        XCTAssertTrue(
            attachmentLabel.exists,
            "The attachment was not present after loading completed."
        )
        
#if targetEnvironment(macCatalyst)
        attachmentLabel.rightClick()
#else
        attachmentLabel.press(forDuration: 1)
#endif
        
        XCTAssertTrue(
            rename.waitForExistence(timeout: 1),
            "The rename button doesn't exist."
        )
        
        rename.tap()
        
        XCTAssertTrue(
            nameField.waitForExistence(timeout: 1),
            "The name field doesn't exist."
        )
        
        nameField.tap()
        app.typeText(#function)
        
        XCTAssertTrue(
            okButton.exists,
            "The OK button doesn't exist."
        )
        
        okButton.tap()
        
        XCTAssertTrue(
            renamedAttachmentLabel.waitForExistence(timeout: 2),
            "The attachment was not present after renaming."
        )
    }
    
    // - MARK: Test case 1: Text Box with no hint, no description, value not required
    
    /// Test case 1.1: unfocused and focused state, no value
    func testCase_1_1() throws {
        let app = XCUIApplication()
        let characterIndicator = app.staticTexts["Single Line No Value, Placeholder or Description Character Indicator"]
        let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
        let footer = app.staticTexts["Single Line No Value, Placeholder or Description Footer"]
        let formTitle = app.staticTexts["InputValidation"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Input"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(fieldTitle, direction: .up)
        
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
        let returnButton = app.buttons["Return"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Input"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(textField, direction: .up)
        
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
            characterIndicator.exists,
            "The character count doesn't exist."
        )
        
        XCTAssertEqual(
            characterIndicator.label,
            "11"
        )
        
        XCTAssertTrue(
            clearButton.exists,
            "The clear button doesn't exist."
        )
        
#if targetEnvironment(macCatalyst) || os(visionOS)
        app.typeText("\r")
#else
        returnButton.tap()
#endif
        
        // Scroll slightly up to expose section header. FB19740517
        app.scrollToElement(fieldTitle, direction: .down, maxSwipes: 1, velocity: .slow)
        
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
        
        app.scrollToElement(textField, direction: .up, maxSwipes: 1, velocity: .slow)
        
        XCTAssertTrue(
            textField.isHittable,
            "The text field isn't hittable."
        )
    }
    
    /// Test case 1.3: unfocused and focused state, with error value (> 256 chars)
    func testCase_1_3() async throws {
        let app = XCUIApplication()
        let characterIndicator = app.staticTexts["Single Line No Value, Placeholder or Description Character Indicator"]
        let clearButton = app.buttons["Single Line No Value, Placeholder or Description Clear Button"]
        let footer = app.staticTexts["Single Line No Value, Placeholder or Description Footer"]
        let formTitle = app.staticTexts["InputValidation"]
        let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
        let returnButton = app.buttons["Return"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Input"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(textField, direction: .up)
        
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
        
        await fulfillment(
            of: [
                expectation(
                    for: NSPredicate(format: "label == \"257\""),
                    evaluatedWith: characterIndicator
                )
            ],
            timeout: 10.0
        )
        
        XCTAssertTrue(
            clearButton.exists,
            "The clear button doesn't exist."
        )
        
#if targetEnvironment(macCatalyst) || os(visionOS)
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
    
    func testCase_1_4() async {
        let app = XCUIApplication()
        let footer = app.staticTexts["numbers Footer"]
        let formTitle = app.staticTexts["Domain"]
        let textField = app.textFields["numbers Text Input"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertEqual(
            textField.value as? String,
            ""
        )
        
        XCTAssertEqual(
            footer.label,
            "Range domain 2-5"
        )
        
        textField.tap()
        
        textField.typeText("1")
        
        XCTAssertEqual(
            footer.label,
            "Enter value from 2.0 to 5.0"
        )
        
        // Highlight/select the current value and replace it
        textField.doubleTap()
        textField.typeText("3")
        
        await fulfillment(
            of: [
                expectation(
                    for: NSPredicate(format: "label == \"Range domain 2-5\""),
                    evaluatedWith: footer
                )
            ],
            timeout: 10
        )
        
        // Highlight/select the current value and replace it
        textField.doubleTap()
        textField.typeText("6")
        
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
        let nowButton = app.buttons["Required Date Now Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(fieldValue, direction: .up)
        
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
            Date.now.formatted()
        )
        
        XCTAssertTrue(
            nowButton.isHittable,
            "The now button isn't hittable."
        )
        
        app.scrollToElement(footer, direction: .up, velocity: .slow)
        
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
        let nowButton = app.buttons["Launch Date and Time for Apollo 11 Now Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        fieldValue.tap()
        
        // Scroll slightly up to expose section header. FB19740517
        app.scrollToElement(fieldTitle, direction: .down, maxSwipes: 1, velocity: .slow)
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The field title isn't hittable."
        )
        
        let localDate = Calendar.current.date(
            from: DateComponents(
                timeZone: .gmt, year: 1969, month: 7, day: 16, hour: 13, minute: 32
            )
        )
        
        XCTAssertEqual(
            fieldValue.label,
            localDate?.formatted()
        )
        
        app.scrollToElement(footer, direction: .up, velocity: .slow)
        
        XCTAssertEqual(
            footer.label,
            "Enter the launch date and time (July 16, 1969 13:32 UTC)"
        )
        
        XCTAssertTrue(
            datePicker.exists,
            "The date picker doesn't exist."
        )
        
        app.scrollToElement(nowButton, direction: .down, velocity: .slow)
        
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
        let todayButton = app.buttons["Launch Date for Apollo 11 Today Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
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
        let nowButton = app.buttons["Launch Date Time End Now Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(fieldValue, direction: .up)
        
        if fieldValue.label != "No Value" {
            clearButton.tap()
        }
        
        fieldValue.tap()
        
        app.scrollToElement(footer, direction: .up, velocity: .slow)
        
        XCTAssertTrue(
            footer.exists,
            "The footer doesn't exist."
        )
        
        app.scrollToElement(nowButton, direction: .down, velocity: .slow)
        
        XCTAssertTrue(
            nowButton.waitForExistence(timeout: 2.5),
            "The Now button doesn't exist."
        )
        
        XCTAssertTrue(
            nowButton.isHittable,
            "The Now button wasn't hittable."
        )
        
        nowButton.tap()
        
        XCTAssertTrue(
            fieldValue.isHittable,
            "The field wasn't hittable."
        )
        
        fieldValue.tap()
        
        app.scrollToElement(footer, direction: .up, velocity: .slow)
        
        XCTAssertEqual(
            footer.label,
            "End date and Time 7/27/1969 12:00:00 AM"
        )
        
        let localDate = Calendar.current.date(
            from: DateComponents(
                timeZone: .gmt, year: 1969, month: 7, day: 27, hour: 7
            )
        )
        
        app.scrollToElement(fieldValue, direction: .down, velocity: .slow)
        
        XCTAssertEqual(
            fieldValue.label,
            localDate?.formatted()
        )
    }
    
    /// Test case 2.5: Minimum date
    func testCase_2_5() {
        let app = XCUIApplication()
        let datePicker = app.datePickers["start and end date time Date Picker"]
        let fieldValue = app.staticTexts["start and end date time Value"]
        let footer = app.staticTexts["start and end date time Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let nowButton = app.buttons["start and end date time Now Button"]
        let previousMonthButton = datePicker.buttons["Previous Month"]
        let julyFirstButton = datePicker.collectionViews.staticTexts["1"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(fieldValue, direction: .up)
        
        fieldValue.tap()
        
        app.scrollToElement(footer, direction: .up, velocity: .slow)
        
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
        
        app.scrollToElement(nowButton, direction: .down, velocity: .slow)
        
        nowButton.tap()
        
        app.scrollToElement(julyFirstButton, direction: .up, velocity: .slow)
        
        julyFirstButton.tap()
        
        let localDate = Calendar.current.date(
            from: DateComponents(
                timeZone: .gmt, year: 1969, month: 7, day: 1, hour: 7
            )
        )
        
        XCTAssertEqual(
            fieldValue.label,
            localDate?.formatted()
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
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
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
        let fieldValue = app.staticTexts["Combo String Combo Box Value"]
        let formTitle = app.staticTexts["comboBox"]
        let footer = app.staticTexts["Combo String Footer"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
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
        let fieldValue = app.staticTexts["Combo Integer Combo Box Value"]
        let formTitle = app.staticTexts["comboBox"]
        let optionsButton = app.images["Combo Integer Options Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
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
        let fieldValue = app.staticTexts["Combo String Combo Box Value"]
        let firstOptionButton = app.buttons["String 1"]
        let formTitle = app.staticTexts["comboBox"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
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
        let fieldValue = app.staticTexts["Combo String Combo Box Value"]
        let formTitle = app.staticTexts["comboBox"]
        let noValueButton = app.buttons["No value"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The field title isn't hittable."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            "String 3"
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            noValueButton.waitForExistence(timeout: 1),
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
        let fieldValue = app.staticTexts["Required Combo Box Combo Box Value"]
        let footer = app.staticTexts["Required Combo Box Footer"]
        let formTitle = app.staticTexts["comboBox"]
        let noValueButton = app.buttons["No value"]
        let oakButton = app.buttons["Oak"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(footer, direction: .up, velocity: .slow)
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The field title doesn't exist."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            "Pine"
        )
        
        XCTAssertFalse(
            clearButton.isHittable,
            "The clear button is hittable."
        )
        
        XCTAssertTrue(
            footer.exists,
            "The footer doesn't exist."
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
    func testCase_3_6() throws {
        let app = XCUIApplication()
        let doneButton = app.buttons["Done"]
        let fieldTitle = app.staticTexts["Combo No Value False"]
        let fieldValue = app.staticTexts["Combo No Value False Combo Box Value"]
        let firstOption = app.buttons["First"]
        let formTitle = app.staticTexts["comboBox"]
        let noValueButton = app.buttons["No Value"]
        let optionsButton = app.images["Combo No Value False Options Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The field title doesn't exist."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            "",
            "The field value was not empty as expected."
        )
        
        optionsButton.tap()
        
        XCTAssertTrue(
            firstOption.waitForExistence(timeout: 1),
            "The First option doesn't exist."
        )
        
        XCTAssertFalse(
            noValueButton.exists,
            "No Value exists as an option but it shouldn't."
        )
        
        XCTAssertTrue(
            firstOption.isHittable,
            "The First option isn't hittable."
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
    
    /// Test case 3.7: Unsupported value
    func testCase_3_7() throws {
        let app = XCUIApplication()
        let fieldTitle = app.staticTexts["Unsupported Value"]
        let fieldValue = app.staticTexts["Unsupported Value Combo Box Value"]
        let formTitle = app.staticTexts["comboBox"]
        let noValueButton = app.buttons["No value"]
        let unsupportedValueSectionHeader = app.staticTexts["Unsupported Value Unsupported Value Section"]
        let unsupportedValue = app.buttons["0"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(fieldTitle, direction: .up)
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The field title doesn't exist."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            "0"
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            unsupportedValueSectionHeader.waitForExistence(timeout: 1),
            "The Unsupported Value section doesn't exist."
        )
        
        XCTAssertTrue(
            unsupportedValue.exists,
            "The Unsupported Value doesn't exist."
        )
        
        XCTAssertTrue(
            noValueButton.exists,
            "No Value doesn't exist."
        )
        
        noValueButton.tap()
        
        XCTAssertFalse(
            unsupportedValueSectionHeader.exists,
            "The Unsupported Value section exists."
        )
    }
    
    // - MARK: Test case 4: Radio Buttons input type
    
    /// Test case 4.1: Test regular selection
    func testCase_4_1() {
        let app = XCUIApplication()
        let birdOptionCheckmark = app.images["Radio Button Text bird Checkmark"]
        let fieldTitle = app.staticTexts["Radio Button Text *"]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        let dogOption = app.buttons["Radio Button Text dog Radio Button"]
        let dogOptionCheckmark = app.images["Radio Button Text dog Checkmark"]
        let noValueOption = app.buttons["Radio Button Text No Value Radio Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
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
    
    /// Test case 4.2: Test radio button fallback to combo box
    func testCase_4_2() {
        let app = XCUIApplication()
        let field1 = app.staticTexts["Fallback 1 Combo Box Value"]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        let noValueDisabledRadioButton = app.buttons["No Value Disabled One Radio Button"]
        let noValueEnabledRadioButton = app.buttons["No Value Enabled N/A Radio Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(field1, direction: .up)
        
        // Verify the Radio Button fallback to Combo Box was successful.
        XCTAssertTrue(
            field1.exists,
            "The combo box doesn't exist."
        )
        
        app.scrollToElement(noValueEnabledRadioButton, direction: .up)
        
        // Verify the radio buttons are shown even when the value option is enabled.
        XCTAssertTrue(
            noValueEnabledRadioButton.exists,
            "The radio button doesn't exist."
        )
        
        // Verify the radio buttons are still shown even when the value option is disabled.
        XCTAssertTrue(
            noValueDisabledRadioButton.exists,
            "The radio button doesn't exist."
        )
    }
    
    // - MARK: Test case 5: Switch input type
    
    /// Test case 5.1: Test switch on
    func testCase_5_1() {
        let app = XCUIApplication()
        let fieldTitle = app.staticTexts["switch integer"]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        let switchView = app.switches["switch integer Switch"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The field title isn't hittable."
        )
        
        XCTAssertEqual(
            switchView.label,
            "2"
        )
        
        switchView.tapSwitch()
        
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
        let switchView = app.switches["switch string Switch"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The field title isn't hittable."
        )
        
        XCTAssertEqual(
            switchView.label,
            "1"
        )
        
        XCTAssertTrue(
            switchView.isHittable,
            "The switch isn't hittable."
        )
        
        switchView.tapSwitch()
        
        XCTAssertEqual(
            switchView.label,
            "2"
        )
    }
    
    /// Test case 5.3: Test switch with no value
    func testCase_5_3() {
        let app = XCUIApplication()
        let fieldTitle = app.staticTexts["switch double"]
        let fieldValue = app.staticTexts["switch double Combo Box Value"]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertTrue(
            fieldTitle.exists,
            "The field title doesn't exist."
        )
        
        XCTAssertTrue(
            fieldValue.exists,
            "The combo box doesn't exist."
        )
    }
    
    /// Test case 6.1: Test initially expanded and collapsed
    func testCase_6_1() {
        let app = XCUIApplication()
        let collapsedGroupFirstElement = app.staticTexts["Single Line Text"]
        let expandedGroupFirstElement = app.staticTexts["MultiLine Text"]
        let formTitle = app.staticTexts["group_formelement_UI_not_editable"]
        
#if targetEnvironment(macCatalyst)
        let collapsedGroup = app.disclosureTriangles["Group with Multiple Form Elements 2"]
        let expandedGroup = app.disclosureTriangles["Group with Multiple Form Elements"]
        let expandedGroupDescription = app.disclosureTriangles["Group with Multiple Form Elements Description"]
#else
        let collapsedGroup = app.staticTexts["Group with Multiple Form Elements 2"]
        let expandedGroup = app.staticTexts["Group with Multiple Form Elements"]
        let expandedGroupDescription = app.staticTexts["Group with Multiple Form Elements Description"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertTrue(
            expandedGroup.exists,
            "The first group header doesn't exist."
        )
        
        XCTAssertTrue(
            expandedGroupDescription.exists,
            "The expanded group's description doesn't exist."
        )
        
        XCTAssertEqual(
            expandedGroupDescription.label,
            "This Group is 'Expand initial state'\nThis group is Visible"
        )
        
        // Confirm the first element of the expanded group exists.
        XCTAssertTrue(
            expandedGroupFirstElement.exists,
            "The first group element doesn't exist."
        )
        
        app.scrollToElement(collapsedGroup, direction: .up)
        
        XCTAssertTrue(
            collapsedGroup.exists,
            "The collapsed group header doesn't exist."
        )
        
        // Confirm the first element of the collapsed group doesn't exist.
        XCTAssertFalse(
            collapsedGroupFirstElement.exists,
            "The first group element exists but should be hidden."
        )
    }
    
    /// Test case 6.2: Test visibility of empty group
    func testCase_6_2() {
        let app = XCUIApplication()
        let formTitle = app.staticTexts["group_formelement_UI_not_editable"]
        let groupElement = app.staticTexts["single line text 3"]
        let showElementsButton = app.buttons["show invisible form element"]
        
#if targetEnvironment(macCatalyst)
        let hiddenElementsGroup = app.disclosureTriangles["Group with children that are visible dependent"]
        let hiddenElementsGroupDescription = app.disclosureTriangles["Group with children that are visible dependent Description"]
#else
        let hiddenElementsGroup = app.staticTexts["Group with children that are visible dependent"]
        let hiddenElementsGroupDescription = app.staticTexts["Group with children that are visible dependent Description"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(hiddenElementsGroup, direction: .up)
        
        XCTAssertTrue(
            hiddenElementsGroup.exists,
            "The group header doesn't exist."
        )
        
        app.scrollToElement(hiddenElementsGroupDescription, direction: .up)
        
        XCTAssertTrue(
            hiddenElementsGroupDescription.exists,
            "The expanded group's description doesn't exist."
        )
        
        XCTAssertEqual(
            hiddenElementsGroupDescription.label,
            "The Form Elements in this group need the Radio button \"show invisible form elements\" to be selected, if you want to see them"
        )
        
        // Confirm the first element of the conditional group doesn't exist.
        XCTAssertFalse(
            groupElement.exists,
            "The first group element exists but should be hidden."
        )
        
        app.scrollToElement(showElementsButton, direction: .down)
        
        // Confirm the option to show the elements exists.
        XCTAssertTrue(
            showElementsButton.exists,
            "The show group elements button doesn't exist."
        )
        
        showElementsButton.tap()
        
        app.scrollToElement(groupElement, direction: .up)
        
        // Confirm the first element of the conditional group doesn't exist.
        XCTAssertTrue(
            groupElement.exists,
            "The first group element doesn't exist."
        )
    }
    
    /// Test case 7.1: Test read only elements
    func testCase_7_1() throws {
        let app = XCUIApplication()
        let formTitle = app.staticTexts["Test Case 7.1 - Read only elements"]
        let elementsAreEditableSwitch = app.switches["Elements are editable Switch"]
        let elementInTheGroupIsEditableReadOnlyInput = app.staticTexts["Element in the group is editable Read Only Input"]
        let elementInTheGroupIsEditableSwitch = app.switches["Element in the group is editable Switch"]
        
        let comboBoxReadOnlyInput = app.staticTexts["Combo box Read Only Input"]
        let comboBox = app.staticTexts["Combo box Combo Box Value"]
        
        let radioButtonsReadOnlyInput = app.staticTexts["Radio buttons Read Only Input"]
        let radioButtonsInput = app.images["Radio buttons 0 Checkmark"]
        
        let dateReadOnlyInput = app.staticTexts["Date Read Only Input"]
        let dateInput = app.staticTexts["Date Value"]
        
        let shortTextReadOnlyInput = app.staticTexts["Short text Read Only Input"]
        let shortTextTextInput = app.textFields["Short text Text Input"]
        
        let longTextReadOnlyInput = app.staticTexts["Long text Read Only Input"]
        let longTextTextInputPreview = app.staticTexts["Long text Text Input Preview"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertTrue(elementInTheGroupIsEditableReadOnlyInput.exists)
        
        XCTAssertTrue(comboBoxReadOnlyInput.exists)
        
        XCTAssertTrue(radioButtonsReadOnlyInput.exists)
        
        app.scrollToElement(dateReadOnlyInput, direction: .up)
        
        XCTAssertTrue(dateReadOnlyInput.exists)
        
        app.scrollToElement(shortTextReadOnlyInput, direction: .up)
        
        XCTAssertTrue(shortTextReadOnlyInput.exists)
        
        app.scrollToElement(longTextReadOnlyInput, direction: .up)
        
        XCTAssertTrue(longTextReadOnlyInput.exists)
        
        // Scroll slightly up to expose section header. FB19740517
        app.scrollToElement(elementsAreEditableSwitch, direction: .down)
        
        elementsAreEditableSwitch.tapSwitch()
        
        XCTAssertTrue(elementInTheGroupIsEditableSwitch.exists)
        
        elementInTheGroupIsEditableSwitch.tapSwitch()
        
        XCTAssertTrue(comboBox.exists)
        
        XCTAssertTrue(radioButtonsInput.exists)
        
        XCTAssertTrue(dateInput.exists)
        
        app.scrollToElement(shortTextTextInput, direction: .up)
        
        XCTAssertTrue(shortTextTextInput.exists)
        
        app.scrollToElement(longTextTextInputPreview, direction: .up)
        
        XCTAssertTrue(longTextTextInputPreview.exists)
    }
    
    func testCase_8_1() {
        let app = XCUIApplication()
        let attachmentElementTitle = app.staticTexts["Attachments"]
        let attachmentName = app.staticTexts["EsriHQ.jpeg"]
        let downloadIcon = app.images["Download"]
        let formTitle = app.staticTexts["Esri Location"]
        let placeholderImage = app.images["Photo"]
        let sizeLabel = app.staticTexts["154 kB"]
        let thumbnailImage = app.images["EsriHQ.jpeg Thumbnail"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertTrue(attachmentElementTitle.waitForExistence(timeout: 10))
        XCTAssertTrue(placeholderImage.waitForExistence(timeout: 10))
        XCTAssertTrue(attachmentName.exists)
        XCTAssertTrue(sizeLabel.exists)
        XCTAssertTrue(downloadIcon.exists)
        
        placeholderImage.tap()
        
        XCTAssertTrue(thumbnailImage.waitForExistence(timeout: 10))
        XCTAssertFalse(placeholderImage.exists)
        XCTAssertFalse(downloadIcon.exists)
    }
    
    /// Test substitution
    func testCase_10_1() {
        let app = XCUIApplication()
        let formTitle = app.staticTexts["Test case 10 Layer"]
        let losAngelesText = app.staticTexts["Title of the map is Los Angeles."]
        let redlandsText = app.staticTexts["Title of the map is Redlands."]
        let titleClearButton = app.buttons["Title Clear Button"]
        let titleTextField = app.textFields["Title Text Input"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertTrue(
            titleTextField.waitForExistence(timeout: 10),
            "The text field wasn't found after 10 seconds."
        )
        
        XCTAssertEqual(
            titleTextField.value as? String,
            "Redlands"
        )
        
        XCTAssertTrue(redlandsText.exists)
        
        titleClearButton.tap()
        titleTextField.tap()
        
        titleTextField.typeText("Los Angeles")
        
        XCTAssertTrue(losAngelesText.waitForExistence(timeout: 10))
    }
    
    /// Test plain text
    func testCase_10_2() {
        let app = XCUIApplication()
        let formTitle = app.staticTexts["Test case 10 Layer"]
        let plainText = app.staticTexts["#### **A Bold and Large Heading**"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertTrue(plainText.exists)
    }
    
    /// Test case 11.1: Barcode Scan and Clear buttons
    func testCase_11_1() {
        let app = XCUIApplication()
        let formTitle = app.staticTexts["Test case 11.1 Layer"]
        let scanButton = app.buttons["Barcode Scan Button"]
        let clearButton = app.buttons["Barcode Clear Button"]
        let barcodeValidationString = app.staticTexts["Barcode Footer"]
        let fieldValue = app.textFields["Barcode Text Input"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
#if !os(visionOS)
        XCTAssertTrue(scanButton.exists, "The scan button doesn't exist.")
#endif
        XCTAssertFalse(clearButton.exists, "The clear button exists.")
        
        fieldValue.tap()
        fieldValue.typeText("https://esri.com/this_is_a_string_longer_than_50_count_on_it")
        
#if !os(visionOS)
        XCTAssertTrue(scanButton.exists, "The scan button doesn't exist.")
#endif
        XCTAssertEqual(barcodeValidationString.label, "Maximum 50 characters")
    }
    
    func testCase_12_1() {
        let app = XCUIApplication()
        let assetGroup = app.staticTexts["Asset group"]
        let elementTitle = app.staticTexts["Associations"]
        let fieldValue = app.staticTexts["Asset group Read Only Input"]
        let formTitle = app.staticTexts["Electric Distribution Device"]
        let filterResults1 = app.staticTexts["Connected"]
        let filterResults2 = app.staticTexts["Structure"]
        let filterResults3 = app.staticTexts["Container"]
        let networkSourceGroup1 = app.staticTexts["Electric Distribution Junction"]
        let networkSourceGroup2Button = app.buttons["Electric Distribution Device, 2"]
        let fuses = app.buttons.matching(identifier: "Fuse, Single Terminal")
        let utilityElement1Button = fuses.element(boundBy: 0)
        let utilityElement2Button = fuses.element(boundBy: 1)
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(elementTitle, direction: .up, velocity: .fast)
        
        XCTAssertTrue(
            elementTitle.waitForExistence(timeout: 5),
            "The element \"Associations\" doesn't exist."
        )
        
        app.scrollToElement(filterResults3, direction: .up)
        
        XCTAssertTrue(
            filterResults1.waitForExistence(timeout: 5),
            "The filter result \"Connected\" doesn't exist."
        )
        
        XCTAssertTrue(
            filterResults2.exists,
            "The filter result \"Structure\" doesn't exist."
        )
        
        XCTAssertTrue(
            filterResults3.exists,
            "The filter result \"Container\" doesn't exist."
        )
        
        filterResults1.tap()
        
        XCTAssertTrue(
            networkSourceGroup1.exists,
            "The network source group \"Electric Distribution Junction\" doesn't exist."
        )
        
        XCTAssertTrue(
            networkSourceGroup2Button.waitForExistence(timeout: 5),
            "The network source group \"Electric Distribution Device\" doesn't exist."
        )
        
        networkSourceGroup2Button.tap()
        
        XCTAssertTrue(
            utilityElement1Button.waitForExistence(timeout: 30),
            "Feature \"Fuse\" failed to appear after 30 seconds."
        )
        
        XCTAssertTrue(
            utilityElement2Button.exists,
            "The utility element \"Fuse\" doesn't exist."
        )
        
        utilityElement1Button.tap()
        
        // Open new form
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertTrue(
            assetGroup.exists,
            "The asset group \"Asset group\" doesn't exist."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            "Fuse"
        )
    }
    
    // Test case 12.2: Associations show fraction along edge
    // It has been determined that with the currently-available public test data
    // this is no longer feasible. So this functionality will be ad-hoc tested only.
    
    func testCase_12_3() {
        let app = XCUIApplication()
        let elementTitle = app.staticTexts["Associations"]
        let filterResults = app.staticTexts["Content"]
        let formTitle = app.staticTexts["Structure Boundary"]
        let networkSourceGroupButton = app.buttons["Electric Distribution Device, 1"]
        let utilityElementButton = app.buttons["Circuit Breaker, Content"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(elementTitle, direction: .up, velocity: .fast)
        
        XCTAssertTrue(
            elementTitle.waitForExistence(timeout: 5),
            "The element \"Associations\" doesn't exist."
        )
        
        app.scrollToElement(filterResults, direction: .up, velocity: .slow)
        
        XCTAssertTrue(
            filterResults.waitForExistence(timeout: 5),
            "The filter result \"Content\" doesn't exist."
        )
        
        filterResults.tap()
        
        XCTAssertTrue(
            networkSourceGroupButton.waitForExistence(timeout: 5),
            "The network source group \"Electric Distribution Device\" doesn't exist."
        )
        
        networkSourceGroupButton.tap()
        
        // Expectation: a list of one utility elements with "Content"
        XCTAssertTrue(
            utilityElementButton.exists,
            "The utility element \"Circuit Breaker\" doesn't exist."
        )
    }
    
    func testCase_12_4() {
        let app = XCUIApplication()
        let elementTitle = app.staticTexts["Associations"]
        let filterResults = app.staticTexts["Container"]
        let formTitle = app.staticTexts["Electric Distribution Device"]
        let networkSourceGroup = app.staticTexts["Structure Boundary"]
        let utilityElementButton = app.buttons["Substation"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(elementTitle, direction: .up, velocity: .fast)
        
        XCTAssertTrue(
            elementTitle.waitForExistence(timeout: 5),
            "The element \"Associations\" doesn't exist."
        )
        
        XCTAssertTrue(
            filterResults.waitForExistence(timeout: 5),
            "The filter result \"Container\" doesn't exist."
        )
        
        filterResults.tap()
        
        XCTAssertTrue(
            networkSourceGroup.waitForExistence(timeout: 5),
            "The network source group \"Structure Boundary\" doesn't exist."
        )
        
        networkSourceGroup.tap()
        
        // Expectation: a list of one utility elements with no "Containment Visible" label
        XCTAssertTrue(
            utilityElementButton.exists,
            "The utility element \"Substation\" doesn't exist."
        )
    }
    
    func testCase_12_5() {
        let app = XCUIApplication()
        let assetType = app.staticTexts["Asset type *"]
        let backButton = app.buttons["Back"]
        let discardEditsButton = app.buttons["Discard Edits"]
        let doneButton = app.buttons["Done"]
        let elementTitle = app.staticTexts["Associations"]
        let fieldValue = app.staticTexts["Asset type Combo Box Value"]
        let filterResults = app.staticTexts["Connected"]
        let firstOptionButton = app.buttons["Unknown"]
        let formTitle = app.staticTexts["Electric Distribution Device"]
        let formTitle2 = app.staticTexts["Electric Distribution Device"]
        let networkSourceGroupButton = app.buttons["Electric Distribution Device, 1"]
        let utilityElementButton = app.buttons["Transformer, High"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.scrollToElement(elementTitle, direction: .up, velocity: .fast)
        
        XCTAssertTrue(
            elementTitle.waitForExistence(timeout: 5),
            "The element \"Associations\" doesn't exist."
        )
        
        XCTAssertTrue(
            filterResults.waitForExistence(timeout: 5),
            "The filter result \"Connected\" doesn't exist."
        )
        
        filterResults.tap()
        
        XCTAssertTrue(
            networkSourceGroupButton.waitForExistence(timeout: 5),
            "The network source group \"Electric Distribution Device\" doesn't exist."
        )
        
        networkSourceGroupButton.tap()
        
        XCTAssertTrue(
            utilityElementButton.waitForExistence(timeout: 5),
            "The utility element \"Transformer\" doesn't exist."
        )
        
        utilityElementButton.tap()
        
        assertFormOpened(titleElement: formTitle2)
        
        XCTAssertTrue(
            assetType.exists,
            "The field form element \"Asset type *\"doesn't exist."
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            firstOptionButton.isHittable,
            "The first option \"Unknown\" isn't hittable."
        )
        
        firstOptionButton.tap()
        
        XCTAssertTrue(
            doneButton.isHittable,
            "The done button isn't hittable."
        )
        
        doneButton.tap()
        
        // Tap the "Back" button
        backButton.tap()
        
        // Expectation: an alert appears with "Discard Edits", "Save Edits", and "Continue Editing" options
        XCTAssertTrue(
            discardEditsButton.exists,
            "The alert \"Discard Edits\" doesn't exist."
        )
        
        // Tap the "Discard" option. Note that some platforms may use "Discard Edits".
        discardEditsButton.tap()
        
        // Access the new `FeatureForm`
        // Expectation: the form title should be "Electric Distribution Junction"
        // Expectation: a list of one utility elements entitled "Transformer - 2552"
        XCTAssertTrue(
            utilityElementButton.waitForExistence(timeout: 5),
            "The utility element \"Transformer - 2552\" doesn't exist."
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

extension XCUIApplication {
    /// Scrolls up until the target element is hittable or max swipes reached.
    func scrollToElement(
        _ element: XCUIElement,
        direction: ScrollDirection,
        maxSwipes: Int = 10,
        velocity: XCUIGestureVelocity? = nil
    ) {
        let target = otherElements["FeatureFormView"].firstMatch
        var swipes = 0
        while !element.isHittable && swipes < maxSwipes {
            switch (direction, velocity) {
            case (.up, .none):
                target.swipeUp()
            case (.up, .some(let velocity)):
                target.swipeUp(velocity: velocity)
            case (.down, .none):
                target.swipeDown()
            case (.down, .some(let velocity)):
                target.swipeDown(velocity: velocity)
            }
            swipes += 1
        }
    }
}

enum ScrollDirection {
    case down
    case up
}

extension XCUIElement {
    func tapSwitch() {
#if os(visionOS)
        tap()
#else
        switches.firstMatch.tap()
#endif
    }
}
