// Copyright 2021 Esri
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
import ArcGIS
import ArcGISToolkit

@MainActor
final class LocatorSearchSourceTests: XCTestCase {
    func testMaximumResults() async throws {
        let locator = LocatorSearchSource()
        locator.maximumResults = 4
        XCTAssertEqual(locator.maximumResults, 4)
        
        var searchResults = try await locator.search("Coffee")
        XCTAssertEqual(searchResults.count, 4)
        
        locator.maximumResults = 12
        searchResults = try await locator.search("Coffee")
        XCTAssertEqual(searchResults.count, 12)
        
        // Set property directly on geocode parameters.
        locator.geocodeParameters.maxResults = 2
        XCTAssertEqual(locator.geocodeParameters.maxResults, 2)
        XCTAssertEqual(locator.maximumResults, 2)
        searchResults = try await locator.search("Coffee")
        XCTAssertEqual(searchResults.count, 2)
    }
    
    func testMaximumSuggestions() async throws {
        let locator = LocatorSearchSource()
        locator.maximumSuggestions = 4
        XCTAssertEqual(locator.maximumSuggestions, 4)
        
        var suggestResults = try await locator.suggest("Coffee")
        XCTAssertEqual(suggestResults.count, 4)
        
        locator.maximumSuggestions = 12
        suggestResults = try await locator.suggest("Coffee")
        XCTAssertEqual(suggestResults.count, 12)
        
        // Set property directly on suggest parameters.
        locator.suggestParameters.maxResults = 2
        XCTAssertEqual(locator.suggestParameters.maxResults, 2)
        XCTAssertEqual(locator.maximumSuggestions, 2)
        suggestResults = try await locator.suggest("Coffee")
        XCTAssertEqual(suggestResults.count, 2)
    }
}
