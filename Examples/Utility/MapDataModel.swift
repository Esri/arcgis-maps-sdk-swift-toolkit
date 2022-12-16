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

***REMOVED***/ A very basic data model class containing a Map. Since a `Map` is not an observable object,
***REMOVED***/ clients can use `MapDataModel` as an example of how you would store a map in a data model
***REMOVED***/ class. The class inherits from `ObservableObject` and the `Map` is defined as an @Published
***REMOVED***/ property. This allows SwiftUI views to be updated automatically when a new map is set on the model.
***REMOVED***/ Being stored in the model also prevents the map from continually being created during redraws.
***REMOVED***/ The data model class would be expanded upon in client code to contain other properties required
***REMOVED***/ for the model.
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
