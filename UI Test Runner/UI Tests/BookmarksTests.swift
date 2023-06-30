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

final class BookmarksTests: XCTestCase {
***REMOVED***override func setUpWithError() throws {
***REMOVED******REMOVED***continueAfterFailure = false
***REMOVED***
***REMOVED***
***REMOVED***func testOpenBookmarks() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***let bookmarksTestButton = app.buttons["Bookmarks Tests"]
***REMOVED******REMOVED***bookmarksTestButton.tap()
***REMOVED***
***REMOVED***
