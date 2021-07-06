***REMOVED***.

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

struct OverviewMapExampleView: View {
***REMOVED***enum MapOrScene {
***REMOVED******REMOVED******REMOVED***/ The Example shows a map view.
***REMOVED******REMOVED***case map
***REMOVED******REMOVED******REMOVED***/ The Example shows a scene view.
***REMOVED******REMOVED***case scene
***REMOVED***
***REMOVED***
***REMOVED***let map = Map(basemapStyle: .arcGISImagery)
***REMOVED***let scene = Scene(basemapStyle: .arcGISImagery)
***REMOVED***
***REMOVED***@State private var viewpoint: Viewpoint?
***REMOVED***@State private var visibleArea: ArcGIS.Polygon?
***REMOVED***
***REMOVED***@State var mapOrScene: MapOrScene = .map
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Picker("Map or Scene", selection: $mapOrScene, content: {
***REMOVED******REMOVED******REMOVED***Text("Map").tag(MapOrScene.map)
***REMOVED******REMOVED******REMOVED***Text("Scene").tag(MapOrScene.scene)
***REMOVED***)
***REMOVED******REMOVED******REMOVED***.pickerStyle(SegmentedPickerStyle())
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***switch mapOrScene {
***REMOVED******REMOVED***case .map:
***REMOVED******REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED******REMOVED***.onViewpointChanged(type: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onVisibleAreaChanged { visibleArea = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***OverviewMap(viewpoint: viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***visibleArea: visibleArea
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   )
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 200, height: 132)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .topTrailing
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .scene:
***REMOVED******REMOVED******REMOVED***SceneView(scene: scene)
***REMOVED******REMOVED******REMOVED******REMOVED***.onViewpointChanged(type: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***OverviewMap(viewpoint: viewpoint)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 200, height: 132)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***alignment: .topTrailing
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

struct OverviewMapExampleView_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***OverviewMapExampleView()
***REMOVED***
***REMOVED***
