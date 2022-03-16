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
***REMOVED***
import XCTest
@testable ***REMOVED***Toolkit

class FloorFilterTests: XCTestCase {
***REMOVED******REMOVED***/ Tests general behavior of `FloorFilterViewModel`.
***REMOVED***func testFloorFilterViewModel() async {
***REMOVED******REMOVED***let map = FloorFilterTests.makeMap()
***REMOVED******REMOVED******REMOVED*** FIXME: Credentials required
***REMOVED******REMOVED***try? await map.load()
***REMOVED******REMOVED***print(map.loadStatus)
***REMOVED***

***REMOVED******REMOVED***/ Get a map constructed from an ArcGIS portal item.
***REMOVED******REMOVED***/ - Returns: A map constructed from an ArcGIS portal item.
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED******REMOVED*** Multiple sites/facilities: Esri IST map with all buildings.
***REMOVED******REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***indoors.maps.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "49520a67773842f1858602735ef538b5")!)

***REMOVED******REMOVED******REMOVED*** Redlands Campus map with multiple sites and facilities.
***REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "7687805bd42549f5ba41237443d0c60a")!)

***REMOVED******REMOVED******REMOVED*** Single site (ESRI Redlands Main) and facility (Building L).
***REMOVED******REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***indoors.maps.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "f133a698536f44c8884ad81f80b6cfc7")!)

***REMOVED******REMOVED***return Map(item: portalItem)
***REMOVED***
***REMOVED***
