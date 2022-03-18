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
***REMOVED******REMOVED***/ Creates a `FloorFilterViewModel`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - automaticSelectionMode: The selection behavior of the floor filter.
***REMOVED******REMOVED***/   - floorManager: The floor manager used by the `FloorFilterViewModel`.
***REMOVED******REMOVED***/   - viewpoint: Viewpoint updated when the selected site or facility changes.
***REMOVED***init(
***REMOVED******REMOVED***automaticSelectionMode: AutomaticSelectionMode = .always,
***REMOVED******REMOVED***floorManager: FloorManager,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>
***REMOVED***) {
***REMOVED******REMOVED***self.automaticSelectionMode = automaticSelectionMode
***REMOVED******REMOVED***self.floorManager = floorManager
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try await floorManager.load()
***REMOVED******REMOVED******REMOVED******REMOVED***if sites.count == 1,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let firstSite = sites.first {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If we have only one site, select it.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***setSite(firstSite, zoomTo: true)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***print("error: \(error)")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***isLoading = false
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ The selection behavior of the floor filter.
***REMOVED***private let automaticSelectionMode: AutomaticSelectionMode

***REMOVED******REMOVED***/ The `Viewpoint` used to pan/zoom to the selected site/facilty.
***REMOVED******REMOVED***/ If `nil`, there will be no automatic pan/zoom operations.
***REMOVED***var viewpoint: Binding<Viewpoint?>

***REMOVED******REMOVED***/ The `FloorManager` containing the site, floor, and level information.
***REMOVED***let floorManager: FloorManager

***REMOVED******REMOVED***/ The floor manager sites.
***REMOVED***var sites: [FloorSite] {
***REMOVED******REMOVED***floorManager.sites
***REMOVED***

***REMOVED******REMOVED***/ The floor manager facilities.
***REMOVED***var facilities: [FloorFacility] {
***REMOVED******REMOVED***floorManager.facilities
***REMOVED***

***REMOVED******REMOVED***/ The floor manager levels.
***REMOVED***var levels: [FloorLevel] {
***REMOVED******REMOVED***floorManager.levels
***REMOVED***

***REMOVED******REMOVED***/ `true` if the model is loading it's properties, `false` if not loading.
***REMOVED***@Published
***REMOVED***private(set) var isLoading = true

***REMOVED******REMOVED***/ Gets the default level for a facility.
***REMOVED******REMOVED***/ - Parameter facility: The facility to get the default level for.
***REMOVED******REMOVED***/ - Returns: The default level for the facility, which is the level with vertical order 0;
***REMOVED******REMOVED***/ if there's no level with vertical order of 0, it returns the lowest level.
***REMOVED***func defaultLevel(for facility: FloorFacility?) -> FloorLevel? {
***REMOVED******REMOVED***return levels.first(where: { level in
***REMOVED******REMOVED******REMOVED***level.facility == facility && level.verticalOrder == .zero
***REMOVED***) ?? lowestLevel()
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

***REMOVED***@Published
***REMOVED***var selectedSite: FloorSite?

***REMOVED***@Published
***REMOVED***var selectedFacility: FloorFacility?

***REMOVED***@Published
***REMOVED***var selectedLevel: FloorLevel?

***REMOVED******REMOVED*** MARK: Set selection methods

***REMOVED******REMOVED***/ Updates the selected site, facility, and level based on a newly selected site.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - floorSite: The selected site.
***REMOVED******REMOVED***/   - zoomTo: The viewpoint should be updated to show to the extent of this site.
***REMOVED***func setSite(
***REMOVED******REMOVED***_ floorSite: FloorSite?,
***REMOVED******REMOVED***zoomTo: Bool = false
***REMOVED***) {
***REMOVED******REMOVED***selectedSite = floorSite
***REMOVED******REMOVED***selectedFacility = nil
***REMOVED******REMOVED***selectedLevel = nil
***REMOVED******REMOVED***if zoomTo {
***REMOVED******REMOVED******REMOVED***zoomToExtent(extent: floorSite?.geometry?.extent)
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ Updates the selected site, facility, and level based on a newly selected facility.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - floorFacility: The selected facility.
***REMOVED******REMOVED***/   - zoomTo: The viewpoint should be updated to show to the extent of this facility.
***REMOVED***func setFacility(
***REMOVED******REMOVED***_ floorFacility: FloorFacility?,
***REMOVED******REMOVED***zoomTo: Bool = false
***REMOVED***) {
***REMOVED******REMOVED***selectedSite = floorFacility?.site
***REMOVED******REMOVED***selectedFacility = floorFacility
***REMOVED******REMOVED***selectedLevel = defaultLevel(for: floorFacility)
***REMOVED******REMOVED***if zoomTo {
***REMOVED******REMOVED******REMOVED***zoomToExtent(extent: floorFacility?.geometry?.extent)
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ Updates the selected site, facility, and level based on a newly selected level.
***REMOVED******REMOVED***/ - Parameter floorLevel: The selected level.
***REMOVED***func setLevel(_ floorLevel: FloorLevel?) {
***REMOVED******REMOVED***selectedSite = floorLevel?.facility?.site
***REMOVED******REMOVED***selectedFacility = floorLevel?.facility
***REMOVED******REMOVED***selectedLevel = floorLevel
***REMOVED******REMOVED***filterMapToSelectedLevel()
***REMOVED***

***REMOVED******REMOVED***/ Updates `selectedSite` and `selectedFacility` based on the latest viewpoint position.
***REMOVED***func updateSelection() {
***REMOVED******REMOVED***guard let viewpoint = viewpoint.wrappedValue,
***REMOVED******REMOVED******REMOVED******REMOVED***  !viewpoint.targetScale.isZero,
***REMOVED******REMOVED******REMOVED******REMOVED***automaticSelectionMode != .never else {
***REMOVED******REMOVED******REMOVED******REMOVED***  return
***REMOVED***  ***REMOVED***

***REMOVED******REMOVED******REMOVED*** Only take action if viewpoint is within minimum scale. Default
***REMOVED******REMOVED******REMOVED*** minscale is 4300 or less (~zoom level 17 or greater)
***REMOVED******REMOVED***var targetScale = floorManager.siteLayer?.minScale ?? .zero
***REMOVED******REMOVED***if targetScale.isZero {
***REMOVED******REMOVED******REMOVED***targetScale = 4300
***REMOVED***

***REMOVED******REMOVED******REMOVED*** If viewpoint is out of range, reset selection (if not non-clearing)
***REMOVED******REMOVED******REMOVED*** and return
***REMOVED******REMOVED***if viewpoint.targetScale > targetScale {
***REMOVED******REMOVED******REMOVED***if automaticSelectionMode == .always {
***REMOVED******REMOVED******REMOVED******REMOVED***setSite(nil)
***REMOVED******REMOVED******REMOVED******REMOVED***setFacility(nil)
***REMOVED******REMOVED******REMOVED******REMOVED***setLevel(nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Assumption: if too zoomed out to see sites, also too zoomed out
***REMOVED******REMOVED******REMOVED******REMOVED*** to see facilities
***REMOVED******REMOVED******REMOVED***return
***REMOVED***

***REMOVED******REMOVED***let facilityResult = floorManager.facilities.first { facility in
***REMOVED******REMOVED******REMOVED***guard let facilityExtent = facility.geometry?.extent else {
***REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return GeometryEngine.intersects(
***REMOVED******REMOVED******REMOVED******REMOVED***geometry1: facilityExtent,
***REMOVED******REMOVED******REMOVED******REMOVED***geometry2: viewpoint.targetGeometry
***REMOVED******REMOVED******REMOVED***)
***REMOVED***

***REMOVED******REMOVED***if let facilityResult = facilityResult {
***REMOVED******REMOVED******REMOVED***setFacility(facilityResult)
***REMOVED******REMOVED******REMOVED***return
***REMOVED*** else if automaticSelectionMode == .always {
***REMOVED******REMOVED******REMOVED***setFacility(nil)
***REMOVED***

***REMOVED******REMOVED******REMOVED*** If the centerpoint is within a site's geometry, select that site.
***REMOVED******REMOVED******REMOVED*** This code gracefully skips selection if there are no sites or no
***REMOVED******REMOVED******REMOVED*** matching sites
***REMOVED******REMOVED***let siteResult = floorManager.sites.first { site in
***REMOVED******REMOVED******REMOVED***guard let siteExtent = site.geometry?.extent else {
***REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return GeometryEngine.intersects(
***REMOVED******REMOVED******REMOVED******REMOVED***geometry1: siteExtent,
***REMOVED******REMOVED******REMOVED******REMOVED***geometry2: viewpoint.targetGeometry
***REMOVED******REMOVED******REMOVED***)
***REMOVED***

***REMOVED******REMOVED***if let siteResult = siteResult {
***REMOVED******REMOVED******REMOVED***setSite(siteResult)
***REMOVED*** else if automaticSelectionMode == .always {
***REMOVED******REMOVED******REMOVED***setSite(nil)
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ Sets the visibility of all the levels on the map based on the vertical order of the current selected level.
***REMOVED***private func filterMapToSelectedLevel() {
***REMOVED******REMOVED***guard let selectedLevel = selectedLevel else { return ***REMOVED***
***REMOVED******REMOVED***levels.forEach {
***REMOVED******REMOVED******REMOVED***$0.isVisible = $0.verticalOrder == selectedLevel.verticalOrder
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ Updates the viewpoint to display a given extent.
***REMOVED******REMOVED***/ - Parameter extent: The new extent to be shown.
***REMOVED***private func zoomToExtent(extent: Envelope?) {
***REMOVED******REMOVED******REMOVED*** Make sure we have an extent and viewpoint to zoom to.
***REMOVED******REMOVED***guard let extent = extent else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***

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

extension FloorSite: Hashable {
***REMOVED***public func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(self.siteId)
***REMOVED******REMOVED***hasher.combine(self.name)
***REMOVED***
***REMOVED***

***REMOVED***/ Defines automatic selection behavior.
public enum AutomaticSelectionMode {
***REMOVED******REMOVED***/ Always update selection based on the current viewpoint; clear the selection when the user
***REMOVED******REMOVED***/ navigates away.
***REMOVED***case always
***REMOVED******REMOVED***/ Only update the selection when there is a new site or facility in the current viewpoint; don't clear
***REMOVED******REMOVED***/ selection when the user navigates away.
***REMOVED***case alwaysNotClearing
***REMOVED******REMOVED***/ Never update selection based on the GeoView's current viewpoint.
***REMOVED***case never
***REMOVED***
