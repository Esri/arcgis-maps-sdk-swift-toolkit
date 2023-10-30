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

extension DynamicEntityArcadeCalloutExampleView {
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
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view that shows how to display and show a callout for a dynamic entity layer
***REMOVED***/ where the information that you want to display is derived from an arcade expression.
struct DynamicEntityArcadeCalloutExampleView: View {
***REMOVED******REMOVED***/ The map information for this example.
***REMOVED***@State private var mapInfo = MapInfo()
***REMOVED******REMOVED***/ The callout placement.
***REMOVED***@State private var placement: CalloutPlacement?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***MapViewReader { proxy in
***REMOVED******REMOVED******REMOVED***MapView(map: mapInfo.map)
***REMOVED******REMOVED******REMOVED******REMOVED***.callout(placement: $placement) { placement in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let dynamicEntity = placement.geoElement! as! DynamicEntity
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VehicleCallout(dynamicEntity: dynamicEntity)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.onSingleTapGesture { point, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let result = try? await proxy.identify(on: mapInfo.layer, screenPoint: point, tolerance: 12),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let observation = result.geoElements.first as? DynamicEntityObservation,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let entity = observation.dynamicEntity
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***placement = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***placement = .geoElement(entity)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A callout view for showing the details of a dynamic entity vehicle.
struct VehicleCallout: View {
***REMOVED******REMOVED***/ The dynamic entity that represents a vehicle.
***REMOVED***let dynamicEntity: DynamicEntity
***REMOVED***
***REMOVED******REMOVED***/ The name of the vehicle.
***REMOVED***@State private var name: String = ""
***REMOVED***
***REMOVED******REMOVED***/ The location of the vehicle.
***REMOVED***@State private var location: String = ""
***REMOVED***
***REMOVED******REMOVED***/ The heading of the vehicle.
***REMOVED***@State private var heading: Double = .nan
***REMOVED***
***REMOVED******REMOVED***/ The speed of the vehicle.
***REMOVED***@State private var speed: Double = .nan
***REMOVED***
***REMOVED******REMOVED***/ Creates a vehicle callout view.
***REMOVED******REMOVED***/ - Parameter dynamicEntity: The dynamic entity vehicle.
***REMOVED***init(dynamicEntity: DynamicEntity) {
***REMOVED******REMOVED***self.dynamicEntity = dynamicEntity
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .center, spacing: 6) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.evaluateArcadeExpression("$feature.vehiclename", for: dynamicEntity) { evaluation in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***name = evaluation.stringValue
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Text(location)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.evaluateArcadeExpression(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"concatenate(\"(\", Round($feature.point_x,6), \", \", Round($feature.point_y,6), \")\")",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: dynamicEntity
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) { evaluation in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***location = evaluation.stringValue
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if !speed.isNaN {
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxHeight: 44)
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(spacing: 6) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(speed, format: .number.precision(.fractionLength(0)))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("MPH")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if !heading.isNaN {
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxHeight: 44)
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(spacing: 6) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "arrow.up.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.rotationEffect(.degrees(heading))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let measurement = Measurement<UnitAngle>(value: heading, unit: .degrees).formatted()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(measurement)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onReceive(dynamicEntity.changes) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED*** Update heading and speed as they change.
***REMOVED******REMOVED******REMOVED***updateHeadingAndSpeed()
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED*** Show initial heading and speed.
***REMOVED******REMOVED******REMOVED***updateHeadingAndSpeed()
***REMOVED***
***REMOVED******REMOVED***.padding(10)
***REMOVED******REMOVED***.id(ObjectIdentifier(dynamicEntity))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Updates the heading and the speed from the dynamic entity.
***REMOVED***private func updateHeadingAndSpeed() {
***REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED***heading = dynamicEntity.attributes["heading"] as? Double ?? .nan
***REMOVED***
***REMOVED******REMOVED***speed = dynamicEntity.attributes["speed"] as? Double ?? .nan
***REMOVED***
***REMOVED***

extension Result<ArcadeEvaluationResult, Error> {
***REMOVED******REMOVED***/ The evaluation as a string. If the evaluation results in an error, `nil`,
***REMOVED******REMOVED***/ or a type other than a string, then an empty string is returned.
***REMOVED***var stringValue: String {
***REMOVED******REMOVED***((try? get())?.result(as: .string) as? String) ?? ""
***REMOVED***
***REMOVED***
