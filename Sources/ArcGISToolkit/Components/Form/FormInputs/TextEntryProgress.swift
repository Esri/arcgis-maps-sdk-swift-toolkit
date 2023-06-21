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

***REMOVED***/ Displays the number of characters entered in a text field out of the maximum.
struct TextEntryProgress: View {
***REMOVED******REMOVED***/ The number of characters entered.
***REMOVED***let current: Int
***REMOVED***
***REMOVED******REMOVED***/ The maximum number of characters.
***REMOVED***let max: Int
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"\(current) / \(max)",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "The number of characters entered in a text field out of the maximum."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED***
***REMOVED***
