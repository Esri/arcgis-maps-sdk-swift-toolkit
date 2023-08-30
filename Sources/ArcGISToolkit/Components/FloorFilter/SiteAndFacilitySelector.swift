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

***REMOVED***/ A view which allows selection of sites and facilities represented in a `FloorManager`.
struct SiteAndFacilitySelector: View {
***REMOVED******REMOVED***/ Creates a `SiteAndFacilitySelector`.
***REMOVED******REMOVED***/ - Parameter isHidden: A binding used to dismiss the site selector.
***REMOVED***init(isHidden: Binding<Bool>) {
***REMOVED******REMOVED***self.isHidden = isHidden
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the `SiteAndFacilitySelector`.
***REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED***private var isHidden: Binding<Bool>
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If there's more than one site
***REMOVED******REMOVED******REMOVED******REMOVED***if viewModel.sites.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Show the list of sites for site selection
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SitesList(isHidden: isHidden)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Otherwise there're no sites or only one site, show the list of facilities
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FacilitiesList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***usesAllSitesStyling: false,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilities: viewModel.facilities,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarBackButtonHidden(true)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CloseButton { isHidden.wrappedValue.toggle() ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.navigationViewStyle(.stack)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view displaying the sites contained in a `FloorManager`.
***REMOVED***struct SitesList: View {
***REMOVED******REMOVED***@Environment(\.horizontalSizeClass)
***REMOVED******REMOVED***private var horizontalSizeClass: UserInterfaceSizeClass?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The view model used by this selector.
***REMOVED******REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A site name filter phrase entered by the user.
***REMOVED******REMOVED***@State private var query: String = ""
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Indicates that the user pressed the back button in the navigation view, indicating the
***REMOVED******REMOVED******REMOVED***/ site should appear "de-selected" even though the viewpoint hasn't changed.
***REMOVED******REMOVED***@State private var userBackedOutOfSelectedSite = false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED******REMOVED***var isHidden: Binding<Bool>
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A subset of `sites` with names containing `searchPhrase` or all `sites` if
***REMOVED******REMOVED******REMOVED***/ `searchPhrase` is empty.
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** If the filtered set of sites is empty
***REMOVED******REMOVED******REMOVED******REMOVED***if matchingSites.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Show the "no matches" view
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NoMatchesView()
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Show the filtered set of sites
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***siteListView
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***allSitesButton
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.searchable(
***REMOVED******REMOVED******REMOVED******REMOVED***text: $query,
***REMOVED******REMOVED******REMOVED******REMOVED***placement: .navigationBarDrawer(displayMode: .always),
***REMOVED******REMOVED******REMOVED******REMOVED***prompt: String(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***localized: "Filter sites",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** A field allowing the user to filter a list of sites by name. A site
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** contains one or more facilities in a floor-aware map or scene.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.keyboardType(.alphabet)
***REMOVED******REMOVED******REMOVED***.disableAutocorrection(true)
***REMOVED******REMOVED******REMOVED***.navigationTitle(String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "Sites",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label in reference to all of the sites in a floor-aware map or scene."
***REMOVED******REMOVED******REMOVED***))
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The "All sites" button.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ This button presents the facilities list in a special format where the facilities list
***REMOVED******REMOVED******REMOVED***/ shows every facility in every site within the floor manager.
***REMOVED******REMOVED***var allSitesButton: some View {
***REMOVED******REMOVED******REMOVED***NavigationLink {
***REMOVED******REMOVED******REMOVED******REMOVED***FacilitiesList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***usesAllSitesStyling: true,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilities: viewModel.sites.flatMap(\.facilities),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CloseButton { isHidden.wrappedValue.toggle() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"All sites",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A reference to all of the sites defined in a floor aware map."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED***.padding([.bottom], horizontalSizeClass == .compact ? 5 : 0)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A view containing a list of the site names.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ If `AutomaticSelectionMode` mode is in use, items will automatically be
***REMOVED******REMOVED******REMOVED***/ selected/deselected.
***REMOVED******REMOVED***var siteListView: some View {
***REMOVED******REMOVED******REMOVED***List(matchingSites) { site in
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***site.name,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***tag: site,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***get: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***userBackedOutOfSelectedSite ? nil : viewModel.selection?.site
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***set: { newSite in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let newSite = newSite else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***userBackedOutOfSelectedSite = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setSite(newSite, zoomTo: true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FacilitiesList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***usesAllSitesStyling: false,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilities: site.facilities,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarBackButtonHidden(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***userBackedOutOfSelectedSite = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.left")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CloseButton { isHidden.wrappedValue.toggle() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED******REMOVED***.onChange(of: viewModel.selection) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***userBackedOutOfSelectedSite = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view displaying the facilities contained in a `FloorManager`.
***REMOVED***struct FacilitiesList: View {
***REMOVED******REMOVED***@Environment(\.horizontalSizeClass)
***REMOVED******REMOVED***private var horizontalSizeClass: UserInterfaceSizeClass?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The view model used by this selector.
***REMOVED******REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A facility name filter phrase entered by the user.
***REMOVED******REMOVED***@State var query: String = ""
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ When `true`, the facilites list will be display with all sites styling.
***REMOVED******REMOVED***let usesAllSitesStyling: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ `FloorFacility`s to be displayed by this view.
***REMOVED******REMOVED***let facilities: [FloorFacility]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED******REMOVED***var isHidden: Binding<Bool>
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A subset of `facilities` with names containing `searchPhrase` or all
***REMOVED******REMOVED******REMOVED***/ `facilities` if `searchPhrase` is empty.
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NoMatchesView()
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilityListView
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.searchable(
***REMOVED******REMOVED******REMOVED******REMOVED***text: $query,
***REMOVED******REMOVED******REMOVED******REMOVED***placement: .navigationBarDrawer(displayMode: .always),
***REMOVED******REMOVED******REMOVED******REMOVED***prompt: String(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***localized: "Filter facilities",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** A field allowing the user to filter a list of facilities by name. A
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** facility contains one or more levels in a floor-aware map or scene.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.keyboardType(.alphabet)
***REMOVED******REMOVED******REMOVED***.disableAutocorrection(true)
***REMOVED******REMOVED******REMOVED***.navigationTitle(
***REMOVED******REMOVED******REMOVED******REMOVED***usesAllSitesStyling ?
***REMOVED******REMOVED******REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***localized: "All sites",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A reference to all of the sites defined in a floor aware map."
***REMOVED******REMOVED******REMOVED******REMOVED***) :
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selection?.site?.name ?? String(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***localized: "Select a facility",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** A label directing the user to select a facility. A facility contains one
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** or more levels in a floor-aware map or scene.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
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
***REMOVED******REMOVED***var facilityListView: some View {
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden.wrappedValue.toggle()
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

***REMOVED***/ Displays text "No matches found".
private struct NoMatchesView: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"No matches found",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A statement that no sites or facilities with names matching a filter phrase were found."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.frame(maxHeight: .infinity)
***REMOVED***
***REMOVED***

***REMOVED***/ A custom button with an "X" enclosed within a circle to be used as a "close" button.
private struct CloseButton: View {
***REMOVED******REMOVED***/ The button's action to be performed when tapped.
***REMOVED***var action: (() -> Void)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button(action: action) {
***REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle")
***REMOVED***
***REMOVED***
***REMOVED***
