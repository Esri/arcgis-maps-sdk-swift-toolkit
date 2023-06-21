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
import FormsPlugin
***REMOVED***

***REMOVED***/ Forms allow users to edit information about GIS features.
***REMOVED***/ - Since: 200.2
public struct Form: View {
***REMOVED******REMOVED***/ Info obtained from the map's JSON which contains the underlying form definition.
***REMOVED***@State private var mapInfo: MapInfo?
***REMOVED***
***REMOVED******REMOVED***/ The attributes of the provided feature.
***REMOVED***private let attributes: [String : Any]?
***REMOVED***
***REMOVED******REMOVED***/ The map containing the underlying form definition.
***REMOVED***private let map: Map
***REMOVED***
***REMOVED******REMOVED***/ Creates a `Form` with the given map and feature.
***REMOVED******REMOVED***/ - Parameter map: The map containing the underlying form definition.
***REMOVED******REMOVED***/ - Parameter feature: The feature to be edited.
***REMOVED***public init(map: Map, feature: ArcGISFeature) {
***REMOVED******REMOVED***self.map = map
***REMOVED******REMOVED***self.attributes = feature.attributes
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED***FormHeader(title: formDefinition?.title)
***REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(formDefinition?.formElements ?? [], id: \.element?.label) { container in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let element = container.element as? FieldFeatureFormElement {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FormElementHeader(element: element)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch element.inputType.input {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case let `input` as TextBoxFeatureFormInput:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SingleLineTextEntry(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***element: element,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***text: attributes?[element.fieldName] as? String,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***input: `input`
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case let `input` as TextAreaFeatureFormInput:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***MultiLineTextEntry(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***text: attributes?[element.fieldName] as? String,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***input: `input`
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***let rawJSON = map.toJSON()
***REMOVED******REMOVED******REMOVED***let decoder = JSONDecoder()
***REMOVED******REMOVED******REMOVED***mapInfo = try? decoder.decode(MapInfo.self, from: rawJSON.data(using: .utf8)!)
***REMOVED***
***REMOVED***
***REMOVED***

extension Form {
***REMOVED******REMOVED***/ A shortcut to `mapInfo`s first operational layer form definition.
***REMOVED***var formDefinition: FeatureFormDefinition? {
***REMOVED******REMOVED***mapInfo?.operationalLayers.first?.featureFormDefinition
***REMOVED***
***REMOVED***
