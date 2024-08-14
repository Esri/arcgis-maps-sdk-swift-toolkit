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

@MainActor
struct ExampleList: View {
***REMOVED******REMOVED***/ The name of the list of examples.
***REMOVED***let name: String
***REMOVED***
***REMOVED******REMOVED***/ The list of examples to display.
***REMOVED***var examples: [Example]
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***List(examples, id: \.name) { (example) in
***REMOVED******REMOVED******REMOVED***NavigationLink(example.name, destination: ExampleView(example: example))
***REMOVED***
***REMOVED******REMOVED***.navigationTitle(name)
***REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED***
***REMOVED***

extension ExampleList: Identifiable {
***REMOVED***nonisolated var id: String { name ***REMOVED***
***REMOVED***
