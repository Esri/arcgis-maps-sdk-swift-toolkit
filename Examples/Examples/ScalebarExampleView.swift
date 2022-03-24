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
***REMOVED******REMOVED***/ Allows for communication between the `Scalebar` and `MapView` or `SceneView`.
***REMOVED***@State private var scale: Double?
***REMOVED***
***REMOVED******REMOVED***/ Allows for communication between the `Scalebar` and `MapView` or `SceneView`.
***REMOVED***@State private var spatialReference: SpatialReference?
***REMOVED***
***REMOVED******REMOVED***/ Allows for communication between the `Scalebar` and `MapView` or `SceneView`.
***REMOVED***@State private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED******REMOVED***/ Allows for communication between the `Scalebar` and `MapView` or `SceneView`.
***REMOVED***@State private var visibleArea: Polygon?
***REMOVED***
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***private let map = Map(basemapStyle: .arcGISTopographic)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map, viewpoint: viewpoint)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged { visibleArea = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onScaleChanged { scale = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onSpatialReferenceChanged { spatialReference = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .bottomTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***if map.loadStatus == .loaded {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Scalebar(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scale,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***spatialReference,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***175,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***visibleArea,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***units: .imperial
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.leading, 10)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.bottom, 30)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
