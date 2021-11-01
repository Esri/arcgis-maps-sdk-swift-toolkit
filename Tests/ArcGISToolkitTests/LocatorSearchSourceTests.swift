***REMOVED***.

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
***REMOVED***
***REMOVED***Toolkit

class LocatorSearchSourceTests: XCTestCase {
***REMOVED***func testMaximumResults() async throws {
***REMOVED******REMOVED***let locator = LocatorSearchSource()
***REMOVED******REMOVED***locator.maximumResults = 4
***REMOVED******REMOVED***XCTAssertEqual(locator.maximumResults, 4)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var searchResults = try await locator.search(
***REMOVED******REMOVED******REMOVED***"Coffee",
***REMOVED******REMOVED******REMOVED***searchArea: nil,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: nil
***REMOVED******REMOVED***)
***REMOVED******REMOVED***var results = try XCTUnwrap(searchResults)
***REMOVED******REMOVED***XCTAssertEqual(results.count, 4)
***REMOVED******REMOVED***
***REMOVED******REMOVED***locator.maximumResults = 12
***REMOVED******REMOVED***searchResults = try await locator.search(
***REMOVED******REMOVED******REMOVED***"Coffee",
***REMOVED******REMOVED******REMOVED***searchArea: nil,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: nil
***REMOVED******REMOVED***)
***REMOVED******REMOVED***results = try XCTUnwrap(searchResults)
***REMOVED******REMOVED***XCTAssertEqual(results.count, 12)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set property directly on geocode parameters.
***REMOVED******REMOVED***locator.geocodeParameters.maxResults = 2
***REMOVED******REMOVED***XCTAssertEqual(Int(locator.geocodeParameters.maxResults), 2)
***REMOVED******REMOVED***XCTAssertEqual(locator.maximumResults, 2)
***REMOVED******REMOVED***searchResults = try await locator.search(
***REMOVED******REMOVED******REMOVED***"Coffee",
***REMOVED******REMOVED******REMOVED***searchArea: nil,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: nil
***REMOVED******REMOVED***)
***REMOVED******REMOVED***results = try XCTUnwrap(searchResults)
***REMOVED******REMOVED***XCTAssertEqual(results.count, 2)
***REMOVED***
***REMOVED***
***REMOVED***func testMaximumSuggestions() async throws {
***REMOVED******REMOVED***let locator = LocatorSearchSource()
***REMOVED******REMOVED***locator.maximumSuggestions = 4
***REMOVED******REMOVED***XCTAssertEqual(locator.maximumSuggestions, 4)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var suggestResults = try await locator.suggest(
***REMOVED******REMOVED******REMOVED***"Coffee",
***REMOVED******REMOVED******REMOVED***searchArea: nil,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: nil
***REMOVED******REMOVED***)
***REMOVED******REMOVED***var results = try XCTUnwrap(suggestResults)
***REMOVED******REMOVED***XCTAssertEqual(results.count, 4)
***REMOVED******REMOVED***
***REMOVED******REMOVED***locator.maximumSuggestions = 12
***REMOVED******REMOVED***suggestResults = try await locator.suggest(
***REMOVED******REMOVED******REMOVED***"Coffee",
***REMOVED******REMOVED******REMOVED***searchArea: nil,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: nil
***REMOVED******REMOVED***)
***REMOVED******REMOVED***results = try XCTUnwrap(suggestResults)
***REMOVED******REMOVED***XCTAssertEqual(results.count, 12)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set property directly on suggest parameters.
***REMOVED******REMOVED***locator.suggestParameters.maxResults = 2
***REMOVED******REMOVED***XCTAssertEqual(Int(locator.suggestParameters.maxResults), 2)
***REMOVED******REMOVED***XCTAssertEqual(locator.maximumSuggestions, 2)
***REMOVED******REMOVED***suggestResults = try await locator.suggest(
***REMOVED******REMOVED******REMOVED***"Coffee",
***REMOVED******REMOVED******REMOVED***searchArea: nil,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: nil
***REMOVED******REMOVED***)
***REMOVED******REMOVED***results = try XCTUnwrap(suggestResults)
***REMOVED******REMOVED***XCTAssertEqual(results.count, 2)
***REMOVED***
***REMOVED***
