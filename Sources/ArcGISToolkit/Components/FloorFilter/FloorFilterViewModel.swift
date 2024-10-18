***REMOVED*** Copyright 2022 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import Combine
***REMOVED***

***REMOVED***/ Manages the state for a `FloorFilter`.
@MainActor
@available(visionOS, unavailable)
final class FloorFilterViewModel: ObservableObject {
***REMOVED******REMOVED***/ Creates a `FloorFilterViewModel`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - automaticSelectionMode: The selection behavior of the floor filter.
***REMOVED******REMOVED***/   - floorManager: The floor manager used by the `FloorFilterViewModel`.
***REMOVED******REMOVED***/   - viewpoint: Viewpoint updated when the selected site or facility changes.
***REMOVED***init(
***REMOVED******REMOVED***automaticSelectionMode: FloorFilterAutomaticSelectionMode = .always,
***REMOVED******REMOVED***floorManager: FloorManager,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>
***REMOVED***) {
***REMOVED******REMOVED***self.automaticSelectionMode = automaticSelectionMode
***REMOVED******REMOVED***self.floorManager = floorManager
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***
***REMOVED******REMOVED***loadFloorManager()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Published members
***REMOVED***
***REMOVED******REMOVED***/ `true` if the model is loading it's properties, `false` if not loading.
***REMOVED***@Published private(set) var isLoading = true
***REMOVED***
***REMOVED******REMOVED***/ The selected site, floor, or level.
***REMOVED***@Published private(set) var selection: FloorFilterSelection?
***REMOVED***
***REMOVED******REMOVED*** MARK: Constants
***REMOVED***
***REMOVED******REMOVED***/ The selection behavior of the floor filter.
***REMOVED***private let automaticSelectionMode: FloorFilterAutomaticSelectionMode
***REMOVED***
***REMOVED******REMOVED***/ The `FloorManager` containing the site, floor, and level information.
***REMOVED***private let floorManager: FloorManager
***REMOVED***
***REMOVED******REMOVED*** MARK: Properties
***REMOVED***
***REMOVED******REMOVED***/ The floor manager facilities.
***REMOVED***var facilities: [FloorFacility] {
***REMOVED******REMOVED***floorManager.facilities
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value that indicates whether there are levels to display. This will be `false` if
***REMOVED******REMOVED***/ there is no selected facility or if the selected facility has no levels.
***REMOVED***var hasLevelsToDisplay: Bool {
***REMOVED******REMOVED***!(selection?.facility?.levels.isEmpty ?? true)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The floor manager levels.
***REMOVED***var levels: [FloorLevel] {
***REMOVED******REMOVED***floorManager.levels
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The floor manager sites.
***REMOVED***var sites: [FloorSite] {
***REMOVED******REMOVED***floorManager.sites.sorted { $0.name <  $1.name ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The selected facility's levels, sorted by `level.verticalOrder`.
***REMOVED***var sortedLevels: [FloorLevel] {
***REMOVED******REMOVED***selection?.facility?.levels
***REMOVED******REMOVED******REMOVED***.sorted(by: { $0.verticalOrder > $1.verticalOrder ***REMOVED***) ?? []
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Methods
***REMOVED***
***REMOVED******REMOVED***/ Sets the current selection to `nil`.
***REMOVED***func clearSelection() {
***REMOVED******REMOVED***selection = nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Allows model users to alert the model that the viewpoint has changed.
***REMOVED***func onViewpointChanged(_ viewpoint: Viewpoint?) {
***REMOVED******REMOVED***guard let viewpoint = viewpoint,
***REMOVED******REMOVED******REMOVED***  !viewpoint.targetScale.isZero else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***automaticallySelectFacilityOrSite()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the selected site, facility, and level based on a newly selected facility.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - newFacility: The new facility to be selected.
***REMOVED******REMOVED***/   - zoomTo: If `true`, changes the viewpoint to the extent of the new facility.
***REMOVED***func setFacility(_ newFacility: FloorFacility, zoomTo: Bool = false) {
***REMOVED******REMOVED***if let oldLevel = selection?.level,
***REMOVED******REMOVED***   let newLevel = newFacility.levels.first(
***REMOVED******REMOVED******REMOVED***where: { $0.verticalOrder == oldLevel.verticalOrder ***REMOVED***
***REMOVED******REMOVED***   ) {
***REMOVED******REMOVED******REMOVED***setLevel(newLevel)
***REMOVED*** else if let defaultLevel = newFacility.defaultLevel {
***REMOVED******REMOVED******REMOVED***setLevel(defaultLevel)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***selection = .facility(newFacility)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if zoomTo {
***REMOVED******REMOVED******REMOVED***zoomToExtent(newFacility.geometry?.extent)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the selected site, facility, and level based on a newly selected level.
***REMOVED******REMOVED***/ - Parameter newLevel: The selected level.
***REMOVED***func setLevel(_ newLevel: FloorLevel) {
***REMOVED******REMOVED***selection = .level(newLevel)
***REMOVED******REMOVED***levels.forEach {
***REMOVED******REMOVED******REMOVED***$0.isVisible = $0.verticalOrder == newLevel.verticalOrder
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the selected site, facility, and level based on a newly selected site.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - newSite: The new site to be selected.
***REMOVED******REMOVED***/   - zoomTo: If `true`, changes the viewpoint to the extent of the new site.
***REMOVED***func setSite(_ newSite: FloorSite, zoomTo: Bool = false) {
***REMOVED******REMOVED***selection = .site(newSite)
***REMOVED******REMOVED***if zoomTo {
***REMOVED******REMOVED******REMOVED***zoomToExtent(newSite.geometry?.extent)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Attempts to make an automated selection based on the current viewpoint.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This method first attempts to select a facility, if that fails, site selection is attempted.
***REMOVED***func automaticallySelectFacilityOrSite() {
***REMOVED******REMOVED***guard automaticSelectionMode != .never else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***if !autoSelectFacility() {
***REMOVED******REMOVED******REMOVED***autoSelectSite()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Private items
***REMOVED***
***REMOVED******REMOVED***/ The `Viewpoint` used to pan/zoom to the selected site/facility.
***REMOVED******REMOVED***/ If `nil`, there will be no automatic pan/zoom operations.
***REMOVED***private var viewpoint: Binding<Viewpoint?>
***REMOVED***
***REMOVED******REMOVED***/ Updates `selectedFacility` if a good selection exists.
***REMOVED******REMOVED***/ - Returns: `false` if a selection was not made.
***REMOVED***@discardableResult
***REMOVED***private func autoSelectFacility() -> Bool {
***REMOVED******REMOVED******REMOVED*** Only select a facility if it is within minimum scale. Default at 1500.
***REMOVED******REMOVED***let facilityMinScale: Double
***REMOVED******REMOVED***if let minScale = floorManager.facilityLayer?.minScale,
***REMOVED******REMOVED***   minScale != .zero {
***REMOVED******REMOVED******REMOVED***facilityMinScale = minScale
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***facilityMinScale = 1500
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if viewpoint.wrappedValue?.targetScale ?? .zero > facilityMinScale {
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** If the centerpoint is within a facilities' geometry, select that site.
***REMOVED******REMOVED***let facilityResult = floorManager.facilities.first { facility in
***REMOVED******REMOVED******REMOVED***guard let extent1 = viewpoint.wrappedValue?.targetGeometry.extent,
***REMOVED******REMOVED******REMOVED******REMOVED***  let extent2 = facility.geometry?.extent else {
***REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return GeometryEngine.isGeometry(extent1, intersecting: extent2)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let facilityResult = facilityResult {
***REMOVED******REMOVED******REMOVED***setFacility(facilityResult)
***REMOVED*** else if automaticSelectionMode == .always {
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***return true
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates `selectedSite` if a good selection exists.
***REMOVED******REMOVED***/ - Returns: `false` if a selection was not made.
***REMOVED***@discardableResult
***REMOVED***private func autoSelectSite() -> Bool {
***REMOVED******REMOVED******REMOVED*** Only select a facility if it is within minimum scale. Default at 4300.
***REMOVED******REMOVED***let siteMinScale: Double
***REMOVED******REMOVED***if let minScale = floorManager.siteLayer?.minScale,
***REMOVED******REMOVED***   minScale != .zero {
***REMOVED******REMOVED******REMOVED***siteMinScale = minScale
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***siteMinScale = 4300
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** If viewpoint is out of range, reset selection and return early.
***REMOVED******REMOVED***if viewpoint.wrappedValue?.targetScale ?? .zero > siteMinScale {
***REMOVED******REMOVED******REMOVED***if automaticSelectionMode == .always {
***REMOVED******REMOVED******REMOVED******REMOVED***clearSelection()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** If the centerpoint is within a site's geometry, select that site.
***REMOVED******REMOVED***let siteResult = sites.first { site in
***REMOVED******REMOVED******REMOVED***guard let extent1 = viewpoint.wrappedValue?.targetGeometry.extent,
***REMOVED******REMOVED******REMOVED******REMOVED***  let extent2 = site.geometry?.extent else {
***REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return GeometryEngine.isGeometry(extent1, intersecting: extent2)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let siteResult {
***REMOVED******REMOVED******REMOVED***setSite(siteResult)
***REMOVED*** else if automaticSelectionMode == .always {
***REMOVED******REMOVED******REMOVED***clearSelection()
***REMOVED***
***REMOVED******REMOVED***return true
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the visibility of all the levels on the map based on the vertical order of the current
***REMOVED******REMOVED***/ selected level.
***REMOVED***private func filterMapToSelectedLevel() {
***REMOVED******REMOVED***if let selectedLevel = selection?.level {
***REMOVED******REMOVED******REMOVED***levels.forEach {
***REMOVED******REMOVED******REMOVED******REMOVED***$0.isVisible = $0.verticalOrder == selectedLevel.verticalOrder
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Loads the given `FloorManager` if needed, then sets `isLoading` to `false`.
***REMOVED***private func loadFloorManager() {
***REMOVED******REMOVED***guard floorManager.loadStatus == .notLoaded,
***REMOVED******REMOVED******REMOVED***  floorManager.loadStatus != .loading else {
***REMOVED******REMOVED******REMOVED***isLoading = false
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***try await floorManager.load()
***REMOVED******REMOVED******REMOVED******REMOVED***if sites.count == 1,
***REMOVED******REMOVED******REMOVED******REMOVED***   let firstSite = sites.first {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If we have only one site, select it.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***setSite(firstSite, zoomTo: true)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***print("error: \(error)")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***isLoading = false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Zoom to given extent.
***REMOVED***private func zoomToExtent(_ extent: Envelope?) {
***REMOVED******REMOVED******REMOVED*** Make sure we have an extent and viewpoint to zoom to.
***REMOVED******REMOVED***guard let extent = extent else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let builder = EnvelopeBuilder(envelope: extent)
***REMOVED******REMOVED***builder.expand(by: 1.5)
***REMOVED******REMOVED***let targetExtent = builder.toGeometry()
***REMOVED******REMOVED***if !targetExtent.isEmpty {
***REMOVED******REMOVED******REMOVED***viewpoint.wrappedValue = Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***boundingGeometry: targetExtent
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
