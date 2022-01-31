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

***REMOVED***/ Manages the state for a `FloorFilter`.
@MainActor
final public class FloorFilterViewModel: ObservableObject {
***REMOVED******REMOVED***/ Creates a `FloorFilterViewModel`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - floorManager: A floor manager.
***REMOVED******REMOVED***/   - viewpoint: Viewpoint updated when the selected site or facility changes.
***REMOVED***public init(
***REMOVED******REMOVED***floorManager: FloorManager,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint>? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***self.floorManager = floorManager
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try await floorManager.load()
***REMOVED******REMOVED******REMOVED******REMOVED***if sites.count == 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If we have only one site, select it.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedSite = sites.first
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch  {
***REMOVED******REMOVED******REMOVED******REMOVED***print("error: \(error)")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***isLoading = false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `Viewpoint` used to pan/zoom to the selected site/facilty.
***REMOVED******REMOVED***/ If `nil`, there will be no automatic pan/zoom operations.
***REMOVED***var viewpoint: Binding<Viewpoint>? = nil
***REMOVED***
***REMOVED******REMOVED***/ The `FloorManager` containing the site, floor, and level information.
***REMOVED***var floorManager: FloorManager
***REMOVED***
***REMOVED******REMOVED***/ The floor manager sites.
***REMOVED***public var sites: [FloorSite] {
***REMOVED******REMOVED***floorManager.sites
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ `true` if the model is loading it's properties, `false` if not loading.
***REMOVED***@Published
***REMOVED***public var isLoading = true
***REMOVED***
***REMOVED******REMOVED***/ Facilities in the selected site. If no site is selected then the list is empty.
***REMOVED******REMOVED***/ If the sites list is empty, all facilities will be returned.
***REMOVED***public var facilities: [FloorFacility] {
***REMOVED******REMOVED***sites.isEmpty ? floorManager.facilities : floorManager.facilities.filter {
***REMOVED******REMOVED******REMOVED***$0.site == selectedSite
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Levels in the selected facility. If no facility is selected then the list is empty.
***REMOVED******REMOVED***/ If the facilities list is empty, all levels will be returned. 
***REMOVED******REMOVED***/ The levels are returned in ascending order.
***REMOVED***public var levels: [FloorLevel] {
***REMOVED******REMOVED***facilities.isEmpty ? floorManager.levels : floorManager.levels.filter {
***REMOVED******REMOVED******REMOVED***$0.facility == selectedFacility
***REMOVED***.reversed()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ All the levels in the map
***REMOVED***public var allLevels: [FloorLevel] {
***REMOVED******REMOVED***floorManager.levels
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The selected site.
***REMOVED***@Published
***REMOVED***public var selectedSite: FloorSite? = nil {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***zoomToSite()
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ The selected facility.
***REMOVED***@Published
***REMOVED***public var selectedFacility: FloorFacility? = nil {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***zoomToFacility()
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ The selected level.
***REMOVED***@Published
***REMOVED***public var selectedLevel: FloorLevel? = nil
***REMOVED***
***REMOVED******REMOVED***/ Zooms to the selected facility; if there is no selected facility, zooms to the selected site.
***REMOVED***public func zoomToSelection() {
***REMOVED******REMOVED***if selectedFacility != nil {
***REMOVED******REMOVED******REMOVED***zoomToFacility()
***REMOVED*** else if selectedSite != nil {
***REMOVED******REMOVED******REMOVED***zoomToSite()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func zoomToSite() {
***REMOVED******REMOVED***zoomToExtent(extent: selectedSite?.geometry?.extent)
***REMOVED***
***REMOVED***
***REMOVED***private func zoomToFacility() {
***REMOVED******REMOVED***zoomToExtent(extent: selectedFacility?.geometry?.extent)
***REMOVED***
***REMOVED***
***REMOVED***private func zoomToExtent(extent: Envelope?) {
***REMOVED******REMOVED******REMOVED*** Make sure we have an extent and viewpoint to zoom to.
***REMOVED******REMOVED***guard let extent = extent,
***REMOVED******REMOVED******REMOVED***  let viewpoint = viewpoint
***REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let builder = EnvelopeBuilder(envelope: extent)
***REMOVED******REMOVED***builder.expand(factor: 1.5)
***REMOVED******REMOVED***let targetExtent = builder.toGeometry() as! Envelope
***REMOVED******REMOVED***if !targetExtent.isEmpty {
***REMOVED******REMOVED******REMOVED***viewpoint.wrappedValue = Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***targetExtent: targetExtent
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
