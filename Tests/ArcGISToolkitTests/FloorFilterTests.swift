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

***REMOVED******REMOVED***/ Tests that a `FloorFilterViewModel` succesfully initializes with a `FloorManager`.`
***REMOVED***func testInitFloorFilterViewModelWithFloorManager() async {
***REMOVED******REMOVED***guard let map = await makeMap(),
***REMOVED******REMOVED******REMOVED***  let floorManager = map.floorManager else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***let viewModel = await FloorFilterViewModel(floorManager: floorManager)
***REMOVED******REMOVED***await verifyInitialization(viewModel)
***REMOVED******REMOVED***let sites = await viewModel.sites
***REMOVED******REMOVED***let facilities = await viewModel.facilities
***REMOVED******REMOVED***let levels = await viewModel.levels
***REMOVED******REMOVED***XCTAssertFalse(sites.isEmpty)
***REMOVED******REMOVED***XCTAssertFalse(facilities.isEmpty)
***REMOVED******REMOVED***XCTAssertFalse(levels.isEmpty)
***REMOVED***

***REMOVED******REMOVED***/ Tests that a `FloorFilterViewModel` succesfully initializes with a `FloorManager` and
***REMOVED******REMOVED***/ `Binding<Viewpoint>?`.`
***REMOVED***func testInitFloorFilterViewModelWithFloorManagerAndViewpoint() async {
***REMOVED******REMOVED***guard let map = await makeMap(),
***REMOVED******REMOVED******REMOVED***  let floorManager = map.floorManager else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***var _viewpoint: Viewpoint = getViewpoint(.zero)
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = await FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await verifyInitialization(viewModel)
***REMOVED******REMOVED***let sites = await viewModel.sites
***REMOVED******REMOVED***let facilities = await viewModel.facilities
***REMOVED******REMOVED***let levels = await viewModel.levels
***REMOVED******REMOVED***let vmViewpoint = await viewModel.viewpoint
***REMOVED******REMOVED***XCTAssertFalse(sites.isEmpty)
***REMOVED******REMOVED***XCTAssertFalse(facilities.isEmpty)
***REMOVED******REMOVED***XCTAssertFalse(levels.isEmpty)
***REMOVED******REMOVED***XCTAssertNotNil(vmViewpoint)
***REMOVED***

***REMOVED******REMOVED***/ Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
***REMOVED***func testSetSite() async {
***REMOVED******REMOVED***guard let map = await makeMap(),
***REMOVED******REMOVED******REMOVED***  let floorManager = map.floorManager else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***let initialViewpoint = getViewpoint(.zero)
***REMOVED******REMOVED***var _viewpoint = initialViewpoint
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = await FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await verifyInitialization(viewModel)
***REMOVED******REMOVED***let site = await viewModel.sites.first
***REMOVED******REMOVED***await viewModel.setSite(site)
***REMOVED******REMOVED***let selectedSite = await viewModel.selectedSite
***REMOVED******REMOVED***let selectedFacility = await viewModel.selectedFacility
***REMOVED******REMOVED***let selectedLevel = await viewModel.selectedLevel
***REMOVED******REMOVED***XCTAssertEqual(selectedSite, site)
***REMOVED******REMOVED***XCTAssertNil(selectedFacility)
***REMOVED******REMOVED***XCTAssertNil(selectedLevel)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***_viewpoint.targetGeometry.extent.center.x,
***REMOVED******REMOVED******REMOVED***initialViewpoint.targetGeometry.extent.center.x
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await viewModel.setSite(site, zoomTo: true)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***_viewpoint.targetGeometry.extent.center.x,
***REMOVED******REMOVED******REMOVED***selectedSite?.geometry?.extent.center.x
***REMOVED******REMOVED***)
***REMOVED***

***REMOVED******REMOVED***/ Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
***REMOVED***func testSetFacility() async {
***REMOVED******REMOVED***guard let map = await makeMap(),
***REMOVED******REMOVED******REMOVED***  let floorManager = map.floorManager else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***let initialViewpoint = getViewpoint(.zero)
***REMOVED******REMOVED***var _viewpoint = initialViewpoint
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = await FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await verifyInitialization(viewModel)
***REMOVED******REMOVED***let facility = await viewModel.facilities.first
***REMOVED******REMOVED***await viewModel.setFacility(facility)
***REMOVED******REMOVED***let selectedSite = await viewModel.selectedSite
***REMOVED******REMOVED***let selectedFacility = await viewModel.selectedFacility
***REMOVED******REMOVED***let selectedLevel = await viewModel.selectedLevel
***REMOVED******REMOVED***let defaultLevel = await viewModel.defaultLevel(for: selectedFacility)
***REMOVED******REMOVED***XCTAssertEqual(selectedSite, selectedFacility?.site)
***REMOVED******REMOVED***XCTAssertEqual(selectedFacility, facility)
***REMOVED******REMOVED***XCTAssertEqual(selectedLevel, defaultLevel)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***_viewpoint.targetGeometry.extent.center.x,
***REMOVED******REMOVED******REMOVED***initialViewpoint.targetGeometry.extent.center.x
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await viewModel.setFacility(facility, zoomTo: true)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***_viewpoint.targetGeometry.extent.center.x,
***REMOVED******REMOVED******REMOVED***selectedFacility?.geometry?.extent.center.x
***REMOVED******REMOVED***)
***REMOVED***

***REMOVED******REMOVED***/ Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
***REMOVED***func testSetLevel() async {
***REMOVED******REMOVED***guard let map = await makeMap(),
***REMOVED******REMOVED******REMOVED***  let floorManager = map.floorManager else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***let initialViewpoint = getViewpoint(.zero)
***REMOVED******REMOVED***var _viewpoint = initialViewpoint
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = await FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***await verifyInitialization(viewModel)
***REMOVED******REMOVED***let levels = await viewModel.levels
***REMOVED******REMOVED***let level = levels.first
***REMOVED******REMOVED***await viewModel.setLevel(level)
***REMOVED******REMOVED***let selectedSite = await viewModel.selectedSite
***REMOVED******REMOVED***let selectedFacility = await viewModel.selectedFacility
***REMOVED******REMOVED***let selectedLevel = await viewModel.selectedLevel
***REMOVED******REMOVED***XCTAssertEqual(selectedSite, selectedFacility?.site)
***REMOVED******REMOVED***XCTAssertEqual(selectedFacility, level?.facility)
***REMOVED******REMOVED***XCTAssertEqual(selectedLevel, level)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***_viewpoint.targetGeometry.extent.center.x,
***REMOVED******REMOVED******REMOVED***initialViewpoint.targetGeometry.extent.center.x
***REMOVED******REMOVED***)
***REMOVED******REMOVED***levels.forEach { level in
***REMOVED******REMOVED******REMOVED***if level.verticalOrder == selectedLevel?.verticalOrder {
***REMOVED******REMOVED******REMOVED******REMOVED***XCTAssertTrue(level.isVisible)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***XCTAssertFalse(level.isVisible)
***REMOVED******REMOVED***
***REMOVED***
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
***REMOVED******REMOVED***return map
***REMOVED***

***REMOVED******REMOVED***/ Verifies that the `FloorFilterViewModel` has succesfully initialized.
***REMOVED******REMOVED***/ - Parameter viewModel: The view model to analyze.
***REMOVED***private func verifyInitialization(_ viewModel: FloorFilterViewModel) async {
***REMOVED******REMOVED***let expectation = XCTestExpectation(
***REMOVED******REMOVED******REMOVED***description: "View model successfully initialized"
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let subscription = await viewModel.$isLoading
***REMOVED******REMOVED******REMOVED***.sink { loading in
***REMOVED******REMOVED******REMOVED******REMOVED***if !loading {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***expectation.fulfill()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***wait(for: [expectation], timeout: 10.0)
***REMOVED******REMOVED***subscription.cancel()
***REMOVED***
***REMOVED***

extension FloorFilterTests {
***REMOVED******REMOVED***/ An arbitrary point to use for testing.
***REMOVED***var point: Point {
***REMOVED******REMOVED***Point(x: -117.19494, y: 34.05723, spatialReference: .wgs84)
***REMOVED***

***REMOVED******REMOVED***/ An arbitrary scale to use for testing.
***REMOVED***var scale: Double {
***REMOVED******REMOVED***10_000.00
***REMOVED***

***REMOVED******REMOVED***/ Builds viewpoints to use for tests.
***REMOVED******REMOVED***/ - Parameter rotation: The rotation to use for the resulting viewpoint.
***REMOVED******REMOVED***/ - Returns: A viewpoint object for tests.
***REMOVED***func getViewpoint(_ rotation: Double) -> Viewpoint {
***REMOVED******REMOVED***return Viewpoint(center: point, scale: scale, rotation: rotation)
***REMOVED***
***REMOVED***
