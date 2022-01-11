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
***REMOVED******REMOVED***self.showSiteList = showSiteSelector
***REMOVED***

***REMOVED***private let viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ Binding allowing the user to toggle the visibility of the results list.
***REMOVED***private var showSiteList: Binding<Bool>

***REMOVED******REMOVED*** TODO: refactor if-else below.
***REMOVED***var body: some View {
***REMOVED******REMOVED***if !viewModel.sites.isEmpty {
***REMOVED******REMOVED******REMOVED***LazyVStack {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Select a site...")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showSiteList.wrappedValue.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height:1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.sites) { site in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("\(site.name)")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***LazyVStack {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Select a facility...")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showSiteList.wrappedValue.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "xmark.circle")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height:1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.facilities) { facility in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("\(facility.name)")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED***
***REMOVED***
***REMOVED***
