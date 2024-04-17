***REMOVED***
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

struct OverviewMapExampleView: View {
***REMOVED***enum MapOrScene {
***REMOVED******REMOVED******REMOVED***/ The example shows a map view.
***REMOVED******REMOVED***case map
***REMOVED******REMOVED******REMOVED***/ The example shows a scene view.
***REMOVED******REMOVED***case scene
***REMOVED***
***REMOVED***
***REMOVED***@State private var mapOrScene: MapOrScene = .map
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***switch mapOrScene {
***REMOVED******REMOVED******REMOVED***case .map:
***REMOVED******REMOVED******REMOVED******REMOVED***OverviewMapForMapView()
***REMOVED******REMOVED******REMOVED***case .scene:
***REMOVED******REMOVED******REMOVED******REMOVED***OverviewMapForSceneView()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.toolbar(content: {
***REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***Picker("Map or Scene", selection: $mapOrScene) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Map").tag(MapOrScene.map)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Scene").tag(MapOrScene.scene)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.pickerStyle(.menu)
***REMOVED******REMOVED***
***REMOVED***)
***REMOVED***
***REMOVED***

struct OverviewMapForMapView: View {
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map = Map(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED***@State private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED***@State private var visibleArea: ArcGIS.Polygon?
***REMOVED***
***REMOVED******REMOVED*** A custom map to display as the overview map.
***REMOVED******REMOVED***@State var customOverviewMap = Map(basemapStyle: .arcGISDarkGray)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged { visibleArea = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***OverviewMap.forMapView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***with: viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***visibleArea: visibleArea***REMOVED*** ,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** map: customOverviewMap ***REMOVED*** Uncomment to use a custom map.
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** These modifiers show how you can modify the default
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** values used for the symbol, map, and scaleFactor.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbol(.customFillSymbol)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.scaleFactor(15.0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 200, height: 132)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

struct OverviewMapForSceneView: View {
***REMOVED******REMOVED***/ The `Scene` displayed in the `SceneView`.
***REMOVED***@State private var scene = Scene(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED***@State private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED******REMOVED*** A custom map to display as the overview map.
***REMOVED******REMOVED******REMOVED***@State var customOverviewMap = Map(basemapStyle: .arcGISDarkGray)

***REMOVED***var body: some View {
***REMOVED******REMOVED***SceneView(scene: scene)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***OverviewMap.forSceneView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***with: viewpoint***REMOVED*** ,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** map: customOverviewMap ***REMOVED*** Uncomment to use a custom map.
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** These modifiers show how you can modify the default
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** values used for the symbol, map, and scaleFactor.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbol(.customMarkerSymbol)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.scaleFactor(15.0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 200, height: 132)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

struct OverviewMapExampleView_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***OverviewMapExampleView()
***REMOVED***
***REMOVED***

***REMOVED*** MARK: Extensions

private extension Symbol {
***REMOVED******REMOVED***/ A custom fill symbol.
***REMOVED***static let customFillSymbol: FillSymbol = SimpleFillSymbol(
***REMOVED******REMOVED***style: .diagonalCross,
***REMOVED******REMOVED***color: .blue,
***REMOVED******REMOVED***outline: SimpleLineSymbol(
***REMOVED******REMOVED******REMOVED***style: .solid,
***REMOVED******REMOVED******REMOVED***color: .blue,
***REMOVED******REMOVED******REMOVED***width: 1.0
***REMOVED******REMOVED***)
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ A custom marker symbol.
***REMOVED***static let customMarkerSymbol: MarkerSymbol = SimpleMarkerSymbol(
***REMOVED******REMOVED***style: .x,
***REMOVED******REMOVED***color: .blue,
***REMOVED******REMOVED***size: 16.0
***REMOVED***)
***REMOVED***
