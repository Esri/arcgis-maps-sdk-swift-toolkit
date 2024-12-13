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
***REMOVED***
@testable ***REMOVED***Toolkit

final class LocationButtonTests: XCTestCase {
***REMOVED******REMOVED***/ Tests the initializer.
***REMOVED***@MainActor
***REMOVED***func testInit() {
***REMOVED******REMOVED***let locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let model = LocationButton.Model(
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay: locationDisplay
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***XCTAssertIdentical(model.locationDisplay, locationDisplay)
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(model.autoPanOptions, [.compassNavigation, .off, .navigation, .recenter])
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(model.lastSelectedAutoPanMode, .recenter)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let model = LocationButton.Model(
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay: locationDisplay,
***REMOVED******REMOVED******REMOVED******REMOVED***autoPanOptions: [.recenter]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(model.autoPanOptions, [.recenter])
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(model.lastSelectedAutoPanMode, .recenter)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let model = LocationButton.Model(
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay: locationDisplay,
***REMOVED******REMOVED******REMOVED******REMOVED***autoPanOptions: []
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(model.autoPanOptions, [])
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(model.lastSelectedAutoPanMode, .off)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let model = LocationButton.Model(
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay: locationDisplay,
***REMOVED******REMOVED******REMOVED******REMOVED***autoPanOptions: [.off, .recenter]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(model.autoPanOptions, [.off, .recenter])
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(model.lastSelectedAutoPanMode, .recenter)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let model = LocationButton.Model(
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay: locationDisplay,
***REMOVED******REMOVED******REMOVED******REMOVED***autoPanOptions: [.off]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(model.autoPanOptions, [.off])
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(model.lastSelectedAutoPanMode, .off)
***REMOVED***
***REMOVED***
***REMOVED***
