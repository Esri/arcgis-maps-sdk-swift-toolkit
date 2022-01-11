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

/*
 
 ***REMOVED*** method that gets/sets the facility in the floor filter using the facility ID
 string selectedFacilityId()
 void setSelectedFacilityId(string facilityId)
 
 ***REMOVED*** method that gets/sets the level in the floor filter using the level ID
 string selectedLevelId()
 void setSelectedtLevelId(String levelId)
 
 ***REMOVED*** method that gets/sets the site in the floor filter using the site ID
 string selectedSiteId()
 void setSelectedSiteId(String siteId)
 
 */

***REMOVED***/ View Model class that contains the Data Model of the Floor Filter
***REMOVED***/ Also contains the business logic to filter and change the map extent based on selected site/level/facility
public class FloorFilterViewModel {
***REMOVED***public init(
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint>? = nil,
***REMOVED******REMOVED***floorManager: FloorManager
***REMOVED***) {
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***self.floorManager = floorManager
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `Viewpoint` used to pan/zoom to the floor level. If `nil`, there will be no zooming.
***REMOVED***public var viewpoint: Binding<Viewpoint>? = nil
***REMOVED***
***REMOVED***public var floorManager: FloorManager
***REMOVED***
***REMOVED***public var sites: [FloorSite] {
***REMOVED******REMOVED***return floorManager.sites
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Facilities in the selected site
***REMOVED******REMOVED***/ If no site is selected then the list is empty
***REMOVED******REMOVED***/ If the sites data does not exist in the map, then use all the facilities in the map
***REMOVED***public var facilities: [FloorFacility] {
***REMOVED******REMOVED***return sites.isEmpty ? floorManager.facilities : floorManager.facilities.filter {
***REMOVED******REMOVED******REMOVED***$0.site == selectedSite
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Levels that are visible in the expanded Floor Filter levels table view
***REMOVED******REMOVED***/ Reverse the order of the levels to make it in ascending order
***REMOVED***public var visibleLevelsInExpandedList: [FloorLevel] {
***REMOVED******REMOVED***return facilities.isEmpty ? floorManager.levels : floorManager.levels.filter {
***REMOVED******REMOVED******REMOVED***$0.facility == selectedFacility
***REMOVED***.reversed()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ All the levels in the map
***REMOVED***public var allLevels: [FloorLevel] {
***REMOVED******REMOVED***return floorManager.levels
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The site, facility, and level that are selected by the user
***REMOVED***public var selectedSite: FloorSite? = nil
***REMOVED***public var selectedFacility: FloorFacility? = nil
***REMOVED***public var selectedLevel: FloorLevel? = nil
***REMOVED***
***REMOVED******REMOVED***/ The default vertical order is 0 according to Runtime 100.12 update for FloorManager
***REMOVED***public let defaultVerticalOrder: Int32 = 0
***REMOVED***
***REMOVED***public func reset() {
***REMOVED******REMOVED***selectedSite = nil
***REMOVED******REMOVED***selectedFacility = nil
***REMOVED******REMOVED***selectedLevel = nil
***REMOVED***
***REMOVED***
***REMOVED***public func getDefaultLevelForFacility(facility: FloorFacility?) -> FloorLevel? {
***REMOVED******REMOVED***let candidateLevels = allLevels.filter {$0.facility == facility***REMOVED***
***REMOVED******REMOVED***return candidateLevels.first {$0.verticalOrder == 0***REMOVED*** ?? getLowestLevel(levels: candidateLevels)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns the FloorLevel with the lowest verticalOrder.
***REMOVED***private func getLowestLevel(levels: [FloorLevel]) -> FloorLevel? {
***REMOVED******REMOVED***var lowestLevel: FloorLevel? = nil
***REMOVED******REMOVED***allLevels.forEach {
***REMOVED******REMOVED******REMOVED***if ($0.verticalOrder != Int.min && $0.verticalOrder != Int.max) {
***REMOVED******REMOVED******REMOVED******REMOVED***let lowestVerticalOrder = lowestLevel?.verticalOrder
***REMOVED******REMOVED******REMOVED******REMOVED***if (lowestVerticalOrder == nil || lowestVerticalOrder ?? defaultVerticalOrder > $0.verticalOrder) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lowestLevel = $0
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***return lowestLevel
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the visibility of all the levels on the map based on the vertical order of the current selected level
***REMOVED***public func filterMapToSelectedLevel() {
***REMOVED******REMOVED***guard let selectedLevel = selectedLevel else { return ***REMOVED***
***REMOVED******REMOVED***allLevels.forEach {
***REMOVED******REMOVED******REMOVED***$0.isVisible = $0.verticalOrder == selectedLevel.verticalOrder
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Zooms to the facility if there is a selected facility, otherwise zooms to the site.
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

extension UIImage {
***REMOVED***static var site: UIImage {
***REMOVED******REMOVED***return UIImage(named: "Site", in: Bundle.module, with: nil)!
***REMOVED***
***REMOVED***
