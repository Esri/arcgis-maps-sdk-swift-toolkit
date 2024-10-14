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
final class BasemapGalleryTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Test general usage of the Basemap Gallery component.
    func testBasemapGallery() throws {
        let app = XCUIApplication()
        app.launch()
        
        let basemapGalleryTestsButton = app.buttons["Basemap Gallery Tests"]
        let openStreetMapBlueprintButton = app.buttons["OpenStreetMap (Blueprint)"]
        let nationalGeographicStyleMapButton = app.buttons["National Geographic Style Map"]
        let worldImageryButton = app.buttons["World_Imagery (WGS 84)"]
        let spatialReferenceErrorText = app.staticTexts["Spatial reference mismatch."]
        let okButton = app.buttons["OK"]
        
        // Open the Basemap Gallery component test view.
        XCTAssertTrue(
            basemapGalleryTestsButton.exists,
            "The Basemap Gallery Tests button wasn't found."
        )
        basemapGalleryTestsButton.tap()
        
        // Select two basemaps that should open without error.
        XCTAssertTrue(
            openStreetMapBlueprintButton.waitForExistence(timeout: 2),
            "The OpenStreetMap (Blueprint) button wasn't found within 2 seconds."
        )
        openStreetMapBlueprintButton.tap()
        XCTAssertTrue(
            nationalGeographicStyleMapButton.exists,
            "The National Geographic Style Map button wasn't found."
        )
        nationalGeographicStyleMapButton.tap()
        
        // Select a basemap that will trigger an error.
        XCTAssertTrue(
            worldImageryButton.exists,
            "The World Imagery button wasn't found."
        )
        worldImageryButton.tap()
        
        // Verify that a spatial reference error was presented after a few moments.
        XCTAssertTrue(
            spatialReferenceErrorText.waitForExistence(timeout: 2),
            "The spatial reference error text wasn't found within 2 seconds."
        )
        
        // Dismiss the error.
        XCTAssertTrue(okButton.exists, "The OK button wasn't found.")
        okButton.tap()
        
        // Verify that a spatial reference error was dismissed.
        XCTAssertFalse(
            spatialReferenceErrorText.exists,
            "The spatial reference error text was unexpectedly found after dismissing the error."
        )
    }
}
