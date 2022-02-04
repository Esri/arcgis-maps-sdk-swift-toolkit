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
***REMOVED******REMOVED***/ - Parameter floorFilterViewModel: The view model used by the `SiteAndFacilitySelector`.
***REMOVED******REMOVED***/ - Parameter isVisible: A binding used to dismiss the site selector.
***REMOVED***init(
***REMOVED******REMOVED***floorFilterViewModel: FloorFilterViewModel,
***REMOVED******REMOVED***isVisible: Binding<Bool>
***REMOVED***) {
***REMOVED******REMOVED***self.viewModel = floorFilterViewModel
***REMOVED******REMOVED***self.isVisible = isVisible
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the `SiteAndFacilitySelector`.
***REMOVED***@ObservedObject
***REMOVED***private var viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site and facility selector.
***REMOVED***private var isVisible: Binding<Bool>
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if viewModel.sites.count > 1 && !(viewModel.selectedSite == nil) {
***REMOVED******REMOVED******REMOVED******REMOVED*** Only show site list if there is more than one site
***REMOVED******REMOVED******REMOVED******REMOVED*** and the user has not yet selected a site.
***REMOVED******REMOVED******REMOVED***Sites(sites: viewModel.sites, isVisible: isVisible)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Facilities(facilities: viewModel.facilities, isVisible: isVisible)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view displaying the sites contained in a `FloorManager`.
***REMOVED***struct Sites: View {
***REMOVED******REMOVED***let sites: [FloorSite]
***REMOVED******REMOVED***var isVisible: Binding<Bool>

***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***LazyVStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED***Header(title: "Select a site…", isVisible: isVisible)
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(sites) { site in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(site.name)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED***
***REMOVED***

***REMOVED******REMOVED***/ A view displaying the facilities contained in a `FloorManager`.
***REMOVED***struct Facilities: View {
***REMOVED******REMOVED***let facilities: [FloorFacility]
***REMOVED******REMOVED***var isVisible: Binding<Bool>
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***LazyVStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED***Header(title: "Select a facility…", isVisible: isVisible)
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(facilities) { facility in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(facility.name)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The header for a site or facility selector.
***REMOVED***struct Header: View {
***REMOVED******REMOVED***let title: String
***REMOVED******REMOVED***var isVisible: Binding<Bool>
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isVisible.wrappedValue.toggle()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle", label: Text("Close"))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: 1)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED***
***REMOVED***
***REMOVED***
