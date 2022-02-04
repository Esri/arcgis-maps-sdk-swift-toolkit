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

***REMOVED***/ The `FloorFilter` component simplifies visualization of GIS data for a specific floor of a building
***REMOVED***/ in your application. It allows you to filter the floor plan data displayed in your map or scene view
***REMOVED***/ to a site, a facility (building) in the site, or a floor in the facility.
public struct FloorFilter: View {
***REMOVED******REMOVED***/ Creates a `FloorFilter`
***REMOVED******REMOVED***/ - Parameter viewModel: The view model used by the `FloorFilter`.
***REMOVED***public init(viewModel: FloorFilterViewModel) {
***REMOVED******REMOVED***self.viewModel = viewModel
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the `FloorFilter`.
***REMOVED***@ObservedObject
***REMOVED***private(set) var viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED******REMOVED***/ Allows the user to toggle the visibility of the site selector.
***REMOVED***@State
***REMOVED***private var isSelectorVisible: Bool = false
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***if viewModel.isLoading {
***REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(.circular)
***REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***HStack(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isSelectorVisible.toggle()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image("Site", bundle: .module, label: Text("Site"))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED******REMOVED***if isSelectorVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SiteAndFacilitySelector(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isVisible: $isSelectorVisible
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 200)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
