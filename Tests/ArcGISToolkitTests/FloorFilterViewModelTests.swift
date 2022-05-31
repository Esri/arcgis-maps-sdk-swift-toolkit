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

@MainActor
final class FloorFilterViewModelTests: XCTestCase {
***REMOVED******REMOVED***/ Tests that a `FloorFilterViewModel` succesfully initializes with a `FloorManager`.`
***REMOVED***func testInitWithFloorManagerAndViewpoint() async throws {
***REMOVED******REMOVED***let floorManager = try  await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .redlandsCampusMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = getEsriRedlandsViewpoint()
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertFalse(viewModel.sites.isEmpty)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.facilities.isEmpty)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.levels.isEmpty)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
***REMOVED***func testSetSite() async throws {
***REMOVED******REMOVED***let floorManager = try  await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .redlandsCampusMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = getEsriRedlandsViewpoint()
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let site = viewModel.sites.first else {
***REMOVED******REMOVED******REMOVED***XCTFail()
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***viewModel.setSite(site, zoomTo: true)
***REMOVED******REMOVED***let selectedSite = viewModel.selectedSite
***REMOVED******REMOVED***let selectedFacility = viewModel.selectedFacility
***REMOVED******REMOVED***let selectedLevel = viewModel.selectedLevel
***REMOVED******REMOVED***XCTAssertEqual(selectedSite, site)
***REMOVED******REMOVED***XCTAssertNil(selectedFacility)
***REMOVED******REMOVED***XCTAssertNil(selectedLevel)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***_viewpoint?.targetGeometry.extent.center.x,
***REMOVED******REMOVED******REMOVED***selectedSite?.geometry?.extent.center.x
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func testSetFacility() async throws {
***REMOVED******REMOVED***let floorManager = try  await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .redlandsCampusMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = getEsriRedlandsViewpoint(.zero)
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***automaticSelectionMode: .never,
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let facility = viewModel.facilities.first else {
***REMOVED******REMOVED******REMOVED***XCTFail()
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***viewModel.setFacility(facility, zoomTo: true)
***REMOVED******REMOVED***let selectedFacility = viewModel.selectedFacility
***REMOVED******REMOVED***let selectedLevel = viewModel.selectedLevel
***REMOVED******REMOVED***let defaultLevel = selectedFacility?.defaultLevel
***REMOVED******REMOVED***XCTAssertEqual(selectedFacility, facility)
***REMOVED******REMOVED***XCTAssertEqual(selectedLevel, defaultLevel)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***_viewpoint?.targetGeometry.extent.center.x,
***REMOVED******REMOVED******REMOVED***selectedFacility?.geometry?.extent.center.x
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
***REMOVED***func testSetLevel() async throws {
***REMOVED******REMOVED***let floorManager = try  await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .redlandsCampusMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let initialViewpoint = getEsriRedlandsViewpoint(.zero)
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = initialViewpoint
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let levels = viewModel.levels
***REMOVED******REMOVED***guard let level = levels.first else {
***REMOVED******REMOVED******REMOVED***XCTFail("A first level does not exist")
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***viewModel.setLevel(level)
***REMOVED******REMOVED***let selectedLevel = viewModel.selectedLevel
***REMOVED******REMOVED***XCTAssertEqual(selectedLevel, level)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***_viewpoint?.targetGeometry.extent.center.x,
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
***REMOVED***
***REMOVED******REMOVED***/ Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
***REMOVED***func testAutoSelectAlways() async throws {
***REMOVED******REMOVED***let floorManager = try  await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .redlandsCampusMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let viewpointLosAngeles = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED******REMOVED***x: -13164116.3284,
***REMOVED******REMOVED******REMOVED******REMOVED***y: 4034465.8065,
***REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: .webMercator
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***scale: 10_000
***REMOVED******REMOVED***)
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = viewpointLosAngeles
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***automaticSelectionMode: .always,
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Viewpoint is Los Angeles, selection should be nil
***REMOVED******REMOVED***var selectedFacility = viewModel.selectedFacility
***REMOVED******REMOVED***var selectedSite = viewModel.selectedSite
***REMOVED******REMOVED***XCTAssertNil(selectedFacility)
***REMOVED******REMOVED***XCTAssertNil(selectedSite)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Viewpoint is Redlands Main Q
***REMOVED******REMOVED***_viewpoint = getEsriRedlandsViewpoint(scale: 1000)
***REMOVED******REMOVED***viewModel.automaticallySelectFacilityOrSite()
***REMOVED******REMOVED***selectedFacility = viewModel.selectedFacility
***REMOVED******REMOVED***selectedSite = viewModel.selectedSite
***REMOVED******REMOVED***XCTAssertEqual(selectedSite?.name, "Redlands Main")
***REMOVED******REMOVED***XCTAssertEqual(selectedFacility?.name, "Q")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Viewpoint is Los Angeles, selection should be nil
***REMOVED******REMOVED***_viewpoint = viewpointLosAngeles
***REMOVED******REMOVED***viewModel.automaticallySelectFacilityOrSite()
***REMOVED******REMOVED***selectedFacility = viewModel.selectedFacility
***REMOVED******REMOVED***selectedSite = viewModel.selectedSite
***REMOVED******REMOVED***XCTAssertNil(selectedSite)
***REMOVED******REMOVED***XCTAssertNil(selectedFacility)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
***REMOVED***func testAutoSelectAlwaysNotClearing() async throws {
***REMOVED******REMOVED***let floorManager = try  await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .redlandsCampusMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = getEsriRedlandsViewpoint(scale: 1000)
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***automaticSelectionMode: .alwaysNotClearing,
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Viewpoint is Redlands Main Q
***REMOVED******REMOVED***_viewpoint = getEsriRedlandsViewpoint(scale: 1000)
***REMOVED******REMOVED***viewModel.automaticallySelectFacilityOrSite()
***REMOVED******REMOVED***var selectedFacility = viewModel.selectedFacility
***REMOVED******REMOVED***var selectedSite = viewModel.selectedSite
***REMOVED******REMOVED***XCTAssertEqual(selectedSite?.name, "Redlands Main")
***REMOVED******REMOVED***XCTAssertEqual(selectedFacility?.name, "Q")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Viewpoint is Los Angeles, but selection should remain Redlands Main Q
***REMOVED******REMOVED***_viewpoint = .losAngeles
***REMOVED******REMOVED***viewModel.automaticallySelectFacilityOrSite()
***REMOVED******REMOVED***selectedFacility = viewModel.selectedFacility
***REMOVED******REMOVED***selectedSite = viewModel.selectedSite
***REMOVED******REMOVED***XCTAssertEqual(selectedSite?.name, "Redlands Main")
***REMOVED******REMOVED***XCTAssertEqual(selectedFacility?.name, "Q")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
***REMOVED***func testAutoSelectNever() async throws {
***REMOVED******REMOVED***let floorManager = try  await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .redlandsCampusMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = .losAngeles
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***automaticSelectionMode: .never,
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Viewpoint is Los Angeles, selection should be nil
***REMOVED******REMOVED***var selectedFacility = viewModel.selectedFacility
***REMOVED******REMOVED***var selectedSite = viewModel.selectedSite
***REMOVED******REMOVED***XCTAssertNil(selectedFacility)
***REMOVED******REMOVED***XCTAssertNil(selectedSite)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Viewpoint is Redlands Main Q but selection should still be nil
***REMOVED******REMOVED***_viewpoint = getEsriRedlandsViewpoint(scale: 1000)
***REMOVED******REMOVED***viewModel.automaticallySelectFacilityOrSite()
***REMOVED******REMOVED***selectedFacility = viewModel.selectedFacility
***REMOVED******REMOVED***selectedSite = viewModel.selectedSite
***REMOVED******REMOVED***XCTAssertNil(selectedFacility)
***REMOVED******REMOVED***XCTAssertNil(selectedSite)
***REMOVED***
***REMOVED***
***REMOVED***private func floorManager(
***REMOVED******REMOVED***forWebMapWithIdentifier id: PortalItem.ID,
***REMOVED******REMOVED***file: StaticString = #filePath,
***REMOVED******REMOVED***line: UInt = #line
***REMOVED***) async throws -> FloorManager {
***REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED***let item = PortalItem(portal: portal, id: id)
***REMOVED******REMOVED***let map = Map(item: item)
***REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED***let floorManager = try XCTUnwrap(map.floorManager, file: file, line: line)
***REMOVED******REMOVED***try await floorManager.load()
***REMOVED******REMOVED***return floorManager
***REMOVED***
***REMOVED***

private extension PortalItem.ID {
***REMOVED***static let redlandsCampusMap = Self("7687805bd42549f5ba41237443d0c60a")!
***REMOVED***

extension FloorFilterViewModelTests {
***REMOVED******REMOVED***/ The coordinates for the Redlands Esri campus.
***REMOVED***var point: Point {
***REMOVED******REMOVED***Point(
***REMOVED******REMOVED******REMOVED***x: -13046157.242121734,
***REMOVED******REMOVED******REMOVED***y: 4036329.622884897,
***REMOVED******REMOVED******REMOVED***spatialReference: .webMercator
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Builds viewpoints to use for tests.
***REMOVED******REMOVED***/ - Parameter rotation: The rotation to use for the resulting viewpoint.
***REMOVED******REMOVED***/ - Returns: A viewpoint object for tests.
***REMOVED***func getEsriRedlandsViewpoint(
***REMOVED******REMOVED***_ rotation: Double = .zero,
***REMOVED******REMOVED***scale: Double = 10_000
***REMOVED***) -> Viewpoint {
***REMOVED******REMOVED***return Viewpoint(center: point, scale: scale, rotation: rotation)
***REMOVED***
***REMOVED***

private extension Viewpoint {
***REMOVED***static var losAngeles: Viewpoint {
***REMOVED******REMOVED***Viewpoint(
***REMOVED******REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED******REMOVED***x: -13164116.3284,
***REMOVED******REMOVED******REMOVED******REMOVED***y: 4034465.8065,
***REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: .webMercator
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***scale: 10_000
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
