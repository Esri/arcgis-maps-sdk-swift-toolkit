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
***REMOVED***
***REMOVED***Toolkit

struct SwiftUIFlyoverExampleView: View {
***REMOVED***private var scene: ArcGIS.Scene = {
***REMOVED******REMOVED***let scene = Scene(
***REMOVED******REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED******REMOVED***id: PortalItem.ID("7558ee942b2547019f66885c44d4f0b1")!
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)

***REMOVED******REMOVED***scene.initialViewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED***latitude: 37.8651,
***REMOVED******REMOVED******REMOVED***longitude: 119.5383,
***REMOVED******REMOVED******REMOVED***scale: 10
***REMOVED******REMOVED***)

***REMOVED******REMOVED***return scene
***REMOVED***()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***ARFlyoverView(
***REMOVED******REMOVED******REMOVED***initialCamera: Camera(
***REMOVED******REMOVED******REMOVED******REMOVED***lookingAt: Point(x: 4.4777, y: 51.9244, spatialReference: .wgs84),
***REMOVED******REMOVED******REMOVED******REMOVED***distance: 1_000,
***REMOVED******REMOVED******REMOVED******REMOVED***heading: 40,
***REMOVED******REMOVED******REMOVED******REMOVED***pitch: 90,
***REMOVED******REMOVED******REMOVED******REMOVED***roll: 0
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***translationFactor: 3_000,
***REMOVED******REMOVED******REMOVED***clippingDistance: 60_000
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***SceneView(scene: scene)
***REMOVED***
***REMOVED***
***REMOVED***
