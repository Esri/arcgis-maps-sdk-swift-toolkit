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
***REMOVED***@State
***REMOVED***private var map: Map
***REMOVED***
***REMOVED***@State
***REMOVED***private var viewpoint = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 1_000_000
***REMOVED***)
***REMOVED***
***REMOVED***@State
***REMOVED***private var floorFilterViewModel: FloorFilterViewModel? = nil
***REMOVED***
***REMOVED***init() {
***REMOVED******REMOVED******REMOVED*** Create the map from a portal item and assign to the mapView.
***REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***indoors.maps.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, itemId: "49520a67773842f1858602735ef538b5") ***REMOVED***<= multiple sites/facilities
***REMOVED******REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, itemId: "f133a698536f44c8884ad81f80b6cfc7") ***REMOVED***<= single site/facility
***REMOVED******REMOVED***map = Map(item: portalItem)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let map2 = Map(item: portalItem)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await map2.load()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("map2.loadStatus = \(map2.loadStatus)")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("error: \(error)")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Create the map from a portal item and assign to the mapView.
***REMOVED******REMOVED******REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***indoors.maps.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED******REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, itemId: "49520a67773842f1858602735ef538b5") ***REMOVED***<= multiple sites/facilities
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, itemId: "f133a698536f44c8884ad81f80b6cfc7") ***REMOVED***<= single site/facility
***REMOVED******REMOVED******REMOVED******REMOVED***await ArcGISURLSession.credentialStore.add(try await .indoors)
***REMOVED******REMOVED******REMOVED******REMOVED***map = Map(item: portalItem)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private let floorFilterPadding: CGFloat = 48
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .bottomLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED***if let viewModel = floorFilterViewModel {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FloorFilter(viewModel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(floorFilterPadding)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***var floorManager: FloorManager?
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***floorManager = map.floorManager
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await floorManager?.load()
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("FloorManager.loadStatus = \(String(describing: floorManager?.loadStatus))")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("load error: \(error)")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
