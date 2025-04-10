***REMOVED*** Copyright 2025 Esri
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

extension Examples {
***REMOVED***enum ListItem {
***REMOVED******REMOVED***case category(_ name: String, examples: [Example])
***REMOVED******REMOVED***case example(Example)
***REMOVED******REMOVED***
***REMOVED******REMOVED***var name: String {
***REMOVED******REMOVED******REMOVED***switch self {
***REMOVED******REMOVED******REMOVED***case .category(let name, _): name
***REMOVED******REMOVED******REMOVED***case .example(let example): example.name
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***static func example<Content: View>(_ name: String, content: @autoclosure @escaping () -> Content) -> Self {
***REMOVED******REMOVED******REMOVED***return .example(.init(name, content: content()))
***REMOVED***
***REMOVED***
***REMOVED***
