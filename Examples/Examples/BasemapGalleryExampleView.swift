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

struct BasemapGalleryExampleView: View {
***REMOVED******REMOVED***/ A Boolean value indicating whether the basemap gallery is presented.
***REMOVED***@State private var basemapGalleryIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The initial list of basemaps.
***REMOVED***@State private var basemaps = makeBasemapGalleryItems()
***REMOVED***
***REMOVED******REMOVED***/ The `Map` displayed in the `MapView`.
***REMOVED***@State private var map: Map = {
***REMOVED******REMOVED***let map = Map(basemapStyle: .arcGISImagery)
***REMOVED******REMOVED***map.initialViewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
***REMOVED******REMOVED******REMOVED***scale: 1_000_000
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return map
***REMOVED***()
***REMOVED***
***REMOVED***@State private var scene: ArcGIS.Scene = {
***REMOVED******REMOVED***let scene = Scene(basemap: Basemap(item: PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: Item.ID("0560e29930dc4d5ebeb58c635c0909c9")!
***REMOVED******REMOVED***)))
***REMOVED******REMOVED***scene.initialViewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED***latitude: .nan,
***REMOVED******REMOVED******REMOVED***longitude: .nan,
***REMOVED******REMOVED******REMOVED***scale: .nan,
***REMOVED******REMOVED******REMOVED***camera: Camera(
***REMOVED******REMOVED******REMOVED******REMOVED***latitude: 40.686169,
***REMOVED******REMOVED******REMOVED******REMOVED***longitude: -74.027986,
***REMOVED******REMOVED******REMOVED******REMOVED***altitude: 1101.149054,
***REMOVED******REMOVED******REMOVED******REMOVED***heading: 30.82,
***REMOVED******REMOVED******REMOVED******REMOVED***pitch: 72,
***REMOVED******REMOVED******REMOVED******REMOVED***roll: 0
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return scene
***REMOVED***()
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $basemapGalleryIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .trailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***doneButton
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***BasemapGallery(items: basemaps, geoModel: map)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.style(.grid(maxItemWidth: 100))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .navigationBarTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Toggle(isOn: $basemapGalleryIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image("basemap", label: Text("Show base map"))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A button that allows a user to close a sheet.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This is especially useful for when the sheet is open an iPhone in landscape.
***REMOVED***private var doneButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***basemapGalleryIsPresented.toggle()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text("Done")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private static func makeBasemapGalleryItems() -> [BasemapGalleryItem] {
***REMOVED******REMOVED***[
***REMOVED******REMOVED******REMOVED***"46a87c20f09e4fc48fa3c38081e0cae6",
***REMOVED******REMOVED******REMOVED***"f33a34de3a294590ab48f246e99958c9",
***REMOVED******REMOVED******REMOVED***"52bdc7ab7fb044d98add148764eaa30a", ***REMOVED*** Mismatched spatial reference
***REMOVED******REMOVED******REMOVED***"3a8d410a4a034a2ba9738bb0860d68c4"  ***REMOVED*** Incorrect portal item type
***REMOVED******REMOVED***]
***REMOVED******REMOVED******REMOVED***.map { identifier in
***REMOVED******REMOVED******REMOVED******REMOVED***BasemapGalleryItem(basemap: Basemap(item: PortalItem(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***id: Item.ID(identifier)!)
***REMOVED******REMOVED******REMOVED******REMOVED***))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
