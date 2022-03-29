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
final class FloorFilterViewModel: ObservableObject {
***REMOVED******REMOVED***/  A selected site, floor, or level.
***REMOVED***enum Selection {
***REMOVED******REMOVED******REMOVED***/ A selected site.
***REMOVED******REMOVED***case site(FloorSite)
***REMOVED******REMOVED******REMOVED***/ A selected facility.
***REMOVED******REMOVED***case facility(FloorFacility)
***REMOVED******REMOVED******REMOVED***/ A selected level.
***REMOVED******REMOVED***case level(FloorLevel)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `FloorFilterViewModel`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - floorManager: The floor manager used by the `FloorFilterViewModel`.
***REMOVED******REMOVED***/   - viewpoint: Viewpoint updated when the selected site or facility changes.
***REMOVED***init(
***REMOVED******REMOVED***floorManager: FloorManager,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint>? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.floorManager = floorManager
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try await floorManager.load()
***REMOVED******REMOVED******REMOVED******REMOVED***if sites.count == 1, let firstSite = sites.first {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If we have only one site, select it.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection = .site(firstSite)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch  {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Note: Should user get to know about this error?
***REMOVED******REMOVED******REMOVED******REMOVED***print("error: \(error)")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***isLoading = false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `Viewpoint` used to pan/zoom to the selected site or facility.
***REMOVED******REMOVED***/ If `nil`, there will be no automatic pan/zoom operations.
***REMOVED***var viewpoint: Binding<Viewpoint>?
***REMOVED***
***REMOVED******REMOVED***/ The `FloorManager` containing the site, floor, and level information.
***REMOVED***let floorManager: FloorManager
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value that indicates whether the model is loading.
***REMOVED***@Published private(set) var isLoading = true
***REMOVED***
***REMOVED******REMOVED***/ The floor manager sites.
***REMOVED***var sites: [FloorSite] {
***REMOVED******REMOVED***floorManager.sites
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The floor manager facilities.
***REMOVED***var facilities: [FloorFacility] {
***REMOVED******REMOVED***floorManager.facilities
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The floor manager levels.
***REMOVED***var levels: [FloorLevel] {
***REMOVED******REMOVED***floorManager.levels
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The selected site, floor, or level.
***REMOVED***@Published var selection: Selection? {
***REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED***if case let .facility(facility) = selection,
***REMOVED******REMOVED******REMOVED***   let level = defaultLevel(for: facility) {
***REMOVED******REMOVED******REMOVED******REMOVED***selection = .level(level)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***filterMapToSelectedLevel()
***REMOVED******REMOVED***
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
***REMOVED******REMOVED***/ A Boolean value that indicates whether there are levels to display. This will be `false` if
***REMOVED******REMOVED***/ there is no selected facility or if the selected facility has no levels.
***REMOVED***var hasLevelsToDisplay: Bool {
***REMOVED******REMOVED***guard let selectedFacility = selectedFacility else {
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***return !selectedFacility.levels.isEmpty
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** Mark: Private Functions
***REMOVED***
***REMOVED******REMOVED***/ Zooms to the selected facility; if there is no selected facility, zooms to the selected site.
***REMOVED***private func zoomToSelection() {
***REMOVED******REMOVED***guard let selection = selection else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch selection {
***REMOVED******REMOVED***case .site(let site):
***REMOVED******REMOVED******REMOVED***zoomToExtent(site.geometry?.extent)
***REMOVED******REMOVED***case .facility(let facility):
***REMOVED******REMOVED******REMOVED***zoomToExtent(facility.geometry?.extent)
***REMOVED******REMOVED***case .level(let level):
***REMOVED******REMOVED******REMOVED***zoomToExtent(level.facility?.geometry?.extent)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Zoom to given extent.
***REMOVED***private func zoomToExtent(_ extent: Envelope?) {
***REMOVED******REMOVED******REMOVED*** Make sure we have an extent and viewpoint to zoom to.
***REMOVED******REMOVED***guard let extent = extent,
***REMOVED******REMOVED******REMOVED***  let viewpoint = viewpoint
***REMOVED******REMOVED***else { return ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let builder = EnvelopeBuilder(envelope: extent)
***REMOVED******REMOVED***builder.expand(factor: 1.5)
***REMOVED******REMOVED***let targetExtent = builder.toGeometry()
***REMOVED******REMOVED***if !targetExtent.isEmpty {
***REMOVED******REMOVED******REMOVED***viewpoint.wrappedValue = Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***targetExtent: targetExtent
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the visibility of all the levels on the map based on the vertical order of the current
***REMOVED******REMOVED***/ selected level.
***REMOVED***private func filterMapToSelectedLevel() {
***REMOVED******REMOVED***guard let selectedLevel = selectedLevel else { return ***REMOVED***
***REMOVED******REMOVED***levels.forEach {
***REMOVED******REMOVED******REMOVED***$0.isVisible = $0.verticalOrder == selectedLevel.verticalOrder
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Gets the default level for a facility.
***REMOVED******REMOVED***/ - Parameter facility: The facility to get the default level for.
***REMOVED******REMOVED***/ - Returns: The default level for the facility, which is the level with vertical order 0;
***REMOVED******REMOVED***/ if there's no level with vertical order of 0, it returns the lowest level.
***REMOVED***private func defaultLevel(for facility: FloorFacility?) -> FloorLevel? {
***REMOVED******REMOVED***return levels.first(where: { level in
***REMOVED******REMOVED******REMOVED***level.facility == facility && level.verticalOrder == .zero
***REMOVED***) ?? lowestLevel()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns the level with the lowest vertical order.
***REMOVED***private func lowestLevel() -> FloorLevel? {
***REMOVED******REMOVED***let sortedLevels = levels.sorted {
***REMOVED******REMOVED******REMOVED***$0.verticalOrder < $1.verticalOrder
***REMOVED***
***REMOVED******REMOVED***return sortedLevels.first {
***REMOVED******REMOVED******REMOVED***$0.verticalOrder != .min && $0.verticalOrder != .max
***REMOVED***
***REMOVED***
***REMOVED***
