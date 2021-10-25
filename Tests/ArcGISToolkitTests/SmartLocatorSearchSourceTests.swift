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

import Foundation

import XCTest
***REMOVED***
***REMOVED***Toolkit
***REMOVED***

class SmartLocatorSearchSourceTests: XCTestCase {
***REMOVED***func testRepeatSearchResultThreshold() async throws {
***REMOVED******REMOVED***let locator = SmartLocatorSearchSource()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Threshold of 0 means no re-query.
***REMOVED******REMOVED***locator.repeatSearchResultThreshold = 0
***REMOVED******REMOVED***var searchResults = try await locator.search(
***REMOVED******REMOVED******REMOVED***"Dunkin' Donuts",
***REMOVED******REMOVED******REMOVED***searchArea: Envelope.edinburgh,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: nil
***REMOVED******REMOVED***)
***REMOVED******REMOVED***var results = try XCTUnwrap(searchResults)
***REMOVED******REMOVED***XCTAssertEqual(results.count, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Threshold of 1+ means requery with fewer restrictions
***REMOVED******REMOVED***locator.repeatSearchResultThreshold = 1
***REMOVED******REMOVED***searchResults = try await locator.search(
***REMOVED******REMOVED******REMOVED***"Dunkin' Donuts",
***REMOVED******REMOVED******REMOVED***searchArea: Envelope.edinburgh,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: nil
***REMOVED******REMOVED***)
***REMOVED******REMOVED***results = try XCTUnwrap(searchResults)
***REMOVED******REMOVED***XCTAssertGreaterThanOrEqual(results.count, 1)
***REMOVED***
***REMOVED***
***REMOVED***func testRepeatSuggestResultThreshold() async throws {
***REMOVED******REMOVED***let locator = SmartLocatorSearchSource()

***REMOVED******REMOVED******REMOVED*** Threshold of 0 means no re-query.
***REMOVED******REMOVED***locator.repeatSuggestResultThreshold = 0
***REMOVED******REMOVED***var suggestResults = try await locator.suggest(
***REMOVED******REMOVED******REMOVED***"Dunkin' Donuts",
***REMOVED******REMOVED******REMOVED***searchArea: Envelope.edinburgh,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: nil
***REMOVED******REMOVED***)
***REMOVED******REMOVED***var results = try XCTUnwrap(suggestResults)
***REMOVED******REMOVED***XCTAssertEqual(results.count, 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Threshold of 1 -> requery with fewer restrictions
***REMOVED******REMOVED***locator.repeatSuggestResultThreshold = 1
***REMOVED******REMOVED***suggestResults = try await locator.suggest(
***REMOVED******REMOVED******REMOVED***"Dunkin' Donuts",
***REMOVED******REMOVED******REMOVED***searchArea: Envelope.edinburgh,
***REMOVED******REMOVED******REMOVED***preferredSearchLocation: nil
***REMOVED******REMOVED***)
***REMOVED******REMOVED***results = try XCTUnwrap(suggestResults)
***REMOVED******REMOVED***XCTAssertGreaterThanOrEqual(results.count, 1)
***REMOVED***
***REMOVED***

extension Envelope {
***REMOVED***static let edinburgh = Envelope(
***REMOVED******REMOVED***xMin: -365155.60783391213,
***REMOVED******REMOVED***yMin: 7536778.456812576,
***REMOVED******REMOVED***xMax: -347494.47622280417,
***REMOVED******REMOVED***yMax: 7559866.706991681
***REMOVED***)
***REMOVED***
