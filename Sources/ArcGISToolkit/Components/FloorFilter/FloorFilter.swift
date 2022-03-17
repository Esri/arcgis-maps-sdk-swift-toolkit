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
***REMOVED******REMOVED***alignment: Alignment,
***REMOVED******REMOVED***automaticSelectionMode: AutomaticSelectionMode = .always,
***REMOVED******REMOVED***floorManager: FloorManager,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>
***REMOVED***) {
***REMOVED******REMOVED***_viewModel = StateObject(wrappedValue: FloorFilterViewModel(
***REMOVED******REMOVED******REMOVED***automaticSelectionMode: automaticSelectionMode,
***REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***))
***REMOVED******REMOVED***self.alignment = alignment
***REMOVED******REMOVED***self.viewpoint = viewpoint
***REMOVED***

***REMOVED******REMOVED***/ The alignment configuration.
***REMOVED***private let alignment: Alignment

***REMOVED******REMOVED***/ A Boolean value that indicates whether there are levels to display.  This will be false if
***REMOVED******REMOVED***/ there is no selected facility or if the selected facility has no levels.
***REMOVED***private var hasLevelsToDisplay: Bool {
***REMOVED******REMOVED***!(viewModel.selectedFacility == nil ||
***REMOVED******REMOVED***  viewModel.selectedFacility!.levels.isEmpty)
***REMOVED***

***REMOVED******REMOVED***/ A Boolean value that indicates whether the site/facility selector is hidden.
***REMOVED***@State
***REMOVED***private var isSelectorHidden: Bool = true

***REMOVED******REMOVED***/ A Boolean value that indicates whether the levels view is currently collapsed.
***REMOVED***@State
***REMOVED***private var isLevelsViewCollapsed: Bool = false

***REMOVED******REMOVED***/ Displays the available levels.
***REMOVED***private var levelsAndDividerView: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if hasLevelsToDisplay {
***REMOVED******REMOVED******REMOVED******REMOVED***if topAligned {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 30)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***LevelsView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***topAligned: topAligned,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***levels: sortedLevels,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isCollapsed: $isLevelsViewCollapsed
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***if !topAligned {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 30)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ Button to open and close the site and facility selector.
***REMOVED***private var facilityButtonView: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***isSelectorHidden.toggle()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "building.2")
***REMOVED***
***REMOVED******REMOVED******REMOVED***.padding(4)
***REMOVED***

***REMOVED******REMOVED***/ A view that allows selecting between levels.
***REMOVED***private var levelSelectorView: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if !topAligned {
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if topAligned {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilityButtonView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***levelsAndDividerView
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***levelsAndDividerView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilityButtonView
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED***if topAligned {
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ Indicates that the selector should be presented with a right oriented aligment configuration.
***REMOVED***private var rightAligned: Bool {
***REMOVED******REMOVED***switch alignment {
***REMOVED******REMOVED***case .topTrailing, .trailing, .bottomTrailing:
***REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ A configured `SiteAndFacilitySelector` view.
***REMOVED***private var siteAndFacilitySelectorView: some View {
***REMOVED******REMOVED***SiteAndFacilitySelector(isHidden: $isSelectorHidden)
***REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED***.opacity(isSelectorHidden ? .zero : 1)
***REMOVED******REMOVED******REMOVED***.onChange(of: viewpoint.wrappedValue?.targetGeometry) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.updateSelection()
***REMOVED******REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ The selected facility's levels, sorted by `level.verticalOrder`.
***REMOVED***private var sortedLevels: [FloorLevel] {
***REMOVED******REMOVED***let levels = viewModel.selectedFacility?.levels ?? []
***REMOVED******REMOVED***return levels.sorted {
***REMOVED******REMOVED******REMOVED***$0.verticalOrder > $1.verticalOrder
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ Indicates that the selector should be presented with a top oriented aligment configuration.
***REMOVED***private var topAligned: Bool {
***REMOVED******REMOVED***switch alignment {
***REMOVED******REMOVED***case .topLeading, .top, .topTrailing:
***REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ The view model used by the `FloorFilter`.
***REMOVED***@StateObject
***REMOVED***private var viewModel: FloorFilterViewModel

***REMOVED******REMOVED***/ The `Viewpoint` used to pan/zoom to the selected site/facilty.
***REMOVED******REMOVED***/ If `nil`, there will be no automatic pan/zoom operations or automatic selection support.
***REMOVED***private var viewpoint: Binding<Viewpoint?>

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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if rightAligned {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***siteAndFacilitySelectorView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***levelSelectorView
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***levelSelectorView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***siteAndFacilitySelectorView
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Ensure space for filter text field on small screens in landscape
***REMOVED******REMOVED******REMOVED***.frame(minHeight: 100)
***REMOVED******REMOVED******REMOVED***.environmentObject(viewModel)
***REMOVED***
***REMOVED***

***REMOVED***/ A view displaying the levels in the selected facility.
struct LevelsView: View {
***REMOVED******REMOVED***/ The alignment configuration.
***REMOVED***var topAligned: Bool

***REMOVED******REMOVED***/ The levels to display.
***REMOVED***let levels: [FloorLevel]

***REMOVED******REMOVED***/ A Boolean value indicating the whether the view shows only the selected level or all levels.
***REMOVED******REMOVED***/ If the value is`false`, the view will display all levels; if it is `true`, the view will only display
***REMOVED******REMOVED***/ the selected level.
***REMOVED***@Binding
***REMOVED***var isCollapsed: Bool

***REMOVED******REMOVED***/ The view model used by the `LevelsView`.
***REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel

***REMOVED******REMOVED***/ The height of the scroll view's content.
***REMOVED***@State
***REMOVED***private var scrollViewContentHeight: CGFloat = .zero

***REMOVED******REMOVED***/ Returns the short name of the currently selected level, the first level or "None" if none of the listed
***REMOVED******REMOVED***/ are available.
***REMOVED***private var selectedLevelName: String {
***REMOVED******REMOVED***if let shortName = viewModel.selectedLevel?.shortName {
***REMOVED******REMOVED******REMOVED***return shortName
***REMOVED*** else if let firstLevelShortName = levels.first?.shortName {
***REMOVED******REMOVED******REMOVED***return firstLevelShortName
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return "None"
***REMOVED***
***REMOVED***

***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if !isCollapsed,
***REMOVED******REMOVED******REMOVED******REMOVED***levels.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***if !topAligned {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CollapseButton(isCollapsed: $isCollapsed)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 30)
***REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxHeight: scrollViewContentHeight)
***REMOVED******REMOVED******REMOVED******REMOVED***if topAligned {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 30)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CollapseButton(isCollapsed: $isCollapsed)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Button for the selected level.
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if levels.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isCollapsed.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(selectedLevelName)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.selected(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(4)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A vertical list of floor levels.
struct LevelsStack: View {
***REMOVED***let levels: [FloorLevel]

***REMOVED******REMOVED***/ The view model used by the `LevelsView`.
***REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel

***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***ForEach(levels) { level in
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setLevel(level)
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(level.shortName)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.selected(level == viewModel.selectedLevel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(4)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A button used to collapse the floor level list.
struct CollapseButton: View {
***REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED***@Binding
***REMOVED***var isCollapsed: Bool

***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED***isCollapsed.toggle()
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "xmark")
***REMOVED***
***REMOVED******REMOVED******REMOVED***.padding(EdgeInsets(
***REMOVED******REMOVED******REMOVED******REMOVED***top: 2,
***REMOVED******REMOVED******REMOVED******REMOVED***leading: 4,
***REMOVED******REMOVED******REMOVED******REMOVED***bottom: 2,
***REMOVED******REMOVED******REMOVED******REMOVED***trailing: 4
***REMOVED******REMOVED******REMOVED***))
***REMOVED***
***REMOVED***
