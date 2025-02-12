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

***REMOVED***/ A category of examples.
struct Category {
***REMOVED******REMOVED***/ The name of this category.
***REMOVED***let name: String
***REMOVED******REMOVED***/ The examples in this category.
***REMOVED***let examples: [Example]
***REMOVED***

extension Category: Equatable {
***REMOVED***static func == (lhs: Self, rhs: Self) -> Bool {
***REMOVED******REMOVED***return lhs.name == rhs.name
***REMOVED***
***REMOVED***

extension Category: Hashable {
***REMOVED***func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(name)
***REMOVED***
***REMOVED***
