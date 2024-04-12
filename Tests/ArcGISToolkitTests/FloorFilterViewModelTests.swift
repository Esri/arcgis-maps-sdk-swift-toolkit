// Copyright 2022 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
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
final class FloorFilterViewModelTests: XCTestCase {
    /// Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
    func testAutoSelectAlways() async throws {
        let floorManager = try await floorManager(
            forWebMapWithIdentifier: .testMap
        )
        
        var _viewpoint: Viewpoint? = .losAngeles
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = FloorFilterViewModel(
            automaticSelectionMode: .always,
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        
        // Viewpoint is Los Angeles, selection should be nil
        XCTAssertNil(viewModel.selection?.facility)
        XCTAssertNil(viewModel.selection?.site)
        
        // Viewpoint is Research Annex Lattice
        _viewpoint = .researchAnnexLattice
        viewModel.automaticallySelectFacilityOrSite()
        XCTAssertEqual(viewModel.selection?.site?.name, "Research Annex")
        XCTAssertEqual(viewModel.selection?.facility?.name, "Lattice")
        
        // Viewpoint is Los Angeles, selection should be nil
        _viewpoint = .losAngeles
        viewModel.automaticallySelectFacilityOrSite()
        XCTAssertNil(viewModel.selection?.site)
        XCTAssertNil(viewModel.selection?.facility)
    }
    
    /// Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
    func testAutoSelectAlwaysNotClearing() async throws {
        let floorManager = try await floorManager(
            forWebMapWithIdentifier: .testMap
        )
        
        var _viewpoint: Viewpoint? = .researchAnnexLattice
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = FloorFilterViewModel(
            automaticSelectionMode: .alwaysNotClearing,
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        
        // Viewpoint is Research Annex Lattice
        _viewpoint = .researchAnnexLattice
        viewModel.automaticallySelectFacilityOrSite()
        XCTAssertEqual(viewModel.selection?.site?.name, "Research Annex")
        XCTAssertEqual(viewModel.selection?.facility?.name, "Lattice")
        
        // Viewpoint is Los Angeles, but selection should remain Research Annex Lattice
        _viewpoint = .losAngeles
        viewModel.automaticallySelectFacilityOrSite()
        XCTAssertEqual(viewModel.selection?.site?.name, "Research Annex")
        XCTAssertEqual(viewModel.selection?.facility?.name, "Lattice")
    }
    
    /// Confirms that the selected site/facility/level properties and the viewpoint are correctly updated.
    func testAutoSelectNever() async throws {
        let floorManager = try await floorManager(
            forWebMapWithIdentifier: .testMap
        )
        
        var _viewpoint: Viewpoint? = .losAngeles
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let viewModel = FloorFilterViewModel(
            automaticSelectionMode: .never,
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        
        // Viewpoint is Los Angeles, selection should be nil
        XCTAssertNil(viewModel.selection?.facility)
        XCTAssertNil(viewModel.selection?.site)
        
        // Viewpoint is Research Annex Lattice but selection should remain nil
        _viewpoint = .researchAnnexLattice
        viewModel.automaticallySelectFacilityOrSite()
        XCTAssertNil(viewModel.selection?.facility)
        XCTAssertNil(viewModel.selection?.site)
    }
    
    /// Tests that a `FloorFilterViewModel` successfully initializes.
    func testInitWithFloorManagerAndViewpoint() async throws {
        let floorManager = try await floorManager(
            forWebMapWithIdentifier: .testMap
        )
        let viewModel = FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: .constant(.researchAnnexLattice)
        )
        XCTAssertFalse(viewModel.sites.isEmpty)
        XCTAssertFalse(viewModel.facilities.isEmpty)
        XCTAssertFalse(viewModel.levels.isEmpty)
    }
    
    /// Confirms that the proper level is visible and all others are hidden.
    func testLevelVisibility() async throws {
        let floorManager = try await floorManager(
            forWebMapWithIdentifier: .testMap
        )
        let viewModel = FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: .constant(.researchAnnexLattice)
        )
        let levels = viewModel.levels
        let firstLevel = try XCTUnwrap(levels.first)
        viewModel.setLevel(firstLevel)
        levels.forEach { level in
            if level.verticalOrder == firstLevel.verticalOrder {
                XCTAssertTrue(level.isVisible)
            } else {
                XCTAssertFalse(level.isVisible)
            }
        }
    }
    
    /// Confirms that the selected site/facility/level properties are correctly updated.
    func testSelectedProperties() async throws {
        let floorManager = try await floorManager(
            forWebMapWithIdentifier: .testMap
        )
        let viewModel = FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: .constant(.researchAnnexLattice)
        )
        let site = try XCTUnwrap(viewModel.sites.first)
        let facility = try XCTUnwrap(viewModel.facilities.first)
        let level = try XCTUnwrap(viewModel.levels.first)
        
        viewModel.setSite(site, zoomTo: true)
        XCTAssertEqual(viewModel.selection?.site, site)
        XCTAssertNil(viewModel.selection?.facility)
        XCTAssertNil(viewModel.selection?.level)
        
        viewModel.setFacility(facility, zoomTo: true)
        XCTAssertEqual(viewModel.selection?.site, facility.site)
        XCTAssertEqual(viewModel.selection?.facility, facility)
        XCTAssertEqual(viewModel.selection?.level, facility.defaultLevel)
        
        viewModel.setLevel(level)
        XCTAssertEqual(viewModel.selection?.site, level.facility?.site)
        XCTAssertEqual(viewModel.selection?.facility, level.facility)
        XCTAssertEqual(viewModel.selection?.level, level)
        
        viewModel.clearSelection()
        XCTAssertEqual(viewModel.selection, nil)
        XCTAssertEqual(viewModel.selection?.site, nil)
        XCTAssertEqual(viewModel.selection?.facility, nil)
        XCTAssertEqual(viewModel.selection?.level, nil)
    }
    
