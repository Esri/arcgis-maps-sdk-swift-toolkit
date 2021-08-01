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

***REMOVED***/ A List with the `.plain` list style.
public struct PlainList<Content> : View where Content : View {
***REMOVED***let content: Content
***REMOVED******REMOVED***/ Creates a plain list with the given content.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - content: The content of the list.
***REMOVED***public init(@ViewBuilder content: () -> Content) {
***REMOVED******REMOVED***self.content = content()
***REMOVED***

***REMOVED******REMOVED***/ The content of the list.
***REMOVED***public var body: some View {
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***content
***REMOVED***
***REMOVED******REMOVED***.listStyle(.plain)
***REMOVED***
***REMOVED***
