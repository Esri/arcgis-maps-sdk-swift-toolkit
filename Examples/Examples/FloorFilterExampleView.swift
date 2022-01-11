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
***REMOVED***private let map: Map
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
***REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, itemId: "f133a698536f44c8884ad81f80b6cfc7")
***REMOVED******REMOVED***map = Map(item: portalItem)
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
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let floorManager = map.floorManager else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***floorFilterViewModel = FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** catch  { ***REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
