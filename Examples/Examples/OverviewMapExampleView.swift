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
***REMOVED***
***REMOVED***Toolkit

struct OverviewMapExampleView: View {
***REMOVED***let map = Map(basemap: .imageryWithLabels())
***REMOVED***@State private var viewpoint: Viewpoint?
***REMOVED***@State private var visibleArea: ArcGIS.Polygon?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(type: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged { visibleArea = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(
***REMOVED******REMOVED******REMOVED******REMOVED***OverviewMap(viewpoint: viewpoint, visibleArea: visibleArea)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 200, height: 132)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(),
***REMOVED******REMOVED******REMOVED******REMOVED***alignment: .topTrailing
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

struct OverviewMapExampleView_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***OverviewMapExampleView()
***REMOVED***
***REMOVED***
