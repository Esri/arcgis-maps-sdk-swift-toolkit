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

struct ScalebarExampleView: View {
***REMOVED******REMOVED***/ The map displayed in the map view.
***REMOVED***private let map = Map(basemapStyle: .arcGISImagery)

***REMOVED***@State
***REMOVED******REMOVED***/ Allows for communication between the Scalebar and MapView or SceneView.
***REMOVED***private var scale: Double?

***REMOVED******REMOVED***/ Allows for communication between the Scalebar and MapView or SceneView.
***REMOVED***@State
***REMOVED***private var viewpoint: Viewpoint? = Viewpoint(
***REMOVED******REMOVED***center: Point(x: -117.19494, y: 34.05723, spatialReference: .wgs84),
***REMOVED******REMOVED***scale: 10_000
***REMOVED***)

***REMOVED******REMOVED***/ Allows for communication between the Scalebar and MapView or SceneView.
***REMOVED***@State
***REMOVED***private var visibleArea: Polygon?

***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map, viewpoint: viewpoint)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged { visibleArea = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onScaleChanged { scale = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .bottomLeading) {
***REMOVED******REMOVED******REMOVED******REMOVED***Scalebar(scale, viewpoint, visibleArea)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.border(.red, width: 2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.leading], 10)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.border(.green, width: 2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom], 30)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.border(.blue, width: 2)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