    /// Confirms that the selection property indicates the correct facility (and therefore level) value.
    func testSelectionOfFacility() async throws {
        let floorManager = try await floorManager(
            forWebMapWithIdentifier: .testMap
        )
        let viewModel = FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: .constant(.researchAnnexLattice)
        )
        let facility = try XCTUnwrap(viewModel.facilities[4])
        let level = try XCTUnwrap(facility.defaultLevel)
        viewModel.setFacility(facility, zoomTo: true)
        XCTAssertEqual(
            viewModel.selection, .level(level)
        )
    }
    
    /// Confirms that the selection property indicates the correct level value.
    func testSelectionOfLevel() async throws {
        let floorManager = try await floorManager(
            forWebMapWithIdentifier: .testMap
        )
        let viewModel = FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: .constant(.researchAnnexLattice)
        )
        let level = try XCTUnwrap(viewModel.levels.first)
        viewModel.setLevel(level)
        XCTAssertEqual(
            viewModel.selection, .level(level)
        )
    }
    
    /// Confirms that the selection property indicates the correct site value.
    func testSelectionOfSite() async throws {
        let floorManager = try await floorManager(
            forWebMapWithIdentifier: .testMap
        )
        let viewModel = FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: .constant(.researchAnnexLattice)
        )
        let site = try XCTUnwrap(viewModel.sites.first)
        viewModel.setSite(site, zoomTo: true)
        XCTAssertEqual(
            viewModel.selection, .site(site)
        )
    }
    
    /// Confirms that the  viewpoint is correctly updated.
    func testViewpointUpdates() async throws {
        var _viewpoint: Viewpoint? = .researchAnnexLattice
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let floorManager = try await floorManager(
            forWebMapWithIdentifier: .testMap
        )
        let viewModel = FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: viewpoint
        )
        
        let site = try XCTUnwrap(viewModel.sites.first)
        let facility = try XCTUnwrap(viewModel.facilities.first)
        
        viewModel.setSite(site, zoomTo: true)
        XCTAssertEqual(
            _viewpoint?.targetGeometry.extent.center.x,
            site.geometry?.extent.center.x
        )
        
        viewModel.setFacility(facility, zoomTo: true)
        XCTAssertEqual(
            _viewpoint?.targetGeometry.extent.center.x,
            facility.geometry?.extent.center.x
        )
    }
    
    private func floorManager(
        forWebMapWithIdentifier id: PortalItem.ID,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> FloorManager {
        let portal = Portal(url: URL(string: "https://www.arcgis.com/")!, connection: .anonymous)
        let item = PortalItem(portal: portal, id: id)
        let map = Map(item: item)
        try await map.load()
        let floorManager = try XCTUnwrap(map.floorManager, file: file, line: line)
        try await floorManager.load()
        return floorManager
    }
}

private extension PortalItem.ID {
    static let testMap = Self("b4b599a43a474d33946cf0df526426f5")!
}

private extension Viewpoint {
    static let researchAnnexLattice = Viewpoint(
        center:
            Point(
                x: -13045075.712950204,
                y: 4036858.6146756615,
                spatialReference: .webMercator
            ),
        scale: 550.0
    )
    
    static let losAngeles = Viewpoint(
        center: Point(
            x: -13164116.3284,
            y: 4034465.8065,
            spatialReference: .webMercator
        ),
        scale: 10_000
    )
}
