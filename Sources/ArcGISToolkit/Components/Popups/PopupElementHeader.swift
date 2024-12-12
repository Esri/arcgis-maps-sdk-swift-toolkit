***REMOVED*** Copyright 2022 Esri
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
***REMOVED***

***REMOVED***/ A view displaying a title and description of a `PopupElement`.
struct PopupElementHeader: View {
***REMOVED***let title: String
***REMOVED***let description: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED*** Text views with empty text still take up some vertical space in
***REMOVED******REMOVED******REMOVED******REMOVED*** a view, so conditionally check for an empty title and description.
***REMOVED******REMOVED******REMOVED***if !title.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.primary)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if !description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED***
***REMOVED***
#if targetEnvironment(macCatalyst) || os(visionOS)
***REMOVED******REMOVED***.padding(.leading, 4)
#endif
***REMOVED***
***REMOVED***
