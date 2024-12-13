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

import Testing
***REMOVED***
@testable ***REMOVED***Toolkit

@Suite("LocationButton Tests")
struct LocationButtonTests {
***REMOVED***@Test
***REMOVED***@MainActor
***REMOVED***func testInit() async throws {
***REMOVED******REMOVED***let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let model = LocationButton.Model(
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay: locationDisplay
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***#expect(model.locationDisplay === locationDisplay)
***REMOVED******REMOVED******REMOVED***#expect(model.autoPanOptions == [.compassNavigation, .off, .navigation, .recenter])
***REMOVED******REMOVED******REMOVED***#expect(model.lastSelectedAutoPanMode == .recenter)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let model = LocationButton.Model(
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay: locationDisplay,
***REMOVED******REMOVED******REMOVED******REMOVED***autoPanOptions: [.recenter]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***#expect(model.autoPanOptions == [.recenter])
***REMOVED******REMOVED******REMOVED***#expect(model.lastSelectedAutoPanMode == .recenter)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let model = LocationButton.Model(
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay: locationDisplay,
***REMOVED******REMOVED******REMOVED******REMOVED***autoPanOptions: []
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***#expect(model.autoPanOptions == [])
***REMOVED******REMOVED******REMOVED***#expect(model.lastSelectedAutoPanMode == .off)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let model = LocationButton.Model(
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay: locationDisplay,
***REMOVED******REMOVED******REMOVED******REMOVED***autoPanOptions: [.off, .recenter]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***#expect(model.autoPanOptions == [.off, .recenter])
***REMOVED******REMOVED******REMOVED***#expect(model.lastSelectedAutoPanMode == .recenter)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***let model = LocationButton.Model(
***REMOVED******REMOVED******REMOVED******REMOVED***locationDisplay: locationDisplay,
***REMOVED******REMOVED******REMOVED******REMOVED***autoPanOptions: [.off]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***#expect(model.autoPanOptions == [.off])
***REMOVED******REMOVED******REMOVED***#expect(model.lastSelectedAutoPanMode == .off)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@Test
***REMOVED***@MainActor
***REMOVED***func testSelectAutoPanMode() async throws {
***REMOVED******REMOVED***let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = LocationButton.Model(
***REMOVED******REMOVED******REMOVED***locationDisplay: locationDisplay
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.select(autoPanMode: .compassNavigation)
***REMOVED******REMOVED***#expect(model.locationDisplay.autoPanMode == .compassNavigation)
***REMOVED******REMOVED***#expect(model.lastSelectedAutoPanMode == .compassNavigation)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.select(autoPanMode: .off)
***REMOVED******REMOVED***#expect(model.locationDisplay.autoPanMode == .off)
***REMOVED******REMOVED***#expect(model.lastSelectedAutoPanMode == .compassNavigation)
***REMOVED***
***REMOVED***

private typealias MockLocationDataSource = CustomLocationDataSource<MockLocationProvider>

extension MockLocationDataSource {
***REMOVED***convenience init() {
***REMOVED******REMOVED***self.init { MockLocationProvider() ***REMOVED***
***REMOVED***
***REMOVED***

private struct MockLocationProvider: LocationProvider {
***REMOVED***var locations: AsyncThrowingStream<Location, Error> {
***REMOVED******REMOVED***.init { return nil ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var headings: AsyncThrowingStream<Double, Error> {
***REMOVED******REMOVED***.init { return nil ***REMOVED***
***REMOVED***
***REMOVED***
