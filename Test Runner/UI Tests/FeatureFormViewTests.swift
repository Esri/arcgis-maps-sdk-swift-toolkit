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
    
    /// Verify that the attachments form element load isn't cancelled early when it's pushed below the fold
    /// by a group element.
    func testAttachmentLoadDurability() {
        let app = XCUIApplication()
        let attachmentLabel = app.staticTexts["esri.jpg"]
        let elementTitle = "Attachments"
        let formTitle = app.staticTexts["Group and Attachments"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        attachmentLabel.assertExistence()
    }
    
    func testAttachmentRenaming() {
        let app = XCUIApplication()
        let activityIndicator = app.activityIndicators.firstMatch
        let attachmentLabel = app.staticTexts["EsriHQ.jpeg"]
        let elementTitle = "Attachments"
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
        
        app.filterElements(elementTitle)
        
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
    
    func testEditingButtonsHidden() {
        let app = XCUIApplication()
        let discardButton = app.buttons["Discard"]
        let formTitle = app.staticTexts["Place of Interest"]
        let funActivitiesButton = app.buttons["Fun Activities"]
        let saveButton = app.buttons["Save"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        saveButton.assertNonExistence()
        discardButton.assertNonExistence()
        
        funActivitiesButton.assertExistenceAndTap()
        
        // Verify the editing buttons are hidden after making a form edit.
        saveButton.assertNonExistence()
        discardButton.assertNonExistence()
    }
    
    func testEditingButtonsVisible() {
        let app = XCUIApplication()
        let discardButton = app.buttons["Discard"]
        let formTitle = app.staticTexts["Place of Interest"]
        let saveButton = app.buttons["Save"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        // Verify the editing buttons are visible without making any form edits.
        saveButton.assertExistence()
        discardButton.assertExistence()
    }
    
    // - MARK: Test case 1: Text Box with no hint, no description, value not required
    
    /// Test case 1.1: unfocused and focused state, no value
    func testCase_1_1() throws {
        let app = XCUIApplication()
        let characterIndicator = app.staticTexts["Single Line No Value, Placeholder or Description Character Indicator"]
        let elementTitle = "Single Line No Value, Placeholder or Description"
        let elementValue = app.staticTexts[elementTitle]
        let footer = app.staticTexts["Single Line No Value, Placeholder or Description Footer"]
        let formTitle = app.staticTexts["InputValidation"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Input"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementValue.assertExistence()
        
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
        
        elementValue.assertExistence()
        
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
        let elementTitle = "Single Line No Value, Placeholder or Description"
        let elementLabel = app.staticTexts[elementTitle]
        let footer = app.staticTexts["Single Line No Value, Placeholder or Description Footer"]
        let formTitle = app.staticTexts["InputValidation"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Input"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        textField.assertExistenceAndTap()
        
        app.typeText("Sample text")
        
        elementLabel.assertExistence()
        
        footer.assertExistence()
        
        XCTAssertEqual(
            footer.label,
            "Maximum 256 characters"
        )
        
        characterIndicator.assertExistence()
        
        characterIndicator.assertLabel("11")
        
        clearButton.assertExistence()
        
        app.typeText("\r")
        
        elementLabel.assertHittable()
        
        XCTAssertFalse(
            footer.isHittable,
            "The footer is hittable."
        )
        
        clearButton.assertHittable()
        
        textField.assertHittable()
    }
    
    /// Test case 1.3: unfocused and focused state, with error value (> 256 chars)
    func testCase_1_3() throws {
        let app = XCUIApplication()
        let characterIndicator = app.staticTexts["Single Line No Value, Placeholder or Description Character Indicator"]
        let clearButton = app.buttons["Single Line No Value, Placeholder or Description Clear Button"]
        let footer = app.staticTexts["Single Line No Value, Placeholder or Description Footer"]
        let formTitle = app.staticTexts["InputValidation"]
        let elementTitle = "Single Line No Value, Placeholder or Description"
        let elementLabel = app.staticTexts[elementTitle]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Input"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        textField.tap()
        
        app.typeText(.loremIpsum257)
        
        elementLabel.assertExistence()
        
        footer.assertExistence()
        
        XCTAssertEqual(
            footer.label,
            "Maximum 256 characters"
        )
        
        characterIndicator.assertExistence()
        
        characterIndicator.assertLabel("257")
        
        clearButton.assertExistence()
        
        app.typeText("\r")
        
        elementLabel.assertExistence()
        
        footer.assertExistence()
        
        XCTAssertEqual(
            footer.label,
            "Maximum 256 characters"
        )
        
        characterIndicator.assertNonExistence()
        
        clearButton.assertHittable()
        
        textField.assertHittable()
    }
    
    func testCase_1_4() {
        let app = XCUIApplication()
        let footer = app.staticTexts["numbers Footer"]
        let formTitle = app.staticTexts["Domain"]
        let textField = app.textFields["numbers Text Input"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        XCTAssertTrue(textField.stringValue?.isEmpty ?? false)
        
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
        
        footer.assertLabel("Range domain 2-5")
        
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
        let elementTitle = "Required Date"
        let calendarImage = app.images["\(elementTitle) Calendar Image"]
        let clearButton = app.buttons["\(elementTitle) Clear Button"]
        let datePicker = app.datePickers["\(elementTitle) Date Picker"]
        let elementValue = app.staticTexts["\(elementTitle) Value"]
        let footer = app.staticTexts["\(elementTitle) Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let nowButton = app.buttons["\(elementTitle) Now Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        if elementValue.label != "No Value" {
            clearButton.tap()
        }
        
        XCTAssertEqual(
            elementValue.label,
            "No Value"
        )
        
        footer.assertExistence()
        
        XCTAssertEqual(
            footer.label,
            "Date Entry is Required"
        )
        
        calendarImage.assertExistence()
        
        elementValue.tap()
        
        datePicker.assertExistence()
        
        // Verify that the date picker defaulted selection to the current date
        // and time, accounting for the possibility that the minute has changed
        // since the picker was opened.
        XCTAssertTrue(
            [
                Date.now.formatted(),
                Date.now.addingTimeInterval(-60).formatted()
            ]
                .contains(elementValue.label)
        )
        
        nowButton.assertHittable()
        
        elementValue.tap()
        
        XCTAssertEqual(
            footer.label,
            "Date Entry is Required"
        )
    }
    
    /// Test case 2.2: Focused and unfocused state, with value (populated)
    func testCase_2_2() {
        let app = XCUIApplication()
        let elementTitle = "Launch Date and Time for Apollo 11"
        let datePicker = app.datePickers["\(elementTitle) Date Picker"]
        let elementLabel = app.staticTexts[elementTitle]
        let elementValue = app.staticTexts["\(elementTitle) Value"]
        let footer = app.staticTexts["\(elementTitle) Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let nowButton = app.buttons["\(elementTitle) Now Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
        XCTAssertEqual(
            footer.label,
            "Enter the launch date and time (July 16, 1969 13:32 UTC)"
        )
        
        elementValue.tap()
        
        datePicker.assertExistence()
        
        let localDate = Calendar.current.date(
            from: DateComponents(
                timeZone: .gmt, year: 1969, month: 7, day: 16, hour: 13, minute: 32
            )
        )
        
        XCTAssertEqual(
            elementValue.label,
            localDate?.formatted()
        )
        
        nowButton.assertHittable()
        
        elementValue.tap()
        
        elementValue.assertHittable()
        
        XCTAssertFalse(
            datePicker.isHittable,
            "The date picker was hittable."
        )
    }
    
    /// Test case 2.3: Date only, no time
    func testCase_2_3() {
        let app = XCUIApplication()
        let datePicker = app.datePickers["Launch Date for Apollo 11 Date Picker"]
        let elementValue = app.staticTexts["Launch Date for Apollo 11 Value"]
        let footer = app.staticTexts["Launch Date for Apollo 11 Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let todayButton = app.buttons["Launch Date for Apollo 11 Today Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        footer.assertExistence()
        
        elementValue.tap()
        
        XCTAssertEqual(
            footer.label,
            "Enter the Date for the Apollo 11 launch"
        )
        
        elementValue.assertHittable()
        
        let localDate = Calendar.current.date(
            from: DateComponents(
                timeZone: .gmt, year: 2023, month: 7, day: 15, hour: 3, minute: 53
            )
        )
        
        XCTAssertEqual(
            elementValue.label,
            localDate?.formatted(.dateTime.day().month().year())
        )
        
        datePicker.assertHittable()
        
        todayButton.assertHittable()
    }
    
    /// Test case 2.4: Maximum date
    func testCase_2_4() {
        let app = XCUIApplication()
        let elementTitle = "Launch Date Time End"
        let clearButton = app.buttons["\(elementTitle) Clear Button"]
        let elementValue = app.staticTexts["\(elementTitle) Value"]
        let footer = app.staticTexts["\(elementTitle) Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let nowButton = app.buttons["\(elementTitle) Now Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        if elementValue.label != "No Value" {
            clearButton.tap()
        }
        
        footer.assertExistence()
        
        elementValue.tap()
        
        nowButton.assertExistenceAndTap()
        
        elementValue.assertExistenceAndTap()
        
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
            elementValue.label,
            localDate?.formatted()
        )
    }
    
    /// Test case 2.5: Minimum date
    func testCase_2_5() {
        let app = XCUIApplication()
        let elementTitle = "start and end date time"
        let datePicker = app.datePickers["\(elementTitle) Date Picker"]
        let elementValue = app.staticTexts["\(elementTitle) Value"]
        let footer = app.staticTexts["\(elementTitle) Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let nowButton = app.buttons["\(elementTitle) Now Button"]
        let previousMonthButton = datePicker.buttons["Previous Month"]
        let julyFirstButton = datePicker.collectionViews.staticTexts["1"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementValue.assertExistence()
        
        footer.assertExistence()
        
        elementValue.tap()
        
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
        
        elementValue.assertLabel(localDate!.formatted())
        
        XCTAssertFalse(
            previousMonthButton.isEnabled,
            "The user was able to view June 1969 in the calendar."
        )
    }
    
    /// Test case 2.6: Clear date
    func testCase_2_6() {
        let app = XCUIApplication()
        let clearButton = app.buttons["Launch Date and Time for Apollo 11 Clear Button"]
        let elementLabel = app.staticTexts["Launch Date and Time for Apollo 11"]
        let elementValue = app.staticTexts["Launch Date and Time for Apollo 11 Value"]
        let formTitle = app.staticTexts["DateTimePoint"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementLabel.assertHittable()
        
        clearButton.assertExistenceAndTap()
        
        XCTAssertEqual(
            elementValue.label,
            "No Value"
        )
    }
    
    // - MARK: Test case 3: Combo Box input type
    
    /// Test case 3.1: Pre-existing value, description, clear button, no value label
    func testCase_3_1() {
        let app = XCUIApplication()
        let elementTitle = "Combo String"
        let clearButton = app.buttons["\(elementTitle) Clear Button"]
        let elementLabel = app.staticTexts[elementTitle]
        let elementValue = app.staticTexts["\(elementTitle) Combo Box Value"]
        let formTitle = app.staticTexts["comboBox"]
        let footer = app.staticTexts["\(elementTitle) Footer"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertHittable()
        
        elementValue.assertHittable()
        
        XCTAssertEqual(
            elementValue.label,
            "String 3"
        )
        
        clearButton.assertExistenceAndTap()
        
        elementValue.assertLabel("No value")
        
        footer.assertExistence()
        
        XCTAssertEqual(
            footer.label,
            "Combo Box of Field Type String"
        )
    }
    
    /// Test case 3.2: No pre-existing value, no value label, options button
    func testCase_3_2() {
        let app = XCUIApplication()
        let elementLabel = app.staticTexts["Combo Integer"]
        let elementValue = app.staticTexts["Combo Integer Combo Box Value"]
        let formTitle = app.staticTexts["comboBox"]
        let optionsButton = app.images["Combo Integer Options Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementLabel.assertHittable()
        
        elementValue.assertHittable()
        
        XCTAssertEqual(
            elementValue.label,
            "No value"
        )
        
        optionsButton.assertHittable()
    }
    
    /// Test case 3.3: Pick a value
    func testCase_3_3() {
        let app = XCUIApplication()
        let elementLabel = app.staticTexts["Combo String"]
        let elementValue = app.staticTexts["Combo String Combo Box Value"]
        let firstOptionButton = app.buttons["String 1"]
        let formTitle = app.staticTexts["comboBox"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementLabel.assertHittable()
        
        elementValue.assertHittable()
        
        XCTAssertEqual(
            elementValue.label,
            "String 3"
        )
        
        elementValue.tap()
        
        firstOptionButton.assertExistenceAndTap()
        
        app.doneButton.assertExistenceAndTap()
        
        XCTAssertEqual(
            elementValue.label,
            "String 1"
        )
    }
    
    /// Test case 3.4: Picker with a noValueLabel row
    func testCase_3_4() {
        let app = XCUIApplication()
        let elementLabel = app.staticTexts["Combo String"]
        let elementValue = app.staticTexts["Combo String Combo Box Value"]
        let formTitle = app.staticTexts["comboBox"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementLabel.assertHittable()
        
        XCTAssertEqual(
            elementValue.label,
            "String 3"
        )
        
        elementValue.tap()
        
        XCTAssertTrue(
            app.noValueComboBoxOption.waitForExistence(timeout: 1),
            "The no value button doesn't exist."
        )
        
        app.noValueComboBoxOption.tap()
        
        app.doneButton.assertExistenceAndTap()
        
        XCTAssertEqual(
            elementValue.label,
            "No value"
        )
    }
    
    /// Test case 3.5: Required Value
    func testCase_3_5() {
        let app = XCUIApplication()
        let elementTitle = "Required Combo Box"
        let clearButton = app.buttons["\(elementTitle) Clear Button"]
        let elementLabel = app.staticTexts["\(elementTitle) *"]
        let elementValue = app.staticTexts["\(elementTitle) Combo Box Value"]
        let footer = app.staticTexts["\(elementTitle) Footer"]
        let formTitle = app.staticTexts["comboBox"]
        let oakButton = app.buttons["Oak"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
        XCTAssertEqual(
            elementValue.label,
            "Pine"
        )
        
        XCTAssertFalse(
            clearButton.isHittable,
            "The clear button is hittable."
        )
        
        footer.assertExistence()
        
        elementValue.tap()
        
        app.noValueComboBoxOption.assertNonExistence()
        
        oakButton.assertExistenceAndTap()
        
        app.doneButton.assertExistenceAndTap()
        
        XCTAssertEqual(
            elementValue.label,
            "Oak"
        )
    }
    
    /// Test case 3.6: noValueOption is 'Hide'
    func testCase_3_6() throws {
        let app = XCUIApplication()
        let elementTitle = "Combo No Value False"
        let elementLabel = app.staticTexts[elementTitle]
        let elementValue = app.staticTexts["Combo No Value False Combo Box Value"]
        let firstOption = app.buttons["First"]
        let formTitle = app.staticTexts["comboBox"]
        let noValueButton = app.buttons["No Value"]
        let optionsButton = app.images["Combo No Value False Options Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
        XCTAssertTrue(elementValue.label.isEmpty)
        
        optionsButton.assertExistenceAndTap()
        
        firstOption.assertExistence()
        
        noValueButton.assertNonExistence()
        
        firstOption.assertExistenceAndTap()
        
        app.doneButton.assertExistenceAndTap()
        
        XCTAssertEqual(
            elementValue.label,
            "First"
        )
    }
    
    /// Test case 3.7: Unsupported value
    func testCase_3_7() throws {
        let app = XCUIApplication()
        let elementTitle = "Unsupported Value"
        let elementLabel = app.staticTexts[elementTitle]
        let elementValue = app.staticTexts["\(elementTitle) Combo Box Value"]
        let formTitle = app.staticTexts["comboBox"]
        let unsupportedValueSectionHeader = app.staticTexts["\(elementTitle) Unsupported Value Section"]
        let unsupportedValue = app.buttons["0"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
        XCTAssertEqual(
            elementValue.label,
            "0"
        )
        
        elementValue.tap()
        
        unsupportedValueSectionHeader.assertExistence()
        
        unsupportedValue.assertExistence()
        
        app.noValueComboBoxOption.assertExistenceAndTap()
        
        unsupportedValueSectionHeader.assertNonExistence()
    }
    
    // - MARK: Test case 4: Radio Buttons input type
    
    /// Test case 4.1: Test regular selection
    func testCase_4_1() throws {
        let app = XCUIApplication()
        let birdOption = app.buttons["bird"]
        let dogOption = app.buttons["dog"]
        let elementTitle = "Radio Button Text"
        let elementLabel = app.staticTexts["\(elementTitle) *"]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        let noValueOption = app.buttons["No Value"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        noValueOption.assertExistence()
        birdOption.assertExistence()
        dogOption.assertExistence()
        
        XCTAssertTrue(birdOption.isSelected)
        XCTAssertFalse(dogOption.isSelected)
        
        app.buttons["dog"].tap()
        
        XCTAssertTrue(dogOption.isSelected)
        XCTAssertFalse(birdOption.isSelected)
    }
    
    /// Test case 4.2: Test radio button fallback to combo box
    func testCase_4_2() {
        let app = XCUIApplication()
        let comboBoxOption = app.buttons["Fallback 1 Combo Box Value-Fallback 1 Options Button"]
        let element1Title = "Fallback 1"
        let element1Value = app.staticTexts["\(element1Title) Combo Box Value"]
        let element2Title = "No Value Enabled"
        let element3Title = "No Value Disabled"
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        let naOption = app.buttons["N/A"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(element1Title)
        
        // Verify the Radio Button fallback to Combo Box was successful.
        element1Value.assertExistence()
        comboBoxOption.assertExistence()
        
        app.filterElements(element2Title)
        
        // Verify the radio buttons are shown even when the no value option is enabled.
        naOption.assertExistence()
        XCTAssertTrue(naOption.isSelected)
        
        app.filterElements(element3Title)
        
        // Verify the radio buttons are still shown even when the no value option is disabled.
        app.buttons["One"].assertExistence()
    }
    
    // - MARK: Test case 5: Switch input type
    
    /// Test case 5.1: Test switch on
    func testCase_5_1() {
        let app = XCUIApplication()
        let elementTitle = "switch integer"
        let elementLabel = app.staticTexts[elementTitle]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        
#if targetEnvironment(macCatalyst)
        let switchView = app.checkBoxes["\(elementTitle) Switch"]
#else
        let switchView = app.switches["\(elementTitle) Switch"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
        XCTAssertEqual(
            switchView.label,
            "2"
        )
        
#if targetEnvironment(macCatalyst) || os(visionOS)
        switchView.assertExistenceAndTap()
#else
        switchView.switches.firstMatch.assertExistenceAndTap()
#endif
        
        switchView.assertLabel("1")
    }
    
    /// Test case 5.2: Test switch off
    func testCase_5_2() {
        let app = XCUIApplication()
        let elementTitle = "switch string"
        let elementLabel = app.staticTexts[elementTitle]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        
#if targetEnvironment(macCatalyst)
        let switchView = app.checkBoxes["\(elementTitle) Switch"]
#else
        let switchView = app.switches["\(elementTitle) Switch"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertHittable()
        
        XCTAssertEqual(
            switchView.label,
            "1"
        )
        
#if targetEnvironment(macCatalyst) || os(visionOS)
        switchView.assertExistenceAndTap()
#else
        switchView.switches.firstMatch.assertExistenceAndTap()
#endif
        
        switchView.assertLabel("2")
    }
    
    /// Test case 5.3: Test switch with no value
    func testCase_5_3() {
        let app = XCUIApplication()
        let elementLabel = app.staticTexts["switch double"]
        let elementValue = app.staticTexts["switch double Combo Box Value"]
        let formTitle = app.staticTexts["mainobservation_ExportFeatures"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        elementLabel.assertExistence()
        
        elementValue.assertExistence()
    }
    
    /// Test case 6.1: Test initially expanded and collapsed
    func testCase_6_1() {
        let app = XCUIApplication()
        let collapsedGroupFirstElement = app.staticTexts["Single Line Text"]
        let collapsedGroupTitle = "Group with Multiple Form Elements 2"
        let expandedGroupTitle = "Group with Multiple Form Elements"
        let expandedGroupFirstElement = app.staticTexts["MultiLine Text"]
        let formTitle = app.staticTexts["group_formelement_UI_not_editable"]
        
#if targetEnvironment(macCatalyst)
        let collapsedGroup = app.buttons["\(collapsedGroupTitle), This group is not expanded for initial state"]
        let expandedGroup = app.buttons["\(expandedGroupTitle), This Group is 'Expand initial state'\nThis group is Visible"]
#else
        let collapsedGroup = app.staticTexts[collapsedGroupTitle]
        let expandedGroup = app.staticTexts[expandedGroupTitle]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(expandedGroupTitle)
        
        expandedGroup.assertExistence()
        
        // Confirm the first element of the expanded group exists.
        expandedGroupFirstElement.assertExistence()
        
        app.filterElements(collapsedGroupTitle)
        
        collapsedGroup.assertExistence()
        
        // Confirm the first element of the collapsed group doesn't exist.
        collapsedGroupFirstElement.assertNonExistence()
    }
    
    /// Test case 6.2: Test visibility of empty group
    func testCase_6_2() throws {
        let app = XCUIApplication()
        let group1ElementTitle = "Group with children that are visible dependent"
        let group1TextElementLabel = app.staticTexts["single line text 3"]
        let group2ElementTitle = "Group with Multiple Form Elements"
        let formTitle = app.staticTexts["group_formelement_UI_not_editable"]
        let hiddenElementsGroup = app.staticTexts[group1ElementTitle]
        let hiddenElementsGroupDescription = app.staticTexts["\(group1ElementTitle) Description"]
        let radioOptionA = app.buttons["No value"]
        let radioOptionB = app.buttons["Everything is working great"]
        let radioOptionC = app.buttons["show invisible form element"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(group1ElementTitle)
        
        hiddenElementsGroup.assertExistence()
        
        hiddenElementsGroupDescription.assertExistence()
        
        XCTAssertEqual(
            hiddenElementsGroupDescription.label,
            "The Form Elements in this group need the Radio button \"show invisible form elements\" to be selected, if you want to see them"
        )
        
        // Confirm the first element of the conditional group doesn't exist.
        group1TextElementLabel.assertNonExistence()
        
        app.filterElements(group2ElementTitle)
        
#if targetEnvironment(macCatalyst)
        radioOptionA.swipeUp()
#endif
        
        // Show the invisible elements.
        radioOptionB.assertExistenceAndTap()
        radioOptionC.assertExistenceAndTap()
        
        app.filterElements(group1ElementTitle)
        
        // Confirm the first element of the conditional group exists.
        group1TextElementLabel.assertExistence()
    }
    
    /// Test case 7.1: Test read only elements
    func testCase_7_1() throws {
        let app = XCUIApplication()
        let comboBoxReadOnlyInput = app.staticTexts["Combo box Read Only Input"]
        let comboBox = app.staticTexts["Combo box Combo Box Value"]
        let dateElementTitle = "Date"
        let dateReadOnlyInput = app.staticTexts["\(dateElementTitle) Read Only Input"]
        let dateInput = app.buttons["\(dateElementTitle) Value"]
        let formTitle = app.staticTexts["Test Case 7.1 - Read only elements"]
        let groupElementTitle = "Group"
        let longTextFieldTitle = "Long text"
        let longTextReadOnlyInput = app.staticTexts["\(longTextFieldTitle) Read Only Input"]
        let longTextTextInputPreview = app.buttons["\(longTextFieldTitle) Text Input Preview"]
        let radioButtonsElementTitle = "Radio buttons"
        let radioButtonsOption0 = app.buttons["0"]
        let radioButtonsReadOnlyInput = app.staticTexts["\(radioButtonsElementTitle) Read Only Input"]
        let shortTextElementTitle = "Short text"
        let shortTextReadOnlyInput = app.staticTexts["\(shortTextElementTitle) Read Only Input"]
        let shortTextTextInput = app.textFields["\(shortTextElementTitle) Text Input"]
        let switch1FieldTitle = "Elements are editable"
        let switch2FieldTitle = "Element in the group is editable"
        let switchReadOnlyInput = app.staticTexts["\(switch2FieldTitle) Read Only Input"]
        
#if targetEnvironment(macCatalyst)
        let switch1 = app.checkBoxes["\(switch1FieldTitle) Switch"]
        let switch2 = app.checkBoxes["\(switch2FieldTitle) Switch"]
#else
        let switch1 = app.switches["\(switch1FieldTitle) Switch"]
        let switch2 = app.switches["\(switch2FieldTitle) Switch"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        switchReadOnlyInput.assertExistence()
        
        comboBoxReadOnlyInput.assertExistence()
        
        app.filterElements(radioButtonsElementTitle)
        
        radioButtonsReadOnlyInput.assertExistence()
        
        app.filterElements(dateElementTitle)
        
        dateReadOnlyInput.assertExistence()
        
        app.filterElements(shortTextElementTitle)
        
        shortTextReadOnlyInput.assertExistence()
        
        app.filterElements(groupElementTitle)
        
        longTextReadOnlyInput.assertExistence()
        
        app.clearElementFilter()
        
#if targetEnvironment(macCatalyst) || os(visionOS)
        switch1.assertExistenceAndTap()
        switch2.assertExistenceAndTap()
#else
        switch1.switches.firstMatch.assertExistenceAndTap()
        switch2.switches.firstMatch.assertExistenceAndTap()
#endif
        
        comboBox.assertExistence()
        
        app.filterElements(radioButtonsElementTitle)
        
        radioButtonsOption0.assertExistence()
        
        XCTAssertTrue(radioButtonsOption0.isSelected)
        
        app.filterElements(dateElementTitle)
        
        dateInput.assertExistence()
        
        app.filterElements(shortTextElementTitle)
        
        shortTextTextInput.assertExistence()
        
        app.filterElements(groupElementTitle)
        
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
            titleTextField.stringValue,
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
        let barcodeValidationString = app.staticTexts["Barcode Footer"]
        let clearButton = app.buttons["Barcode Clear Button"]
        let elementValue = app.textFields["Barcode Text Input"]
        let formTitle = app.staticTexts["Test case 11.1 Layer"]
        let scanButton = app.buttons["Barcode Scan Button"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
#if !os(visionOS)
        scanButton.assertExistence()
#endif
        clearButton.assertNonExistence()
        
        elementValue.assertExistenceAndTap()
        elementValue.typeText("https://esri.com/this_is_a_string_longer_than_50_count_on_it")
        
#if !os(visionOS)
        scanButton.assertExistence()
#endif
        XCTAssertEqual(barcodeValidationString.label, "Maximum 50 characters")
    }
    
    func testCase_12_1() {
        let app = XCUIApplication()
        let assetGroup = app.staticTexts["Asset group"]
        let elementTitle = "Associations"
        let elementLabel = app.staticTexts[elementTitle]
        let elementValue = app.staticTexts["Asset group Read Only Input"]
        let formTitle = app.staticTexts["Electric Distribution Device"]
        let filterResults1 = app.staticTexts["Connected"]
        let filterResults2 = app.staticTexts["Structure"]
        let filterResults3 = app.staticTexts["Container"]
        let networkSourceGroup1 = app.staticTexts["Electric Distribution Junction"]
        let networkSourceGroup2Button = app.buttons["Electric Distribution Device, 2"]
        
#if targetEnvironment(macCatalyst)
        let fuses = app.staticTexts.matching(identifier: "Fuse, Single Terminal")
#else
        let fuses = app.buttons.matching(identifier: "Fuse, Single Terminal")
#endif
        
        let fuseOption1 = fuses.element(boundBy: 0)
        let fuseOption2 = fuses.element(boundBy: 1)
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
        filterResults1.assertExistence()
        
        filterResults2.assertExistence()
        
        filterResults3.assertExistence()
        
        filterResults1.tap()
        
        networkSourceGroup1.assertExistence()
        
        networkSourceGroup2Button.assertExistenceAndTap()
        
        fuseOption1.assertExistence()
        
        fuseOption2.assertExistence()
        
        fuseOption1.tap()
        
        // Open new form
        assertFormOpened(titleElement: formTitle)
        
        assetGroup.assertExistence()
        
        XCTAssertEqual(
            elementValue.label,
            "Fuse"
        )
    }
    
    // Test case 12.2: Associations show percent along
    // It has been determined that with the currently-available public test data
    // this is no longer feasible. So this functionality will be ad-hoc tested only.
    
    func testCase_12_3() {
        let app = XCUIApplication()
        let elementTitle = "Associations"
        let elementLabel = app.staticTexts[elementTitle]
        let filterResults = app.staticTexts["Content"]
        let formTitle = app.staticTexts["Structure Boundary"]
        let networkSourceGroupButton = app.buttons["Electric Distribution Device, 1"]
        
#if targetEnvironment(macCatalyst)
        let circuitBreakerButton = app.staticTexts["Circuit Breaker, Visible: false"]
#else
        let circuitBreakerButton = app.buttons["Circuit Breaker, Visible: false"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
        filterResults.assertExistenceAndTap()
        
        networkSourceGroupButton.assertExistenceAndTap()
        
        // Expectation: a list of one utility element with label "Circuit Breaker"
        circuitBreakerButton.assertExistence()
    }
    
    func testCase_12_4() {
        let app = XCUIApplication()
        let elementTitle = "Associations"
        let elementLabel = app.staticTexts[elementTitle]
        let filterResults = app.staticTexts["Container"]
        let formTitle = app.staticTexts["Electric Distribution Device"]
        let networkSourceGroup = app.staticTexts["Structure Boundary"]
        
#if targetEnvironment(macCatalyst)
        let substationButton = app.staticTexts["Substation"]
#else
        let substationButton = app.buttons["Substation"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
        filterResults.assertExistenceAndTap()
        
        networkSourceGroup.assertExistenceAndTap()
        
        // Expectation: a list of one utility element with no "Containment Visible" label
        substationButton.assertExistence()
    }
    
    func testCase_12_5() {
        let app = XCUIApplication()
        let assetType = app.staticTexts["Asset type *"]
        let backButton = app.buttons["Back"]
        let elementTitle = "Associations"
        let elementLabel = app.staticTexts[elementTitle]
        let elementValue = app.staticTexts["Asset type Combo Box Value"]
        let filterResults = app.staticTexts["Connected"]
        let firstOptionButton = app.buttons["Unknown Combo Box Option"]
        let formTitle = app.staticTexts["Electric Distribution Device"]
        let formTitle2 = app.staticTexts["Electric Distribution Device"]
        let networkSourceGroupButton = app.buttons["Electric Distribution Device, 1"]
        
#if targetEnvironment(macCatalyst)
        let discardEditsButton = app.buttons["Discard Edits"].firstMatch
        let transformerButton = app.staticTexts["Transformer, High"]
#else
        let discardEditsButton = app.buttons["Discard Edits"]
        let transformerButton = app.buttons["Transformer, High"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
        filterResults.assertExistenceAndTap()
        
        networkSourceGroupButton.assertExistenceAndTap()
        
        transformerButton.assertExistenceAndTap()
        
        assertFormOpened(titleElement: formTitle2)
        
        assetType.assertExistence()
        
        elementValue.tap()
        
        firstOptionButton.assertExistenceAndTap()
        
        app.doneButton.assertExistenceAndTap()
        
        // Tap the "Back" button
        backButton.tap()
        
        // Expectation: an alert appears with "Discard Edits", "Save Edits", and "Continue Editing" options
        discardEditsButton.assertExistenceAndTap()
        
        // Access the new `FeatureForm`
        // Expectation: the form title should be "Electric Distribution Junction"
        // Expectation: a list of one utility elements entitled "Transformer - 2552"
        transformerButton.assertExistence()
    }
    
    func testCase_12_6() {
        let app = XCUIApplication()
        let cancelButton = app.buttons["Cancel"].firstMatch
        let discardButton = app.buttons["Discard"].firstMatch
        let elementTitle = "Associations"
        let elementLabel = app.staticTexts[elementTitle]
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
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
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
        let cabinetFuseButton = app.buttons["Cabinet Fuse, Fuse"]
        let connectedFilterTitle = app.staticTexts["Connected"]
        let connectivityLabel = app.staticTexts["Connectivity"]
        let discardButton = app.buttons["Discard"]
        let electricDistributionDeviceDataSourceButton = app.buttons["Electric Distribution Device"]
        let electricDistributionJunctionDataSourceButton = app.buttons["Electric Distribution Junction"]
        let electricDistributionDeviceLabel = app.staticTexts["Electric Distribution Device"]
        let elementTitle = "Associations"
        let elementLabel = app.staticTexts[elementTitle]
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
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
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
        let elementTitle = "Associations"
        let elementLabel = app.staticTexts[elementTitle]
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
        let undergroundMediumVoltageThreePhaseDisconnectButton = app.buttons["Underground Medium Voltage Three Phase Disconnect, Switch"]
        
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
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
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
        let elementTitle = "Associations"
        let elementLabel = app.staticTexts[elementTitle]
        let formTitle = app.staticTexts["Electric Distribution Junction"]
        let fromElementLabel = app.staticTexts["From Element"]
        let newAssociationText = app.staticTexts["New Association"]
        let saveButton = app.buttons["Save"]
        let searchField = app.textFields["Search"]
        let structureJunction2 = app.buttons["Structure Junction, 2"]
        let structureJunctionDataSourceButton = app.buttons["Structure Junction"]
        let toElementValueLabel = app.staticTexts["Vault"]
        let toElementLabel = app.staticTexts["To Element"]
        let vaultAssetTypeButton = app.buttons["Vault, Vault"]
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
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
        containerFilterTitle.assertExistenceAndTap()
        
        addAssociationButton.assertExistenceAndTap()
        
        structureJunctionDataSourceButton.assertExistenceAndTap()
        
        searchField.assertExistenceAndTap()
        
        searchField.typeText("Vault")
        
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
        let app = XCUIApplication()
        let addAssociationButton = app.staticTexts["Add Association"]
        let addConditionButton = app.buttons["Add Condition"]
        let cancelButton = app.buttons["Cancel"]
        let conditionEqualsButton = app.buttons["Condition, ="]
        let connectedFilterTitle = app.staticTexts["Connected"]
        let electricDistributionJunctionDataSourceButton = app.buttons["Electric Distribution Junction"]
        let elementTitle = "Associations"
        let elementLabel = app.staticTexts[elementTitle]
        let filterButton = app.buttons["Filter Candidates"]
        let formTitle = app.staticTexts["Electric Distribution Device"]
        let lineEndCandidates = app.buttons.matching(identifier: "Line End")
        let lowVoltageSinglePhaseLineEnd = app.buttons["Low Voltage Single Phase Line End, Line End"]
        let valueButton = app.buttons["Value, Unknown"]
        
#if os(visionOS) || targetEnvironment(macCatalyst)
        let isBlankLabel = app.buttons["Condition, is blank"]
        let objectIDField = app.buttons["Field, Object ID"]
#else
        let isBlankLabel = app.staticTexts["is blank"]
        let objectIDField = app.staticTexts["Object ID"]
#endif
        
#if targetEnvironment(macCatalyst)
        let condition1Options = app.popUpButtons.firstMatch
        let deleteButton = app.menuItems["delete"].firstMatch
        let discardEditsButton = app.buttons["Discard Edits"].firstMatch
        let equalOption = app.menuItems["="]
        let isBlankOption = app.menuItems["is_blank"]
        let optionAButton = app.menuItems["A"]
        let phasesCurrentState = app.menuItems["phases_current_state"]
        let unsavedChangesAlert = app.staticTexts["Filters have not been applied"]
#else
        let condition1Options = app.buttons["Condition 1 Options"]
        let deleteButton = app.buttons["Delete"]
        let discardEditsButton = app.buttons["Discard Edits"]
        let equalOption = app.buttons["="]
        let isBlankOption = app.buttons["is blank"]
        let optionAButton = app.buttons["A"]
        let phasesCurrentState = app.buttons["Phases Current State"]
        let unsavedChangesAlert = app.alerts["Filters have not been applied"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
        connectedFilterTitle.assertExistenceAndTap()
        
        addAssociationButton.assertExistenceAndTap()
        
        electricDistributionJunctionDataSourceButton.assertExistenceAndTap()
        
        lowVoltageSinglePhaseLineEnd.assertExistenceAndTap()
        
        lineEndCandidates.firstMatch.assertExistence()
        
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
        
        lineEndCandidates.firstMatch.assertExistence()
        
        XCTAssertEqual(lineEndCandidates.count, 2)
        
        filterButton.assertExistenceAndTap()
        
        addConditionButton.assertExistenceAndTap()
        
        objectIDField.assertExistence()
        
        condition1Options.assertExistenceAndTap()
        
        deleteButton.assertExistenceAndTap()
        
        addConditionButton.assertExistenceAndTap()
        
        objectIDField.assertExistenceAndTap()
        
        phasesCurrentState.assertExistenceAndTap()
        
        conditionEqualsButton.assertExistenceAndTap()
        
        isBlankOption.assertExistenceAndTap()
        
        app.doneButton.assertExistenceAndTap()
        
        lineEndCandidates.firstMatch.assertNonExistence()
        
        filterButton.assertExistenceAndTap()
        
        isBlankLabel.assertExistenceAndTap()
        
        equalOption.assertExistenceAndTap()
        
        valueButton.assertExistenceAndTap()
        
        optionAButton.assertExistenceAndTap()
        
        app.doneButton.assertExistenceAndTap()
        
        lineEndCandidates.firstMatch.assertExistence()
        
        XCTAssertEqual(lineEndCandidates.count, 1)
    }
    
    func testCase_13_5() throws {
        let app = XCUIApplication()
        let addAssociationButton = app.staticTexts["Add Association"]
        let addConditionButton = app.buttons["Add Condition"]
        let connectedFilterTitle = app.staticTexts["Connected"]
        let currentMonthYear = Date.now.formatted(.dateTime.month(.wide).year())
        let currentMonthYearLabel = app.staticTexts[currentMonthYear]
        let datePickers = XCUIApplication().datePickers
        let datePicker1 = datePickers.firstMatch
        let datePicker2 = datePickers.element(boundBy: 1)
        let dismissPopover = app.buttons["PopoverDismissRegion"]
        let electricDistributionDeviceDataSourceButton = app.buttons["Electric Distribution Device"]
        let elementTitle = "Associations"
        let elementLabel = app.staticTexts[elementTitle]
        let filterButton = app.buttons["Filter Candidates"]
        let formTitle = app.staticTexts["Electric Distribution Device"]
        // Using app.buttons allows this to work on both Mac Catalyst and iOS
        let greaterThanLabels = app.buttons.matching(identifier: "Condition, >")
        let jan2014Label = app.staticTexts["January 2014"]
        let municipalButton = app.buttons["Municipal, Street Light"]
        let streetLightCandidates = app.buttons.matching(identifier: "Street Light")
        
#if os(visionOS) || targetEnvironment(macCatalyst)
        let currentMonthYearOption = app.buttons[currentMonthYear]
        let equalsCondition = app.buttons["Condition, ="]
        let objectIDField = app.buttons["Field, Object ID"]
#else
        let currentMonthYearOption = app.staticTexts[currentMonthYear]
        let equalsCondition = app.staticTexts["="]
        let objectIDField = app.staticTexts["Object ID"]
#endif
        
#if targetEnvironment(macCatalyst)
        let condition1Options = app.popUpButtons["Condition 1 Options"]
        let dateInstalledButton = app.menuItems["date_installed"]
        let duplicateButton = app.menuItems["duplicate"]
        let greaterThanButton = app.menuItems[">"]
        let lessThanButton = app.menuItems["<"]
#else
        let condition1Options = app.buttons["Condition 1 Options"]
        let dateInstalledButton = app.buttons["Date Installed"]
        let duplicateButton = app.buttons["Duplicate"]
        let greaterThanButton = app.buttons[">"]
        let lessThanButton = app.buttons["<"]
#endif
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
        connectedFilterTitle.assertExistenceAndTap()
        
        addAssociationButton.assertExistenceAndTap()
        
        electricDistributionDeviceDataSourceButton.assertExistenceAndTap()
        
        municipalButton.assertExistenceAndTap()
        
        streetLightCandidates.firstMatch.assertExistence()
        
        XCTAssertTrue(streetLightCandidates.count > 3)
        
        filterButton.assertExistenceAndTap()
        
        addConditionButton.assertExistenceAndTap()
        
        objectIDField.assertExistenceAndTap()
        
        dateInstalledButton.assertExistenceAndTap()
        
        equalsCondition.assertExistenceAndTap()
        
        greaterThanButton.assertExistenceAndTap()
        
        datePicker1.assertExistenceAndTap()
        
#if os(visionOS)
        XCTExpectFailure("Opening the date picker's month & year picker doesn't work as expected on visionOS.")
        currentMonthYearLabel.assertExistenceAndTap()
#elseif targetEnvironment(macCatalyst)
        datePicker1.typeKey(.leftArrow, modifierFlags: .function)
        datePicker1.typeKey(.leftArrow, modifierFlags: .function)
        datePicker1.typeText("1")
        datePicker1.typeKey(.rightArrow, modifierFlags: .function)
        datePicker1.typeText("1")
        datePicker1.typeKey(.rightArrow, modifierFlags: .function)
        datePicker1.typeText("2014")
        datePicker1.typeKey(.return, modifierFlags: .function)
#else
        currentMonthYearLabel.assertExistenceAndTap()
        datePicker1.adjustPickerWheelElement(boundBy: 0, to: "January")
        datePicker1.adjustPickerWheelElement(boundBy: 1, to: "2014")
        dismissPopover.firstMatch.assertExistenceAndTap()
#endif
        
        condition1Options.assertExistenceAndTap()
        
        duplicateButton.assertExistenceAndTap()
        
        greaterThanLabels.element(boundBy: 1).assertExistenceAndTap()
        
        lessThanButton.assertExistenceAndTap()
        
        datePicker2.assertExistenceAndTap()
        
#if targetEnvironment(macCatalyst)
        datePicker2.typeKey(.leftArrow, modifierFlags: .function)
        datePicker2.typeKey(.leftArrow, modifierFlags: .function)
        datePicker2.typeText("3")
        datePicker2.typeKey(.return, modifierFlags: .function)
#else
        jan2014Label.assertExistenceAndTap()
        datePicker2.adjustPickerWheelElement(boundBy: 0, to: "March")
        dismissPopover.firstMatch.assertExistenceAndTap()
#endif
        
        app.doneButton.assertExistenceAndTap()
        
        streetLightCandidates.firstMatch.assertExistence()
        
        XCTAssertEqual(streetLightCandidates.count, 1)
    }
    
    func testCase_13_6() throws {
        let app = XCUIApplication()
        let addAssociationButton = app.staticTexts["Add Association"]
        let addButton = app.buttons["Add"]
        let addConditionButton = app.buttons["Add Condition"]
        let attachmentFilterTitle = app.staticTexts["Attachment"]
        let electricDistributionDevice2Button = app.buttons["Electric Distribution Device, 2"]
        let electricDistributionDeviceDataSourceButton = app.buttons["Electric Distribution Device"]
        let elementTitle = "Associations"
        let elementLabel = app.staticTexts[elementTitle]
        let textField = app.textFields["Enter a value"]
        let filterButton = app.buttons["Filter Candidates"]
        let formTitle = app.staticTexts["Structure Junction"]
        let municipalButton = app.buttons["Municipal, Street Light"]
        let popoverDismissRegion = app.otherElements["PopoverDismissRegion"].firstMatch
        let streetLightButton = app.buttons["Street Light"]
        let streetLightCandidates = app.buttons.matching(identifier: "Street Light")
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        
        elementLabel.assertExistence()
        
        attachmentFilterTitle.assertExistenceAndTap()
        
        addAssociationButton.assertExistenceAndTap()
        
        electricDistributionDeviceDataSourceButton.assertExistenceAndTap()
        
        municipalButton.assertExistenceAndTap()
        
        streetLightCandidates.firstMatch.assertExistence()
        
        XCTAssertTrue(streetLightCandidates.count > 3)
        
        filterButton.assertExistenceAndTap()
        
        addConditionButton.assertExistenceAndTap()
        
        textField.assertExistenceAndTap()
        
        textField.typeText("449")
        
        if popoverDismissRegion.exists {
            popoverDismissRegion.tap()
        }
        
        app.doneButton.assertExistenceAndTap()
        
        streetLightCandidates.firstMatch.assertExistence()
        
        XCTAssertEqual(streetLightCandidates.count, 1)
        
        streetLightButton.assertExistenceAndTap()
        
        addButton.assertExistenceAndTap()
        
        electricDistributionDevice2Button.assertExistence()
    }
    
    func testCase_14_1() throws {
        // Catalyst and visionOS don't have the same sample photos as iOS that
        // make this test possible.
        try skipIf(macCatalyst: true, visionOS: true)
        
        let app = XCUIApplication()
        let addAttachmentButton = app.buttons["Add Attachment"]
        let attachment1Label = app.staticTexts["Attachment1"]
        let chooseFromFilesButton = app.buttons["Choose From Files"]
        let chooseFromLibraryButton = app.buttons["Choose From Library"]
        let element1Title = "General - All Inputs"
        let element2Title = "General - Photo Only"
        let elementFooterValidationError = app.staticTexts["At least 1 attachment is required."]
        let formTitle = app.staticTexts["AttachmentsFormElement"]
        let maximumReachedMessage = app.staticTexts["The maximum number of attachments allowed is 2."]
        let photosPickerApp = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow.photospicker")
        let photoPickerPhoto1 = photosPickerApp.images["Photo, March 30, 2018, 12:14"]
        let photoPickerPhoto2 = photosPickerApp.images["Photo, August 08, 2012, 14:55"]
        let saveButton = app.buttons["Save"]
        let takePhotoOrVideoButton = app.buttons["Take Photo or Video"]
        let validationErrorsAlert = app.alerts["Validation Errors"]
        let validationErrorsAlertContinueButton = validationErrorsAlert.buttons["Continue Editing"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(element1Title)
        addAttachmentButton.assertExistenceAndTap()
        takePhotoOrVideoButton.assertExistence()
        chooseFromFilesButton.assertExistence()
        chooseFromLibraryButton.assertExistenceAndTap()
        photoPickerPhoto1.assertExistenceAndTap()
        addAttachmentButton.assertExistenceAndTap()
        chooseFromLibraryButton.assertExistenceAndTap()
        photoPickerPhoto2.assertExistenceAndTap()
        maximumReachedMessage.assertExistence()
        attachment1Label.assertNonExistence()
        app.filterElements(element2Title)
        saveButton.assertExistenceAndTap()
        validationErrorsAlert.assertExistence()
        validationErrorsAlertContinueButton.assertExistenceAndTap()
        elementFooterValidationError.assertExistence()
        addAttachmentButton.assertExistenceAndTap()
        chooseFromLibraryButton.assertExistenceAndTap()
        XCTExpectFailure("The photo picker is unresponsive to programatic taps after being presented a second time.")
        photoPickerPhoto1.assertExistenceAndTap()
        elementFooterValidationError.assertNonExistence()
        attachment1Label.assertExistence()
    }
    
    func testCase_14_2() throws {
        let app = XCUIApplication()
        
#if os(visionOS)
        let addAttachmentButton = app.collectionViews.buttons.staticTexts["Add Attachment"]
#else
        let addAttachmentButton = app.buttons["Add Attachment"]
#endif
        
#if targetEnvironment(macCatalyst)
        let chooseFromFilesButton = app.menuItems["choose_from_files"]
        let chooseFromLibraryButton = app.menuItems["choose_from_library"]
#else
        let chooseFromFilesButton = app.buttons["Choose From Files"]
        let chooseFromLibraryButton = app.buttons["Choose From Library"]
#endif
        
        let elementTitle = "Document"
        let formTitle = app.staticTexts["AttachmentsFormElement"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(elementTitle)
        addAttachmentButton.assertExistenceAndTap()
        chooseFromFilesButton.assertExistence()
        chooseFromLibraryButton.assertNonExistence()
    }
    
    func testCase_14_3() throws {
        // visionOS doesn't provide a way of dismissing the attachment import
        // menu which the test design calls for in two spots.
        try skipIf(visionOS: true)
        
        let app = XCUIApplication()
        let addAttachmentButton = app.buttons["Add Attachment"]
        
#if targetEnvironment(macCatalyst)
        let chooseFromFilesButton = app.menuItems["choose_from_files"]
        let chooseFromLibraryButton = app.menuItems["choose_from_library"]
        let takePhotoButton = app.menuItems["take_photo"]
#else
        let chooseFromFilesButton = app.buttons["Choose From Files"]
        let chooseFromLibraryButton = app.buttons["Choose From Library"]
        let takePhotoButton = app.buttons["Take Photo"]
#endif
        
        let dismissPopover = app.windows.containing(.other, identifier: "SystemInputAssistantView").firstMatch
        
        let element1Title = "Media - Photo - Any"
        let element2Title = "Media - Photo - Capture"
        let element3Title = "Media - Photo - Upload"
        let formTitle = app.staticTexts["AttachmentsFormElement"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(element1Title)
        addAttachmentButton.assertExistenceAndTap()
        takePhotoButton.assertExistence()
        chooseFromLibraryButton.assertExistence()
        chooseFromFilesButton.assertExistence()
        
#if targetEnvironment(macCatalyst)
        addAttachmentButton.assertExistenceAndTap()
#else
        dismissPopover.assertExistenceAndTap()
#endif
        
        app.filterElements(element2Title)
        addAttachmentButton.assertExistenceAndTap()
        takePhotoButton.assertExistence()
        chooseFromFilesButton.assertNonExistence()
        chooseFromLibraryButton.assertNonExistence()
        
#if targetEnvironment(macCatalyst)
        addAttachmentButton.assertExistenceAndTap()
#else
        dismissPopover.assertExistenceAndTap()
#endif
        
        app.filterElements(element3Title)
        addAttachmentButton.assertExistenceAndTap()
        takePhotoButton.assertNonExistence()
        chooseFromFilesButton.assertExistence()
        chooseFromLibraryButton.assertExistence()
    }
    
    func testCase_14_4() throws {
        // visionOS doesn't provide a way of dismissing the attachment import
        // menu which the test design calls for in two spots.
        try skipIf(visionOS: true)
        
        let app = XCUIApplication()
        let addAttachmentButton = app.buttons["Add Attachment"]
        
#if targetEnvironment(macCatalyst)
        let chooseFromFilesButton = app.menuItems["choose_from_files"]
        let chooseFromLibraryButton = app.menuItems["choose_from_library"]
        let takeVideoButton = app.menuItems["take_video"]
#else
        let chooseFromFilesButton = app.buttons["Choose From Files"]
        let chooseFromLibraryButton = app.buttons["Choose From Library"]
        let takeVideoButton = app.buttons["Take Video"]
#endif
        
        let dismissPopover = app.windows.containing(.other, identifier: "SystemInputAssistantView").firstMatch
        
        let element1Title = "Media - Video - Any"
        let element2Title = "Media - Video - Capture"
        let element3Title = "Media - Video - Upload"
        let formTitle = app.staticTexts["AttachmentsFormElement"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(element1Title)
        addAttachmentButton.assertExistenceAndTap()
        takeVideoButton.assertExistence()
        chooseFromLibraryButton.assertExistence()
        chooseFromFilesButton.assertExistence()
        
#if targetEnvironment(macCatalyst)
        addAttachmentButton.assertExistenceAndTap()
#else
        dismissPopover.assertExistenceAndTap()
#endif
        
        app.filterElements(element2Title)
        addAttachmentButton.assertExistenceAndTap()
        takeVideoButton.assertExistence()
        chooseFromFilesButton.assertNonExistence()
        chooseFromLibraryButton.assertNonExistence()
        
#if targetEnvironment(macCatalyst)
        addAttachmentButton.assertExistenceAndTap()
#else
        dismissPopover.assertExistenceAndTap()
#endif
        
        app.filterElements(element3Title)
        addAttachmentButton.assertExistenceAndTap()
        takeVideoButton.assertNonExistence()
        chooseFromFilesButton.assertExistence()
        chooseFromLibraryButton.assertExistence()
    }
    
    func testCase_14_5() throws {
        // visionOS doesn't provide a way of dismissing the attachment import
        // menu which the test design calls for in two spots.
        try skipIf(visionOS: true)
        
        let app = XCUIApplication()
        let addAttachmentButton = app.buttons["Add Attachment"]
        
#if targetEnvironment(macCatalyst)
        let chooseFromFilesButton = app.menuItems["choose_from_files"]
#else
        let chooseFromFilesButton = app.buttons["Choose From Files"]
#endif
        
        let dismissPopover = app.windows.containing(.other, identifier: "SystemInputAssistantView").firstMatch
        
        let element1Title = "Media - Audio - Any"
        let element2Title = "Media - Audio - Capture"
        let element3Title = "Media - Audio - Upload"
        let formTitle = app.staticTexts["AttachmentsFormElement"]
        
        openTestCase()
        assertFormOpened(titleElement: formTitle)
        
        app.filterElements(element1Title)
        addAttachmentButton.assertExistenceAndTap()
        chooseFromFilesButton.assertExistence()
        
#if targetEnvironment(macCatalyst)
        addAttachmentButton.assertExistenceAndTap()
#else
        dismissPopover.assertExistenceAndTap()
#endif
        
        app.filterElements(element2Title)
        addAttachmentButton.assertExistenceAndTap()
        chooseFromFilesButton.assertNonExistence()
        
#if targetEnvironment(macCatalyst)
        addAttachmentButton.assertExistenceAndTap()
#else
        dismissPopover.assertExistenceAndTap()
#endif
        
        app.filterElements(element3Title)
        addAttachmentButton.assertExistenceAndTap()
        chooseFromFilesButton.assertExistence()
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
    /// The app's "Done"/checkmark button.
    var doneButton: XCUIElement {
#if os(visionOS)
        buttons["Confirm"]
#else
        buttons["Done"]
#endif
    }
    
    /// The element filter field.
    var filterElementsField: XCUIElement {
        searchFields["Filter Elements"]
    }
    
    /// The "No value" combo box option.
    var noValueComboBoxOption: XCUIElement {
        buttons["No value Combo Box Option"]
    }
    
    /// Clears the element filter in the form.
    func clearElementFilter() {
        buttons["Clear text"].assertExistenceAndTap()
    }
    
    /// Filters the elements in the form.
    /// - Parameter text: The title of the form element to filter with.
    func filterElements(_ text: String) {
        filterElementsField.assertExistenceAndTap()
        
#if targetEnvironment(macCatalyst)
        let hasCurrentValue = !(filterElementsField.stringValue?.isEmpty ?? true)
#else
        let hasCurrentValue = filterElementsField.stringValue != filterElementsField.placeholderValue
#endif
        
        if hasCurrentValue {
            clearElementFilter()
            filterElementsField.assertExistenceAndTap()
        }
        
        filterElementsField.typeText(text)
    }
}

private extension XCUIElement {
    /// The element's value as a string.
    var stringValue: String? {
        value as? String
    }
}
