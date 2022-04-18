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
***REMOVED******REMOVED***/   - alignment: Determines the display configuration of Floor Filter elements.
***REMOVED******REMOVED***/   - automaticSelectionMode: The selection behavior of the floor filter.
***REMOVED******REMOVED***/   - floorManager: The floor manager used by the `FloorFilter`.
***REMOVED******REMOVED***/   - viewpoint: Viewpoint updated when the selected site or facility changes.
***REMOVED***public init(
***REMOVED******REMOVED***floorManager: FloorManager,
***REMOVED******REMOVED***alignment: Alignment,
***REMOVED******REMOVED***automaticSelectionMode: FloorFilterAutomaticSelectionMode = .always,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?> = .constant(nil)
***REMOVED***) {
***REMOVED******REMOVED***_viewModel = StateObject(wrappedValue: FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***automaticSelectionMode: automaticSelectionMode,
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***))
***REMOVED******REMOVED***self.alignment = alignment
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the `FloorFilter`.
***REMOVED***@StateObject private var viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value that indicates whether the site and facility selector is hidden.
***REMOVED***@State private var isSitesAndFacilitiesHidden: Bool = true
***REMOVED***
***REMOVED******REMOVED***/ The alignment configuration.
***REMOVED***private let alignment: Alignment
***REMOVED***
***REMOVED******REMOVED***/ Button to open and close the site and facility selector.
***REMOVED***private var sitesAndFacilitiesButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***isSitesAndFacilitiesHidden.toggle()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "building.2")
***REMOVED***
***REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays the available levels.
***REMOVED***@ViewBuilder
***REMOVED***private var levelSelector: some View {
***REMOVED******REMOVED***LevelSelector(
***REMOVED******REMOVED******REMOVED***levels: viewModel.sortedLevels,
***REMOVED******REMOVED******REMOVED***isTopAligned: topAligned
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.hidden(!viewModel.hasLevelsToDisplay)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view that allows selecting between levels.
***REMOVED***private var floorFilter: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if topAligned {
***REMOVED******REMOVED******REMOVED******REMOVED***sitesAndFacilitiesButton
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.hidden(!viewModel.hasLevelsToDisplay)
***REMOVED******REMOVED******REMOVED******REMOVED***levelSelector
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***levelSelector
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.hidden(!viewModel.hasLevelsToDisplay)
***REMOVED******REMOVED******REMOVED******REMOVED***sitesAndFacilitiesButton
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED***.frame(width: 75)
***REMOVED******REMOVED***.frame(maxHeight: .infinity, alignment: alignment)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A configured `SiteAndFacilitySelector` view.
***REMOVED***private var siteAndFacilitySelector: some View {
***REMOVED******REMOVED***SiteAndFacilitySelector(isHidden: $isSitesAndFacilitiesHidden)
***REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED***.opacity(isSitesAndFacilitiesHidden ? .zero : 1)
***REMOVED******REMOVED******REMOVED***.onChange(of: viewpoint.wrappedValue?.targetGeometry) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.viewpointSubject.send(viewpoint.wrappedValue)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Indicates that the selector should be presented with a top oriented aligment configuration.
***REMOVED***private var topAligned: Bool {
***REMOVED******REMOVED***alignment.vertical == .top
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `Viewpoint` used to pan/zoom to the selected site/facilty.
***REMOVED******REMOVED***/ If `nil`, there will be no automatic pan/zoom operations or automatic selection support.
***REMOVED***private var viewpoint: Binding<Viewpoint?>
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***HStack(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED***if alignment.horizontal == .trailing {
***REMOVED******REMOVED******REMOVED******REMOVED***siteAndFacilitySelector
***REMOVED******REMOVED******REMOVED******REMOVED***floorFilter
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***floorFilter
***REMOVED******REMOVED******REMOVED******REMOVED***siteAndFacilitySelector
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Ensure space for filter text field on small screens in landscape
***REMOVED******REMOVED***.frame(minHeight: 100)
***REMOVED******REMOVED***.environmentObject(viewModel)
***REMOVED******REMOVED***.disabled(viewModel.isLoading)
***REMOVED***
***REMOVED***
