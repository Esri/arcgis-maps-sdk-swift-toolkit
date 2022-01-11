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

public struct FloorFilter: View {
***REMOVED******REMOVED***/ Creates a `FloorFilter`
***REMOVED******REMOVED***/ - Parameter content: The view shown in the floating panel.
***REMOVED***public init(_ floorFilterViewModel: FloorFilterViewModel) {
***REMOVED******REMOVED***self.viewModel = floorFilterViewModel
***REMOVED***
***REMOVED***
***REMOVED***@ObservedObject
***REMOVED***private(set) var viewModel: FloorFilterViewModel
***REMOVED***
***REMOVED***@State
***REMOVED***private var showSiteSelector: Bool = false
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***HStack(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED***if viewModel.isLoading {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(CircularProgressViewStyle())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** show levels and close button here
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showSiteSelector.toggle()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: .site)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.esriBorder()
***REMOVED******REMOVED******REMOVED******REMOVED***if showSiteSelector {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SiteSelector(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showSiteSelector: $showSiteSelector
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 200)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
