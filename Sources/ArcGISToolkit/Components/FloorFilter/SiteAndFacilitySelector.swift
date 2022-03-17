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
***REMOVED******REMOVED***/ - Parameter selectedFacilityID: Indicates the implicity selected facility based on the
***REMOVED******REMOVED***/ current viewpoint.
***REMOVED******REMOVED***/ - Parameter selectedSiteID: Indicates the implicity selected site based on the current
***REMOVED******REMOVED***/ viewpoint.
***REMOVED***init(isHidden: Binding<Bool>) {
***REMOVED******REMOVED***self.isHidden = isHidden
***REMOVED***

***REMOVED******REMOVED***/ The view model used by the `SiteAndFacilitySelector`.
***REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel

***REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED***private var isHidden: Binding<Bool>

***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if viewModel.sites.count == 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***Facilities(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilities: viewModel.sites.first!.facilities,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showSites: true
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Sites(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sites: viewModel.sites
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ A view displaying the sites contained in a `FloorManager`.
***REMOVED***struct Sites: View {
***REMOVED******REMOVED******REMOVED***/ The view model used by this selector.
***REMOVED******REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel

***REMOVED******REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED******REMOVED***var isHidden: Binding<Bool>

***REMOVED******REMOVED******REMOVED***/ A subset of `sites` that contain `searchPhrase`.
***REMOVED******REMOVED***var matchingSites: [FloorSite] {
***REMOVED******REMOVED******REMOVED***if searchPhrase.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***return sites
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return sites.filter { floorSite in
***REMOVED******REMOVED******REMOVED******REMOVED***floorSite.name.lowercased().contains(searchPhrase.lowercased())
***REMOVED******REMOVED***
***REMOVED***

***REMOVED******REMOVED******REMOVED***/ A site filtering phrase entered by the user.
***REMOVED******REMOVED***@State
***REMOVED******REMOVED***var searchPhrase: String = ""

***REMOVED******REMOVED******REMOVED***/ Sites contained in a `FloorManager`.
***REMOVED******REMOVED***let sites: [FloorSite]

***REMOVED******REMOVED******REMOVED***/ The height of the scroll view's content.
***REMOVED******REMOVED***@State
***REMOVED******REMOVED***private var scrollViewContentHeight: CGFloat = .zero

***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField("Filter sites", text: $searchPhrase)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.keyboardType(.alphabet)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disableAutocorrection(true)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List(matchingSites) { (site) in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***site.name,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***tag: site,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: $viewModel.selectedSite
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Facilities(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilities: site.facilities,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setSite(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***site,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***zoomTo: true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink("All sites") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Facilities(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilities: sites.flatMap({ $0.facilities ***REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showSites: true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top, .bottom], 4)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitle(Text("Select a site"), displayMode: .inline)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationViewStyle(.stack)
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ A view displaying the facilities contained in a `FloorManager`.
***REMOVED***struct Facilities: View {
***REMOVED******REMOVED******REMOVED***/ `FloorFacility`s to be displayed by this view.
***REMOVED******REMOVED***let facilities: [FloorFacility]

***REMOVED******REMOVED******REMOVED***/ The view model used by this selector.
***REMOVED******REMOVED***@EnvironmentObject var viewModel: FloorFilterViewModel

***REMOVED******REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED******REMOVED***var isHidden: Binding<Bool>

***REMOVED******REMOVED******REMOVED***/ A subset of `facilities` that contain `searchPhrase`.
***REMOVED******REMOVED***var matchingFacilities: [FloorFacility] {
***REMOVED******REMOVED******REMOVED***if searchPhrase.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***return facilities
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return facilities.filter { floorFacility in
***REMOVED******REMOVED******REMOVED******REMOVED***floorFacility.name.lowercased().contains(searchPhrase.lowercased())
***REMOVED******REMOVED***
***REMOVED***

***REMOVED******REMOVED******REMOVED***/ A facility filtering phrase entered by the user.
***REMOVED******REMOVED***@State
***REMOVED******REMOVED***var searchPhrase: String = ""

***REMOVED******REMOVED******REMOVED***/ Indicates if site names should be shown as subtitles to the facility.
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***/ Used when the user selects "All sites".
***REMOVED******REMOVED***var showSites: Bool = false

***REMOVED******REMOVED******REMOVED***/ Determines  if a given site is the one marked as selected in the view model.
***REMOVED******REMOVED******REMOVED***/ - Parameter facility: The facility of interest
***REMOVED******REMOVED******REMOVED***/ - Returns: `true` if the facility is marked as selected in the view model.
***REMOVED******REMOVED***func facilityIsSelected(_ facility: FloorFacility) -> Bool {
***REMOVED******REMOVED******REMOVED***return facility.facilityId ==
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selectedFacility?.facilityId
***REMOVED***

***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if !showSites, let siteName = facilities.first?.site?.name {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(siteName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.ultraLight)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***TextField("Filter facilities", text: $searchPhrase)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.keyboardType(.alphabet)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disableAutocorrection(true)
***REMOVED******REMOVED******REMOVED******REMOVED***ScrollViewReader { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List(matchingFacilities, id: \.facilityId) { facility in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setFacility(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facility,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***zoomTo: true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden.wrappedValue.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***systemName:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilityIsSelected(facility) ? "circle.fill" : "circle"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(facility.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.regular)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: .infinity,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .leading
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if showSites, let siteName = facility.site?.name {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(siteName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.ultraLight)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: .infinity,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .leading
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: viewModel.selectedFacility) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let facility = $0 else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***proxy.scrollTo(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facility.facilityId,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***anchor: .center
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitle("Select a facility")
***REMOVED***
***REMOVED***
***REMOVED***
