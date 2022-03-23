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

***REMOVED******REMOVED***/ The view model used by the `SiteAndFacilitySelector`.
***REMOVED***@EnvironmentObject
***REMOVED***var floorFilterViewModel: FloorFilterViewModel

***REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED***private var isHidden: Binding<Bool>

***REMOVED***var body: some View {
***REMOVED******REMOVED***if let selectedSite = floorFilterViewModel.selectedSite {
***REMOVED******REMOVED******REMOVED***FacilitiesView(facilities: selectedSite.facilities, isHidden: isHidden)
***REMOVED*** else if floorFilterViewModel.sites.count == 1 {
***REMOVED******REMOVED******REMOVED***FacilitiesView(
***REMOVED******REMOVED******REMOVED******REMOVED***facilities: floorFilterViewModel.sites.first!.facilities,
***REMOVED******REMOVED******REMOVED******REMOVED***isHidden: isHidden
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***SitesView(sites: floorFilterViewModel.sites, isHidden: isHidden)
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ A view displaying the sites contained in a `FloorManager`.
***REMOVED***struct SitesView: View {
***REMOVED******REMOVED******REMOVED***/ The floor sites.
***REMOVED******REMOVED***let sites: [FloorSite]

***REMOVED******REMOVED******REMOVED***/ Allows the user to toggle the visibility of the sites.
***REMOVED******REMOVED***var isHidden: Binding<Bool>

***REMOVED******REMOVED******REMOVED***/ The view model used by the `Sites`.
***REMOVED******REMOVED***@EnvironmentObject
***REMOVED******REMOVED***var floorFilterViewModel: FloorFilterViewModel

***REMOVED******REMOVED******REMOVED***/ The height of the scroll view's content.
***REMOVED******REMOVED***@State
***REMOVED******REMOVED***private var scrollViewContentHeight: CGFloat = .zero

***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED***Header(title: "Select a site", isHidden: isHidden)
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(sites) { site in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(site.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***floorFilterViewModel.selection = .site(site)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(4)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.selected(floorFilterViewModel.selectedSite == site)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scrollViewContentHeight = $0.height
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxHeight: scrollViewContentHeight)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ A view displaying the facilities contained in a `FloorManager`.
***REMOVED***struct FacilitiesView: View {
***REMOVED******REMOVED***let facilities: [FloorFacility]
***REMOVED******REMOVED***var isHidden: Binding<Bool>

***REMOVED******REMOVED***@EnvironmentObject var floorFilterViewModel: FloorFilterViewModel

***REMOVED******REMOVED******REMOVED***/ The height of the scroll view's content.
***REMOVED******REMOVED***@State
***REMOVED******REMOVED***private var scrollViewContentHeight: CGFloat = .zero

***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED***Header(title: "Select a facility", isHidden: isHidden)
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(facilities) { facility in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(facility.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***floorFilterViewModel.selection = .facility(facility)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isHidden.wrappedValue = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(4 )
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.selected(floorFilterViewModel.selectedFacility == facility)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSizeChange {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scrollViewContentHeight = $0.height
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxHeight: scrollViewContentHeight)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ The header for a site or facility selector.
***REMOVED***struct Header: View {
***REMOVED******REMOVED***let title: String
***REMOVED******REMOVED***var isHidden: Binding<Bool>

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
