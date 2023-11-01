***REMOVED*** Copyright 2023 Esri.

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

extension PopupDynamicEntityExampleView {
***REMOVED******REMOVED***/ An object that contains map information for the dynamic entity arcade callout example view.
***REMOVED***final class MapInfo {
***REMOVED******REMOVED***let layer: DynamicEntityLayer
***REMOVED******REMOVED***let map: Map
***REMOVED******REMOVED***
***REMOVED******REMOVED***init() {
***REMOVED******REMOVED******REMOVED***layer = DynamicEntityLayer(
***REMOVED******REMOVED******REMOVED******REMOVED***dataSource: ArcGISStreamService(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** More sample services can be found here:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** https:***REMOVED***devtopia.esri.com/runtime/milano/blob/main/References/StreamService/streamServiceList.md#sample-stream-services
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***url: URL(string: "https:***REMOVED***realtimegis2016.esri.com:6443/arcgis/rest/services/SandyVehicles/StreamServer")!
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***layer.trackDisplayProperties.showsPreviousObservations = true
***REMOVED******REMOVED******REMOVED***layer.trackDisplayProperties.showsTrackLine = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***map = Map(basemapStyle: .arcGISOceans)
***REMOVED******REMOVED******REMOVED***map.addOperationalLayer(layer)
***REMOVED******REMOVED******REMOVED***map.initialViewpoint = Viewpoint(boundingGeometry: Envelope.saltLake)
***REMOVED***
***REMOVED***
***REMOVED***

private extension Envelope {
***REMOVED*** ***REMOVED***/ An envelope around the Salt Lake City area.
***REMOVED*** static let saltLake = Envelope(
***REMOVED******REMOVED*** xRange: -12475445.104735145...(-12436309.346470555),
***REMOVED******REMOVED*** yRange: 4922143.160533925...4993908.647699355,
***REMOVED******REMOVED*** spatialReference: .webMercator
***REMOVED*** )
 ***REMOVED***

***REMOVED***/ A view that shows how to display and show a callout for a dynamic entity layer
***REMOVED***/ where the information that you want to display is derived from an arcade expression.
struct PopupDynamicEntityExampleView: View {
***REMOVED******REMOVED***/ The map information for this example.
***REMOVED***@State private var mapInfo = MapInfo()
***REMOVED***
***REMOVED******REMOVED***/ The popup to be shown as the result of the layer identify operation.
***REMOVED***@State private var popup: Popup? {
***REMOVED******REMOVED***didSet { showPopup = popup != nil ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value specifying whether the popup view should be shown or not.
***REMOVED***@State private var showPopup = false
***REMOVED***
***REMOVED******REMOVED***/ The detent value specifying the initial `FloatingPanelDetent`.  Defaults to "full".
***REMOVED***@State private var floatingPanelDetent: FloatingPanelDetent = .half
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { proxy in
***REMOVED******REMOVED******REMOVED***MapView(map: mapInfo.map)
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { point, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let result = try? await proxy.identify(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***on: mapInfo.layer,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***screenPoint: point,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***tolerance: 12
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let result = result.geoElements.first {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let de = result as? DynamicEntity {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("-- de")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else if let obs = result as? DynamicEntityObservation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***print("-- obs")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***popup = Popup(geoElement: obs.dynamicEntity!, definition: mapInfo.layer.popupDefinition!)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***try? await mapInfo.layer.load()
***REMOVED******REMOVED******REMOVED***try? await mapInfo.layer.dataSource.load()
***REMOVED******REMOVED******REMOVED***let pd = PopupDefinition()
***REMOVED******REMOVED******REMOVED***let ds = mapInfo.layer.dataSource as! ArcGISStreamService
***REMOVED******REMOVED******REMOVED***let fields = ds.info!.fields
***REMOVED******REMOVED******REMOVED***let popupFields = fields.map {
***REMOVED******REMOVED******REMOVED******REMOVED***let pf = PopupField()
***REMOVED******REMOVED******REMOVED******REMOVED***pf.fieldName = $0.name
***REMOVED******REMOVED******REMOVED******REMOVED***pf.isVisible = true
***REMOVED******REMOVED******REMOVED******REMOVED***return pf
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***pd.addFields(popupFields)
***REMOVED******REMOVED******REMOVED***let element = FieldsPopupElement(fields: popupFields)
***REMOVED******REMOVED******REMOVED***element.title = "fields"
***REMOVED******REMOVED******REMOVED***pd.addElement(element)
***REMOVED******REMOVED******REMOVED***pd.title = "Vehicle"
***REMOVED******REMOVED******REMOVED***mapInfo.layer.popupDefinition = pd
***REMOVED***
***REMOVED******REMOVED***.floatingPanel(
***REMOVED******REMOVED******REMOVED***selectedDetent: $floatingPanelDetent,
***REMOVED******REMOVED******REMOVED***horizontalAlignment: .leading,
***REMOVED******REMOVED******REMOVED***isPresented: $showPopup
***REMOVED******REMOVED***) { [popup] in
***REMOVED******REMOVED******REMOVED***PopupView(popup: popup!, isPresented: $showPopup)
***REMOVED******REMOVED******REMOVED******REMOVED***.showCloseButton(true)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED***
