***REMOVED*** Copyright 2024 Esri
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

final class RepresentedUITextViewTests: XCTestCase {
***REMOVED***func testInit() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let boundValue = app.staticTexts["Bound Value"]
***REMOVED******REMOVED***let textView = app.textViews["Text View"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***app.buttons["RepresentedUITextView Tests"].tap()
***REMOVED******REMOVED***app.buttons["TestInit"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(boundValue.label, "World!")
***REMOVED******REMOVED***
***REMOVED******REMOVED***textView.tap()
***REMOVED******REMOVED***textView.typeText("Hello, ")
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(boundValue.label, "Hello, World!")
***REMOVED***
***REMOVED***
***REMOVED***func testInitWithActions() {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let boundValue = app.staticTexts["Bound Value"]
***REMOVED******REMOVED***let endValue = app.staticTexts["End Value"]
***REMOVED******REMOVED***let textView = app.textViews["Text View"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***app.buttons["RepresentedUITextView Tests"].tap()
***REMOVED******REMOVED***app.buttons["TestInitWithActions"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(boundValue.label, "World!")
***REMOVED******REMOVED***
***REMOVED******REMOVED***textView.tap()
***REMOVED******REMOVED***textView.typeText("Hello, ")
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(boundValue.label, "Hello, World!")
***REMOVED******REMOVED***XCTAssertEqual(endValue.label, "")
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.buttons["End Editing"].tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(endValue.label, "Hello, World!")
***REMOVED***
***REMOVED***
