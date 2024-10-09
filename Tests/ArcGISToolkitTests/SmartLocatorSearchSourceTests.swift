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

#if !os(visionOS)
import XCTest
import ArcGIS
import ArcGISToolkit

final class SmartLocatorSearchSourceTests: XCTestCase {
    func testRepeatSearchResultThreshold() async throws {
        let locator = SmartLocatorSearchSource()
        
        // Threshold of nil means no re-query.
        locator.repeatSearchResultThreshold = nil
        var searchResults = try await locator.search(
            "Dunkin' Donuts",
            searchArea: Envelope.edinburgh
        )
        var results = try XCTUnwrap(searchResults)
        XCTAssertEqual(results, [])
        
        // Threshold of 1+ means requery with fewer restrictions
        locator.repeatSearchResultThreshold = 1
        searchResults = try await locator.search(
            "Dunkin' Donuts",
            searchArea: Envelope.edinburgh
        )
        results = try XCTUnwrap(searchResults)
        XCTAssertNotEqual(results, [])
    }
    
    func testRepeatSuggestResultThreshold() async throws {
        let locator = SmartLocatorSearchSource()

        // Threshold of nil means no re-query.
        locator.repeatSuggestResultThreshold = nil
        var suggestResults = try await locator.suggest(
            "Dunkin' Donuts",
            searchArea: Envelope.edinburgh
        )
        var results = try XCTUnwrap(suggestResults)
        XCTAssertEqual(results, [])
        
        // Threshold of 1 -> requery with fewer restrictions
        locator.repeatSuggestResultThreshold = 1
        suggestResults = try await locator.suggest(
            "Dunkin' Donuts",
            searchArea: Envelope.edinburgh
        )
        results = try XCTUnwrap(suggestResults)
        XCTAssertNotEqual(suggestResults, [])
    }
}

private extension Envelope {
    static let edinburgh = Envelope(
        xRange: -365155.60783391213 ... -347494.47622280417,
        yRange: 7536778.456812576...7559866.706991681
    )
}
#endif
