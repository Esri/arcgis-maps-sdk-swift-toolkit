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

struct AnyExample<Content: View> {
***REMOVED***var name: String
***REMOVED***var content: @MainActor () -> Content
***REMOVED***
***REMOVED***init(_ name: String, content: @autoclosure @escaping @MainActor () -> Content) {
***REMOVED******REMOVED***self.name = name
***REMOVED******REMOVED***self.content = content
***REMOVED***
***REMOVED***

extension AnyExample: Example {
***REMOVED***func makeBody() -> AnyView { AnyView(content()) ***REMOVED***
***REMOVED***
