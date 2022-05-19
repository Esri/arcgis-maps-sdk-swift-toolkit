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

@MainActor
class FloorFilterViewModelTests: XCTestCase {
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
        try? await floorManager.load()
        
        var _viewpoint: Viewpoint? = getEsriRedlandsViewpoint()
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        
        let viewModel = FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        
        XCTAssertFalse(viewModel.sites.isEmpty)
        XCTAssertFalse(viewModel.facilities.isEmpty)
        XCTAssertFalse(viewModel.levels.isEmpty)
    }
    
    /// Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
    func testSetSite() async {
        guard let map = await makeMap(),
              let floorManager = map.floorManager else {
            return
        }
        try? await floorManager.load()
        
        var _viewpoint: Viewpoint? = getEsriRedlandsViewpoint()
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        
        let viewModel = FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        guard let site = viewModel.sites.first else {
            XCTFail()
            return
        }
        viewModel.setSite(site, zoomTo: true)
        let selectedSite = viewModel.selectedSite
        let selectedFacility = viewModel.selectedFacility
        let selectedLevel = viewModel.selectedLevel
        XCTAssertEqual(selectedSite, site)
        XCTAssertNil(selectedFacility)
        XCTAssertNil(selectedLevel)
        XCTAssertEqual(
            _viewpoint?.targetGeometry.extent.center.x,
            selectedSite?.geometry?.extent.center.x
        )
    }
    
    func testSetFacility() async {
        guard let map = await makeMap(),
              let floorManager = map.floorManager else {
            return
        }
        try? await floorManager.load()
        let initialViewpoint = getEsriRedlandsViewpoint(.zero)
        var _viewpoint: Viewpoint? = initialViewpoint
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = FloorFilterViewModel(
            automaticSelectionMode: .never,
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        guard let facility = viewModel.facilities.first else {
            XCTFail()
            return
        }
        viewModel.setFacility(facility, zoomTo: true)
        let selectedFacility = viewModel.selectedFacility
        let selectedLevel = viewModel.selectedLevel
        let defaultLevel = selectedFacility?.defaultLevel
        XCTAssertEqual(selectedFacility, facility)
        XCTAssertEqual(selectedLevel, defaultLevel)
        XCTAssertEqual(
            _viewpoint?.targetGeometry.extent.center.x,
            selectedFacility?.geometry?.extent.center.x
        )
    }
    
    /// Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
    func testSetLevel() async {
        guard let map = await makeMap(),
              let floorManager = map.floorManager else {
            return
        }
        try? await floorManager.load()
        let initialViewpoint = getEsriRedlandsViewpoint(.zero)
        var _viewpoint: Viewpoint? = initialViewpoint
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        let levels = viewModel.levels
        guard let level = levels.first else {
            XCTFail("A first level does not exist")
            return
        }
        viewModel.setLevel(level)
        let selectedLevel = viewModel.selectedLevel
        XCTAssertEqual(selectedLevel, level)
        XCTAssertEqual(
            _viewpoint?.targetGeometry.extent.center.x,
            initialViewpoint.targetGeometry.extent.center.x
        )
        levels.forEach { level in
            if level.verticalOrder == selectedLevel?.verticalOrder {
                XCTAssertTrue(level.isVisible)
            } else {
                XCTAssertFalse(level.isVisible)
            }
        }
    }
    
    /// Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
    func testAutoSelectAlways() async {
        guard let map = await makeMap(),
              let floorManager = map.floorManager else {
            return
        }
        try? await floorManager.load()
        let viewpointLosAngeles = Viewpoint(
            center: Point(
                x: -13164116.3284,
                y: 4034465.8065,
                spatialReference: .webMercator
            ),
            scale: 10_000
        )
        var _viewpoint: Viewpoint? = viewpointLosAngeles
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = FloorFilterViewModel(
            automaticSelectionMode: .always,
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        
        // Viewpoint is Los Angeles, selection should be nil
        var selectedFacility = viewModel.selectedFacility
        var selectedSite = viewModel.selectedSite
        XCTAssertNil(selectedFacility)
        XCTAssertNil(selectedSite)
        
        // Viewpoint is Redlands Main Q
        _viewpoint = getEsriRedlandsViewpoint(scale: 1000)
        viewModel.automaticallySelectFacilityOrSite()
        selectedFacility = viewModel.selectedFacility
        selectedSite = viewModel.selectedSite
        XCTAssertEqual(selectedSite?.name, "Redlands Main")
        XCTAssertEqual(selectedFacility?.name, "Q")
        
        // Viewpoint is Los Angeles, selection should be nil
        _viewpoint = viewpointLosAngeles
        viewModel.automaticallySelectFacilityOrSite()
        selectedFacility = viewModel.selectedFacility
        selectedSite = viewModel.selectedSite
        XCTAssertNil(selectedSite)
        XCTAssertNil(selectedFacility)
    }
    
    /// Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
    func testAutoSelectAlwaysNotClearing() async {
        guard let map = await makeMap(),
              let floorManager = map.floorManager else {
            return
        }
        try? await floorManager.load()
        let viewpointLosAngeles = Viewpoint(
            center: Point(
                x: -13164116.3284,
                y: 4034465.8065,
                spatialReference: .webMercator
            ),
            scale: 10_000
        )
        var _viewpoint: Viewpoint? = getEsriRedlandsViewpoint(scale: 1000)
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = FloorFilterViewModel(
            automaticSelectionMode: .alwaysNotClearing,
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        
        // Viewpoint is Redlands Main Q
        _viewpoint = getEsriRedlandsViewpoint(scale: 1000)
        viewModel.automaticallySelectFacilityOrSite()
        var selectedFacility = viewModel.selectedFacility
        var selectedSite = viewModel.selectedSite
        XCTAssertEqual(selectedSite?.name, "Redlands Main")
        XCTAssertEqual(selectedFacility?.name, "Q")
        
        // Viewpoint is Los Angeles, but selection should remain Redlands Main Q
        _viewpoint = viewpointLosAngeles
        viewModel.automaticallySelectFacilityOrSite()
        selectedFacility = viewModel.selectedFacility
        selectedSite = viewModel.selectedSite
        XCTAssertEqual(selectedSite?.name, "Redlands Main")
        XCTAssertEqual(selectedFacility?.name, "Q")
    }
    
    /// Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
    func testAutoSelectNever() async {
        guard let map = await makeMap(),
              let floorManager = map.floorManager else {
            return
        }
        try? await floorManager.load()
        let viewpointLosAngeles = Viewpoint(
            center: Point(
                x: -13164116.3284,
                y: 4034465.8065,
                spatialReference: .webMercator
            ),
            scale: 10_000
        )
        var _viewpoint: Viewpoint? = viewpointLosAngeles
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = FloorFilterViewModel(
            automaticSelectionMode: .never,
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        
        // Viewpoint is Los Angeles, selection should be nil
        var selectedFacility = viewModel.selectedFacility
        var selectedSite = viewModel.selectedSite
        XCTAssertNil(selectedFacility)
        XCTAssertNil(selectedSite)
        
        // Viewpoint is Redlands Main Q but selection should still be nil
        _viewpoint = getEsriRedlandsViewpoint(scale: 1000)
        viewModel.automaticallySelectFacilityOrSite()
        selectedFacility = viewModel.selectedFacility
        selectedSite = viewModel.selectedSite
        XCTAssertNil(selectedFacility)
        XCTAssertNil(selectedSite)
    }
    
    /// Get a map constructed from an ArcGIS portal item.
    /// - Returns: A map constructed from an ArcGIS portal item.
    private func makeMap() async -> Map? {
        // Multiple sites/facilities: Esri IST map with all buildings.
        // let portal = Portal(url: URL(string: "https://indoors.maps.arcgis.com/")!, isLoginRequired: false)
        // let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "49520a67773842f1858602735ef538b5")!)
        
        // Redlands Campus map with multiple sites and facilities.
        let portal = Portal(url: URL(string: "https://runtimecoretest.maps.arcgis.com/")!, isLoginRequired: false)
        let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "7687805bd42549f5ba41237443d0c60a")!)
        
        // Single site (ESRI Redlands Main) and facility (Building L).
        // let portal = Portal(url: URL(string: "https://indoors.maps.arcgis.com/")!, isLoginRequired: false)
        // let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "f133a698536f44c8884ad81f80b6cfc7")!)
        
        let map = Map(item: portalItem)
        do {
            try await map.load()
            try await map.floorManager?.load()
        } catch {
            XCTFail("\(#fileID), \(#function), \(#line), \(error.localizedDescription)")
            return nil
        }
        return map
    }
}

extension FloorFilterViewModelTests {
    /// The coordinates for the Redlands Esri campus.
    var point: Point {
        Point(
            x: -13046157.242121734,
            y: 4036329.622884897,
            spatialReference: .webMercator
        )
    }
    
    /// Builds viewpoints to use for tests.
    /// - Parameter rotation: The rotation to use for the resulting viewpoint.
    /// - Returns: A viewpoint object for tests.
    func getEsriRedlandsViewpoint(_ rotation: Double = .zero, scale: Double = 10_000) -> Viewpoint {
        return Viewpoint(center: point, scale: scale, rotation: rotation)
    }
}
