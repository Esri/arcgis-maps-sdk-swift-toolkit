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
***REMOVED***

***REMOVED***/ The `FloorFilter` component simplifies visualization of GIS data for a specific floor of a
***REMOVED***/ building in your application. It allows you to filter the floor plan data displayed in your map
***REMOVED***/ or scene view to a site, a facility (building) in the site, or a floor in the facility.
***REMOVED***/
***REMOVED***/ The ArcGIS Maps SDK currently supports filtering a floor aware map or scene based on the sites,
***REMOVED***/ buildings, or levels in the geo model's floor definition.
***REMOVED***/
***REMOVED***/ | iPhone | iPad |
***REMOVED***/ | ------ | ---- |
***REMOVED***/ | ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202811733-dcd640e9-3b27-43a8-8bec-fd9aeb6798c7.png) | ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202811772-bf6009e7-82ec-459f-86ae-6651f519b2ef.png) |
***REMOVED***/
***REMOVED***/ **Features**
***REMOVED***/
***REMOVED***/ - Automatically hides the floor browsing view when the associated map or scene is not floor-aware.
***REMOVED***/ - Selects the facility in view automatically (can be configured through the
***REMOVED***/ ``FloorFilterAutomaticSelectionMode``).
***REMOVED***/ - Shows the selected facility's levels in proper vertical order.
***REMOVED***/ - Filters the map/scene content to show the selected level.
***REMOVED***/ - Allows browsing the full floor-aware hierarchy of sites, facilities, and levels.
***REMOVED***/ - Shows the ground floor of all facilities when there is no active selection.
***REMOVED***/ - Updates the visibility of floor levels across all facilities (e.g. if you are looking at floor
***REMOVED***/  3 in building A, floor 3 will be shown in neighboring buildings).
***REMOVED***/ - Adjusts layout and presentation to work well regardless of positioning - left/right and
***REMOVED***/ top/bottom.
***REMOVED***/ - Keeps the selected facility visible in the list while the selection is changing in response to
***REMOVED***/ map or scene navigation.
***REMOVED***/
***REMOVED***/ **Behavior**
***REMOVED***/
***REMOVED***/ | Sites Button |
***REMOVED***/ | ----------- |
***REMOVED***/ | ![Image of button that displays the list of sites when tapped](https:***REMOVED***user-images.githubusercontent.com/3998072/203417956-5161103d-5d29-42fa-8564-de254159efe2.png) |
***REMOVED***/
***REMOVED***/ When the Site button is tapped, a prompt opens so the user can select a site and then a
***REMOVED***/ facility. After selecting a site and facility, a list of levels is displayed. The list of sites
***REMOVED***/ and facilities can be dynamically filtered using the search bar.
***REMOVED***/
***REMOVED***/ **Associated Types**
***REMOVED***/
***REMOVED***/ Floor Filter has two associated enum type:
***REMOVED***/
***REMOVED***/ - ``FloorFilterAutomaticSelectionMode``
***REMOVED***/ - ``FloorFilterSelection``
***REMOVED***/
***REMOVED***/ To see it in action, try out the [Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
***REMOVED***/ and refer to [FloorFilterExampleView.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/FloorFilterExampleView.swift)
***REMOVED***/ in the project. To learn more about using the `FloorFilter` see the <doc:FloorFilterTutorial>.
@MainActor
@preconcurrency
public struct FloorFilter: View {
***REMOVED***@Environment(\.horizontalSizeClass)
***REMOVED***private var horizontalSizeClass: UserInterfaceSizeClass?
***REMOVED***
***REMOVED******REMOVED***/ Creates a `FloorFilter`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - floorManager: The floor manager used by the `FloorFilter`.
***REMOVED******REMOVED***/   - alignment: Determines the display configuration of Floor Filter elements.
***REMOVED******REMOVED***/   - automaticSelectionMode: The selection behavior of the floor filter.
***REMOVED******REMOVED***/   - viewpoint: Viewpoint updated when the selected site or facility changes.
***REMOVED******REMOVED***/   - isNavigating: A Boolean value indicating whether the map or scene is currently being navigated.
***REMOVED******REMOVED***/   - selection: The selected site, facility, or level.
***REMOVED***public init(
***REMOVED******REMOVED***floorManager: FloorManager,
***REMOVED******REMOVED***alignment: Alignment,
***REMOVED******REMOVED***automaticSelectionMode: FloorFilterAutomaticSelectionMode = .always,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?> = .constant(nil),
***REMOVED******REMOVED***isNavigating: Binding<Bool>,
***REMOVED******REMOVED***selection: Binding<FloorFilterSelection?>? = nil
***REMOVED***) {
***REMOVED******REMOVED***_viewModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED***automaticSelectionMode: automaticSelectionMode,
***REMOVED******REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***self.alignment = alignment
***REMOVED******REMOVED***self.isNavigating = isNavigating
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED******REMOVED***self.selection = selection
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the `FloorFilter`.
***REMOVED***@StateObject private var viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value that indicates whether the site and facility selector is presented.
***REMOVED***@State private var siteAndFacilitySelectorIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The selected site, floor, or level.
***REMOVED***private var selection: Binding<FloorFilterSelection?>?
***REMOVED***
***REMOVED******REMOVED***/ The alignment configuration.
***REMOVED***private let alignment: Alignment
***REMOVED***
***REMOVED******REMOVED***/ The width of the level selector.
***REMOVED***private var levelSelectorWidth: CGFloat = 60
***REMOVED***
***REMOVED******REMOVED***/ The `Viewpoint` used to pan/zoom to the selected site/facility.
***REMOVED******REMOVED***/ If `nil`, there will be no automatic pan/zoom operations or automatic selection support.
***REMOVED***private var viewpoint: Binding<Viewpoint?>
***REMOVED***
***REMOVED******REMOVED***/ Button to open and close the site and facility selector.
***REMOVED***private var sitesAndFacilitiesButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***siteAndFacilitySelectorIsPresented.toggle()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "building.2")
***REMOVED******REMOVED******REMOVED******REMOVED***.accessibilityIdentifier("Floor Filter button")
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.toolkitDefault)
***REMOVED******REMOVED******REMOVED******REMOVED***.opacity(viewModel.isLoading ? .zero : 1)
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if viewModel.isLoading {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(.circular)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view that displays the level selector and the sites and facilities button.
***REMOVED***private var levelSelectorContainer: some View {
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
***REMOVED******REMOVED***.frame(width: levelSelectorWidth)
***REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED***maxWidth: horizontalSizeClass == .compact ? .infinity : nil,
***REMOVED******REMOVED******REMOVED***maxHeight: .infinity,
***REMOVED******REMOVED******REMOVED***alignment: alignment
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the map or scene is currently being navigated.
***REMOVED***private var isNavigating: Binding<Bool>
***REMOVED***
***REMOVED******REMOVED***/ Indicates that the selector should be presented with a top oriented alignment configuration.
***REMOVED***private var isTopAligned: Bool {
***REMOVED******REMOVED***alignment.vertical == .top
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view that allows selecting between levels.
***REMOVED***@ViewBuilder private var levelSelector: some View {
***REMOVED******REMOVED***LevelSelector(
***REMOVED******REMOVED******REMOVED***isTopAligned: isTopAligned,
***REMOVED******REMOVED******REMOVED***levels: viewModel.sortedLevels
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A configured `SiteAndFacilitySelector`.
***REMOVED***@ViewBuilder private var siteAndFacilitySelector: some View {
***REMOVED******REMOVED***if horizontalSizeClass == .compact {
***REMOVED******REMOVED******REMOVED***Color.clear
***REMOVED******REMOVED******REMOVED******REMOVED***.sheet(isPresented: $siteAndFacilitySelectorIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SiteAndFacilitySelector(isPresented: $siteAndFacilitySelectorIsPresented)
***REMOVED******REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Color.clear
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED******REMOVED***SiteAndFacilitySelector(isPresented: $siteAndFacilitySelectorIsPresented)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top, .leading, .trailing], 2.5)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.bottom)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.opacity(siteAndFacilitySelectorIsPresented ? 1 : .zero)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***HStack(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED***if alignment.horizontal == .trailing {
***REMOVED******REMOVED******REMOVED******REMOVED***siteAndFacilitySelector
***REMOVED******REMOVED******REMOVED******REMOVED***levelSelectorContainer
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***levelSelectorContainer
***REMOVED******REMOVED******REMOVED******REMOVED***siteAndFacilitySelector
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Ensure space for filter text field on small screens in landscape
***REMOVED******REMOVED***.frame(minHeight: 100)
***REMOVED******REMOVED***.environmentObject(viewModel)
***REMOVED******REMOVED***.disabled(viewModel.isLoading)
***REMOVED******REMOVED***.onChange(of: selection?.wrappedValue) { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED*** Prevent a double-set if the view model triggered the original change.
***REMOVED******REMOVED******REMOVED***guard newValue != viewModel.selection else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***switch newValue {
***REMOVED******REMOVED******REMOVED***case .site(let site): viewModel.setSite(site)
***REMOVED******REMOVED******REMOVED***case .facility(let facility): viewModel.setFacility(facility)
***REMOVED******REMOVED******REMOVED***case .level(let level): viewModel.setLevel(level)
***REMOVED******REMOVED******REMOVED***case .none: viewModel.clearSelection()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: viewModel.selection) { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED*** Prevent a double-set if the user triggered the original change.
***REMOVED******REMOVED******REMOVED***guard selection?.wrappedValue != newValue else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***selection?.wrappedValue = newValue
***REMOVED***
***REMOVED******REMOVED***.onChange(of: viewpoint.wrappedValue) { newViewpoint in
***REMOVED******REMOVED******REMOVED***guard isNavigating.wrappedValue else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***if let newViewpoint {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.onViewpointChanged(newViewpoint)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The width of the level selector.
***REMOVED******REMOVED***/ - Parameter width: The new width for the level selector.
***REMOVED******REMOVED***/ - Returns: The `FloorFilter`.
***REMOVED***public func levelSelectorWidth(_ width: CGFloat) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.levelSelectorWidth = width
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
