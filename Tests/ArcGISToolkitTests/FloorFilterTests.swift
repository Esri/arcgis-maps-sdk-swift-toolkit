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
import SwiftUI
import XCTest
@testable import ArcGISToolkit

class FloorFilterTests: XCTestCase {
    /// Tests general behavior of `FloorFilterViewModel`.
    func testFloorFilterViewModel() async {
        let map = FloorFilterTests.makeMap()
        // FIXME: Credentials required
        try? await map.load()
        print(map.loadStatus)
    }

    /// Get a map constructed from an ArcGIS portal item.
    /// - Returns: A map constructed from an ArcGIS portal item.
    static func makeMap() -> Map {
        // Multiple sites/facilities: Esri IST map with all buildings.
//        let portal = Portal(url: URL(string: "https://indoors.maps.arcgis.com/")!, isLoginRequired: false)
//        let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "49520a67773842f1858602735ef538b5")!)

        // Redlands Campus map with multiple sites and facilities.
        let portal = Portal(url: URL(string: "https://runtimecoretest.maps.arcgis.com/")!, isLoginRequired: false)
        let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "7687805bd42549f5ba41237443d0c60a")!)

        // Single site (ESRI Redlands Main) and facility (Building L).
//        let portal = Portal(url: URL(string: "https://indoors.maps.arcgis.com/")!, isLoginRequired: false)
//        let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "f133a698536f44c8884ad81f80b6cfc7")!)

        return Map(item: portalItem)
    }
}
