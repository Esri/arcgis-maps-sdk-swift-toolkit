***REMOVED*** Copyright 2023 Esri.

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

***REMOVED***/  A selected site, facility, or level.
public enum FloorFilterSelection: Hashable {
***REMOVED******REMOVED***/ A selected site.
***REMOVED***case site(FloorSite)
***REMOVED******REMOVED***/ A selected facility.
***REMOVED***case facility(FloorFacility)
***REMOVED******REMOVED***/ A selected level.
***REMOVED***case level(FloorLevel)
***REMOVED***
