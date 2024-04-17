***REMOVED*** Copyright 2023 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***Toolkit
***REMOVED***

***REMOVED***/ A view that displays the Bookmarks component initialized with bookmarks.
struct BookmarksTestCase5View: View {
***REMOVED***@State private var bookmarks = [Bookmark(name: "Bookmark 1")]
***REMOVED***
***REMOVED******REMOVED***/ The `Map` with no predefined bookmarks.
***REMOVED***@State private var map = Map(basemapStyle: .arcGISCommunity)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: .constant(true)) {
***REMOVED******REMOVED******REMOVED******REMOVED***Bookmarks(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: .constant(true),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bookmarks: bookmarks,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: .constant(nil)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Add New") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bookmarks.append(Bookmark(name: "Bookmark \(bookmarks.count + 1)"))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
