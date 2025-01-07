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
***REMOVED***Toolkit
***REMOVED***

struct FlyoverExampleView: View {
***REMOVED***@State private var scene = Scene(
***REMOVED******REMOVED***item: PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: PortalItem.ID("7558ee942b2547019f66885c44d4f0b1")!
***REMOVED******REMOVED***)
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***FlyoverSceneView(
***REMOVED******REMOVED******REMOVED***initialLocation: Point(x: 4.4777, y: 51.9244, z: 1_000, spatialReference: .wgs84),
***REMOVED******REMOVED******REMOVED***translationFactor: 1_000
***REMOVED******REMOVED***) { proxy in
***REMOVED******REMOVED******REMOVED***SceneView(scene: scene)
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { screen, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("Identifying...")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task { @MainActor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let results = try await proxy.identifyLayers(screenPoint: screen, tolerance: 20)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("\(results.count) identify result(s).")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
