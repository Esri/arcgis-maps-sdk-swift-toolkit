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
***REMOVED***@Environment(\.horizontalSizeClass)
***REMOVED***private var horizontalSizeClass: UserInterfaceSizeClass?
***REMOVED***
***REMOVED***@Environment(\.verticalSizeClass)
***REMOVED***private var verticalSizeClass: UserInterfaceSizeClass?
***REMOVED***
***REMOVED******REMOVED***/ If `true`, the site and facility selector will appear as a sheet.
***REMOVED******REMOVED***/ If `false`, the site and facility selector will appear as a popup modal alongside the level selector.
***REMOVED***private var isCompact: Bool {
***REMOVED******REMOVED***return horizontalSizeClass == .compact || verticalSizeClass == .compact
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `FloorFilter`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - floorManager: The floor manager used by the `FloorFilter`.
***REMOVED******REMOVED***/   - alignment: Determines the display configuration of Floor Filter elements.
***REMOVED******REMOVED***/   - automaticSelectionMode: The selection behavior of the floor filter.
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
***REMOVED******REMOVED***/ A Boolean value that indicates whether the levels view is currently collapsed.
***REMOVED***@State private var isLevelsViewCollapsed: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value that indicates whether the site and facility selector is presented.
***REMOVED***@State private var siteAndFacilitySelectorIsPresented: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ The alignment configuration.
***REMOVED***private let alignment: Alignment
***REMOVED***
***REMOVED******REMOVED***/ The width of the level selector.
***REMOVED***private let filterWidth: CGFloat = 60
***REMOVED***
***REMOVED******REMOVED***/ The `Viewpoint` used to pan/zoom to the selected site/facilty.
***REMOVED******REMOVED***/ If `nil`, there will be no automatic pan/zoom operations or automatic selection support.
***REMOVED***private var viewpoint: Binding<Viewpoint?>
***REMOVED***
***REMOVED******REMOVED***/ Button to open and close the site and facility selector.
***REMOVED***private var sitesAndFacilitiesButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***siteAndFacilitySelectorIsPresented.toggle()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "building.2")
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.toolkitDefault)
***REMOVED***
***REMOVED******REMOVED***.sheet(
***REMOVED******REMOVED******REMOVED***isAllowed: isCompact,
***REMOVED******REMOVED******REMOVED***isPresented: $siteAndFacilitySelectorIsPresented
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***SiteAndFacilitySelector(isHidden: $siteAndFacilitySelectorIsPresented)
***REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: viewpoint.wrappedValue) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.onViewpointChanged($0)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view that allows selecting between levels.
***REMOVED***private var floorFilter: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if isTopAligned {
***REMOVED******REMOVED******REMOVED******REMOVED***sitesAndFacilitiesButton
***REMOVED******REMOVED******REMOVED******REMOVED***if viewModel.hasLevelsToDisplay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***levelSelector
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***if viewModel.hasLevelsToDisplay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***levelSelector
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***sitesAndFacilitiesButton
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.frame(width: filterWidth)
***REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED***maxWidth: isCompact ? .infinity : nil,
***REMOVED******REMOVED******REMOVED***maxHeight: .infinity,
***REMOVED******REMOVED******REMOVED***alignment: alignment
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Indicates that the selector should be presented with a top oriented aligment configuration.
***REMOVED***private var isTopAligned: Bool {
***REMOVED******REMOVED***alignment.vertical == .top
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays the available levels.
***REMOVED***@ViewBuilder private var levelSelector: some View {
***REMOVED******REMOVED***LevelSelector(
***REMOVED******REMOVED******REMOVED***isTopAligned: isTopAligned,
***REMOVED******REMOVED******REMOVED***levels: viewModel.sortedLevels
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A configured `SiteAndFacilitySelector` view.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ The layering of the `SiteAndFacilitySelector` over a `RoundedRectangle` is needed to
***REMOVED******REMOVED***/ produce a rounded corners effect. We can not simply use `.esriBorder()` here because
***REMOVED******REMOVED***/ applying the `cornerRadius()` modifier on `SiteAndFacilitySelector`'s underlying
***REMOVED******REMOVED***/ `NavigationView` causes a rendering bug. This bug remains in iOS 16 with
***REMOVED******REMOVED***/ `NavigationStack` and has been reported to Apple as FB10034457.
***REMOVED***@ViewBuilder private var siteAndFacilitySelector: some View {
***REMOVED******REMOVED***if !isCompact {
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***RoundedRectangle(cornerRadius: 8)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fill(Color(uiColor: .systemBackground))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED******REMOVED***SiteAndFacilitySelector(isHidden: $siteAndFacilitySelectorIsPresented)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: viewpoint.wrappedValue) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.onViewpointChanged($0)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.opacity(siteAndFacilitySelectorIsPresented ? .zero : 1)
***REMOVED***
***REMOVED***
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
