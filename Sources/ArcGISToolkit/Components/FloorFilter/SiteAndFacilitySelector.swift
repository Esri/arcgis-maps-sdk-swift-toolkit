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
***REMOVED***@EnvironmentObject var floorFilterViewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED***private var isHidden: Binding<Bool>

***REMOVED***@State
***REMOVED***var text: String = ""
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***TextField("Enter site name", text: $text)
***REMOVED******REMOVED******REMOVED******REMOVED***.border(.gray)
***REMOVED******REMOVED******REMOVED***if floorFilterViewModel.sites.count == 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***Facilities(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilities: floorFilterViewModel.sites.first!.facilities,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showSites: true
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Sites(sites: floorFilterViewModel.sites, isHidden: isHidden)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view displaying the sites contained in a `FloorManager`.
***REMOVED***struct Sites: View {
***REMOVED******REMOVED***let sites: [FloorSite]
***REMOVED******REMOVED***var isHidden: Binding<Bool>
***REMOVED******REMOVED***
***REMOVED******REMOVED***@EnvironmentObject var floorFilterViewModel: FloorFilterViewModel

***REMOVED******REMOVED******REMOVED***/ The height of the scroll view's content.
***REMOVED******REMOVED***@State
***REMOVED******REMOVED***private var scrollViewContentHeight: CGFloat = .zero

***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List(sites) { (site) in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***site.name,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***destination: Facilities(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilities: site.facilities,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"All sites",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***destination: Facilities(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***facilities: sites.flatMap({ $0.facilities ***REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showSites: true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.top, .bottom], 4)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitle(Text("Select a site"), displayMode: .inline)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view displaying the facilities contained in a `FloorManager`.
***REMOVED***struct Facilities: View {
***REMOVED******REMOVED***let facilities: [FloorFacility]

***REMOVED******REMOVED***var isHidden: Binding<Bool>

***REMOVED******REMOVED***var showSites: Bool = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***@EnvironmentObject var floorFilterViewModel: FloorFilterViewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The height of the scroll view's content.
***REMOVED******REMOVED***@State
***REMOVED******REMOVED***private var scrollViewContentHeight: CGFloat = .zero
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***List(facilities) { facility in
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print(facility.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***floorFilterViewModel.selection = .facility(facility)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden.wrappedValue.toggle()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(facility.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***floorFilterViewModel.selectedFacility == facility ? .bold : .regular
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if showSites, let siteName = facility.site?.name {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(siteName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.ultraLight)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.listStyle(.plain)
***REMOVED******REMOVED******REMOVED***.navigationBarTitle("Select a facility")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The header for a site or facility selector.
***REMOVED***struct Header: View {
***REMOVED******REMOVED***let title: String
***REMOVED******REMOVED***var isHidden: Binding<Bool>
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden.wrappedValue.toggle()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
