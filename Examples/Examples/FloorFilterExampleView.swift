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
***REMOVED***Toolkit
***REMOVED***

struct FloorFilterExampleView: View {
***REMOVED******REMOVED***/ Make a map from a portal item.
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED******REMOVED*** Multiple sites/facilities: Esri IST map with all buildings.
***REMOVED******REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***indoors.maps.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "49520a67773842f1858602735ef538b5")!)

***REMOVED******REMOVED******REMOVED*** Redlands Campus map with multiple sites and facilities
***REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***runtimecoretest.maps.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "7687805bd42549f5ba41237443d0c60a")!)

***REMOVED******REMOVED******REMOVED*** Single site (ESRI Redlands Main) and facility (Building L).
***REMOVED******REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***indoors.maps.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "f133a698536f44c8884ad81f80b6cfc7")!)

***REMOVED******REMOVED***return Map(item: portalItem)
***REMOVED***

***REMOVED******REMOVED***/ Determines the arrangement of the inner `FloorFilter` UI componenets.
***REMOVED***private let filterAlignment = Alignment.bottomLeading

***REMOVED******REMOVED***/ Determines the appropriate time to initialize the `FloorFilter`.
***REMOVED***@State
***REMOVED***private var isMapLoaded: Bool = false

***REMOVED******REMOVED***/ The `Map` that will be provided to the `MapView`.
***REMOVED***private var map = makeMap()

***REMOVED******REMOVED***/ The initial viewpoint of the map.
***REMOVED***@State
***REMOVED***private var viewpoint: Viewpoint? = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -117.19496, y: 34.05713, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 100_000
***REMOVED***)

***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = $0
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***/ Preserve the current viewpoint when a keyboard is presented in landscape.
***REMOVED******REMOVED******REMOVED***.ignoresSafeArea(.keyboard, edges: .bottom)
***REMOVED******REMOVED******REMOVED***.overlay(alignment: filterAlignment) {
***REMOVED******REMOVED******REMOVED******REMOVED***if isMapLoaded,
***REMOVED******REMOVED******REMOVED******REMOVED***   let floorManager = map.floorManager {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FloorFilter(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: filterAlignment,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***automaticSelectionMode: .always,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: 300, maxHeight: 300)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(36)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isMapLoaded = true
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("load error: \(error)")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
