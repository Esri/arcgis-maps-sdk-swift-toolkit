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

@MainActor
final class BasemapGalleryTests: XCTestCase {
***REMOVED***override func setUpWithError() throws {
***REMOVED******REMOVED***continueAfterFailure = false
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test general usage of the Basemap Gallery component.
***REMOVED***func testBasemapGallery() throws {
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let basemapGalleryTestsButton = app.buttons["Basemap Gallery Tests"]
***REMOVED******REMOVED***let openStreetMapBlueprintButton = app.buttons["OpenStreetMap (Blueprint)"]
***REMOVED******REMOVED***let nationalGeographicStyleMapButton = app.buttons["National Geographic Style Map"]
***REMOVED******REMOVED***let worldImageryButton = app.buttons["World_Imagery (WGS 84)"]
***REMOVED******REMOVED***let spatialReferenceErrorText = app.staticTexts["Spatial reference mismatch."]
***REMOVED******REMOVED***let okButton = app.buttons["OK"]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Open the Basemap Gallery component test view.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***basemapGalleryTestsButton.exists,
***REMOVED******REMOVED******REMOVED***"The Basemap Gallery Tests button wasn't found."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***basemapGalleryTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Select two basemaps that should open without error.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***openStreetMapBlueprintButton.waitForExistence(timeout: 2),
***REMOVED******REMOVED******REMOVED***"The OpenStreetMap (Blueprint) button wasn't found within 2 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***openStreetMapBlueprintButton.tap()
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***nationalGeographicStyleMapButton.exists,
***REMOVED******REMOVED******REMOVED***"The National Geographic Style Map button wasn't found."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***nationalGeographicStyleMapButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Select a basemap that will trigger an error.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***worldImageryButton.exists,
***REMOVED******REMOVED******REMOVED***"The World Imagery button wasn't found."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***worldImageryButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify that a spatial reference error was presented after a few moments.
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***spatialReferenceErrorText.waitForExistence(timeout: 2),
***REMOVED******REMOVED******REMOVED***"The spatial reference error text wasn't found within 2 seconds."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Dismiss the error.
***REMOVED******REMOVED***XCTAssertTrue(okButton.exists, "The OK button wasn't found.")
***REMOVED******REMOVED***okButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Verify that a spatial reference error was dismissed.
***REMOVED******REMOVED***XCTAssertFalse(
***REMOVED******REMOVED******REMOVED***spatialReferenceErrorText.exists,
***REMOVED******REMOVED******REMOVED***"The spatial reference error text was unexpectedly found after dismissing the error."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
