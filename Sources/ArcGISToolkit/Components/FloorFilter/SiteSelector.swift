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

struct SiteSelector: View {
***REMOVED******REMOVED***/ Creates a `FloorFilter`
***REMOVED******REMOVED***/ - Parameter content: The view shown in the floating panel.
***REMOVED***public init(
***REMOVED******REMOVED***_ floorFilterViewModel: FloorFilterViewModel,
***REMOVED******REMOVED***showSiteSelector: Binding<Bool>
***REMOVED***) {
***REMOVED******REMOVED***self.viewModel = floorFilterViewModel
***REMOVED******REMOVED***self.showSiteSelector = showSiteSelector
***REMOVED***
***REMOVED***
***REMOVED***private let viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ Binding allowing the user to toggle the visibility of the results list.
***REMOVED***private var showSiteSelector: Binding<Bool>
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if viewModel.sites.count > 1 && !(viewModel.selectedSite == nil) {
***REMOVED******REMOVED******REMOVED******REMOVED*** Only show site list if there is more than one site
***REMOVED******REMOVED******REMOVED******REMOVED*** and the user has not yet selected a site.
***REMOVED******REMOVED******REMOVED***FloorFilterList(
***REMOVED******REMOVED******REMOVED******REMOVED***"Select a site...",
***REMOVED******REMOVED******REMOVED******REMOVED***sites: viewModel.sites,
***REMOVED******REMOVED******REMOVED******REMOVED***showSiteSelector: showSiteSelector
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***FloorFilterList(
***REMOVED******REMOVED******REMOVED******REMOVED***"Select a facility...",
***REMOVED******REMOVED******REMOVED******REMOVED***facilities: viewModel.facilities,
***REMOVED******REMOVED******REMOVED******REMOVED***showSiteSelector: showSiteSelector
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct FloorFilterList: View {
***REMOVED******REMOVED***private let title: String
***REMOVED******REMOVED***private let sites: [FloorSite]?
***REMOVED******REMOVED***private let facilities: [FloorFacility]?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Binding allowing the user to toggle the visibility of the results list.
***REMOVED******REMOVED***private var showSiteSelector: Binding<Bool>
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(
***REMOVED******REMOVED******REMOVED***_ title: String,
***REMOVED******REMOVED******REMOVED***sites: [FloorSite],
***REMOVED******REMOVED******REMOVED***showSiteSelector: Binding<Bool>
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***self.title = title
***REMOVED******REMOVED******REMOVED***self.sites = sites
***REMOVED******REMOVED******REMOVED***facilities = []
***REMOVED******REMOVED******REMOVED***self.showSiteSelector = showSiteSelector
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(
***REMOVED******REMOVED******REMOVED***_ title: String,
***REMOVED******REMOVED******REMOVED***facilities: [FloorFacility],
***REMOVED******REMOVED******REMOVED***showSiteSelector: Binding<Bool>
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***self.title = title
***REMOVED******REMOVED******REMOVED***self.facilities = facilities
***REMOVED******REMOVED******REMOVED***sites = nil
***REMOVED******REMOVED******REMOVED***self.showSiteSelector = showSiteSelector
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED******REMOVED***TODO: figure this navigation stuff out or at least get to a demo-able point
***REMOVED******REMOVED******REMOVED******REMOVED***LazyVStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showSiteSelector.wrappedValue.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height:1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(sites ?? []) { site in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***destination: EmptyView()) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(site.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(facilities ?? []) { facility in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***destination: EmptyView()) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(facility.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitle("Mountain Airport")
***REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED***
