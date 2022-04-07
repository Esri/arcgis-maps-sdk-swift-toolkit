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
***REMOVED******REMOVED***/ Creates a `SiteAndFacilitySelector`
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
***REMOVED******REMOVED***if viewModel.sites.count == 1 {
***REMOVED******REMOVED******REMOVED***FacilitiesList(
***REMOVED******REMOVED******REMOVED******REMOVED***facilities: viewModel.sites.first!.facilities,
***REMOVED******REMOVED******REMOVED******REMOVED***presentationStyle: .singleSite,
***REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***SitesList(
***REMOVED******REMOVED******REMOVED******REMOVED***sites: viewModel.sites,
***REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view displaying the sites contained in a `FloorManager`.
***REMOVED***struct SitesList: View {
***REMOVED******REMOVED******REMOVED***/ The view model used by this selector.
***REMOVED******REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Indicates whether the view model should be notified of the selection update.
***REMOVED******REMOVED***@State private var updateViewModel = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Indicates that the keyboard is animating and some views may require reload.
***REMOVED******REMOVED***@State private var keyboardAnimating = false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A site name filter phrase entered by the user.
***REMOVED******REMOVED***@State private var searchPhrase: String = ""
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A local record of the site selected in the view model.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ As the view model's selection will change to `.facility(FloorFacility)` and
***REMOVED******REMOVED******REMOVED***/ `.level(FloorLevel)` over time, this is needed to keep track of the site at the top of the
***REMOVED******REMOVED******REMOVED***/ hierarchy to keep the site selection persistent in the navigation view.
***REMOVED******REMOVED***@State private var selectedSite: FloorSite? {
***REMOVED******REMOVED******REMOVED***didSet {
***REMOVED******REMOVED******REMOVED******REMOVED***if updateViewModel {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setSite(selectedSite)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***updateViewModel = true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Sites contained in a `FloorManager`.
***REMOVED******REMOVED***let sites: [FloorSite]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED******REMOVED***var isHidden: Binding<Bool>
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A subset of `sites` with names containing `searchPhrase` or all `sites` if
***REMOVED******REMOVED******REMOVED***/ `searchPhrase` is empty.
***REMOVED******REMOVED***var matchingSites: [FloorSite] {
***REMOVED******REMOVED******REMOVED***if searchPhrase.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***return sites
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return sites.filter {
***REMOVED******REMOVED******REMOVED******REMOVED***$0.name.lowercased().contains(searchPhrase.lowercased())
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***siteListAndFilterView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Trigger a reload on keyboard frame changes for proper layout
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** across all devices.
***REMOVED******REMOVED******REMOVED******REMOVED***.opacity(keyboardAnimating ? 0.99 : 1.0)
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationViewStyle(.stack)
***REMOVED******REMOVED******REMOVED******REMOVED***.onReceive(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NotificationCenter.default.publisher(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: UIResponder.keyboardWillChangeFrameNotification
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***keyboardAnimating = true
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onReceive(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NotificationCenter.default.publisher(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: UIResponder.keyboardDidChangeFrameNotification
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***keyboardAnimating = false
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A view containing a filter-via-name field, a list of the site names and an "All sites" button.
***REMOVED******REMOVED***var siteListAndFilterView: some View {
***REMOVED******REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField("Filter sites", text: $searchPhrase)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.keyboardType(.alphabet)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disableAutocorrection(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if matchingSites.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NoMatchesView()
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***siteListView
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink("All sites") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FacilitiesList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilities: sites.flatMap({ $0.facilities ***REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***presentationStyle: .allSites,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.vertical], 4)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitle(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Select a site"),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***displayMode: .inline
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarItems(trailing:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CloseButton { isHidden.wrappedValue.toggle() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: $selectedSite
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FacilitiesList(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilities: site.facilities,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***presentationStyle: .standard,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setSite(site)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED******REMOVED***.onChange(of: $viewModel.selection.wrappedValue) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Setting the `updateViewModel` flag false allows
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** `selectedSite` to receive upstream updates from the view
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** model without republishing them back up to the view model.
***REMOVED******REMOVED******REMOVED******REMOVED***updateViewModel = false
***REMOVED******REMOVED******REMOVED******REMOVED***selectedSite = viewModel.selectedSite
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view displaying the facilities contained in a `FloorManager`.
***REMOVED***struct FacilitiesList: View {
***REMOVED******REMOVED******REMOVED***/ The view model used by this selector.
***REMOVED******REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Presentation styles for the facility list.
***REMOVED******REMOVED***enum PresentationStyle {
***REMOVED******REMOVED******REMOVED******REMOVED***/ A specific site was selected and the body is presented within a navigation view.
***REMOVED******REMOVED******REMOVED***case standard
***REMOVED******REMOVED******REMOVED******REMOVED***/ The all sites button was selcted and the body is presented within a navigation view.
***REMOVED******REMOVED******REMOVED***case allSites
***REMOVED******REMOVED******REMOVED******REMOVED***/ Only one site exists and the body is not presented within a navigation view.
***REMOVED******REMOVED******REMOVED***case singleSite
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A facility name filter phrase entered by the user.
***REMOVED******REMOVED***@State
***REMOVED******REMOVED***var searchPhrase: String = ""
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ `FloorFacility`s to be displayed by this view.
***REMOVED******REMOVED***let facilities: [FloorFacility]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The selected presentation style for the facility list.
***REMOVED******REMOVED***let presentationStyle: PresentationStyle
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED******REMOVED***var isHidden: Binding<Bool>
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A subset of `facilities` with names containing `searchPhrase` or all
***REMOVED******REMOVED******REMOVED***/ `facilities` if `searchPhrase` is empty.
***REMOVED******REMOVED***var matchingFacilities: [FloorFacility] {
***REMOVED******REMOVED******REMOVED***if searchPhrase.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***return facilities
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return facilities.filter {
***REMOVED******REMOVED******REMOVED******REMOVED***$0.name.lowercased().contains(searchPhrase.lowercased())
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Determines the SF Symbols image name to represent selection/non-selection of a facility.
***REMOVED******REMOVED******REMOVED***/ - Parameter facility: The facility of interest
***REMOVED******REMOVED******REMOVED***/ - Returns: "circle.fill" if the facility is marked selected or "cirlce" if the facility is not selected
***REMOVED******REMOVED******REMOVED***/ in the view model.
***REMOVED******REMOVED***func imageFor(_ facility: FloorFacility) -> String {
***REMOVED******REMOVED******REMOVED***if facility.id == viewModel.selectedFacility?.id {
***REMOVED******REMOVED******REMOVED******REMOVED***return "circle.fill"
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return "circle"
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***if presentationStyle == .singleSite {
***REMOVED******REMOVED******REMOVED******REMOVED***facilityListAndFilterView
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***facilityListAndFilterView
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Only apply navigation modifiers if this is displayed
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** within a navigation view
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitle("Select a facility")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarItems(trailing:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CloseButton { isHidden.wrappedValue.toggle() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A view containing a label for the site name, a filter-via-name bar and a list of the facility names.
***REMOVED******REMOVED***var facilityListAndFilterView: some View {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if presentationStyle == .standard {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(facilities.first?.site?.name ?? "N/A")
***REMOVED******REMOVED******REMOVED******REMOVED*** else if presentationStyle == .allSites {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("All sites")
***REMOVED******REMOVED******REMOVED******REMOVED*** else if presentationStyle == .singleSite {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(facilities.first?.site?.name ?? "N/A")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CloseButton { isHidden.wrappedValue.toggle() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***TextField("Filter facilities", text: $searchPhrase)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.keyboardType(.alphabet)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disableAutocorrection(true)
***REMOVED******REMOVED******REMOVED******REMOVED***if matchingFacilities.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NoMatchesView()
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilityListView
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Displays a list of facilities matching the filter criteria as determined by
***REMOVED******REMOVED******REMOVED***/ `matchingFacilities`.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ If a certain facility is indicated as selected by the view model, it will have a slighlty different
***REMOVED******REMOVED******REMOVED***/ appearance.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ If `AutomaticSelectionMode` mode is in use, this list will automatically scroll to the
***REMOVED******REMOVED******REMOVED***/ selected item.
***REMOVED******REMOVED***var facilityListView: some View {
***REMOVED******REMOVED******REMOVED***ScrollViewReader { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED***List(matchingFacilities, id: \.id) { facility in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setFacility(facility)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden.wrappedValue.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: imageFor(facility))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(facility.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.regular)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: .infinity,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .leading
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if presentationStyle == .allSites,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let siteName = facility.site?.name {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(siteName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.ultraLight)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: .infinity,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .leading
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: viewModel.selection) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let floorFacility = viewModel.selectedFacility {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***proxy.scrollTo(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***floorFacility.id,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***anchor: .center
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ Displays text "No matches found".
struct NoMatchesView: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***Text("No matches found")
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A custom button with an "X" enclosed within a circle to be used as a "close" button.
struct CloseButton: View {
***REMOVED******REMOVED***/ The button's action to be performed when tapped.
***REMOVED***var action: (() -> Void)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***action()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle")
***REMOVED***
***REMOVED***
***REMOVED***
