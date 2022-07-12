***REMOVED*** Copyright 2022 Esri.

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

extension UtilityNetwork: Hashable {
***REMOVED***public static func == (
***REMOVED******REMOVED***lhs: UtilityNetwork,
***REMOVED******REMOVED***rhs: UtilityNetwork
***REMOVED***) -> Bool {
***REMOVED******REMOVED***lhs.name == rhs.name && lhs.url == rhs.url
***REMOVED***
***REMOVED***
***REMOVED***public func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(name)
***REMOVED******REMOVED***hasher.combine(url)
***REMOVED***
***REMOVED***
