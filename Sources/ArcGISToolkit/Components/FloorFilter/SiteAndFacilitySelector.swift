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

extension SiteAndFacilitySelector {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***struct Header: View {
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***@Binding var allSitesIsSelected: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED***@Binding var isPresented: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***@Binding var query: String
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the user pressed the back button in the header.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ This allows for browsing the site list while keeping the current selection unmodified.
***REMOVED******REMOVED***@Binding var userDidBackOutToSiteList: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The view model used by the `SiteAndFacilitySelector`.
***REMOVED******REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***@FocusState var textFieldIsFocused: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***upperHeader
***REMOVED******REMOVED******REMOVED******REMOVED***lowerHeader
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***var lowerHeader: some View {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "magnifyingglass")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField(String.filterSites, text: $query)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disableAutocorrection(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.focused($textFieldIsFocused)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.keyboardType(.alphabet)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if textFieldIsFocused {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(String.cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***query.removeAll()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***textFieldIsFocused = false
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***@MainActor
***REMOVED******REMOVED***var upperHeader: some View {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***userDidBackOutToSiteList = true
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.left")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.opacity(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selection == .none || userDidBackOutToSiteList
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***? 0 : 1
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if viewModel.selection == .none || userDidBackOutToSiteList {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text.sites
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(viewModel.selection?.site?.name ?? String.selectAFacility)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.title3)
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view which allows selection of sites and facilities represented in a `FloorManager`.
***REMOVED***/
***REMOVED***/ If the floor aware data contains only one site, the selector opens directly to the facilities list.
@MainActor
struct SiteAndFacilitySelector: View {
***REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED***@Binding var isPresented: Bool
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the `SiteAndFacilitySelector`.
***REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var allSitesIsSelected = false
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var query = ""
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the user pressed the back button in the header.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This allows for browsing the site list while keeping the current selection unmodified.
***REMOVED***@State private var userDidBackOutToSiteList = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***Header(allSitesIsSelected: $allSitesIsSelected, isPresented: $isPresented, query: $query, userDidBackOutToSiteList: $userDidBackOutToSiteList)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.leading, .top, .trailing])
***REMOVED******REMOVED******REMOVED***if userDidBackOutToSiteList {
***REMOVED******REMOVED******REMOVED******REMOVED***SiteList(allSitesIsSelected: $allSitesIsSelected, isPresented: $isPresented, query: $query, userDidBackOutToSiteList: $userDidBackOutToSiteList)
***REMOVED******REMOVED*** else if viewModel.sites.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***switch viewModel.selection {
***REMOVED******REMOVED******REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SiteList(allSitesIsSelected: $allSitesIsSelected, isPresented: $isPresented, query: $query, userDidBackOutToSiteList: $userDidBackOutToSiteList)
***REMOVED******REMOVED******REMOVED******REMOVED***case .site(let floorSite):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeFacilitiesList(site: floorSite)
***REMOVED******REMOVED******REMOVED******REMOVED***case .facility(let floorFacility):
#warning("Remove forced optionals")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeFacilitiesList(site: floorFacility.site!)
***REMOVED******REMOVED******REMOVED******REMOVED***case .level(let floorLevel):
#warning("Remove forced optionals")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeFacilitiesList(site: floorLevel.facility!.site!)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***FacilityList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $isPresented,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***query: $query,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***usesAllSitesStyling: false,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilities: viewModel.facilities
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view displaying the sites contained in a `FloorManager`.
***REMOVED***@MainActor
***REMOVED***struct SiteList: View {
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***@Binding var allSitesIsSelected: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED******REMOVED***@Binding var isPresented: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A site name filter phrase entered by the user.
***REMOVED******REMOVED***@Binding var query: String
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the user pressed the back button in the header.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ This allows for browsing the site list while keeping the current selection unmodified.
***REMOVED******REMOVED***@Binding var userDidBackOutToSiteList: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED***@Environment(\.horizontalSizeClass)
***REMOVED******REMOVED***private var horizontalSizeClass: UserInterfaceSizeClass?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The view model used by this selector.
***REMOVED******REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A subset of `sites` with names containing `query` or all `sites` if `query` is empty.
***REMOVED******REMOVED***var matchingSites: [FloorSite] {
***REMOVED******REMOVED******REMOVED***guard !query.isEmpty else {
***REMOVED******REMOVED******REMOVED******REMOVED***return viewModel.sites
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return viewModel.sites.filter {
***REMOVED******REMOVED******REMOVED******REMOVED***$0.name.localizedStandardContains(query)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A view with a filter-via-name field, a list of site names and an "All sites" button.
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if matchingSites.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if #available(iOS 17, *) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ContentUnavailableView(String.noMatchesFound, systemImage: "building.2")
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NoMatchesView()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***siteList
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***allSitesButton
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The "All sites" button.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ This button presents the facilities list in a special format where the facilities list
***REMOVED******REMOVED******REMOVED***/ shows every facility in every site within the floor manager.
***REMOVED******REMOVED***var allSitesButton: some View {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***allSitesIsSelected = true
***REMOVED******REMOVED******REMOVED******REMOVED***userDidBackOutToSiteList = false
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(String.allSites)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED***.padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A view containing a list of the site names.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ If `AutomaticSelectionMode` mode is in use, items will automatically be
***REMOVED******REMOVED******REMOVED***/ selected/deselected.
***REMOVED******REMOVED***var siteList: some View {
***REMOVED******REMOVED******REMOVED***List(matchingSites) { site in
***REMOVED******REMOVED******REMOVED******REMOVED***Button(site.name) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setSite(site)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED******REMOVED***.onChange(of: viewModel.selection) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***userDidBackOutToSiteList = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view displaying the facilities contained in a `FloorManager`.
***REMOVED***@MainActor
***REMOVED***struct FacilityList: View {
***REMOVED******REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED******REMOVED***@Binding var isPresented: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A facility name filter phrase entered by the user.
***REMOVED******REMOVED***@Binding var query: String
***REMOVED******REMOVED***
***REMOVED******REMOVED***@Environment(\.horizontalSizeClass)
***REMOVED******REMOVED***private var horizontalSizeClass: UserInterfaceSizeClass?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The view model used by this selector.
***REMOVED******REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ When `true`, the facilities list will be display with all sites styling.
***REMOVED******REMOVED***let usesAllSitesStyling: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ `FloorFacility`s to be displayed by this view.
***REMOVED******REMOVED***let facilities: [FloorFacility]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A subset of `facilities` with names containing `query` or all `facilities` if
***REMOVED******REMOVED******REMOVED***/ `query` is empty.
***REMOVED******REMOVED***var matchingFacilities: [FloorFacility] {
***REMOVED******REMOVED******REMOVED***guard !query.isEmpty else {
***REMOVED******REMOVED******REMOVED******REMOVED***return facilities
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.sorted { $0.name < $1.name ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return facilities
***REMOVED******REMOVED******REMOVED******REMOVED***.filter { $0.name.localizedStandardContains(query) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.sorted { $0.name < $1.name  ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if matchingFacilities.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if #available(iOS 17, *) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ContentUnavailableView(String.noMatchesFound, systemImage: "building")
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NoMatchesView()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilityList
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationTitle(usesAllSitesStyling ? String.allSites : (viewModel.selection?.site?.name ?? String.selectAFacility))
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Displays a list of facilities matching the filter criteria as determined by
***REMOVED******REMOVED******REMOVED***/ `matchingFacilities`.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ If a certain facility is indicated as selected by the view model, it will have a
***REMOVED******REMOVED******REMOVED***/ slightly different appearance.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ If `AutomaticSelectionMode` mode is in use, this list will automatically scroll to the
***REMOVED******REMOVED******REMOVED***/ selected item.
***REMOVED******REMOVED***var facilityList: some View {
***REMOVED******REMOVED******REMOVED***ScrollViewReader { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED***List(matchingFacilities, id: \.id) { facility in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(facility.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: .infinity,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .leading
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if usesAllSitesStyling, let siteName = facility.site?.name {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(siteName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: .infinity,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .leading
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(Rectangle())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(facility.id == viewModel.selection?.facility?.id ? Color.secondary.opacity(0.5) : Color.clear)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setFacility(facility, zoomTo: true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if horizontalSizeClass == .compact {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: viewModel.selection) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let floorFacility = viewModel.selection?.facility {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***proxy.scrollTo(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***floorFacility.id
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension SiteAndFacilitySelector {
***REMOVED******REMOVED***/ Makes the list of facilities for a site from the sites list.
***REMOVED***func makeFacilitiesList(site: FloorSite) -> some View {
***REMOVED******REMOVED***SiteAndFacilitySelector.FacilityList(
***REMOVED******REMOVED******REMOVED***isPresented: $isPresented,
***REMOVED******REMOVED******REMOVED***query: $query,
***REMOVED******REMOVED******REMOVED***usesAllSitesStyling: false,
***REMOVED******REMOVED******REMOVED***facilities: site.facilities
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

extension SiteAndFacilitySelector.SiteList {
***REMOVED******REMOVED***/ The selected site as reflected in the state of the navigation stack.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ Note that the selection state of the navigation stack can differ from the selection state of the
***REMOVED******REMOVED***/ view model. See `userBackedOutOfSelectedSite` for further explanation.
***REMOVED***var selectedSite: Binding<FloorSite?> {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***get: {
***REMOVED******REMOVED******REMOVED******REMOVED***userDidBackOutToSiteList ? nil : viewModel.selection?.site
***REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED***set: { newSite in
***REMOVED******REMOVED******REMOVED******REMOVED***guard let newSite = newSite else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***userDidBackOutToSiteList = false
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setSite(newSite, zoomTo: true)
***REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED***/ Displays text "No matches found".
private struct NoMatchesView: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***Text(String.noMatchesFound)
***REMOVED******REMOVED******REMOVED***.frame(maxHeight: .infinity)
***REMOVED***
***REMOVED***

private extension String {
***REMOVED***static var allSites: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "All sites",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A reference to all of the sites defined in a floor aware map."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***static var filterFacilities: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Filter facilities",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED***A field allowing the user to filter a list of facilities by name. A
***REMOVED******REMOVED******REMOVED******REMOVED***facility contains one or more levels in a floor-aware map or scene.
***REMOVED******REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***static var filterSites: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Filter sites",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED*** A field allowing the user to filter a list of sites by name. A site
***REMOVED******REMOVED******REMOVED******REMOVED*** contains one or more facilities in a floor-aware map or scene.
***REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A statement that no sites or facilities with names matching a filter phrase were found.
***REMOVED***static var noMatchesFound: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "No matches found.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A statement that no sites or facilities with names matching a filter phrase were found."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***static var selectAFacility: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Select a facility",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED*** A label directing the user to select a facility. A facility contains one
***REMOVED******REMOVED******REMOVED******REMOVED*** or more levels in a floor-aware map or scene.
***REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private extension Text {
***REMOVED******REMOVED***/ A label in reference to all of the sites in a floor-aware map or scene.
***REMOVED***static var sites: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Sites",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label in reference to all of the sites in a floor-aware map or scene."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
