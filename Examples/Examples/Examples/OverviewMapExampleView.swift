***REMOVED***./APsPl0cx9SjC7zrU5rCZKCw

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

struct OverviewMapExampleView: View {
***REMOVED***private var mapViewProxy: Binding<MapViewProxy?>?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ZStack (alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED***MapView(map: Map(basemap: Basemap.imageryWithLabels()),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   proxy: mapViewProxy)
***REMOVED******REMOVED******REMOVED***OverviewMap(proxy: mapViewProxy)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED***

struct OverviewMapExampleView_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***OverviewMapExampleView()
***REMOVED***
***REMOVED***
