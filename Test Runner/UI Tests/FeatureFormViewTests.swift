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
        
        // Pass the name of the test function as the testCase, dropping the parentheses.
        let testCaseArgument = ["-testCase", "\(id.dropLast(2))"]
        app.launchArguments.append(contentsOf: testCaseArgument)
        
        // Open tests
        app.launch()
        formViewTestsButton.tap()
    }
    
    func testAttachmentRenaming() {
        let app = XCUIApplication()
        let activityIndicator = app.activityIndicators.firstMatch
        let attachmentLabel = app.staticTexts["EsriHQ.jpeg"]
        let formTitle = app.staticTexts["Esri Location"]
        let nameField = app.textFields["New name"]
        let okButton = app.buttons["OK"]
        let renamedAttachmentLabel = app.staticTexts["EsriHQ\(#function).jpeg"]
#if targetEnvironment(macCatalyst)
        let rename = app.menuItems["Rename"]
#else
        let rename = app.buttons["Rename"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        activityIndicator.assertNonExistence()
        
        attachmentLabel.assertExistence()
        
#if targetEnvironment(macCatalyst)
        attachmentLabel.rightClick()
#else
        attachmentLabel.press(forDuration: 1)
#endif
        
        rename.assertExistenceAndTap()
        
        nameField.assertExistenceAndTap()
        
        app.typeText(#function)
        
        okButton.assertExistenceAndTap()
        
        renamedAttachmentLabel.assertExistence()
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
        
        fieldTitle.assertExistence()
        
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
        
        fieldTitle.assertExistence()
        
        footer.assertExistence()
        
        XCTAssertEqual(
            footer.label,
            "Maximum 256 characters"
        )
        
        characterIndicator.assertExistence()
        
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
        
        textField.assertExistenceAndTap()
        
        app.typeText("Sample text")
        
        fieldTitle.assertExistence()
        
        footer.assertExistence()
        
        XCTAssertEqual(
            footer.label,
            "Maximum 256 characters"
        )
        
        characterIndicator.assertExistence()
        
        XCTAssertEqual(
            characterIndicator.label,
            "11"
        )
        
        clearButton.assertExistence()
        
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
        let formTitle = app.staticTexts["InputValidation"]
        let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
        let returnButton = app.buttons["Return"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Input"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        textField.tap()
        
        app.typeText(.loremIpsum257)
        
        fieldTitle.assertExistence()
        
        footer.assertExistence()
        
        XCTAssertEqual(
            footer.label,
            "Maximum 256 characters"
        )
        
        characterIndicator.assertExistence()
        
        XCTAssertEqual(
            characterIndicator.label,
            "257"
        )
        
        clearButton.assertExistence()
        
#if targetEnvironment(macCatalyst)
        app.typeText("\r")
#else
        returnButton.tap()
#endif
        
        fieldTitle.assertExistence()
        
        footer.assertExistence()
        
        XCTAssertEqual(
            footer.label,
            "Maximum 256 characters"
        )
        
        characterIndicator.assertNonExistence()
        
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
        
        // Replace the current value with 3
        textField.typeText(XCUIKeyboardKey.delete.rawValue)
        textField.typeText("3")
        
        expectation(
            for: NSPredicate(format: "label == \"Range domain 2-5\""),
            evaluatedWith: footer
        )
        waitForExpectations(timeout: 10, handler: nil)
        
        // Replace the current value with 6
        textField.typeText(XCUIKeyboardKey.delete.rawValue)
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
        
        if fieldValue.label != "No Value" {
            clearButton.tap()
        }
        
        XCTAssertEqual(
            fieldValue.label,
            "No Value"
        )
        
        footer.assertExistence()
        
        XCTAssertEqual(
            footer.label,
            "Date Entry is Required"
        )
        
        calendarImage.assertExistence()
        
        fieldValue.tap()
        
        datePicker.assertExistence()
        
        XCTAssertEqual(
            fieldValue.label,
            Date.now.formatted()
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
        let nowButton = app.buttons["Launch Date and Time for Apollo 11 Now Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        fieldValue.tap()
        
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
        
        XCTAssertEqual(
            footer.label,
            "Enter the launch date and time (July 16, 1969 13:32 UTC)"
        )
        
        datePicker.assertExistence()
        
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
        
        if fieldValue.label != "No Value" {
            clearButton.tap()
        }
        
        fieldValue.tap()
        
        footer.assertExistence()
        
        nowButton.assertExistence()
        
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
        
        fieldValue.tap()
        
        // Swipe up to reveal the entire date picker.
        app.scrollViews.firstMatch.swipeUp()
        
        footer.assertExistence()
        
        XCTAssertEqual(
            footer.label,
            """
            Form with Start date and End date defined
            Start July 1, 1969
            End  July 31, 1969
            """
        )
        
        nowButton.tap()
        
        XCTAssertTrue(julyFirstButton.waitForExistence(timeout: 5))
        
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
            app.noValueComboBoxOption.waitForExistence(timeout: 1),
            "The no value button doesn't exist."
        )
        
        app.noValueComboBoxOption.tap()
        
        doneButton.assertExistenceAndTap()
        
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
        let oakButton = app.buttons["Oak"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        fieldTitle.assertExistence()
        
        XCTAssertEqual(
            fieldValue.label,
            "Pine"
        )
        
        XCTAssertFalse(
            clearButton.isHittable,
            "The clear button is hittable."
        )
        
        footer.assertExistence()
        
        fieldValue.tap()
        
        app.noValueComboBoxOption.assertNonExistence()
        
        oakButton.assertExistenceAndTap()
        
        doneButton.assertExistenceAndTap()
        
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
        
        fieldTitle.assertExistence()
        
        XCTAssertEqual(
            fieldValue.label,
            ""
        )
        
        optionsButton.assertExistenceAndTap()
        
        firstOption.assertExistence()
        
        noValueButton.assertNonExistence()
        
        XCTAssertTrue(
            firstOption.isHittable,
            "The First option isn't hittable."
        )
        
        firstOption.tap()
        
        doneButton.assertExistence()
        
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
        let unsupportedValueSectionHeader = app.staticTexts["Unsupported Value Unsupported Value Section"]
        let unsupportedValue = app.buttons["0"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        fieldTitle.assertExistence()
        
        XCTAssertEqual(
            fieldValue.label,
            "0"
        )
        
        fieldValue.tap()
        
        unsupportedValueSectionHeader.assertExistence()
        
        unsupportedValue.assertExistence()
        
        app.noValueComboBoxOption.assertExistenceAndTap()
        
        unsupportedValueSectionHeader.assertNonExistence()
    }
    
    // - MARK: Test case 4: Radio Buttons input type
    
    /// Test case 4.1: Test regular selection
    func testCase_4_1() throws {
        try skipIf(visionOS: true)
        
        let app = XCUIApplication()
        let fieldTitle = app.staticTexts["Radio Button Text *"]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        let radioButtonTextPicker = app.pickers["Radio Button Text"].pickerWheels.firstMatch
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        fieldTitle.assertExistence()
        
        XCTAssertEqual(
            radioButtonTextPicker.stringValue,
            "bird"
        )
        
        XCTAssertNotEqual(
            radioButtonTextPicker.stringValue,
            "dog"
        )
        
#if !os(visionOS)
        radioButtonTextPicker.adjust(toPickerWheelValue: "dog")
#endif
        
        XCTAssertEqual(
            radioButtonTextPicker.stringValue,
            "dog"
        )
        
        XCTAssertNotEqual(
            radioButtonTextPicker.stringValue,
            "bird"
        )
        
        // The following assertion is skipped because all possible values in a
        // picker cannot be programmatically checked.
//        XCTAssertTrue(
//            noValueOption.exists,
//            "The no value option doesn't exist."
//        )
    }
    
    /// Test case 4.2: Test radio button fallback to combo box
    func testCase_4_2() {
        let app = XCUIApplication()
        let field1 = app.staticTexts["Fallback 1 Combo Box Value"]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        let noValueDisabledPicker = app.pickers["No Value Disabled"].pickerWheels.firstMatch
        let noValueEnabledPicker = app.pickers["No Value Enabled"].pickerWheels.firstMatch
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        // Verify the Radio Button fallback to Combo Box was successful.
        field1.assertExistence()
        
        // Verify the radio buttons are shown even when the no value option is enabled.
        XCTAssertEqual(
            noValueEnabledPicker.stringValue,
            "N/A"
        )
        
        // Verify the radio buttons are still shown even when the no value option is disabled.
        XCTAssertEqual(
            noValueDisabledPicker.stringValue,
            "One"
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
        
        fieldTitle.assertExistence()
        
        XCTAssertEqual(
            switchView.label,
            "2"
        )
        
        switchView.assertExistenceAndTap()
        
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
        let fieldValue = app.staticTexts["switch double Combo Box Value"]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        fieldTitle.assertExistence()
        
        fieldValue.assertExistence()
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
        
        expandedGroup.assertExistence()
        
        expandedGroupDescription.assertExistence()
        
        XCTAssertEqual(
            expandedGroupDescription.label,
            "This Group is 'Expand initial state'\nThis group is Visible"
        )
        
        // Confirm the first element of the expanded group exists.
        expandedGroupFirstElement.assertExistence()
        
        collapsedGroup.assertExistence()
        
        // Confirm the first element of the collapsed group doesn't exist.
        collapsedGroupFirstElement.assertNonExistence()
    }
    
    /// Test case 6.2: Test visibility of empty group
    func testCase_6_2() throws {
        try skipIf(visionOS: true)
        
        let app = XCUIApplication()
        let formTitle = app.staticTexts["group_formelement_UI_not_editable"]
        let groupElement = app.staticTexts["single line text 3"]
        let radioButtonPicker = app.pickers["Radio Button"].pickerWheels.firstMatch
        
#if targetEnvironment(macCatalyst)
        let hiddenElementsGroup = app.disclosureTriangles["Group with children that are visible dependent"]
        let hiddenElementsGroupDescription = app.disclosureTriangles["Group with children that are visible dependent Description"]
#else
        let hiddenElementsGroup = app.staticTexts["Group with children that are visible dependent"]
        let hiddenElementsGroupDescription = app.staticTexts["Group with children that are visible dependent Description"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        hiddenElementsGroup.assertExistence()
        
        hiddenElementsGroupDescription.assertExistence()
        
        XCTAssertEqual(
            hiddenElementsGroupDescription.label,
            "The Form Elements in this group need the Radio button \"show invisible form elements\" to be selected, if you want to see them"
        )
        
        // Confirm the first element of the conditional group doesn't exist.
        groupElement.assertNonExistence()
        
        // Confirm the option to show the elements exists.
        radioButtonPicker.assertExistence()
        
#if !os(visionOS)
        radioButtonPicker.adjust(toPickerWheelValue: "Everything is working great")
        radioButtonPicker.adjust(toPickerWheelValue: "Everything could be working greater")
        radioButtonPicker.adjust(toPickerWheelValue: "Its good Enough!")
        radioButtonPicker.adjust(toPickerWheelValue: "Show Group Visible Dependent")
        radioButtonPicker.adjust(toPickerWheelValue: "show invisible form element")
#endif
        
        // Confirm the first element of the conditional group exists.
        groupElement.assertExistence()
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
        
        let radioButtonsPicker = app.pickers["Radio buttons"].pickerWheels.firstMatch
        let radioButtonsReadOnlyInput = app.staticTexts["Radio buttons Read Only Input"]
        
        let dateReadOnlyInput = app.staticTexts["Date Read Only Input"]
        let dateInput = app.buttons["Date Value"]
        
        let shortTextReadOnlyInput = app.staticTexts["Short text Read Only Input"]
        let shortTextTextInput = app.textFields["Short text Text Input"]
        
        let longTextReadOnlyInput = app.staticTexts["Long text Read Only Input"]
        let longTextTextInputPreview = app.staticTexts["Long text Text Input Preview"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementInTheGroupIsEditableReadOnlyInput.assertExistence()
        
        comboBoxReadOnlyInput.assertExistence()
        
        radioButtonsReadOnlyInput.assertExistence()
        
        dateReadOnlyInput.assertExistence()
        
        shortTextReadOnlyInput.assertExistence()
        
        longTextReadOnlyInput.assertExistence()
        
        elementsAreEditableSwitch.assertExistenceAndTap()
        
        elementInTheGroupIsEditableSwitch.assertExistenceAndTap()
        
        comboBox.assertExistence()
        
        XCTAssertEqual(radioButtonsPicker.stringValue, "0")
        
        dateInput.assertExistence()
        
        shortTextTextInput.assertExistence()
        
        longTextTextInputPreview.assertExistence()
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
        
        attachmentElementTitle.assertExistence()
        placeholderImage.assertExistence()
        attachmentName.assertExistence()
        sizeLabel.assertExistence()
        downloadIcon.assertExistence()
        
        placeholderImage.assertExistenceAndTap()
        
        thumbnailImage.assertExistence()
        placeholderImage.assertNonExistence()
        downloadIcon.assertNonExistence()
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
        
        titleTextField.assertExistence()
        
        XCTAssertEqual(
            titleTextField.value as? String,
            "Redlands"
        )
        
        redlandsText.assertExistence()
        
        titleClearButton.assertExistenceAndTap()
        titleTextField.assertExistenceAndTap()
        
        titleTextField.typeText("Los Angeles")
        
        losAngelesText.assertExistence()
    }
    
    /// Test plain text
    func testCase_10_2() {
        let app = XCUIApplication()
        let formTitle = app.staticTexts["Test case 10 Layer"]
        let plainText = app.staticTexts["#### **A Bold and Large Heading**"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        plainText.assertExistence()
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
        scanButton.assertExistence()
#endif
        clearButton.assertNonExistence()
        
        fieldValue.assertExistenceAndTap()
        fieldValue.typeText("https://esri.com/this_is_a_string_longer_than_50_count_on_it")
        
#if !os(visionOS)
        scanButton.assertExistence()
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
        
        elementTitle.assertExistence()
        
        filterResults1.assertExistence()
        
        filterResults2.assertExistence()
        
        filterResults3.assertExistence()
        
        filterResults1.tap()
        
        networkSourceGroup1.assertExistence()
        
        networkSourceGroup2Button.assertExistenceAndTap()
        
        utilityElement1Button.assertExistence()
        
        utilityElement2Button.assertExistence()
        
        utilityElement1Button.tap()
        
        // Open new form
        assertFormOpened(titleElement: formTitle)
        
        assetGroup.assertExistence()
        
        XCTAssertEqual(
            fieldValue.label,
            "Fuse"
        )
    }
    
    // Test case 12.2: Associations show percent along
    // It has been determined that with the currently-available public test data
    // this is no longer feasible. So this functionality will be ad-hoc tested only.
    
    func testCase_12_3() {
        let app = XCUIApplication()
        let elementTitle = app.staticTexts["Associations"]
        let filterResults = app.staticTexts["Content"]
        let formTitle = app.staticTexts["Structure Boundary"]
        let networkSourceGroupButton = app.buttons["Electric Distribution Device, 1"]
        let utilityElementButton = app.buttons["Circuit Breaker, Visible: false"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementTitle.assertExistence()
        
        filterResults.assertExistenceAndTap()
        
        networkSourceGroupButton.assertExistenceAndTap()
        
        // Expectation: a list of one utility elements with "Content"
        utilityElementButton.assertExistence()
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
        
        elementTitle.assertExistence()
        
        filterResults.assertExistenceAndTap()
        
        networkSourceGroup.assertExistenceAndTap()
        
        // Expectation: a list of one utility elements with no "Containment Visible" label
        utilityElementButton.assertExistence()
    }
    
    func testCase_12_5() {
        let app = XCUIApplication()
        let assetType = app.staticTexts["Asset type *"]
        let backButton = app.buttons["Back"]
        let discardEditsButton = app.buttons["Discard Edits"]
        let elementTitle = app.staticTexts["Associations"]
        let fieldValue = app.staticTexts["Asset type Combo Box Value"]
        let filterResults = app.staticTexts["Connected"]
        let firstOptionButton = app.buttons["Unknown Combo Box Option"]
        let formTitle = app.staticTexts["Electric Distribution Device"]
        let formTitle2 = app.staticTexts["Electric Distribution Device"]
        let networkSourceGroupButton = app.buttons["Electric Distribution Device, 1"]
        let utilityElementButton = app.buttons["Transformer, High"]
        
#if os(visionOS)
        let doneButton = app.buttons["Confirm"]
#else
        let doneButton = app.buttons["Done"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementTitle.assertExistence()
        
        filterResults.assertExistenceAndTap()
        
        networkSourceGroupButton.assertExistenceAndTap()
        
        utilityElementButton.assertExistenceAndTap()
        
        assertFormOpened(titleElement: formTitle2)
        
        assetType.assertExistence()
        
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
        discardEditsButton.assertExistenceAndTap()
        
        // Access the new `FeatureForm`
        // Expectation: the form title should be "Electric Distribution Junction"
        // Expectation: a list of one utility elements entitled "Transformer - 2552"
        utilityElementButton.assertExistence()
    }
    
    func testCase_12_6() {
        let app = XCUIApplication()
        let cancelButton = app.buttons["Cancel"].firstMatch
        let discardButton = app.buttons["Discard"].firstMatch
        let elementTitle = app.staticTexts["Associations"]
        let connectedFilterTitle = app.staticTexts["Connected"]
        let electricDistributionDevice = app.staticTexts["Electric Distribution Device"]
        let networkSourceGroupButton = app.buttons["Electric Distribution Device, 1"]
        let removeButton = app.buttons["Remove"].firstMatch
        
#if targetEnvironment(macCatalyst)
        let moreOptionsButton = app.popUpButtons["More Options"]
        let removeAssociationButton = app.menuItems["Remove Association"]
        let transformerButton = app.popUpButtons["Transformer, High"]
#else
        let moreOptionsButton = app.buttons["More Options"]
        let removeAssociationButton = app.buttons["Remove Association"]
        let transformerButton = app.buttons["Transformer, High"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: electricDistributionDevice)
        
        elementTitle.assertExistence()
        
        connectedFilterTitle.assertExistenceAndTap()
        
        networkSourceGroupButton.assertExistenceAndTap()
        
        transformerButton.assertExistence()
        
        moreOptionsButton.assertExistenceAndTap()
        
        removeAssociationButton.assertExistenceAndTap()
        
        cancelButton.assertExistenceAndTap()
        
        moreOptionsButton.tap()
        
        removeAssociationButton.tap()
        
        removeButton.assertExistenceAndTap()
        
        // Expectation: Navigation returns to the "Connected" filter results page.
        connectedFilterTitle.assertExistence()
        
        discardButton.assertExistenceAndTap()
        
        networkSourceGroupButton.assertExistenceAndTap()
        
        transformerButton.assertExistence()
        
#if targetEnvironment(macCatalyst)
        moreOptionsButton.tap()
#else
        transformerButton.swipeLeft()
#endif
        
#if os(visionOS)
        XCTExpectFailure("The \"Remove Association\" button does not trigger properly in visionOS.")
#endif
        
        removeAssociationButton.assertExistenceAndTap()
        
        cancelButton.assertExistenceAndTap()
        
#if targetEnvironment(macCatalyst)
        moreOptionsButton.tap()
#else
        transformerButton.swipeLeft()
#endif
        removeAssociationButton.assertExistenceAndTap()
        
        removeButton.assertExistenceAndTap()
        
        discardButton.assertExistence()
        
        connectedFilterTitle.assertExistence()
    }
    
    func testCase_13_1() {
        let app = XCUIApplication()
        
        let addButton = app.buttons["Add"]
        let associationTypeLabel = app.staticTexts["Association Type"]
        let cabinetFuseButton = app.buttons["Cabinet Fuse"]
        let connectedFilterTitle = app.staticTexts["Connected"]
        let connectivityLabel = app.staticTexts["Connectivity"]
        let discardButton = app.buttons["Discard"]
        let electricDistributionDeviceDataSourceButton = app.buttons["Electric Distribution Device"]
        let electricDistributionJunctionDataSourceButton = app.buttons["Electric Distribution Junction"]
        let electricDistributionDeviceLabel = app.staticTexts["Electric Distribution Device"]
        let elementTitle = app.staticTexts["Associations"]
        let formTitle = app.staticTexts["Electric Distribution Device"]
        let fromElementLabel = app.staticTexts["From Element"]
        let fuseButton = app.staticTexts["Fuse"].firstMatch
        let fuseLabel = app.staticTexts["Fuse"]
        let networkSourceGroupButtonAfter = app.buttons["Electric Distribution Device, 2"]
        let newAssociationText = app.staticTexts["New Association"]
        let saveButton = app.buttons["Save"]
        let searchField = app.textFields["Search"]
        let toElementLabel = app.staticTexts["To Element"]
        
#if targetEnvironment(macCatalyst)
        let addAssociationButton = app.buttons["Add Association"]
#else
        let addAssociationButton = app.staticTexts["Add Association"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementTitle.assertExistence()
        
        connectedFilterTitle.assertExistenceAndTap()
        
        addAssociationButton.assertExistenceAndTap()
        
        electricDistributionDeviceDataSourceButton.assertExistence()
        
        electricDistributionJunctionDataSourceButton.assertExistence()
        
        electricDistributionDeviceDataSourceButton.tap()
        
        searchField.assertExistenceAndTap()
        
        searchField.typeText("Cabinet Fuse")
        
        cabinetFuseButton.assertExistenceAndTap()
        
        fuseButton.assertExistenceAndTap()
        
        newAssociationText.assertExistence()
        
        associationTypeLabel.assertExistence()
        
        connectivityLabel.assertExistence()
        
        fromElementLabel.assertExistence()
        
        electricDistributionDeviceLabel.assertExistence()
        
        toElementLabel.assertExistence()
        
        fuseLabel.assertExistence()
        
        addButton.assertExistenceAndTap()
        
        networkSourceGroupButtonAfter.assertExistence()
        
        saveButton.assertExistence()
        
        discardButton.assertExistence()
    }
    
    func testCase_13_2() {
        let app = XCUIApplication()
        
        let addButton = app.buttons["Add"]
        let associationTypeLabel = app.staticTexts["Association Type"]
        let connectedFilterTitle = app.staticTexts["Connected"]
        let connectivityLabel = app.staticTexts["Connectivity"]
        let discardButton = app.buttons["Discard"]
        let electricDistributionDevice2 = app.buttons["Electric Distribution Device, 2"]
        let electricDistributionDevice3 = app.buttons["Electric Distribution Device, 3"]
        let electricDistributionDeviceDataSourceButton = app.buttons["Electric Distribution Device"]
        let electricDistributionDeviceLabel = app.staticTexts["Electric Distribution Device"]
        let electricDistributionJunctionButton5 = app.buttons["Electric Distribution Junction, 5"]
        let electricDistributionJunctionDataSourceButton = app.buttons["Electric Distribution Junction"]
        let elementTitle = app.staticTexts["Associations"]
        let formTitle = app.staticTexts["Electric Distribution Device"]
        let fromElementLabel = app.staticTexts["From Element"]
        let newAssociationText = app.staticTexts["New Association"]
        let saveButton = app.buttons["Save"]
        let searchField = app.textFields["Search"].firstMatch
        let switchButton = app.staticTexts["Switch"].firstMatch
        let switchLabel = app.staticTexts["Switch"]
        let terminalLabel = app.staticTexts["Terminal"]
        let terminalPicker = app.buttons["Terminal, High"]
        let toElementLabel = app.staticTexts["To Element"]
        let undergroundMediumVoltageThreePhaseDisconnectButton = app.buttons["Asset Type Underground Medium Voltage Three Phase Disconnect 493"]
        
#if targetEnvironment(macCatalyst)
        let addAssociationButton = app.buttons["Add Association"]
        let terminalHighButton = app.menuItems["high"]
        let terminalLowButton = app.menuItems["low"]
#else
        let addAssociationButton = app.staticTexts["Add Association"]
        let terminalHighButton = app.buttons["High"]
        let terminalLowButton = app.buttons["Low"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementTitle.assertExistence()
        
        connectedFilterTitle.assertExistenceAndTap()
        
        electricDistributionJunctionButton5.assertExistence()
        
        electricDistributionDevice2.assertExistence()
        
        addAssociationButton.assertExistenceAndTap()
        
        electricDistributionDeviceDataSourceButton.assertExistence()
        
        electricDistributionJunctionDataSourceButton.assertExistence()
        
        electricDistributionDeviceDataSourceButton.tap()
        
        searchField.assertExistenceAndTap()
        
        searchField.typeText("Disconnect")
        
        undergroundMediumVoltageThreePhaseDisconnectButton.firstMatch.assertExistenceAndTap()
        
        switchButton.firstMatch.assertExistenceAndTap()
        
        newAssociationText.assertExistence()
        
        associationTypeLabel.assertExistence()
        
        connectivityLabel.assertExistence()
        
        fromElementLabel.assertExistence()
        
        electricDistributionDeviceLabel.assertExistence()
        
        terminalLabel.assertExistence()
        
        terminalPicker.assertExistence()
        
        toElementLabel.assertExistence()
        
        switchLabel.assertExistence()
        
        addButton.assertExistence()
        
        terminalPicker.tap()
        
        terminalHighButton.assertExistence()
        
        terminalLowButton.assertExistence()
        
        terminalHighButton.tap()
        
        addButton.tap()
        
        electricDistributionJunctionButton5.assertExistence()
        
        electricDistributionDevice3.assertExistence()
        
        saveButton.assertExistence()
        
        discardButton.assertExistence()
    }
    
    func testCase_13_3() {
        let app = XCUIApplication()
        
        let addButton = app.buttons["Add"]
        let associationTypeLabel = app.staticTexts["Association Type"]
        let containerFilterTitle = app.staticTexts["Container"].firstMatch
        let containmentLabel = app.staticTexts["Containment"]
        let discardButton = app.buttons["Discard"]
        let electricDistributionJunctionLabel = app.staticTexts["Electric Distribution Junction"]
        let elementTitle = app.staticTexts["Associations"]
        let formTitle = app.staticTexts["Electric Distribution Junction"]
        let fromElementLabel = app.staticTexts["From Element"]
        let newAssociationText = app.staticTexts["New Association"]
        let saveButton = app.buttons["Save"]
        let structureJunction2 = app.buttons["Structure Junction, 2"]
        let structureJunctionDataSourceButton = app.buttons["Structure Junction"]
        let toElementValueLabel = app.staticTexts["Vault"]
        let toElementLabel = app.staticTexts["To Element"]
        let vaultAssetTypeButton = app.buttons["Vault"]
        let vaultCandidateButton = app.staticTexts.matching(identifier: "Vault").element(boundBy: 1)
        
#if targetEnvironment(macCatalyst)
        let addAssociationButton = app.buttons["Add Association"]
        let contentVisibleSwitch = app.checkBoxes["Content Visible"]
#else
        let addAssociationButton = app.staticTexts["Add Association"]
        let contentVisibleSwitch = app.switches["Content Visible"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementTitle.assertExistence()
        
        containerFilterTitle.assertExistenceAndTap()
        
        addAssociationButton.assertExistenceAndTap()
        
        structureJunctionDataSourceButton.assertExistenceAndTap()
        
        vaultAssetTypeButton.assertExistenceAndTap()
        
        vaultCandidateButton.assertExistenceAndTap()
        
        newAssociationText.assertExistence()
        
        associationTypeLabel.assertExistence()
        
        containmentLabel.assertExistence()
        
        contentVisibleSwitch.assertExistence()
        
        fromElementLabel.assertExistence()
        
        toElementValueLabel.assertExistence()
        
        toElementLabel.assertExistence()
        
        electricDistributionJunctionLabel.assertExistence()
        
        addButton.assertExistence()
        
        contentVisibleSwitch.tap()
        
        addButton.tap()
        
        structureJunction2.assertExistence()
        
        saveButton.assertExistence()
        
        discardButton.assertExistence()
    }
    
    func testCase_13_4() throws {
        try skipIf(macCatalyst: true, visionOS: true)
        
        let app = XCUIApplication()
        let addAssociationButton = app.staticTexts["Add Association"]
        let addConditionButton = app.buttons["Add Condition"]
        let cancelButton = app.buttons["Cancel"]
        let condition1Options = app.buttons["Condition 1 Options"]
        let conditionEqualsButton = app.buttons["Condition, ="]
        let connectedFilterTitle = app.staticTexts["Connected"]
        let deleteButton = app.buttons["Delete"]
        let discardEditsButton = app.buttons["Discard Edits"]
        let doneButton = app.buttons["Done"]
        let electricDistributionJunctionDataSourceButton = app.buttons["Electric Distribution Junction"]
        let elementTitle = app.staticTexts["Associations"]
        let equalOption = app.buttons["="]
        let filterButton = app.buttons["Filter Candidates"]
        let formTitle = app.staticTexts["Electric Distribution Device"]
        let isBlankLabel = app.staticTexts["is blank"]
        let isBlankOption = app.buttons["is blank"]
        let lineEndCandidates = app.buttons.matching(identifier: "Line End")
        let lowVoltageSinglePhaseLineEnd = app.buttons["Low Voltage Single Phase Line End"]
        let objectIDConditionLabel = app.staticTexts["Object ID"]
        let optionAButton = app.buttons["A"]
        let phasesCurrentState = app.buttons["Phases Current State"]
        let unsavedChangesAlert = app.alerts["Filters have not been applied"]
        let valueButton = app.buttons["Value"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementTitle.assertExistence()
        
        connectedFilterTitle.assertExistenceAndTap()
        
        addAssociationButton.assertExistenceAndTap()
        
        electricDistributionJunctionDataSourceButton.assertExistenceAndTap()
        
        lowVoltageSinglePhaseLineEnd.assertExistenceAndTap()
        
        XCTAssertEqual(lineEndCandidates.count, 2)
        
        filterButton.assertExistenceAndTap()
        
        addConditionButton.assertExistenceAndTap()
        
        cancelButton.assertExistenceAndTap()
        
        unsavedChangesAlert.assertExistence()
        
        // Dismiss the alert
        cancelButton.firstMatch.assertExistenceAndTap()
        
        unsavedChangesAlert.assertNonExistence()
        
        cancelButton.assertExistenceAndTap()
        
        unsavedChangesAlert.assertExistence()
        
        discardEditsButton.assertExistenceAndTap()
        
        unsavedChangesAlert.assertNonExistence()
        
        XCTAssertEqual(lineEndCandidates.count, 2)
        
        filterButton.assertExistenceAndTap()
        
        addConditionButton.assertExistenceAndTap()
        
        objectIDConditionLabel.assertExistence()
        
        condition1Options.assertExistenceAndTap()
        
        deleteButton.assertExistenceAndTap()
        
        addConditionButton.assertExistenceAndTap()
        
        objectIDConditionLabel.assertExistenceAndTap()
        
        phasesCurrentState.assertExistenceAndTap()
        
        conditionEqualsButton.assertExistenceAndTap()
        
        isBlankOption.assertExistenceAndTap()
        
        doneButton.assertExistenceAndTap()
        
        XCTAssertEqual(lineEndCandidates.count, 0)
        
        filterButton.assertExistenceAndTap()
        
        isBlankLabel.assertExistenceAndTap()
        
        equalOption.assertExistenceAndTap()
        
        valueButton.assertExistenceAndTap()
        
        optionAButton.assertExistenceAndTap()
        
        doneButton.assertExistenceAndTap()
        
        XCTAssertEqual(lineEndCandidates.count, 1)
    }
    
    func testCase_13_5() throws {
        try skipIf(macCatalyst: true, visionOS: true)
        
        let app = XCUIApplication()
        let addAssociationButton = app.staticTexts["Add Association"]
        let addConditionButton = app.buttons["Add Condition"]
        let condition1Options = app.buttons["Condition 1 Options"]
        let connectedFilterTitle = app.staticTexts["Connected"]
        let currentMonthYear = Date.now.formatted(.dateTime.month(.wide).year())
        let currentMonthYearLabel = app.staticTexts[currentMonthYear]
        let dateInstalledButton = app.buttons["Date Installed"]
        let datePickers = XCUIApplication().datePickers
        let datePicker1 = datePickers.firstMatch
        let datePicker2 = datePickers.element(boundBy: 1)
        let dismissPopover = app.buttons["PopoverDismissRegion"]
        let doneButton = app.buttons["Done"]
        let duplicateButton = app.buttons["Duplicate"]
        let electricDistributionDeviceDataSourceButton = app.buttons["Electric Distribution Device"]
        let elementTitle = app.staticTexts["Associations"]
        let equalStaticText = app.staticTexts["="]
        let filterButton = app.buttons["Filter Candidates"]
        let formTitle = app.staticTexts["Electric Distribution Device"]
        let greaterThanButton = app.buttons[">"]
        let greaterThanLabels = app.staticTexts.matching(identifier: ">")
        let jan2014Label = app.staticTexts["January 2014"]
        let lessThanButton = app.buttons["<"]
        let municipalButton = app.buttons["Municipal"]
        let objectIDConditionLabel = app.staticTexts["Object ID"]
        let streetLightCandidates = app.buttons.matching(identifier: "Street Light")
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementTitle.assertExistence()
        
        connectedFilterTitle.assertExistenceAndTap()
        
        addAssociationButton.assertExistenceAndTap()
        
        electricDistributionDeviceDataSourceButton.assertExistenceAndTap()
        
        municipalButton.assertExistenceAndTap()
        
        XCTAssertTrue(streetLightCandidates.count > 3)
        
        filterButton.assertExistenceAndTap()
        
        addConditionButton.assertExistenceAndTap()
        
        objectIDConditionLabel.assertExistenceAndTap()
        
        dateInstalledButton.assertExistenceAndTap()
        
        equalStaticText.assertExistenceAndTap()
        
        greaterThanButton.assertExistenceAndTap()
        
        datePicker1.assertExistenceAndTap()
        
        currentMonthYearLabel.assertExistenceAndTap()
        
        datePicker1.adjustPickerWheelElement(boundBy: 0, to: "January")
        
        datePicker1.adjustPickerWheelElement(boundBy: 1, to: "2014")
        
        dismissPopover.firstMatch.assertExistenceAndTap()
        
        condition1Options.assertExistenceAndTap()
        
        duplicateButton.assertExistenceAndTap()
        
        greaterThanLabels.element(boundBy: 1).assertExistenceAndTap()
        
        lessThanButton.assertExistenceAndTap()
        
        datePicker2.assertExistenceAndTap()
        
        jan2014Label.assertExistenceAndTap()
        
        datePicker2.adjustPickerWheelElement(boundBy: 0, to: "March")
        
        dismissPopover.firstMatch.assertExistenceAndTap()
        
        doneButton.assertExistenceAndTap()
        
        XCTAssertEqual(streetLightCandidates.count, 1)
    }
    
    func testCase_13_6() throws {
        try skipIf(macCatalyst: true, visionOS: true)

        let app = XCUIApplication()
        let addAssociationButton = app.staticTexts["Add Association"]
        let addButton = app.buttons["Add"]
        let addConditionButton = app.buttons["Add Condition"]
        let attachmentFilterTitle = app.staticTexts["Attachment"]
        let doneButton = app.buttons["Done"]
        let electricDistributionDevice2Button = app.buttons["Electric Distribution Device, 2"]
        let electricDistributionDeviceDataSourceButton = app.buttons["Electric Distribution Device"]
        let elementTitle = app.staticTexts["Associations"]
        let textField = app.textFields["Enter a value"]
        let filterButton = app.buttons["Filter Candidates"]
        let formTitle = app.staticTexts["Structure Junction"]
        let municipalButton = app.buttons["Municipal"]
        let streetLightButton = app.buttons["Street Light"]
        let streetLightCandidates = app.buttons.matching(identifier: "Street Light")
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementTitle.assertExistence()
        
        attachmentFilterTitle.assertExistenceAndTap()
        
        addAssociationButton.assertExistenceAndTap()
        
        electricDistributionDeviceDataSourceButton.assertExistenceAndTap()
        
        municipalButton.assertExistenceAndTap()
        
        XCTAssertTrue(streetLightCandidates.count > 3)
        
        filterButton.assertExistenceAndTap()
        
        addConditionButton.assertExistenceAndTap()
        
        textField.assertExistenceAndTap()
        
        textField.typeText("449")
        
        doneButton.assertExistenceAndTap()
        
        XCTAssertEqual(streetLightCandidates.count, 1)
        
        streetLightButton.assertExistenceAndTap()
        
        addButton.assertExistenceAndTap()
        
        electricDistributionDevice2Button.assertExistence()
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

private extension XCUIApplication {
    /// The "No value" combo box option.
    var noValueComboBoxOption: XCUIElement {
        buttons["No value Combo Box Option"]
    }
}

private extension XCUIElement {
    /// The element's value as a string.
    var stringValue: String? {
        value as? String
    }
}
