// Copyright 2021 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

import XCTest
import ArcGIS
import ArcGISToolkit
import SwiftUI

class SmartLocatorSearchSourceTests: XCTestCase {
    func testRepeatSearchResultThreshold() async throws {
        let locator = SmartLocatorSearchSource()
        locator.searchArea = Envelope.edinburgh
        
        // Threshold of 0 means no re-query.
        locator.repeatSearchResultThreshold = 0
        var searchResults = try await locator.search(
            "Dunkin' Donuts"
        )
        var results = try XCTUnwrap(searchResults)
        XCTAssertEqual(results.count, 0)
        
        // Threshold of 1+ means requery with fewer restrictions
        locator.repeatSearchResultThreshold = 1
        searchResults = try await locator.search(
            "Dunkin' Donuts"
        )
        results = try XCTUnwrap(searchResults)
        XCTAssertGreaterThanOrEqual(results.count, 1)
    }
    
    func testRepeatSuggestResultThreshold() async throws {
        let locator = SmartLocatorSearchSource()
        locator.searchArea = Envelope.edinburgh
        
        // Threshold of 0 means no re-query.
        locator.repeatSuggestResultThreshold = 0
        var suggestResults = try await locator.suggest(
            "Dunkin' Donuts"
        )
        var results = try XCTUnwrap(suggestResults)
        XCTAssertEqual(results.count, 0)
        
        // Threshold of 1 -> requery with fewer restrictions
        locator.repeatSuggestResultThreshold = 1
        suggestResults = try await locator.suggest(
            "Dunkin' Donuts"
        )
        results = try XCTUnwrap(suggestResults)
        XCTAssertGreaterThanOrEqual(results.count, 1)
    }
    
    func testLocalLocatorTask() async throws {
        let locatorTask = LocatorTask(url: URL(fileURLWithPath: "/Users/mark1113/san-diego/SanDiego_StreetAddress.loc/"));
        let locator = SmartLocatorSearchSource(locatorTask: locatorTask)
        
        let suggestResults = try await locator.suggest("Coffee")
        let suggestions = try XCTUnwrap(suggestResults)
        XCTAssertEqual(suggestions.count, 3)

        let searchResults = try await locator.search("Hotel")
        let results = try XCTUnwrap(searchResults)
        XCTAssertEqual(results.count, 2)
    }

}

extension Envelope {
    static let edinburgh = Envelope(
        xMin: -365155.60783391213,
        yMin: 7536778.456812576,
        xMax: -347494.47622280417,
        yMax: 7559866.706991681
    )
}
