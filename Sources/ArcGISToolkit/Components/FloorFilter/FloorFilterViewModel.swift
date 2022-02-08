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
***REMOVED******REMOVED***/  A selected site, floor, or level.
***REMOVED***public enum Selection {
***REMOVED******REMOVED******REMOVED***/ A selected site.
***REMOVED******REMOVED***case site(FloorSite)
***REMOVED******REMOVED******REMOVED***/ A selected facility.
***REMOVED******REMOVED***case facility(FloorFacility)
***REMOVED******REMOVED******REMOVED***/ A selected level.
***REMOVED******REMOVED***case level(FloorLevel)
***REMOVED***

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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection = .site(sites.first!)
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
***REMOVED***let viewpoint: Binding<Viewpoint>?
***REMOVED***
***REMOVED******REMOVED***/ The `FloorManager` containing the site, floor, and level information.
***REMOVED***let floorManager: FloorManager
***REMOVED***
***REMOVED******REMOVED***/ The floor manager sites.
***REMOVED***public var sites: [FloorSite] {
***REMOVED******REMOVED***floorManager.sites
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The floor manager facilities.
***REMOVED***public var facilities: [FloorFacility] {
***REMOVED******REMOVED***floorManager.facilities
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The floor manager levels.
***REMOVED***public var levels: [FloorLevel] {
***REMOVED******REMOVED***floorManager.levels
***REMOVED***

***REMOVED******REMOVED***/ `true` if the model is loading it's properties, `false` if not loading.
***REMOVED***@Published
***REMOVED***private(set) var isLoading = true
***REMOVED***
***REMOVED******REMOVED***/ The selected site, floor, or level.
***REMOVED***@Published
***REMOVED***public var selection: Selection? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***zoomToSelection()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The selected site.
***REMOVED***var selectedSite: FloorSite? {
***REMOVED******REMOVED***guard let selection = selection else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch selection {
***REMOVED******REMOVED***case .site(let site):
***REMOVED******REMOVED******REMOVED***return site
***REMOVED******REMOVED***case .facility(let facility):
***REMOVED******REMOVED******REMOVED***return facility.site
***REMOVED******REMOVED***case .level(let level):
***REMOVED******REMOVED******REMOVED***return level.facility?.site
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The selected facility.
***REMOVED***var selectedFacility: FloorFacility? {
***REMOVED******REMOVED***guard let selection = selection else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch selection {
***REMOVED******REMOVED***case .site:
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***case .facility(let facility):
***REMOVED******REMOVED******REMOVED***return facility
***REMOVED******REMOVED***case .level(let level):
***REMOVED******REMOVED******REMOVED***return level.facility
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The selected level.
***REMOVED***var selectedLevel: FloorLevel? {
***REMOVED******REMOVED***if case let .level(level) = selection {
***REMOVED******REMOVED******REMOVED***return level
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Zooms to the selected facility; if there is no selected facility, zooms to the selected site.
***REMOVED***public func zoomToSelection() {
***REMOVED******REMOVED***guard let selection = selection else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch selection {
***REMOVED******REMOVED***case .site(let site):
***REMOVED******REMOVED******REMOVED***zoomToExtent(extent: site.geometry?.extent)
***REMOVED******REMOVED***case .facility(let facility):
***REMOVED******REMOVED******REMOVED***zoomToExtent(extent: facility.geometry?.extent)
***REMOVED******REMOVED***case .level:
***REMOVED******REMOVED******REMOVED***break
***REMOVED***
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
