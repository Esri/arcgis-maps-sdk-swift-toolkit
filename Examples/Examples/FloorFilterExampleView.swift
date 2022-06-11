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
***REMOVED******REMOVED***let portal = Portal(url: URL(string: "https:***REMOVED***www.arcgis.com/")!, isLoginRequired: false)
***REMOVED******REMOVED***let portalItem = PortalItem(portal: portal, id: Item.ID(rawValue: "b4b599a43a474d33946cf0df526426f5")!)
***REMOVED******REMOVED***return Map(item: portalItem)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines the arrangement of the inner `FloorFilter` UI componenets.
***REMOVED***private let floorFilterAlignment = Alignment.bottomLeading
***REMOVED***
***REMOVED******REMOVED***/ Determines the appropriate time to initialize the `FloorFilter`.
***REMOVED***@State private var isMapLoaded: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ The map is currently being navigated.
***REMOVED***@State private var isNavigating: Bool = false
***REMOVED***
***REMOVED***@State private var mapLoadError: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ The initial viewpoint of the map.
***REMOVED***@State private var viewpoint: Viewpoint? = Viewpoint(
***REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED***x: -117.19496,
***REMOVED******REMOVED******REMOVED***y: 34.05713,
***REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED***),
***REMOVED******REMOVED***scale: 100_000
***REMOVED***)
***REMOVED***
***REMOVED***@StateObject private var map = makeMap()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(
***REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.onNavigatingChanged {
***REMOVED******REMOVED******REMOVED***isNavigating = $0
***REMOVED***
***REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) {
***REMOVED******REMOVED******REMOVED***viewpoint = $0
***REMOVED***
***REMOVED******REMOVED******REMOVED***/ Preserve the current viewpoint when a keyboard is presented in landscape.
***REMOVED******REMOVED***.ignoresSafeArea(.keyboard, edges: .bottom)
***REMOVED******REMOVED***.overlay(alignment: floorFilterAlignment) {
***REMOVED******REMOVED******REMOVED***if isMapLoaded,
***REMOVED******REMOVED******REMOVED***   let floorManager = map.floorManager {
***REMOVED******REMOVED******REMOVED******REMOVED***FloorFilter(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: floorFilterAlignment,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isNavigating: $isNavigating
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: 400,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxHeight: 400
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(36)
***REMOVED******REMOVED*** else if mapLoadError {
***REMOVED******REMOVED******REMOVED******REMOVED***Label(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Map load error!",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***systemImage: "exclamationmark.triangle"
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.red)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: .infinity,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxHeight: .infinity,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .center
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED******REMOVED******REMOVED***isMapLoaded = true
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***mapLoadError = true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
