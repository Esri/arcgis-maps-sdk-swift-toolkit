***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import Combine
***REMOVED***
import XCTest
@testable ***REMOVED***Toolkit

class FloorFilterTests: XCTestCase {
***REMOVED******REMOVED***/ Applies credentials necessary to run tests.
***REMOVED***override func setUp() async throws {
***REMOVED******REMOVED***await addCredentials()
***REMOVED***

***REMOVED***private var cancellables = Set<AnyCancellable>()

***REMOVED******REMOVED***/ Tests general behavior of `FloorFilterViewModel`.
***REMOVED***func testFloorFilterViewModel() async {
***REMOVED******REMOVED***guard let map = await makeMap() else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***guard let floorManager = map.floorManager else {
***REMOVED******REMOVED******REMOVED***XCTFail("No FloorManager available")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***let viewModel = await FloorFilterViewModel(floorManager: floorManager)
***REMOVED******REMOVED***let expectation = XCTestExpectation(
***REMOVED******REMOVED******REMOVED***description: "View model successfully initialized"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await viewModel.$isLoading
***REMOVED******REMOVED******REMOVED***.sink { loading in
***REMOVED******REMOVED******REMOVED******REMOVED***if !loading {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***expectation.fulfill()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.store(in: &cancellables)
***REMOVED******REMOVED***wait(for: [expectation], timeout: 10.0)
***REMOVED***

***REMOVED******REMOVED***/ Get a map constructed from an ArcGIS portal item.
***REMOVED******REMOVED***/ - Returns: A map constructed from an ArcGIS portal item.
***REMOVED***private func makeMap() async -> Map? {
***REMOVED******REMOVED******REMOVED*** Multiple sites/facilities: Esri IST map with all buildings.
***REMOVED******REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***indoors.maps.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "49520a67773842f1858602735ef538b5")!)

***REMOVED******REMOVED******REMOVED*** Redlands Campus map with multiple sites and facilities.
***REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "7687805bd42549f5ba41237443d0c60a")!)

***REMOVED******REMOVED******REMOVED*** Single site (ESRI Redlands Main) and facility (Building L).
***REMOVED******REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***indoors.maps.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "f133a698536f44c8884ad81f80b6cfc7")!)

***REMOVED******REMOVED***let map = Map(item: portalItem)
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***XCTFail("\(#fileID), \(#function), \(#line), \(error.localizedDescription)")
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED******REMOVED***guard map.loadStatus == .loaded else {
***REMOVED******REMOVED******REMOVED***XCTFail("\(#fileID), \(#function), \(#line), Map not loaded")
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED******REMOVED***return map
***REMOVED***
***REMOVED***
