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
    /// Tests that a `FloorFilterViewModel` succesfully initializes with a `FloorManager` and
    /// `Binding<Viewpoint?>`.`
    func testInitFloorFilterViewModelWithFloorManagerAndViewpoint() async {
        guard let map = await makeMap(),
              let floorManager = map.floorManager else {
            return
        }
        
        var _viewpoint: Viewpoint? = nil
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
        
        var _viewpoint: Viewpoint? = .site_ResearchAnnex_facility_Lattice
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
        
        var _viewpoint: Viewpoint? = .site_ResearchAnnex_facility_Lattice
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
        
        let initialViewpoint: Viewpoint = .site_ResearchAnnex_facility_Lattice
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
        
        var _viewpoint: Viewpoint? = .losAngeles
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = FloorFilterViewModel(
            automaticSelectionMode: .always,
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        
        // Viewpoint is Los Angeles, selection should be nil
        viewModel.automaticallySelectFacilityOrSite()
        
        var selectedFacility = viewModel.selectedFacility
        var selectedSite = viewModel.selectedSite
        XCTAssertNil(selectedFacility)
        XCTAssertNil(selectedSite)
        
        _viewpoint = .site_ResearchAnnex_facility_Lattice
        viewModel.automaticallySelectFacilityOrSite()
        
        // Viewpoint is the Lattice facility at the Research Annex site
        selectedFacility = viewModel.selectedFacility
        selectedSite = viewModel.selectedSite
        XCTAssertEqual(selectedSite?.name, "Research Annex")
        XCTAssertEqual(selectedFacility?.name, "Lattice")
        
        _viewpoint = .losAngeles
        viewModel.automaticallySelectFacilityOrSite()
        
        // Viewpoint is Los Angeles, selection should be nil
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
        
        var _viewpoint: Viewpoint? = .site_ResearchAnnex_facility_Lattice
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = FloorFilterViewModel(
            automaticSelectionMode: .alwaysNotClearing,
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        
        viewModel.automaticallySelectFacilityOrSite()
        
        // Viewpoint is the Lattice facility at the Research Annex site
        var selectedFacility = viewModel.selectedFacility
        var selectedSite = viewModel.selectedSite
        XCTAssertEqual(selectedSite?.name, "Research Annex")
        XCTAssertEqual(selectedFacility?.name, "Lattice")
        
        // Viewpoint is Los Angeles, but selection should remain Redlands Main Q
        _viewpoint = .losAngeles
        viewModel.automaticallySelectFacilityOrSite()
        
        // Viewpoint is Los Angeles, but selection should remain Redlands Main Q
        selectedFacility = viewModel.selectedFacility
        selectedSite = viewModel.selectedSite
        XCTAssertEqual(selectedSite?.name, "Research Annex")
        XCTAssertEqual(selectedFacility?.name, "Lattice")
    }
    
    /// Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
    func testAutoSelectNever() async {
        guard let map = await makeMap(),
              let floorManager = map.floorManager else {
            return
        }
        
        var _viewpoint: Viewpoint? = .losAngeles
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = FloorFilterViewModel(
            automaticSelectionMode: .never,
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        
        viewModel.automaticallySelectFacilityOrSite()
        
        // Viewpoint is Los Angeles, selection should be nil
        var selectedFacility = viewModel.selectedFacility
        var selectedSite = viewModel.selectedSite
        XCTAssertNil(selectedFacility)
        XCTAssertNil(selectedSite)
        
        _viewpoint = .site_ResearchAnnex_facility_Lattice
        viewModel.automaticallySelectFacilityOrSite()
        
        // Viewpoint is the Lattice facility at the Research Annex site
        selectedFacility = viewModel.selectedFacility
        selectedSite = viewModel.selectedSite
        XCTAssertNil(selectedFacility)
        XCTAssertNil(selectedSite)
    }
    
    /// Get a map constructed from an ArcGIS portal item.
    /// - Returns: A map constructed from an ArcGIS portal item.
    private func makeMap() async -> Map? {
        let portal = Portal(url: URL(string: "https://www.arcgis.com/")!, isLoginRequired: false)
        let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "b4b599a43a474d33946cf0df526426f5")!)
        
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

private extension Viewpoint {
    static var losAngeles: Viewpoint {
        Viewpoint(
            center: Point(
                x: -13164116.3284,
                y: 4034465.8065,
                spatialReference: .webMercator
            ),
            scale: 10_000
        )
    }
    
    static var site_ResearchAnnex_facility_Lattice: Viewpoint {
        Viewpoint(
            center:
                Point(
                    x: -13045075.712950204,
                    y: 4036858.6146756615,
                    spatialReference: .webMercator
                ),
            scale: 550.0
        )
    }
}
