***REMOVED*** Copyright 2023 Esri
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

***REMOVED***/  A selected site, facility, or level.
@available(visionOS, unavailable)
public enum FloorFilterSelection: Hashable, Sendable {
***REMOVED******REMOVED***/ A selected site.
***REMOVED***case site(FloorSite)
***REMOVED******REMOVED***/ A selected facility.
***REMOVED***case facility(FloorFacility)
***REMOVED******REMOVED***/ A selected level.
***REMOVED***case level(FloorLevel)
***REMOVED***

@available(visionOS, unavailable)
public extension FloorFilterSelection {
***REMOVED******REMOVED***/ The selected site.
***REMOVED***var site: FloorSite? {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .site(let site):
***REMOVED******REMOVED******REMOVED***return site
***REMOVED******REMOVED***case .facility(let facility):
***REMOVED******REMOVED******REMOVED***return facility.site
***REMOVED******REMOVED***case .level(let level):
***REMOVED******REMOVED******REMOVED***return level.facility?.site
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The selected facility.
***REMOVED***var facility: FloorFacility? {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .facility(let facility):
***REMOVED******REMOVED******REMOVED***return facility
***REMOVED******REMOVED***case .level(let level):
***REMOVED******REMOVED******REMOVED***return level.facility
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The selected level.
***REMOVED***var level: FloorLevel? {
***REMOVED******REMOVED***if case let .level(level) = self {
***REMOVED******REMOVED******REMOVED***return level
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
