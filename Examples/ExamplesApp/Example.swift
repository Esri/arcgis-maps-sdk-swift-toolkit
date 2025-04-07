***REMOVED***
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

***REMOVED***/ An example demonstrating how a toolkit component may be used.
struct Example {
***REMOVED******REMOVED***/ The name of the example.
***REMOVED***let name: String
***REMOVED******REMOVED***/ The view for this example.
***REMOVED***var view: AnyView { content() ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A closure that builds the view for this example.
***REMOVED***private let content: () -> AnyView
***REMOVED***
***REMOVED******REMOVED***/ Creates an example with the given name and content view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - name: The name for the example.
***REMOVED******REMOVED***/   - content: The content view for the example.
***REMOVED***init<Content: View>(_ name: String, content: @autoclosure @escaping () -> Content) {
***REMOVED******REMOVED***self.name = name
***REMOVED******REMOVED***self.content = { .init(content()) ***REMOVED***
***REMOVED***
***REMOVED***

extension Example: Equatable {
***REMOVED***static func == (lhs: Self, rhs: Self) -> Bool {
***REMOVED******REMOVED***return lhs.name == rhs.name
***REMOVED***
***REMOVED***

extension Example: Hashable {
***REMOVED***func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(name)
***REMOVED***
***REMOVED***

extension Example: MenuItem { ***REMOVED***
