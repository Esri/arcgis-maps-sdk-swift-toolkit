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

    private var cancellables = Set<AnyCancellable>()

    /// Tests general behavior of `FloorFilterViewModel`.
    func testFloorFilterViewModel() async {
        guard let map = await makeMap() else {
            return
        }
        guard let floorManager = map.floorManager else {
            XCTFail("No FloorManager available")
            return
        }
        let viewModel = await FloorFilterViewModel(floorManager: floorManager)
        let expectation = XCTestExpectation(
            description: "View model successfully initialized"
        )
        await viewModel.$isLoading
            .sink { loading in
                if !loading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 10.0)
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
        guard map.loadStatus == .loaded else {
            XCTFail("\(#fileID), \(#function), \(#line), Map not loaded")
            return nil
        }
        return map
    }
}
