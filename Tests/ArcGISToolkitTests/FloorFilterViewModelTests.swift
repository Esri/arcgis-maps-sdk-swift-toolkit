***REMOVED*** Copyright 2022 Esri
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

***REMOVED***
import Combine
***REMOVED***
import XCTest
@testable ***REMOVED***Toolkit

final class FloorFilterViewModelTests: XCTestCase {
***REMOVED******REMOVED***/ Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
***REMOVED***@MainActor
***REMOVED***func testAutoSelectAlways() async throws {
***REMOVED******REMOVED***let floorManager = try await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .testMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = .losAngeles
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***automaticSelectionMode: .always,
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Viewpoint is Los Angeles, selection should be nil
***REMOVED******REMOVED***XCTAssertNil(viewModel.selection?.facility)
***REMOVED******REMOVED***XCTAssertNil(viewModel.selection?.site)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Viewpoint is Research Annex Lattice
***REMOVED******REMOVED***_viewpoint = .researchAnnexLattice
***REMOVED******REMOVED***viewModel.automaticallySelectFacilityOrSite()
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.site?.name, "Research Annex")
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.facility?.name, "Lattice")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Viewpoint is Los Angeles, selection should be nil
***REMOVED******REMOVED***_viewpoint = .losAngeles
***REMOVED******REMOVED***viewModel.automaticallySelectFacilityOrSite()
***REMOVED******REMOVED***XCTAssertNil(viewModel.selection?.site)
***REMOVED******REMOVED***XCTAssertNil(viewModel.selection?.facility)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
***REMOVED***@MainActor
***REMOVED***func testAutoSelectAlwaysNotClearing() async throws {
***REMOVED******REMOVED***let floorManager = try await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .testMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = .researchAnnexLattice
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***automaticSelectionMode: .alwaysNotClearing,
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Viewpoint is Research Annex Lattice
***REMOVED******REMOVED***_viewpoint = .researchAnnexLattice
***REMOVED******REMOVED***viewModel.automaticallySelectFacilityOrSite()
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.site?.name, "Research Annex")
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.facility?.name, "Lattice")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Viewpoint is Los Angeles, but selection should remain Research Annex Lattice
***REMOVED******REMOVED***_viewpoint = .losAngeles
***REMOVED******REMOVED***viewModel.automaticallySelectFacilityOrSite()
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.site?.name, "Research Annex")
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.facility?.name, "Lattice")
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
***REMOVED***@MainActor
***REMOVED***func testAutoSelectNever() async throws {
***REMOVED******REMOVED***let floorManager = try await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .testMap
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
***REMOVED******REMOVED***XCTAssertNil(viewModel.selection?.facility)
***REMOVED******REMOVED***XCTAssertNil(viewModel.selection?.site)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Viewpoint is Research Annex Lattice but selection should remain nil
***REMOVED******REMOVED***_viewpoint = .researchAnnexLattice
***REMOVED******REMOVED***viewModel.automaticallySelectFacilityOrSite()
***REMOVED******REMOVED***XCTAssertNil(viewModel.selection?.facility)
***REMOVED******REMOVED***XCTAssertNil(viewModel.selection?.site)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Tests that a `FloorFilterViewModel` successfully initializes.
***REMOVED***@MainActor
***REMOVED***func testInitWithFloorManagerAndViewpoint() async throws {
***REMOVED******REMOVED***let floorManager = try await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .testMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: .constant(.researchAnnexLattice)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.sites.isEmpty)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.facilities.isEmpty)
***REMOVED******REMOVED***XCTAssertFalse(viewModel.levels.isEmpty)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Confirms that the proper level is visible and all others are hidden.
***REMOVED***@MainActor
***REMOVED***func testLevelVisibility() async throws {
***REMOVED******REMOVED***let floorManager = try await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .testMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: .constant(.researchAnnexLattice)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let levels = viewModel.levels
***REMOVED******REMOVED***let firstLevel = try XCTUnwrap(levels.first)
***REMOVED******REMOVED***viewModel.setLevel(firstLevel)
***REMOVED******REMOVED***levels.forEach { level in
***REMOVED******REMOVED******REMOVED***if level.verticalOrder == firstLevel.verticalOrder {
***REMOVED******REMOVED******REMOVED******REMOVED***XCTAssertTrue(level.isVisible)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***XCTAssertFalse(level.isVisible)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Confirms that the selected site/facility/level properties are correctly updated.
***REMOVED***@MainActor
***REMOVED***func testSelectedProperties() async throws {
***REMOVED******REMOVED***let floorManager = try await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .testMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: .constant(.researchAnnexLattice)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let site = try XCTUnwrap(viewModel.sites.first)
***REMOVED******REMOVED***let facility = try XCTUnwrap(viewModel.facilities.first)
***REMOVED******REMOVED***let level = try XCTUnwrap(viewModel.levels.first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***viewModel.setSite(site, zoomTo: true)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.site, site)
***REMOVED******REMOVED***XCTAssertNil(viewModel.selection?.facility)
***REMOVED******REMOVED***XCTAssertNil(viewModel.selection?.level)
***REMOVED******REMOVED***
***REMOVED******REMOVED***viewModel.setFacility(facility, zoomTo: true)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.site, facility.site)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.facility, facility)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.level, facility.defaultLevel)
***REMOVED******REMOVED***
***REMOVED******REMOVED***viewModel.setLevel(level)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.site, level.facility?.site)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.facility, level.facility)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.level, level)
***REMOVED******REMOVED***
***REMOVED******REMOVED***viewModel.clearSelection()
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection, nil)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.site, nil)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.facility, nil)
***REMOVED******REMOVED***XCTAssertEqual(viewModel.selection?.level, nil)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Confirms that the selection property indicates the correct facility (and therefore level) value.
***REMOVED***@MainActor
***REMOVED***func testSelectionOfFacility() async throws {
***REMOVED******REMOVED***let floorManager = try await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .testMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: .constant(.researchAnnexLattice)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let facility = try XCTUnwrap(viewModel.facilities[4])
***REMOVED******REMOVED***let level = try XCTUnwrap(facility.defaultLevel)
***REMOVED******REMOVED***viewModel.setFacility(facility, zoomTo: true)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.selection, .level(level)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Confirms that the selection property indicates the correct level value.
***REMOVED***@MainActor
***REMOVED***func testSelectionOfLevel() async throws {
***REMOVED******REMOVED***let floorManager = try await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .testMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: .constant(.researchAnnexLattice)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let level = try XCTUnwrap(viewModel.levels.first)
***REMOVED******REMOVED***viewModel.setLevel(level)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.selection, .level(level)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Confirms that the selection property indicates the correct site value.
***REMOVED***@MainActor
***REMOVED***func testSelectionOfSite() async throws {
***REMOVED******REMOVED***let floorManager = try await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .testMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: .constant(.researchAnnexLattice)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let site = try XCTUnwrap(viewModel.sites.first)
***REMOVED******REMOVED***viewModel.setSite(site, zoomTo: true)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***viewModel.selection, .site(site)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Confirms that the  viewpoint is correctly updated.
***REMOVED***@MainActor
***REMOVED***func testViewpointUpdates() async throws {
***REMOVED******REMOVED***var _viewpoint: Viewpoint? = .researchAnnexLattice
***REMOVED******REMOVED***let viewpoint = Binding(get: { _viewpoint ***REMOVED***, set: { _viewpoint = $0 ***REMOVED***)
***REMOVED******REMOVED***let floorManager = try await floorManager(
***REMOVED******REMOVED******REMOVED***forWebMapWithIdentifier: .testMap
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let viewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let site = try XCTUnwrap(viewModel.sites.first)
***REMOVED******REMOVED***let facility = try XCTUnwrap(viewModel.facilities.first)
***REMOVED******REMOVED***
***REMOVED******REMOVED***viewModel.setSite(site, zoomTo: true)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***_viewpoint?.targetGeometry.extent.center.x,
***REMOVED******REMOVED******REMOVED***site.geometry?.extent.center.x
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***viewModel.setFacility(facility, zoomTo: true)
***REMOVED******REMOVED***XCTAssertEqual(
***REMOVED******REMOVED******REMOVED***_viewpoint?.targetGeometry.extent.center.x,
***REMOVED******REMOVED******REMOVED***facility.geometry?.extent.center.x
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***private func floorManager(
***REMOVED******REMOVED***forWebMapWithIdentifier id: PortalItem.ID,
***REMOVED******REMOVED***file: StaticString = #filePath,
***REMOVED******REMOVED***line: UInt = #line
***REMOVED***) async throws -> FloorManager {
***REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***www.arcgis.com/")!, connection: .anonymous)
***REMOVED******REMOVED***let item = PortalItem(portal: portal, id: id)
***REMOVED******REMOVED***let map = Map(item: item)
***REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED***let floorManager = try XCTUnwrap(map.floorManager, file: file, line: line)
***REMOVED******REMOVED***try await floorManager.load()
***REMOVED******REMOVED***return floorManager
***REMOVED***
***REMOVED***

private extension PortalItem.ID {
***REMOVED***static let testMap = Self("b4b599a43a474d33946cf0df526426f5")!
***REMOVED***

private extension Viewpoint {
***REMOVED***static let researchAnnexLattice = Viewpoint(
***REMOVED******REMOVED***center:
***REMOVED******REMOVED******REMOVED***Point(
***REMOVED******REMOVED******REMOVED******REMOVED***x: -13045075.712950204,
***REMOVED******REMOVED******REMOVED******REMOVED***y: 4036858.6146756615,
***REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: .webMercator
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED***scale: 550.0
***REMOVED***)
***REMOVED***
***REMOVED***static let losAngeles = Viewpoint(
***REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED***x: -13164116.3284,
***REMOVED******REMOVED******REMOVED***y: 4034465.8065,
***REMOVED******REMOVED******REMOVED***spatialReference: .webMercator
***REMOVED******REMOVED***),
***REMOVED******REMOVED***scale: 10_000
***REMOVED***)
***REMOVED***
