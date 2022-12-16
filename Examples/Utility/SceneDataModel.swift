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

***REMOVED***/ A very basic data model class containing a Scene. Since a `Scene` is not an observable object,
***REMOVED***/ clients can use `SceneDataModel` as an example of how you would store a scene in a data model
***REMOVED***/ class. The class inherits from `ObservableObject` and the `Scene` is defined as an @Published
***REMOVED***/ property. This allows SwiftUI views to be updated automatically when a new scene is set on the model.
***REMOVED***/ Being stored in the model also prevents the scene from continually being created during redraws.
***REMOVED***/ The data model class would be expanded upon in client code to contain other properties required
***REMOVED***/ for the model.
public class SceneDataModel: ObservableObject {
***REMOVED******REMOVED***/ The `Scene` used for display in a `SceneView`.
***REMOVED***@Published public var scene: ArcGIS.Scene
***REMOVED***
***REMOVED******REMOVED***/ Creates a `SceneDataModel`.
***REMOVED******REMOVED***/ - Parameter scene: The `Scene` used for display.
***REMOVED***public init(scene: ArcGIS.Scene) {
***REMOVED******REMOVED***self.scene = scene
***REMOVED***
***REMOVED***
