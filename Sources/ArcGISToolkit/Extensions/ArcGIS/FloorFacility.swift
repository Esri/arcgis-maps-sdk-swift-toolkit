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

extension FloorFacility {
***REMOVED******REMOVED***/ - Returns: The default level for the facility, which is the level with vertical order 0.
***REMOVED***var defaultLevel: FloorLevel? {
***REMOVED******REMOVED***levels.first(where: { $0.verticalOrder == .zero ***REMOVED***)
***REMOVED***
***REMOVED***

extension FloorFacility: @retroactive Equatable {
***REMOVED***public static func == (lhs: FloorFacility, rhs: FloorFacility) -> Bool {
***REMOVED******REMOVED***lhs.id == rhs.id
***REMOVED***
***REMOVED***

extension FloorFacility: @retroactive Hashable {
***REMOVED***public func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED***hasher.combine(id)
***REMOVED***
***REMOVED***
