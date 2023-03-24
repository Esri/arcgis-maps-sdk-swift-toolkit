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
***REMOVED***Toolkit
***REMOVED***

***REMOVED***/ An example demonstrating how to use a compass in three different environments.
struct CompassExampleView: View {
***REMOVED******REMOVED***/ A scenario represents a type of environment a compass may be used in.
***REMOVED***enum Scenario: CaseIterable {
***REMOVED******REMOVED***case map
***REMOVED******REMOVED***case sceneWithCamera
***REMOVED******REMOVED***case sceneWithCameraController
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A human-readable label for the scenario.
***REMOVED******REMOVED***var label: String {
***REMOVED******REMOVED******REMOVED***switch self {
***REMOVED******REMOVED******REMOVED***case .map: return "Map"
***REMOVED******REMOVED******REMOVED***case .sceneWithCamera: return "Scene with camera"
***REMOVED******REMOVED******REMOVED***case .sceneWithCameraController: return "Scene with camera controller"
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The active scenario.
***REMOVED***@State private var scenario = Scenario.map
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***switch scenario {
***REMOVED******REMOVED******REMOVED***case.map:
***REMOVED******REMOVED******REMOVED******REMOVED***MapWithViewpoint()
***REMOVED******REMOVED******REMOVED***case .sceneWithCamera:
***REMOVED******REMOVED******REMOVED******REMOVED***SceneWithCamera()
***REMOVED******REMOVED******REMOVED***case .sceneWithCameraController:
***REMOVED******REMOVED******REMOVED******REMOVED***SceneWithCameraController()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Picker("Scenario", selection: $scenario) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(Scenario.allCases, id: \.self) { scen in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(scen.label)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ An example demonstrating how to use a compass with a map view.
struct MapWithViewpoint: View {
***REMOVED******REMOVED***/ The data model containing the `Map` displayed in the `MapView`.
***REMOVED***@StateObject private var dataModel = MapDataModel(
***REMOVED******REMOVED***map: Map(basemapStyle: .arcGISImagery)
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ Allows for communication between the Compass and MapView or SceneView.
***REMOVED***@State private var viewpoint: Viewpoint? = Viewpoint(
***REMOVED******REMOVED***center: .esriRedlands,
***REMOVED******REMOVED***scale: 10_000,
***REMOVED******REMOVED***rotation: -45
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED***MapView(map: dataModel.map, viewpoint: viewpoint)
***REMOVED******REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Compass(viewpoint: $viewpoint)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Optionally provide a different size for the compass.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.compassSize(size: T##CGFloat)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try? await mapViewProxy.setViewpointRotation(0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ An example demonstrating how to use a compass with a scene view and camera.
struct SceneWithCamera: View {
***REMOVED******REMOVED***/ The camera used by the scene view.
***REMOVED***@State private var camera: Camera? = Camera(
***REMOVED******REMOVED***lookingAt: .esriRedlands,
***REMOVED******REMOVED***distance: 1_000,
***REMOVED******REMOVED***heading: 45,
***REMOVED******REMOVED***pitch: 45,
***REMOVED******REMOVED***roll: .zero
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ The data model containing the `Scene` displayed in the `SceneView`.
***REMOVED***@StateObject private var dataModel = SceneDataModel(
***REMOVED******REMOVED***scene: Scene(basemapStyle: .arcGISImagery)
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ The current heading as reported by the scene view.
***REMOVED***var heading: Binding<Double> {
***REMOVED******REMOVED***Binding {
***REMOVED******REMOVED******REMOVED***if let camera {
***REMOVED******REMOVED******REMOVED******REMOVED***return camera.heading
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return .zero
***REMOVED******REMOVED***
***REMOVED*** set: { _ in
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***SceneViewReader { sceneViewProxy in
***REMOVED******REMOVED******REMOVED***SceneView(scene: dataModel.scene, camera: $camera)
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Compass(viewpointRotation: heading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let camera {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let newCamera = Camera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***location: camera.location,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***heading: .zero,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pitch: camera.pitch,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***roll: camera.roll
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try? await sceneViewProxy.setViewpointCamera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***newCamera,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***duration: 0.3
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ An example demonstrating how to use a compass with a scene view and camera controller.
struct SceneWithCameraController: View {
***REMOVED******REMOVED***/ The data model containing the `Scene` displayed in the `SceneView`.
***REMOVED***@StateObject private var dataModel = SceneDataModel(
***REMOVED******REMOVED***scene: Scene(basemapStyle: .arcGISImagery)
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ The current heading as reported by the scene view.
***REMOVED***@State private var heading: Double = .zero
***REMOVED***
***REMOVED******REMOVED***/ The orbit location camera controller used by the scene view.
***REMOVED***private let cameraController = OrbitLocationCameraController(
***REMOVED******REMOVED***target: .esriRedlands,
***REMOVED******REMOVED***distance: 10_000
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***SceneView(scene: dataModel.scene, cameraController: cameraController)
***REMOVED******REMOVED******REMOVED***.onCameraChanged { newCamera in
***REMOVED******REMOVED******REMOVED******REMOVED***heading = newCamera.heading.rounded()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***Compass(viewpointRotation: $heading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try? await cameraController.moveCamera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***distanceDelta: .zero,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***headingDelta: heading > 180 ? 360 - heading : -heading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pitchDelta: .zero,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***duration: 0.3
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

private extension Point {
***REMOVED***static var esriRedlands: Point {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***x: -117.19494,
***REMOVED******REMOVED******REMOVED***y: 34.05723,
***REMOVED******REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
