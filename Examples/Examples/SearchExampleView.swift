***REMOVED***.

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
import Combine
***REMOVED***
***REMOVED***Toolkit

struct SearchExampleView: View {
***REMOVED***let searchViewModel = SearchViewModel(
***REMOVED******REMOVED***sources: [LocatorSearchSource(displayName: "Locator One"),
***REMOVED******REMOVED******REMOVED******REMOVED***  LocatorSearchSource(displayName: "Locator Two")]
***REMOVED***)
***REMOVED***
***REMOVED***@State
***REMOVED***var showResults = true
***REMOVED***
***REMOVED***@State
***REMOVED***private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED***@State
***REMOVED***private var visibleArea: ArcGIS.Polygon?

***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack (alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED***MapViewReader { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED***MapView(map: Map(basemap: Basemap.imageryWithLabels()))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onViewpointChanged(type: .centerAndScale) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.queryCenter = $0.targetGeometry as? Point
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***searchViewModel.queryArea = $0
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: searchViewModel.results, perform: { results in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("Search results changed")
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onChange(of: searchViewModel.suggestions, perform: { results in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("Search suggestions changed")
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.overlay(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SearchView(proxy: proxy, searchViewModel:searchViewModel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.enableResultListView(showResults)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 360)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .topTrailing
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showResults.toggle()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(showResults ? "Hide results" : "Show results")
***REMOVED******REMOVED******REMOVED***

***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

struct SearchExampleView_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***SearchExampleView()
***REMOVED***
***REMOVED***
