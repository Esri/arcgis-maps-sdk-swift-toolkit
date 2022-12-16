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
***REMOVED***

***REMOVED***/ A data model class containing a Map.
public class MapDataModel: ObservableObject {
***REMOVED******REMOVED***/ The `Map` used for display in a `MapView`.
***REMOVED***@Published public var map: Map
***REMOVED***
***REMOVED******REMOVED***/ Creates a `MapDataModel`.
***REMOVED******REMOVED***/ - Parameter map: The `Map` used for display.
***REMOVED***public init(map: Map) {
***REMOVED******REMOVED***self.map = map
***REMOVED***
***REMOVED***
