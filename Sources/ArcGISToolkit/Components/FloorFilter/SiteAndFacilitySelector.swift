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

***REMOVED***/ A view which allows selection of sites and facilities represented in a `FloorManager`.
***REMOVED***/
***REMOVED***/ If the floor aware data contains only one site, the selector opens directly to the facilities list.
@available(visionOS, unavailable)
struct SiteAndFacilitySelector: View {
***REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED***@Binding var isPresented: Bool
***REMOVED***
***REMOVED***@Environment(\.horizontalSizeClass)
***REMOVED***private var horizontalSizeClass: UserInterfaceSizeClass?
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the `SiteAndFacilitySelector`.
***REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the user is typing into the text field.
***REMOVED***@FocusState var textFieldIsFocused: Bool
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the user tapped the "All Sites" button.
***REMOVED***@State private var allSitesIsSelected = false
***REMOVED***
***REMOVED******REMOVED***/ The site or facility filter phrase.
***REMOVED***@State private var query = ""
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the user pressed the back button in the header.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This allows for browsing the site list while keeping the current selection unmodified.
***REMOVED***@State private var userDidBackOutToSiteList = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***header
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.leading, .top, .trailing])
***REMOVED******REMOVED******REMOVED***if (facilityListIsVisible && matchingFacilities.isEmpty) || (!facilityListIsVisible && matchingSites.isEmpty) {
***REMOVED******REMOVED******REMOVED******REMOVED***if #available(iOS 17, *) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ContentUnavailableView(String.noMatchesFound, systemImage: "building.2")
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(String.noMatchesFound)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxHeight: .infinity)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else if facilityListIsVisible {
***REMOVED******REMOVED******REMOVED******REMOVED***facilityList
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.transition(.move(edge: .trailing))
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***siteList
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.transition(.move(edge: .leading))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.animation(.default, value: facilityListIsVisible)
***REMOVED******REMOVED***.animation(.default, value: textFieldIsFocused)
***REMOVED******REMOVED***.clipped()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays a list of facilities matching the filter criteria as determined by
***REMOVED******REMOVED***/ `matchingFacilities`.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ If a certain facility is indicated as selected by the view model, it will have a
***REMOVED******REMOVED***/ slightly different appearance.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ If `AutomaticSelectionMode` mode is in use, this list will automatically scroll to the
***REMOVED******REMOVED***/ selected item.
***REMOVED***var facilityList: some View {
***REMOVED******REMOVED***ScrollViewReader { proxy in
***REMOVED******REMOVED******REMOVED***List(matchingFacilities, id: \.id) { facility in
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(facility.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if allSitesIsSelected, let siteName = facility.site?.name {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(siteName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(Rectangle())
***REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(facility.id == viewModel.selection?.facility?.id ? Color.secondary.opacity(0.5) : Color.clear)
***REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setFacility(facility, zoomTo: true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if horizontalSizeClass == .compact {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED******REMOVED***.onChange(viewModel.selection) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***if let floorFacility = viewModel.selection?.facility {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***proxy.scrollTo(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***floorFacility.id
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The header at the top of the selector containing the navigation controls and text field.
***REMOVED***var header: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if !textFieldIsFocused {
***REMOVED******REMOVED******REMOVED******REMOVED***headerUpperHalf
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.transition(.opacity)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***headerLowerHalf
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The portion of the header containing the text field.
***REMOVED***var headerLowerHalf: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "magnifyingglass")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***TextField(facilityListIsVisible ? String.filterFacilities : String.filterSites, text: $query)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disableAutocorrection(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.focused($textFieldIsFocused)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.keyboardType(.alphabet)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(facilityListIsVisible) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***query.removeAll()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***textFieldIsFocused = false
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if textFieldIsFocused && !query.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***XButton(.clear) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***query.removeAll()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding(5)
***REMOVED******REMOVED******REMOVED***.background(.quinary)
***REMOVED******REMOVED******REMOVED***.clipShape(.rect(cornerRadius: 10))
***REMOVED******REMOVED******REMOVED***if textFieldIsFocused {
***REMOVED******REMOVED******REMOVED******REMOVED***Button(String.cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***query.removeAll()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***textFieldIsFocused = false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.transition(.move(edge: .trailing))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The portion of the header containing the navigation controls.
***REMOVED***var headerUpperHalf: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***userDidBackOutToSiteList = true
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.left")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.toolkitDefault)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(Rectangle())
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED******REMOVED***.opacity(backButtonIsVisible ? 1 : 0)
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if allSitesIsSelected {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(String.allSites)
***REMOVED******REMOVED******REMOVED*** else if facilityListIsVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(viewModel.selection?.site?.name ?? String.selectAFacility)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text.sites
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***XButton(.dismiss) {
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.title3)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view containing a list of the site names.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ If `AutomaticSelectionMode` mode is in use, items will automatically be
***REMOVED******REMOVED***/ selected/deselected.
***REMOVED***@ViewBuilder
***REMOVED***var siteList: some View {
***REMOVED******REMOVED***List(matchingSites) { site in
***REMOVED******REMOVED******REMOVED***Button(site.name) {
***REMOVED******REMOVED******REMOVED******REMOVED***userDidBackOutToSiteList = false
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setSite(site)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***allSitesIsSelected = false
***REMOVED***
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***allSitesIsSelected = true
***REMOVED******REMOVED******REMOVED***userDidBackOutToSiteList = false
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text(String.allSites)
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED***.padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
***REMOVED******REMOVED***.transition(.move(edge: .bottom))
***REMOVED***
***REMOVED***

@available(visionOS, unavailable)
extension SiteAndFacilitySelector {
***REMOVED******REMOVED***/ A Boolean value indicating whether the back button in the header navigations controls is visible..
***REMOVED***var backButtonIsVisible: Bool {
***REMOVED******REMOVED***facilityListIsVisible
***REMOVED******REMOVED***&& multipleSitesAreAvailable
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the facility list is visible.
***REMOVED***var facilityListIsVisible: Bool {
***REMOVED******REMOVED***(allSitesIsSelected
***REMOVED******REMOVED*** || viewModel.selection != .none
***REMOVED******REMOVED*** || !multipleSitesAreAvailable)
***REMOVED******REMOVED***&& !userDidBackOutToSiteList
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A subset of `facilities` with names containing `query` or all `facilities` if
***REMOVED******REMOVED***/ `query` is empty.
***REMOVED***var matchingFacilities: [FloorFacility] {
***REMOVED******REMOVED***let facilities = allSitesIsSelected ? viewModel.facilities : viewModel.selection?.site?.facilities ?? viewModel.facilities
***REMOVED******REMOVED***guard !query.isEmpty else {
***REMOVED******REMOVED******REMOVED***return facilities
***REMOVED******REMOVED******REMOVED******REMOVED***.sorted { $0.name < $1.name ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***return facilities
***REMOVED******REMOVED******REMOVED***.filter { $0.name.localizedStandardContains(query) ***REMOVED***
***REMOVED******REMOVED******REMOVED***.sorted { $0.name < $1.name  ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A subset of `sites` with names containing `query` or all `sites` if `query` is empty.
***REMOVED***var matchingSites: [FloorSite] {
***REMOVED******REMOVED***guard !query.isEmpty else {
***REMOVED******REMOVED******REMOVED***return viewModel.sites
***REMOVED***
***REMOVED******REMOVED***return viewModel.sites.filter {
***REMOVED******REMOVED******REMOVED***$0.name.localizedStandardContains(query)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the floor aware data contains more than one site.
***REMOVED***var multipleSitesAreAvailable: Bool {
***REMOVED******REMOVED***viewModel.sites.count > 1
***REMOVED***
***REMOVED***

private extension String {
***REMOVED***static var allSites: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "All Sites",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A reference to all of the sites defined in a floor aware map."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A field allowing the user to filter a list of facilities by name. A facility contains one or more levels in a floor-aware map or scene.
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
***REMOVED******REMOVED***/ A field allowing the user to filter a list of sites by name. A site contains one or more facilities in a floor-aware map or scene.
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
***REMOVED******REMOVED***/ A label directing the user to select a facility. A facility contains one or more levels in a floor-aware map or scene.
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
