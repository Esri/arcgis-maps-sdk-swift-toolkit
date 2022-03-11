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

***REMOVED***/ The `FloorFilter` component simplifies visualization of GIS data for a specific floor of a building
***REMOVED***/ in your application. It allows you to filter the floor plan data displayed in your map or scene view
***REMOVED***/ to a site, a facility (building) in the site, or a floor in the facility.
public struct FloorFilter: View {
***REMOVED******REMOVED***/ Creates a `FloorFilter`
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - floorManager: The floor manager used by the `FloorFilter`.
***REMOVED******REMOVED***/   - automaticSelectionMode: The selection behavior of the floor filter.
***REMOVED******REMOVED***/   - viewpoint: Viewpoint updated when the selected site or facility changes.
***REMOVED***public init(
***REMOVED******REMOVED***floorManager: FloorManager,
***REMOVED******REMOVED***automaticSelectionMode: AutomaticSelectionMode = .always,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint>? = nil
***REMOVED***) {
***REMOVED******REMOVED***_viewModel = StateObject(wrappedValue: FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***))
***REMOVED******REMOVED***self.automaticSelectionMode = automaticSelectionMode
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED***

***REMOVED******REMOVED***/ The selection behavior of the floor filter.
***REMOVED***private let automaticSelectionMode: AutomaticSelectionMode

***REMOVED******REMOVED***/ A Boolean value that indicates whether there are levels to display.  This will be false if
***REMOVED******REMOVED***/ there is no selected facility or if the selected facility has no levels.
***REMOVED***private var hasLevelsToDisplay: Bool {
***REMOVED******REMOVED***!(viewModel.selectedFacility == nil ||
***REMOVED******REMOVED***  viewModel.selectedFacility!.levels.isEmpty)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value that indicates whether the site/facility selector is hidden.
***REMOVED***@State
***REMOVED***private var isSelectorHidden: Bool = true
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value that indicates whether the levels view is currently collapsed.
***REMOVED***@State
***REMOVED***private var isLevelsViewCollapsed: Bool = false

***REMOVED******REMOVED***/ Indicates the implicity selected facility based on the current viewpoint.
***REMOVED***@State
***REMOVED***private var selectedFacilityID: String? = nil

***REMOVED******REMOVED***/ Indicates the implicity selected site based on the current viewpoint.
***REMOVED***@State
***REMOVED***private var selectedSiteID: String? = nil
***REMOVED***
***REMOVED******REMOVED***/ The selected facility's levels, sorted by `level.verticalOrder`.
***REMOVED***private var sortedLevels: [FloorLevel] {
***REMOVED******REMOVED***viewModel.selectedFacility?.levels.sorted() {
***REMOVED******REMOVED******REMOVED***$0.verticalOrder > $1.verticalOrder
***REMOVED*** ?? []
***REMOVED***

***REMOVED******REMOVED***/ The view model used by the `FloorFilter`.
***REMOVED***@StateObject
***REMOVED***private var viewModel: FloorFilterViewModel

***REMOVED******REMOVED***/ The `Viewpoint` used to pan/zoom to the selected site/facilty.
***REMOVED******REMOVED***/ If `nil`, there will be no automatic pan/zoom operations or automatic selection support.
***REMOVED***private var viewpoint: Binding<Viewpoint>?
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if viewModel.isLoading {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(12)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if hasLevelsToDisplay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***LevelsView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***levels: sortedLevels,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isCollapsed: $isLevelsViewCollapsed
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 30)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Site button.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isSelectorHidden.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "building.2")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(4)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SiteAndFacilitySelector(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: $isSelectorHidden,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***$selectedFacilityID,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***$selectedSiteID
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.opacity(isSelectorHidden ? .zero : 1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: viewpoint?.wrappedValue.targetGeometry) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateSelection()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Ensure space for filter text field on small screens in landscape
***REMOVED******REMOVED***.frame(minHeight: 100)
***REMOVED******REMOVED***.environmentObject(viewModel)
***REMOVED***

***REMOVED******REMOVED***/ Updates `selectedFacilityID` and `selectedSiteID` based on the most recent
***REMOVED******REMOVED***/ viewpoint.
***REMOVED***private func updateSelection() {
***REMOVED******REMOVED***guard let viewpoint = viewpoint?.wrappedValue,
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint.targetScale != .zero,
***REMOVED******REMOVED******REMOVED******REMOVED***automaticSelectionMode != .never else {
***REMOVED******REMOVED******REMOVED******REMOVED***  return
***REMOVED***  ***REMOVED***

***REMOVED******REMOVED******REMOVED*** Only take action if viewpoint is within minimum scale. Default
***REMOVED******REMOVED******REMOVED*** minscale is 4300 or less (~zoom level 17 or greater)
***REMOVED******REMOVED***var targetScale = viewModel.floorManager.siteLayer?.minScale ?? .zero
***REMOVED******REMOVED***if targetScale.isZero {
***REMOVED******REMOVED******REMOVED***targetScale = 4300
***REMOVED***

***REMOVED******REMOVED******REMOVED*** If viewpoint is out of range, reset selection (if not non-clearing)
***REMOVED******REMOVED******REMOVED*** and return
***REMOVED******REMOVED***if viewpoint.targetScale > targetScale {
***REMOVED******REMOVED******REMOVED***if automaticSelectionMode == .always {
***REMOVED******REMOVED******REMOVED******REMOVED***selectedSiteID = nil
***REMOVED******REMOVED******REMOVED******REMOVED***selectedFacilityID = nil
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Assumption: if too zoomed out to see sites, also too zoomed out
***REMOVED******REMOVED******REMOVED******REMOVED*** to see facilities
***REMOVED******REMOVED******REMOVED***return
***REMOVED***

***REMOVED******REMOVED******REMOVED*** If the centerpoint is within a site's geometry, select that site.
***REMOVED******REMOVED******REMOVED*** This code gracefully skips selection if there are no sites or no
***REMOVED******REMOVED******REMOVED*** matching sites
***REMOVED******REMOVED***let siteResult = viewModel.floorManager.sites.first { site in
***REMOVED******REMOVED******REMOVED***guard let siteExtent = site.geometry?.extent else {
***REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return GeometryEngine.intersects(
***REMOVED******REMOVED******REMOVED******REMOVED***geometry1: siteExtent,
***REMOVED******REMOVED******REMOVED******REMOVED***geometry2: viewpoint.targetGeometry
***REMOVED******REMOVED******REMOVED***)
***REMOVED***

***REMOVED******REMOVED***if let siteResult = siteResult {
***REMOVED******REMOVED******REMOVED***selectedSiteID = siteResult.siteId
***REMOVED*** else if automaticSelectionMode == .always {
***REMOVED******REMOVED******REMOVED***selectedSiteID = nil
***REMOVED***

***REMOVED******REMOVED******REMOVED*** Move on to facility selection. Default to map-authored Facility
***REMOVED******REMOVED******REMOVED*** MinScale. If MinScale not specified or is 0, default to 1500.
***REMOVED******REMOVED***targetScale = viewModel.floorManager.facilityLayer?.minScale ?? .zero
***REMOVED******REMOVED***if targetScale.isZero  {
***REMOVED******REMOVED******REMOVED***targetScale = 1500
***REMOVED***

***REMOVED******REMOVED******REMOVED*** If out of scale, stop here
***REMOVED******REMOVED***if viewpoint.targetScale > targetScale {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***

***REMOVED******REMOVED***let facilityResult = viewModel.floorManager.facilities.first { facility in
***REMOVED******REMOVED******REMOVED***guard let facilityExtent = facility.geometry?.extent else {
***REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return GeometryEngine.intersects(
***REMOVED******REMOVED******REMOVED******REMOVED***geometry1: facilityExtent,
***REMOVED******REMOVED******REMOVED******REMOVED***geometry2: viewpoint.targetGeometry
***REMOVED******REMOVED******REMOVED***)
***REMOVED***

***REMOVED******REMOVED***if let facilityResult = facilityResult {
***REMOVED******REMOVED******REMOVED***selectedFacilityID = facilityResult.facilityId
***REMOVED*** else if automaticSelectionMode == .always {
***REMOVED******REMOVED******REMOVED***selectedFacilityID = nil
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view displaying the levels in the selected facility.
struct LevelsView: View {
***REMOVED******REMOVED***/ The levels to display.
***REMOVED***let levels: [FloorLevel]
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating the whether the view shows only the selected level or all levels.
***REMOVED******REMOVED***/ If the value is`false`, the view will display all levels; if it is `true`, the view will only display
***REMOVED******REMOVED***/ the selected level.
***REMOVED***@Binding
***REMOVED***var isCollapsed: Bool
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the `LevelsView`.
***REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ The height of the scroll view's content.
***REMOVED***@State
***REMOVED***private var scrollViewContentHeight: CGFloat = .zero
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if !isCollapsed,
***REMOVED******REMOVED******REMOVED***   levels.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***CollapseButton(isCollapsed: $isCollapsed)
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 30)
***REMOVED******REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***LevelsStack(levels: levels)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***GeometryReader { geometry -> Color in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scrollViewContentHeight = geometry.size.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return .clear
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxHeight: scrollViewContentHeight)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Button for the selected level.
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if levels.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isCollapsed.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(viewModel.selectedLevel?.shortName ?? (levels.first?.shortName ?? "None"))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonSelected(true)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(4)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A vertical list of floor levels.
struct LevelsStack: View {
***REMOVED***let levels: [FloorLevel]
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the `LevelsView`.
***REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***ForEach(levels) { level in
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selection = .level(level)
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(level.shortName)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonSelected(level == viewModel.selectedLevel)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(4)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A button used to collapse the floor level list.
struct CollapseButton: View {
***REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED***@Binding
***REMOVED***var isCollapsed: Bool
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***isCollapsed.toggle()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "xmark")
***REMOVED***
***REMOVED******REMOVED***.padding(EdgeInsets(
***REMOVED******REMOVED******REMOVED***top: 2,
***REMOVED******REMOVED******REMOVED***leading: 4,
***REMOVED******REMOVED******REMOVED***bottom: 2,
***REMOVED******REMOVED******REMOVED***trailing: 4
***REMOVED******REMOVED***))
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
