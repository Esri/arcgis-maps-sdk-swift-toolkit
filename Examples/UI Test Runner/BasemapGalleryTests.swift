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

final class BasemapGalleryTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    /// Test general usage of the Basemap Gallery component.
    func testBasemapGallery() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Open the GeoView examples category.
        app.buttons["GeoView"].tap()
        
        // Open the Basemap Gallery component example view.
        app.buttons["Basemap Gallery"].tap()
        
        // Open the Basemap Gallery.
        app.buttons["Show base map"].tap()
        
        // Select two basemaps that should open without error.
        app.buttons["OpenStreetMap (Blueprint)"].tap()
        app.buttons["National Geographic Style Map"].tap()
        
        // Select a basemap that will trigger an error.
        app.buttons["World_Imagery (WGS 84)"].tap()
        
        // Verify that a spatial reference error was presented after a few moments.
        XCTAssertTrue(
            app.staticTexts["Spatial reference mismatch."]
                .waitForExistence(timeout: 2)
        )
        
        // Dismiss the error.
        app.buttons["OK"].tap()
    }
}
