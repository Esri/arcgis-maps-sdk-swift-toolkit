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

***REMOVED***/ A data model class containing a Scene.
public class SceneDataModel: ObservableObject {
***REMOVED******REMOVED***/ The `Scene` used for display in a `SceneView`.
***REMOVED***public var scene: ArcGIS.Scene
***REMOVED***
***REMOVED******REMOVED***/ Creates a `SceneDataModel`.
***REMOVED******REMOVED***/ - Parameter scene: The `Scene` used for display.
***REMOVED***public init(scene: ArcGIS.Scene) {
***REMOVED******REMOVED***self.scene = scene
***REMOVED***
***REMOVED***
