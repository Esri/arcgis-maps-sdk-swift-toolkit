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

struct ExampleView: View {
***REMOVED******REMOVED***/ The example to display in the view.
***REMOVED***var example: Example
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***example.makeBody()
***REMOVED******REMOVED******REMOVED***.navigationTitle(example.name)
***REMOVED***
***REMOVED***

extension ExampleView: Identifiable {
***REMOVED***var id: String { example.name ***REMOVED***
***REMOVED***
