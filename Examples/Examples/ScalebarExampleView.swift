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
***REMOVED******REMOVED***/ The size of the map view's attribution bar.
***REMOVED***@State private var attributionBarSize: CGSize = .zero
***REMOVED***
***REMOVED******REMOVED***/ Allows for communication between the `Scalebar` and `MapView`.
***REMOVED***@State private var spatialReference: SpatialReference?
***REMOVED***
***REMOVED******REMOVED***/ Allows for communication between the `Scalebar` and `MapView`.
***REMOVED***@State private var unitsPerPoint: Double?
***REMOVED***
***REMOVED******REMOVED***/ Allows for communication between the `Scalebar` and `MapView`.
***REMOVED***@State private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED******REMOVED***/ The location of the scalebar on screen.
***REMOVED***private let alignment: Alignment = .bottomLeading
***REMOVED***
***REMOVED******REMOVED***/ The data model containing the `Map` displayed in the `MapView`.
***REMOVED***@StateObject private var dataModel = MapDataModel(
***REMOVED******REMOVED***map: Map(basemapStyle: .arcGISTopographic)
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ The maximum screen width allotted to the scalebar.
***REMOVED***private let maxWidth: Double = 175.0
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: dataModel.map)
***REMOVED******REMOVED******REMOVED***.onAttributionBarSizeChanged { newSize in
***REMOVED******REMOVED******REMOVED******REMOVED***withAnimation { attributionBarSize = newSize ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onSpatialReferenceChanged { spatialReference = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onUnitsPerPointChanged { unitsPerPoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: alignment) {
***REMOVED******REMOVED******REMOVED******REMOVED***Scalebar(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: maxWidth,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: $spatialReference,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***unitsPerPoint: $unitsPerPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $viewpoint
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal, 10)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.vertical, 10 + attributionBarSize.height)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
