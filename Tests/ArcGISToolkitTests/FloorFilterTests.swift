// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import Combine
import SwiftUI
import XCTest
@testable import ArcGISToolkit

class FloorFilterTests: XCTestCase {
    /// Applies credentials necessary to run tests.
    override func setUp() async throws {
        await addCredentials()
    }

    /// Tests that a `FloorFilterViewModel` succesfully initializes with a `FloorManager`.`
    func testInitFloorFilterViewModelWithFloorManager() async {
        guard let map = await makeMap(),
              let floorManager = map.floorManager else {
            return
        }
        let viewModel = await FloorFilterViewModel(floorManager: floorManager)
        await verifyInitialization(viewModel)
        let sites = await viewModel.sites
        let facilities = await viewModel.facilities
        let levels = await viewModel.levels
        XCTAssertFalse(sites.isEmpty)
        XCTAssertFalse(facilities.isEmpty)
        XCTAssertFalse(levels.isEmpty)
    }

    /// Tests that a `FloorFilterViewModel` succesfully initializes with a `FloorManager` and
    /// `Binding<Viewpoint>?`.`
    func testInitFloorFilterViewModelWithFloorManagerAndViewpoint() async {
        guard let map = await makeMap(),
              let floorManager = map.floorManager else {
            return
        }
        var _viewpoint: Viewpoint = getViewpoint(.zero)
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = await FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        await verifyInitialization(viewModel)
        let sites = await viewModel.sites
        let facilities = await viewModel.facilities
        let levels = await viewModel.levels
        let vmViewpoint = await viewModel.viewpoint
        XCTAssertFalse(sites.isEmpty)
        XCTAssertFalse(facilities.isEmpty)
        XCTAssertFalse(levels.isEmpty)
        XCTAssertNotNil(vmViewpoint)
    }

    /// Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
    func testSetSite() async {
        guard let map = await makeMap(),
              let floorManager = map.floorManager else {
            return
        }
        var _viewpoint: Viewpoint = getViewpoint(.zero)
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = await FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        await verifyInitialization(viewModel)
        let sites = await viewModel.sites
        await viewModel.setSite(sites.first)
        let selectedSite = await viewModel.selectedSite
        let selectedFacility = await viewModel.selectedFacility
        let selectedLevel = await viewModel.selectedLevel
        var vmViewpoint = await viewModel.viewpoint
        XCTAssertEqual(selectedSite, sites.first)
        XCTAssertNil(selectedFacility)
        XCTAssertNil(selectedLevel)
        XCTAssertEqual(
            _viewpoint.targetGeometry.extent.center.x,
            vmViewpoint?.wrappedValue.targetGeometry.extent.center.x
        )
        await viewModel.setSite(sites.first, zoomTo: true)
        vmViewpoint = await viewModel.viewpoint
        XCTAssertEqual(
            selectedSite?.geometry?.extent.center.x,
            vmViewpoint?.wrappedValue.targetGeometry.extent.center.x
        )
    }

    /// Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
    func testSetFacility() async {
        guard let map = await makeMap(),
              let floorManager = map.floorManager else {
            return
        }
        var _viewpoint: Viewpoint = getViewpoint(.zero)
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = await FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        await verifyInitialization(viewModel)
        let facilities = await viewModel.facilities
        await viewModel.setFacility(facilities.first)
        let selectedSite = await viewModel.selectedSite
        let selectedFacility = await viewModel.selectedFacility
        let selectedLevel = await viewModel.selectedLevel
        let defaultLevel = await viewModel.defaultLevel(for: selectedFacility)
        var vmViewpoint = await viewModel.viewpoint
        XCTAssertEqual(selectedSite, selectedFacility?.site)
        XCTAssertEqual(selectedFacility, facilities.first)
        XCTAssertEqual(selectedLevel, defaultLevel)
        XCTAssertEqual(
            _viewpoint.targetGeometry.extent.center.x,
            vmViewpoint?.wrappedValue.targetGeometry.extent.center.x
        )
        await viewModel.setFacility(facilities.first, zoomTo: true)
        vmViewpoint = await viewModel.viewpoint
        XCTAssertEqual(
            selectedFacility?.geometry?.extent.center.x,
            vmViewpoint?.wrappedValue.targetGeometry.extent.center.x
        )
    }

    /// Get a map constructed from an ArcGIS portal item.
    /// - Returns: A map constructed from an ArcGIS portal item.
    private func makeMap() async -> Map? {
        // Multiple sites/facilities: Esri IST map with all buildings.
//        let portal = Portal(url: URL(string: "https://indoors.maps.arcgis.com/")!, isLoginRequired: false)
//        let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "49520a67773842f1858602735ef538b5")!)

        // Redlands Campus map with multiple sites and facilities.
        let portal = Portal(url: URL(string: "https://runtimecoretest.maps.arcgis.com/")!, isLoginRequired: false)
        let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "7687805bd42549f5ba41237443d0c60a")!)

        // Single site (ESRI Redlands Main) and facility (Building L).
//        let portal = Portal(url: URL(string: "https://indoors.maps.arcgis.com/")!, isLoginRequired: false)
//        let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "f133a698536f44c8884ad81f80b6cfc7")!)

        let map = Map(item: portalItem)
        do {
            try await map.load()
        } catch {
            XCTFail("\(#fileID), \(#function), \(#line), \(error.localizedDescription)")
            return nil
        }
        return map
    }

    /// Verifies that the `FloorFilterViewModel` has succesfully initialized.
    /// - Parameter viewModel: The view model to analyze.
    private func verifyInitialization(_ viewModel: FloorFilterViewModel) async {
        let expectation = XCTestExpectation(
            description: "View model successfully initialized"
        )
        let subscription = await viewModel.$isLoading
            .sink { loading in
                if !loading {
                    expectation.fulfill()
                }
            }
        wait(for: [expectation], timeout: 10.0)
        subscription.cancel()
    }
}

extension FloorFilterTests {
    /// An arbitrary point to use for testing.
    var point: Point {
        Point(x: -117.19494, y: 34.05723, spatialReference: .wgs84)
    }

    /// An arbitrary scale to use for testing.
    var scale: Double {
        10_000.00
    }

    /// Builds viewpoints to use for tests.
    /// - Parameter rotation: The rotation to use for the resulting viewpoint.
    /// - Returns: A viewpoint object for tests.
    func getViewpoint(_ rotation: Double) -> Viewpoint {
        return Viewpoint(center: point, scale: scale, rotation: rotation)
    }
}
