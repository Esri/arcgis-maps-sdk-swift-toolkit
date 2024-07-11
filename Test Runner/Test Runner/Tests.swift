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

struct Tests: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink("AttachmentCameraController Tests", destination: AttachmentCameraControllerTestView())
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink("Basemap Gallery Tests", destination: BasemapGalleryTestView())
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink("Bookmarks Tests", destination: BookmarksTestViews())
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink("Feature Form Tests", destination: FeatureFormTestView())
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink("Floor Filter Tests", destination: FloorFilterTestView())
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink("RepresentedUITextView Tests", destination: RepresentedUITextViewTestView())
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
