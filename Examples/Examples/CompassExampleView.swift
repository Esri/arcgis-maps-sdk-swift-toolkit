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
***REMOVED***enum Scenario: String {
***REMOVED******REMOVED***case map
***REMOVED******REMOVED***case scene
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The active scenario.
***REMOVED***@State private var scenario = Scenario.map
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch scenario {
***REMOVED******REMOVED******REMOVED***case .map:
***REMOVED******REMOVED******REMOVED******REMOVED***MapWithViewpoint()
***REMOVED******REMOVED******REMOVED***case .scene:
***REMOVED******REMOVED******REMOVED******REMOVED***SceneWithCameraController()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***Menu(scenario.rawValue.capitalized) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scenario = .map
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label("Map", systemImage: "map.fill")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scenario = .scene
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label("Scene", systemImage: "globe.americas.fill")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ An example demonstrating how to use a compass with a map view.
struct MapWithViewpoint: View {
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map = Map(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED******REMOVED***/ Allows for communication between the Compass and MapView or SceneView.
***REMOVED***@State private var viewpoint: Viewpoint? = Viewpoint(
***REMOVED******REMOVED***center: .esriRedlands,
***REMOVED******REMOVED***scale: 10_000,
***REMOVED******REMOVED***rotation: -45
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { proxy in
***REMOVED******REMOVED******REMOVED***MapView(map: map, viewpoint: viewpoint)
***REMOVED******REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Compass(viewpoint: $viewpoint) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let viewpoint else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Animate the map view to zero when the compass is tapped.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await proxy.setViewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint.withRotation(0),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***duration: 0.25
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ An example demonstrating how to use a compass with a scene view and camera controller.
struct SceneWithCameraController: View {
***REMOVED******REMOVED***/ The data model containing the `Scene` displayed in the `SceneView`.
***REMOVED***@State private var scene = Scene(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED******REMOVED***/ The current heading as reported by the scene view.
***REMOVED***@State private var heading = Double.zero
***REMOVED***
***REMOVED******REMOVED***/ The orbit location camera controller used by the scene view.
***REMOVED***private let cameraController = OrbitLocationCameraController(
***REMOVED******REMOVED***target: .esriRedlands,
***REMOVED******REMOVED***distance: 10_000
***REMOVED***)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***SceneView(scene: scene, cameraController: cameraController)
***REMOVED******REMOVED******REMOVED***.onCameraChanged { newCamera in
***REMOVED******REMOVED******REMOVED******REMOVED***heading = newCamera.heading.rounded()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***Compass(viewpointRotation: $heading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Animate the scene view when the compass is tapped.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***_ = try? await cameraController.moveCamera(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***distanceDelta: .zero,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***headingDelta: heading > 180 ? 360 - heading : -heading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***pitchDelta: .zero,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***duration: 0.3
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
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
