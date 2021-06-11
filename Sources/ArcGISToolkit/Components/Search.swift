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

public struct Search: View {
***REMOVED***public var proxy: Binding<MapViewProxy?>

***REMOVED***@State private var searchText = ""
***REMOVED***
***REMOVED***public init(proxy: Binding<MapViewProxy?>) {
***REMOVED******REMOVED***self.proxy = proxy
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***TextField("Search",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  text: $searchText) { editing in
***REMOVED******REMOVED******REMOVED******REMOVED***print("editing changed")
***REMOVED******REMOVED*** onCommit: { 
***REMOVED******REMOVED******REMOVED******REMOVED***print("On commit")
***REMOVED******REMOVED***

***REMOVED***
***REMOVED***
***REMOVED***
