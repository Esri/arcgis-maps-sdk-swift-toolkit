***REMOVED*** Copyright 2022 Esri
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

***REMOVED***/ An example demonstrating how to use a compass with a map view.
struct CompassExampleView: View {
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map = Map(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED******REMOVED***/ Allows for communication between the Compass and MapView or SceneView.
***REMOVED***@State private var viewpoint: Viewpoint? = .esriRedlands
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { proxy in
***REMOVED******REMOVED******REMOVED***MapView(map: map, viewpoint: viewpoint)
***REMOVED******REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Compass(rotation: viewpoint?.rotation, mapViewProxy: proxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.snapToZeroSensoryFeedbackIfAvailable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension Compass {
***REMOVED******REMOVED***/ Enables the sensory feedback when the compass snaps to `zero`
***REMOVED******REMOVED***/ when sensory feedback is available.
***REMOVED***@ViewBuilder
***REMOVED***func snapToZeroSensoryFeedbackIfAvailable() -> some View {
***REMOVED******REMOVED***snapToZeroSensoryFeedback()
***REMOVED***
***REMOVED***

private extension Viewpoint {
***REMOVED***static var esriRedlands: Viewpoint {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***center: .init(x: -117.19494, y: 34.05723, spatialReference: .wgs84),
***REMOVED******REMOVED******REMOVED***scale: 10_000,
***REMOVED******REMOVED******REMOVED***rotation: -45
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
