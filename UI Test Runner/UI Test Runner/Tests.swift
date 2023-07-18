***REMOVED*** Copyright 2023 Esri.

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

struct Tests: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink("Basemap Gallery Tests", destination: BasemapGalleryTestView())
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink("Bookmarks Tests", destination: BookmarksTestView())
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink("Floor Filter Tests", destination: FloorFilterTestView())
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.navigationViewStyle(.stack)
***REMOVED***
***REMOVED***
